pipeline{
    agent any
    stages {
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/SandeepNainala/Reddit-clone-DevSecOps.git'
            }
        }
        stage('Terraform init'){
             steps{
                 dir('eks_terraform') {
                      sh 'terraform init'
                   }
             }
        }
        stage('Terraform validate'){
             steps{
                 dir('eks_terraform') {
                      sh 'terraform validate'
                   }
             }
        }
        stage('Terraform plan'){
             steps{
                 dir('eks_terraform') {
                      sh 'terraform plan'
                   }
             }
        }
        stage('Terraform apply/destroy'){
             steps{
                 dir('eks_terraform') {
                      sh 'terraform ${action} --auto-approve'
                   }
             }
        }
    }
}