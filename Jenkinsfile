pipleline {
    agent any

    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }
    
    environment {
        SCANNER_HOME =tool 'sonar-scanner'
    }

    options {
        ansiColor('xterm')
        timeout(time: 1, unit: 'HOURS')
    }

    stages {
        stage ('Clean workspace') {
            steps {
                cleanWs()
            }
        }
        stage ('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/SandeepNainala/Reddit-clone-DevSecOps.git'
            }
        }
        stage ('Install dependencies') {
            steps {
                    sh 'npm install'
                }
            }

        stage ('SonarQube analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    // Ensure the SonarQube server is running and accessible
                    sh ''' ${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectName=Reddit \ 
                        -Dsonar.projectKey=Reddit '''              
                }
            }
        }
        stage ('Quality Gate') {
            steps {
                script {
                    timeout(time: 10, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true credentialsId: 'sonar-token'
                    }
                }
            }
        }
        stage('OWASP Dependency-Check Vulnerabilities') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage ('Trivy Scan') {
            steps {
                sh " trivy fs . $gt; trivyfs.txt"
            }
        }
        stage ('Docker build image and push'){
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh "docker build -t  reddit ."
                        sh "docker tag reddit sandeepnainala9/reddit:latest"
                        sh "docker psuh sandeepnainala9/reddit:latest"
                    }
                }
            }
        }
        stage ('Trivy'){
            steps {
                sh "trivy image sandeepnainala9/reddit:latest &gt; trivy.txt"
            }
        }
        stage ('Deploy to container'){
            steps {
                sh ' docker run -d --name reddit -p 3000:3000 sandeepnainala9/reddit:latest'
            }
        }
    }
}