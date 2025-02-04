This is a basic guide in setting up Jenkins pipeline functionality in AWS leveraging terraform and github.

Prerequsites:

- Docker command line or Docker Desktop installed on a information system.

- Jenkins container running on Docker with required plugins, terraform and AWS CLI.

- AWS security key for the Jenkins service.

- Working GitHub repository that you are certain can be beployed in AWS leveragin terraform. NOTE: This is a 
critical requirmemnt to "reduce" teh amount of troubleshooting you may have to do if something does not work
as expected.

- Jenkins file located in the GitHub repository you have selected to use for the AWS pipeline testing.

