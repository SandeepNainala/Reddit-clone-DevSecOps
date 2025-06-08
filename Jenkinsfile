pipeline {

    agent any

    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        NEW_IMAGE_NAME = "sandeepnainala9/reddit:v1"
        GIT_USER_NAME = "SandeepNainala"
        GIT_REPO_NAME = "Reddit-clone-DevSecOps"
    }

    options {
        ansiColor('xterm')
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/SandeepNainala/Reddit-clone-DevSecOps.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }

        stage("SonarQube Analysis") {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=Reddit \
                        -Dsonar.projectKey=Reddit'''
                }
            }
        }

        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }

        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('TRIVY FS SCAN') {
            steps {
                sh 'trivy fs . > trivyfs.txt'
            }
        }

        stage("Docker Build & Push") {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh "docker build -t reddit ."
                        sh "docker tag reddit ${NEW_IMAGE_NAME}"
                        sh "docker push ${NEW_IMAGE_NAME}"
                    }
                }
            }
        }

        stage("TRIVY Image Scan") {
            steps {
                sh "trivy image ${NEW_IMAGE_NAME} > trivy.txt"
            }
        }

        stage('Deploy to Docker container') {
            steps {
                sh 'docker run -d --name reddit -p 3000:3000 ${NEW_IMAGE_NAME}'
            }
        }

        stage('Update Deployment File') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                        sh "sed -i 's|image: .*|image: ${NEW_IMAGE_NAME}|' deployment.yml"
                        sh 'git config user.email "nainala_sandeep@yahoo.com"'
                        sh 'git config user.name "SandeepNainala" '
                        sh 'git add deployment.yml'
                        sh "git commit -m 'Update deployment image to ${NEW_IMAGE_NAME}' || echo 'No changes to commit'"
                        sh "git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME}.git HEAD:main"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withKubeConfig(
                        credentialsId: 'k8s',
                        caCertificate: '',
                        clusterName: '',
                        contextName: '',
                        namespace: '',
                        restrictKubeConfigAccess: false,
                        serverUrl: ''
                    ) {
                        sh 'kubectl apply -f deployment.yml'
                        sh 'kubectl apply -f service.yml'
                        sh 'kubectl apply -f ingress.yml'
                    }
                }
            }
        }
    }
}
