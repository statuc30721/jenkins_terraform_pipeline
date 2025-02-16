pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-1'
        ACTION = "${params.ACTION}"
    }

    parameters {
            choice (name: 'ACTION',
				            choices: [ 'plan', 'apply', 'destroy'],
				            description: 'Run terraform plan / apply / destroy')
    }


    stages {
        stage('Set AWS Credentials') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'AWS_SECRET_ACCESS_KEY' 
                ]]) {
                    sh '''
                    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
                    aws sts get-caller-identity
                    '''
                }
            }
        }
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/statuc30721/jenkins_terraform_pipeline' 
            }
        }
        stage('Initialize Terraform') {
            steps {
                sh '''
                terraform init
                '''
            }
        }
        stage('Plan Terraform') {
                when { anyOf
                {
                    	environment name: 'ACTION', value: 'plan';
						environment name: 'ACTION', value: 'apply'

                }
            }

            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform plan -out=tfplan
                    '''
                }
            }
        }
        stage('Apply Terraform') {
                when { anyOf
                {
						environment name: 'ACTION', value: 'apply'

                }
            }


            steps {
                input message: "Approve Terraform Apply?", ok: "Deploy"
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }
        stage('Destroy Terraform') {
            when { anyOf
               {
                   environment name: 'ACTION', value: 'destroy'

                }
            }


            steps {

                script {
                    def IS_APPROVED = input(
                        message: "Destroy Deployed Project ?!",
                        ok: "Yes",
                        parameters: [
                                string(name: 'IS_APPROVED', defaultValue: 'No', description: 'Think again!!!')
                            ]
                        )
                        if (IS_APPROVED != 'Yes') {
                            currentBuild.result = "ABORTED"
                            error "User destruction cancelled"
                        }


                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                        terraform destroy -auto-approve
                        '''
                    }
                }
            }
        }


    }
}