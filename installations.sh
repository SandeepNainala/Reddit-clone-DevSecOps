#!/bin/bash
# This script installs the necessary dependencies for the project.

USERID=$(id -u)
DATE=$(date +%Y-%m-%d)
LOGFILE="/var/log/installations_$DATE.log"

R="\e[31m"
G="\e[32m"
N="\e[0m"


if [ "$USERID" -ne 0 ]; then
    echo -e  "${R}This script must be run as root. Please use sudo."
    exit 1
fi


echo -e "${G}>>> Updating package index${N}"
apt update -y

# Install Java (openjdk 17)
echo -e "${G}>>> Installing Temurin 17 JDK${N}"
if ! java -version 2>&1 | grep "17" >/dev/null; then
  mkdir -p /etc/apt/keyrings
  wget -qO /etc/apt/keyrings/adoptium.asc https://packages.adoptium.net/artifactory/api/gpg/key/public
  echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
  apt update -y
  apt install openjdk-17-jdk -y
  java -version
else
  echo -e "${G}openjdk 17 already installed.${N}"
fi
java -version

# Install Jenkins
echo -e "${G}>>> Installing Jenkins${N}"
if ! systemctl is-active --quiet jenkins; then
  curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
  apt-get update -y
  apt-get install -y jenkins
  systemctl enable jenkins
  systemctl start jenkins
  jenkins_status=$(systemctl is-active jenkins)
    if [ "$jenkins_status" = "active" ]; then
        echo -e "${G}Jenkins installed and started successfully.${N}"
    else
        echo -e "${R}Failed to start Jenkins. Please check the logs.${N}"
    fi
else
  echo -e "${G}Jenkins is already installed and running.${N}"
fi
systemctl status jenkins --no-pager || echo -e "${R}Jenkins may not be running.${N}"
cat /var/lib/jenkins/secrets/initialAdminPassword || echo -e "${R}Initial Jenkins password not yet available.${N}"

# Install Docker
echo -e "${G}>>> Installing Docker${N}"
if ! command -v docker &>/dev/null; then
  apt install -y docker.io
  usermod -aG docker ubuntu
  chmod 777 /var/run/docker.sock
else
  echo -e "${G}Docker is already installed.${N}"
fi
docker version

# Install Trivy
echo -e "${G}>>> Installing Trivy${N}"
if ! command -v trivy &>/dev/null; then
  apt-get install -y wget apt-transport-https gnupg lsb-release
  wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/trivy.list
  apt-get update
  apt-get install -y trivy
else
  echo -e "${G}Trivy is already installed.${N}"
fi

# Install Terraform
echo -e "${G}>>> Installing Terraform${N}"
if ! command -v terraform &>/dev/null; then
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
  apt update && apt install -y terraform
else
  echo -e "${G}Terraform is already installed.${N}"
fi

# Install kubectl
echo -e "${G}>>> Installing kubectl${N}"
if ! command -v kubectl &>/dev/null; then
  apt install -y curl
  curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl
else
  echo -e "${G}kubectl is already installed.${N}"
fi
kubectl version --client

# Install AWS CLI
echo -e "${G}>>> Installing AWS CLI${N}"
if ! command -v aws &>/dev/null; then
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  apt-get install -y unzip
  unzip -q awscliv2.zip
  ./aws/install
  rm -rf aws awscliv2.zip
else
  echo -e "${G}AWS CLI is already installed.${N}"
fi
aws --version

echo -e "${G}>>> All tools installed successfully.${N}"