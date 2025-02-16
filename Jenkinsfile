pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'What action should Terraform take?')
    }


    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCESS_KEY_ID = Credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = Credentials('aws-secret-access-key') 
    }




    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/statuc30721/jenkins_terraform_pipeline' 
            }
        }
        stage('Initialize Terraform') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Plan Terraform') {
            steps {
                sh 'terraform plan -out=tfplan'
                sh ' terraform show -no-color tfplan > tfplan.txt'
            }
        }
        stage('Apply / Destroy Terraform') {
            steps {

                script {
                    if (parameters.action == 'apply'){
                        if (!parameters.autoApprove) {
                            def plan = readfile 'tfplan.txt'
                            input message: "Approve Terraform Apply?", 
                            parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                        }

                        sh 'terraform ${action} -input=false tfplan'
                    } else if (parameters.action == 'destroy'){
                        sh 'terraform ${action} --auto-aprove'
                    } else {
                        error "Invalid action selected. Please choose either 'Apply' or 'Destroy'."
                    }
                }

            }
        }
    }
}