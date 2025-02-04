This is a basic guide in setting up Jenkins pipeline functionality in AWS leveraging terraform and github.

Prerequsites:

- Docker command line or Docker Desktop installed on a information system.

- Jenkins container running on Docker with required plugins, terraform and AWS CLI.

- AWS security key for the Jenkins service.

- Working GitHub repository that you are certain can be beployed in AWS leveragin terraform. NOTE: This is a 
critical requirmemnt to "reduce" teh amount of troubleshooting you may have to do if something does not work
as expected.

- Jenkins file located in the GitHub repository you have selected to use for the AWS pipeline testing.


Start Docker desktop or docker command line. In this example we will use the Docker Desktop application.



(1) Start the Jenkins container by pressing the start button in Docker Desktop.
- Connect to the jenkins container as root.

$ docker exec -it --user root <container-name> bash

- Create a directory under home 
$ mkdir -p /home/jenkins/bin

- Install AWS CLI and patch the Jenkins container.
$ apt update && apt install -y awscli

- Verify AWS CLI is installed.
aws --version

- Install wget
apt-get install wget

- Install Terraform
apt-get update && apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
tee /etc/apt/sources.list.d/hashicorp.list

apt update

apt-get install terraform

- Verify terraform is installed.

terraform -version


(2) Commit a image of the modified jenkins container.
- Stop the jenkins container.

= Run the following command to commit a new docker container image of the jenkins container.

docker commit <containername> jenkins-terraform

Note: You should see a new container image in Docker Desktop with the name you provided. It will be much larger that the original Jenkins container due to the software packages that were installed.

(3) Start the new container using the following commands:

docker run --name=jenkins-terraform-v1 \
-p 8080:8080 \
-p 50000:50000 \
-v jenkins_home:/var/jenkins_home \
jenkins-terraform

Note: In this example I named the container "jenkins-terraform-v1". You can name it according to what you use in your DevOps environment.

(4) Connect to the jenkins container via a web browser application.

Upon successfuly authentication using the username and password from your previous Jenkins container you should see the Jenkins dashboard.

(5) Provide Jenkins with the AWS credentials you should already have created in the AWS IAM dashboard.

Note: If you "do not" have a service account for the Jenkins container, then reference below:

- Logon to AWS web console and go to the IAM dashboard.
- Select Users.
- Select "Create User"
- Input a User Name. ** Do NOT select the provide user access to AWS Management Console option.

- Select Next.
- Select Attach Policies directly.
- Search and select policies that Jenkins will need to perform pipeline functions in AWS:
-- AdministratorAccess
-- AmazonAPIGatewayAdministrator
-- SystemAdministrator

- Select next.
- At the "Review and create step" you need to verify you have set the required permissions and also you can add Tags.

- Select Create User. If everything worked you should see the following message.


- Select create access key
- Copy and securely store the Access Key and Secret Access Key.


- Go to the Jenkins dashboard and select "Manage Jenkins"
- Select Credentioals > System > Global credentials (unrestricted).

- Select New credentials.

- In "Kind" click on the down arrow and select "AWS Credentials".

- Do not change the default "Scope" setting.

- In ID add the name AWS_SECRET_ACCESS_KEY.

- In Description add the name AWS_SECRET_ACCESS_KEY.

- In Access Key ID input the access key id from your AWS IAM for the jenkins service.

- In Secret Access Key input the AWS secret key. Once finished you should have a new credentials record in Jenkins.

(6) Create your Jenkins pipeline.
- Select Dashboard > All > New Item
- Enter an item name, for example "test_pipeline".
- Select Pipeline, then okay.
- Select the pipeline name you entered and then select Configuration.
- Select Advanced Project Options.
- Under "Definituion" select Pipeline script from SCM.
- Under SCM click the dropdown and select "Git".

- Under Repositories input the URL to the GitHub repository you intend to use with Jenkins.

- Select branch and change to the name in the GitHub repository. In this example that is "main"

- Select "Save".

- Go back to the Jenkins Dashboard.

- Add a Jenkinsfile to the repo you selected to manage using Jenkins.

(7) Return to the Jenkins dashboard and select the pipeline you want to run.
- Select "Build Now" on teh left side.