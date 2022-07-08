sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform

#-- to remove repo from rhel 8
cd /etc/yum.repos.d
ls
rm hashicorp.repo

#############################################

# IaC(Infrastructure as code) tools: Terraform, AWS CloudFormation, Azure Resource Manager(ARM), Google Cloud Deplyment Manager, Pulumi.

## Terraform Goals: 

Unify the view of resources using infrastructure as code
Support the modern data center (IaaS, PaaS, SaaS)
Expose a way for individuals and teams to safely and predictably change infrastructure
Provide a workflow that is technology agnostic
Manage anything with an API


## Terraform Benefits:
Provides a high-level abstraction of infrastructure (IaC)
Allows for composition and combination
Supports parallel management of resources (graph, fast)
Separates planning from execution (dry-run)

Basic commands:

terraform init
terraform validate
terraform plan
terraform apply
terraform destory

terraform -version
terraform -help

# when you ran terraform init... it will download some plugins and it creates .terrafoem.lock.hcl lock file to record the provider.
./terraform/providers/registry.terraform.io/hashicorp/random/3.1.0/windows_amd64 --- provider gets installed here

# terraform plan -out myplan ---> to save the plan and we can apply myplan also


# vi terraform.tf

terraform {
required_version = ">= 1.0.0"
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 3.0"
}
random = {
source = "hashicorp/random"
version = "3.1.0"
}
}
}

# vi main.tf
provider "aws" {
region = "us-east-1"
}

# terraform init
# terraform version --> which providers are installed
# terraform providers  -- tell us which providers are required for the configuration


# provider block
# Resource block
# Variable block
# Data Block ---> to get corrent setup/data info
# Configuration Block -- for requred specific version

terraform {
required_version = ">= 1.0.0"
}

# Module Block ---> for reusable 
# Output Block

output "web_server_ip" {
description = "Public IP Address of Web Server on EC2"
value = aws_instance.web_server.public_ip
sensitive = true
}


## Comments the terraform code
Single line commnet ----> # or //
Multiline comment ---> /* starts and ends with */

#### Terraform version and provider version
terraform {
required_version = ">= 1.0.0"
}

required_version = "= 1.0.0"  ---> searches for correct vestion

required_version = "~> 1.0.0"   ----> executes if change in minior versions. like 1.0.10 or 1.0.11


terraform {
 required_version = ">= 0.15.0"
 required_providers {
 aws = {
 source = "hashicorp/aws"
 version = "~> 3.0"
 }
 }
 }

### Multiple Terraform providers

terraform {
required_version = ">= 1.0.0"
required_providers {
aws = {
source = "hashicorp/aws"
}
http = {
source = "hashicorp/http"
version = "2.1.0"
}
random = {
source = "hashicorp/random"
version = "3.1.0"
}
local = {
source = "hashicorp/local"
version = "2.1.0"
}
}
}

# terraform init

or 
# terraform init -upgrade

# terraform version --> version and provider verstion. like below

Terraform v1.0.8
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v3.62.0
+ provider registry.terraform.io/hashicorp/http v2.1.0
+ provider registry.terraform.io/hashicorp/local v2.1.0
+ provider registry.terraform.io/hashicorp/random v3.1.0


terraform {
required_version = ">= 1.0.0"
required_providers {
aws = {
source = "hashicorp/aws"
}
http = {
source = "hashicorp/http"
version = "2.1.0"
}
random = {
source = "hashicorp/random"
version = "3.1.0"
}
local = {
source = "hashicorp/local"
version = "2.1.0"
}
tls = {
source = "hashicorp/tls"
version = "3.1.0"
}
}
}


resource "tls_private_key" "generated" {
algorithm = "RSA"
}
resource "local_file" "private_key_pem" {
content = tls_private_key.generated.private_key_pem
filename = "MyAWSKey.pem"
}

# terraform apply

######Fetch, Version and Upgrade Terraform Providers
#terraform version
# terraform init -upgrade ----> for upgrade and downgrade also with same command


######### Terraform Provisioners


#terraform state show <aws_interface.ubuntu_server



# terraform fmt ---> to correct the alignment in the file
####### terraform Taint and replace

# terraform -h
# terraform taint <aws_instance.web_server>

# terraform plan --> can see web is tainted, so must be replaced

if any error wile executing the terraform script the terraform will taint the automatically the failed resource or the paricular thing.

#terraform state list ---> you can view the list of resources

# terraform state show <aws_instance.web_server>  ----> we can see that the aws_instance.web_server is tainted

### Terraform also supports untaint command
# terraform untaint aws_instance.web_server
# terraform state show <aws_instance.web_server> --- untaint command removed the taint in the wed_server

### taint command is depricated now and we can use new option replace

#terraform apply -replace="aws_instance.web_server"


############## loops in terraform  ############### https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9
variable "user_names" {
  description = "Create IAM users with these names"
  type        = list(string)
  default     = ["neo", "trinity", "morpheus"]
}


resource "aws_iam_user" "example" {
  count = length(var.user_names)       ### count = 3
  name  = var.user_names[count.index]
}

output "all_arns" {
  value       = aws_iam_user.example[*].arn
  description = "The ARNs for all users"
}
 ## ---> count has problrm with indexing

better to go with for_each loop
#documentation can be found in Modules -> Meta-Arguments

resource "aws_iam_user" "example" {
  for_each = toset(var.user_names)
  name     = each.value
}

output "all_users" {
  value = aws_iam_user.example
}

output "all_arns" {
  value = values(aws_iam_user.example)[*].arn
}

### Terraform Import ----> importing existing(manually or with script create) resources into terraform

provider "aws" {
region = "us-west-2"
}

resource "aws_instance" "aws_linux" {}

# terraform import aws_instance.aws_linux <i-0bfff5070c5fb87b6>  ---> instance ID that wanted to import

# terraform plan ----> it(any other command) will give error while running and says that imported image missing instanace_type, ami, launch_template... these are must be specied

# terraform state list   ---> you can see the imported new instance details also
# terraform stat show aws_instance.aws_linux   ---> To view more information, you can copy the required entries and place it in configuration

--> below details are place in the above code
resource "aws_instance" "aws_linux" {
ami = "ami-013a129d325529d4d"
instance_type = "t2.micro"
}

# terraform plan ---> now we wont get any errors
# terraform apply  ---> Once completing this command... terraform will get the full control of this item.
----> removel of above code will destory the existing instance in the AWS.

############# Terraform workspace
--- to create the different work spaces, and state file will store in the default work space and this can be changed

# terraform workspace   ---> new, list, show, select and delete terraform work spaces
# terraform workspace show ---> shows default if no other workspaces

#terraform workspace new development
# terraform workspace show ----> now we are in development work space
# terraform workspace list
#terraform show ----> no state file

vi main.tf
# Configure the AWS Provider
provider "aws" {
region = "us-east-1"
default_tags {
tags = {
Owner = "Acme"
Provisoned = "Terraform"
}
}
}

#terraform plan
# terraform apply ---> above listed will be added in the us-west-2 region... since there is no infrastructure in it
--> change between the workspaces 
# terraform workspace select default
# terraform workspace select development

vi main.tf
# Configure the AWS Provider
provider "aws" {
region = "us-east-1"
default_tags {
tags = {
  Environment = terraform.workspace
Owner = "Acme"
Provisoned = "Terraform"
}
}
}

#terraform plan

#################### terraform state  ### terrafomr.tfstate file
terraform state file will be in JOSN formate

# terraform state -help  ----> list, mv, pull, push, replace-provider, rm, show
--> Do not modify the state file any time.

########### debugging terraform #
In linux, can be enabled by setting the TF_LOG environment variable
export TF_LOG=TRACE
In Windows, $env:TF_LOG="TRACE"

and run below
# terraform apply or terraform init

Terraform has detailed logs which can be enabled by setting the TF_LOG environment variable to any
value. This will cause detailed logs to appear on stderr.
You can set TF_LOG to one of the log levels TRACE, DEBUG, INFO, WARN or ERROR to change the
verbosity of the logs, with TRACE being the most verbose.

### Enable Logging Path
## To persist logged output you can set TF_LOG_PATH in order to force the log to always be appended to
a specific file when logging is enabled. Note that even when TF_LOG_PATH is set, TF_LOG must be set
in order for any logging to be enabled.
# export TF_LOG_PATH="terraform_log.txt"
PowerShell
# $env:TF_LOG_PATH="terraform_log.txt"
Run terraform init to see the initialization debugging information.
# terraform init -upgrade

### Disable Logging
Terraform logging can be disabled by clearing the appropriate environment variable.
Linux
# export TF_LOG=""
PowerShell
# $env:TF_LOG=""

###################
# You are managing multiple resources using Terraform running in AWS. You want to destroy all the resources except for a single web server. How can you accomplish this?
--> run a terraform state rm to remove it from state and then destory the remaining resources by running terrafomr destory


####################
### Terrafome Modules

Modules are used to package and reuse resource configurations with in terraform 
Modules are used to orgnaize the code
with it we can run sub dirctories code also

/workspace/terraform/# mkdir server
cd  server
touch server.tf

variable "ami" {}
variable "size" {
default = "t2.micro"
}
variable "subnet_id" {}
variable "security_groups" {
type = list(any)
}
resource "aws_instance" "web" {
ami = var.ami
instance_type = var.size
subnet_id = var.subnet_id
vpc_security_group_ids = var.security_groups
tags = {
"Name" = "Server from Module"
"Environment" = "Training"
}
}
output "public_ip" {
value = aws_instance.web.public_ip
}
output "public_dns" {
value = aws_instance.web.public_dns
}


/workspace/terraform/main.tf
ex: moudule "any_name" {  }

module "server" {
source = "./server"
ami = data.aws_ami.ubuntu.id
subnet_id = aws_subnet.public_subnets["public_subnet_3"].id
security_groups = [aws_security_group.vpc-ping.id, aws_security_group.ingress-ssh.id, ]
}

# terraform init
# terraform providers
# terraform apply
# terraform state list ---> we can see a module resource in it
# terraform state show module.server.aws_instanace.web

If any new module added in the existing then we need to do terraform init 

### terraform module sources
Module Source paths are local paths, Terraform Registory, GitHub, Bitbucket, Generic Git, Mercurial repositories, HTTP URLs, S3 buckets, GCS bucket
#terraform fmt -recursive

https://registry.terraform.io/browse/modules?provider=aws
we can find the modules in the terraform registory to use. ex: autoscalling group 


#### terraform modules Inputs and Outputs

You've included two different modules from the official Terraform registry in a new configuration file. When you run a terraform init, where does Terraform OSS download and store the modules locally?
--> in the .terraform/modules folder in the working directory

A child module created a new subnet for some new workloads. What Terraform block type would allow you to pass the subnet ID back to the parent module?
--> output block 

You have a number of different variables in a parent module that calls multiple child modules. Can the child modules refer to any of the variables declared in the parent module?
--> No, it can only refer to the variables passed to the module.

When you are referencing a module, you must specify the version of the module in the calling module block.
--> False.


###### terraform workflows
# terraform -version
# terraform -help --> init, validate, plan, apply, destory, console, fmt, force-unlock, get, graph, import, login, logout, output, providers, referesh, show, state, taint, test, untaint, version, workspace

Write --> plan ---> apply


### terraform init  --> initilize a working directory
init need to run for new configuration setup like first time running the code
and if nay chnage in the backend, if any other providers added in the configuration

#terraform init ---> it creates lock file also(.terraform.lock.hcl)
it will downloads the required provides into .terraform\providers\registory.terraform.io\hashicorp

## vi terraform.tf
terraform {
required_version = ">= 1.0.0"
required_providers {
aws = {
source = "hashicorp/aws"
}
http = {
source = "hashicorp/http"
version = "2.1.0"
}
random = {
source = "hashicorp/random"
version = "3.1.0"
}
local = {
source = "hashicorp/local"
version = "2.1.0"
}
tls = {
source = "hashicorp/tls"
version = "3.1.0"
}
azurerm = {
source = "hashicorp/azurerm"
version = "2.84.0"
}
}
}
# terraform providers
# terraform init
# terraform providers

## vi main.tf

resource "random_pet" "server" {
length = 2
}
#### new module added
module "s3-bucket_example_complete" {
source = "terraform-aws-modules/s3-bucket/aws//examples/complete"
version = "2.10.0"
}

# terraform providers --> gives error that "Module not installed"

# terraform init ---> it will downloades the required modules and place in the .terraform directory.

# terraform providers --> will shows the providers and modules

--> if nay changes in the providers 
# terraform init -upgrade

# vi terraform.tf
old code----
terraform {
backend "local" {
path = "mystate/terraform.tfstate"
}
}

#terraform init ----> terraform will created the state file in the required location and it will asks for the existing state file also into other loacation if you say yes

# terraform init -migrate-state --> current directory to specified dir it will copy

#### terraform validate
The terraform validate command validates the configuration files in a directory, referring only to
 the Terraform configuration files. Validate runs checks that verify whether a configuration is syntactically valid and internally consistent.
it also validate the proper arguments in the code

it wont check with the our backend provider

# terrafomr validate -json --> 

### terrafomr plan
The terraform plan command performs a dry-run of executing your terraform configuration and
checks whether the proposed changes match what you expect before you apply the changes or share
your changes with your team for broader review.
• Task 1: Generate and Review a plan
• Task 2: Save a Terraform plan
• Task 3: No Change Plans
• Task 4: Refresh Only plans

terraform plan command will compare with the existing state file

+ resource will be created
- resource will be destoryed
~ resource will be updated in-place
-/+ resource will be destoryed and re-created

# terraform plan -help ---> -destory, -refresh-only, -refresh=false, -repalce=resource, -target=resource, -var 'foo=bar', -var-file=filename, -compact-wornings, -detailed-exitcode, -input=true, -lock=false, -lock-timeout=0s, -no-color, -out=path, -parallelism=n, -state=statefile

# terrafomr plan -out=myplan
# terraform show myplan

# terraform plan -refresh-only  --> we can check the modification in the resource manually.. it wont save it and can show the changes. if you were expecting these changes then you can apply this plan to record the updated values in the terraform state without changeing any remote objects.
--> drefect ditection

#### terraform apply

--> import infrastructure task that a terraform apply cannot perform.
 #terraform applt -aoto-approve

# terraform apply myplan

## terrafrom destory or terraform apply -destory


###### Implement and mainintain the state file

Terraform state default local backend.
state file will in json formate ( terraform.tfstate )
it not required any backend code for local state file
state file backup also saved in the  same location as terraform.tfstate.backup file

# terraform state list

#vi terraform.tf

terraform {
backend "local" {            ##### backend configuration
path = "terraform.tfstate"
}
required_version = ">= 1.0.0"
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 3.0"
}
http = {
source = "hashicorp/http"
version = "2.1.0"
}
random = {
source = "hashicorp/random"
version = "3.1.0"
}
local = {
source = "hashicorp/local"
version = "2.1.0"
}
tls = {
source = "hashicorp/tls"
version = "3.1.0"
}
}

# terraform init

Append the following code to main.tf

# Terraform Resource Block - To Build EC2 instance in Public Subnet
resource "aws_instance" "web_server_2" {
ami = data.aws_ami.ubuntu.id
instance_type = "t2.micro"
subnet_id = aws_subnet.public_subnets["public_subnet_2"].id
tags = {
Name = "Web EC2 Server"
}
}

# terrafrom fmt
# terraform plan
# terraform apply

# terraform state list
# terraform state show aws_instance.web_server_2

##### terraform state Locking
the state backend will “lock” to prevent concurrent modifications which could cause corruption state file.

# terraform state list
# vi main.tf
### update some code
# terraform apply


#terraform apply -locak-timeout=60s

# Task 3: Explore State Backends that Support Locking
Not all Terraform backends support locking - Terraform’s documentation identifies which backends
support this functionality. Some common Terraform backends that support locking include:
• Remote Backend (Terraform Enterprise, Terraform Cloud)
• AWS S3 Backend (with DynamoDB)
• Google Cloud Storage Backend
• Azure Storage Backend
Obviously locking is an important feature of a Terraform backend in which there are multiple people
collaborating on a single state file.


### Terraform State Backend Authentication

### Authentication: S3 Standard Backend
--> Create the bucket in AWS
-->  Update Terraform Configuration to use s3 backend

terraform {
backend "s3" {
bucket = "myterraformstate"
key = "path/to/my/key"
region = "us-east-1"
}
}

Example:
terraform {
backend "s3" {
bucket = "my-terraform-state-ghm"
key = "prod/aws_infra"
region = "us-east-1"
}
}

Note: A Terraform configuration can only specify a single backend. If a backend is already configured be sure to replace it. Copy just the backend block above and not the full terraform block
You can validate the syntax is correct by issuing a terraform validate

--> Provide Terraform AWS credentials to connect to S3 Bucket
export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"

--> - Verify Authentication to S3 Backend
# terraform init
error: we actually change the backend in the code... so need to run below command
# terraform init -reconfigure
--> Write Terraform State to S3 Backend
# terraform apply


## Authentication: Terraform Remote Enhanced Backend
--> create terraform cloud free account
--> Create an Organization
---> create API token

# terraform login
  Enter a value: yes
  Enter Token value: 

## Terraform State Backend Storage
## Standard Backend: S3
--> Create S3 Bucket and validate Terraform Configuration
-- Validate State on S3 Backend
terraform {
backend "s3" {
bucket = "myterraformstate"
key = "path/to/my/key"
region = "us-east-1"
}
}

--> Enable Versioning on S3 Bucket
Amazon S3 --> <bucket_name> -->Properties -->Bucket Versioning --> Edit --> Enable --> save changes

resource "aws_instance" "web_server_2" {
ami = data.aws_ami.ubuntu.id
instance_type = "t2.small"
subnet_id = aws_subnet.public_subnets["public_subnet_2"].id
tags = {
Name = "Web EC2 Server 2"
}
}

# terraform apply
# terraform state list

---> Enable Encryption on S3 Bucket
--> Edit default encryption --> Enable , Amazon S3 key (SSE-KMS)

--> - Enable Locking for S3 Backend
The s3 backend stores Terraform state as a given key in a given bucket on Amazon S3 to allow everyone
working with a given collection of infrastructure the ability to access the same state data. In order to
prevent concurrent modifications which could cause corruption, we need to implement locking on the
backend. The s3 backend supports state locking and consistency checking via Dynamo DB.
State locking for the s3 backend can be enabled by setting the dynamodb_table field to an existing
DynamoDB table name. A single DynamoDB table can be used to lock multiple remote state files.

--> Create a DynamoDB table
-- create table --> tablname: <--->, Partition key : LockID , string
Settings: Default Settings

terraform {
backend "s3" {
# Replace this with your bucket name!
bucket = "myterraformstate"
key = "path/to/my/key"
region = "us-east-1"
# Replace this with your DynamoDB table name!
dynamodb_table = "terraform-locks"
encrypt = true
}
}

# terraform init -reconfigure

# vi main.tf  ## change below code
resource "aws_instance" "web_server_2" {
ami = data.aws_ami.ubuntu.id
instance_type = "t2.micro"
subnet_id = aws_subnet.public_subnets["public_subnet_2"].id
tags = {
Name = "Web EC2 Server 2"
}
}

# terraform apply
---> you view the lock info in the DynamoDB table

Note: Terraform supports only one backend at a time with current directory.


#### Terraform Remote State - Enhanced Backend

Enhanced backends can both store state and perform operations. There are only two enhanced
backends: local and remote. The local backend is the default backend used by Terraform which
we worked with in previous labs. The remote backend stores Terraform state and may be used to run
operations in Terraform Cloud. When using full remote operations, operations like terraform plan or
terraform apply can be executed in Terraform Cloud’s run environment, with log output streaming to
the local terminal. Remote plans and applies use variable values from the associated Terraform Cloud
workspace.
• Task 1: Log in to Terraform Cloud
• Task 2: Update Terraform configuration to use Remote Enchanced Backend
• Task 3: Re-initialize Terraform and Validate Remote Backend
• Task 4: Provide Secure Credentials for Remote Runs
• Task 5: View the state, log and lock files in Terraform Cloud
• Task 6: Remove existing resources with terraform destroy
Let’s take a closer look at the remote enhanced backend.

# vi terraform.tf
terraform {
backend "remote" {
hostname = "app.terraform.io"
organization = "YOUR-ORGANIZATION"
workspaces {
name = "my-aws-app"
}
}
}

Example:
terraform {
backend "remote" {
hostname = "app.terraform.io"
organization = "Enterprise-Cloud"
workspaces {
name = "my-aws-app"
}
}
}

# terraform init -reconfigure
# terraform apply


-- Create the credential in the terraform cloud
# terraform login


## : Terraform State Migration
As your maturity and use of Terraform develops there may come a time when you need change the
backend type you are using. Perhaps you are onboarding new employees and now need to centralize
state. You might be part of a merger/acquistion where you need to onboard another organization’s
Terraform code to your standard configuration. You may simply like to move from a standard backend
to an enhanced backend to leverage some of those backend features. Luckily Terraform makes it
relatively easy to change your state backend configuration and migrate the state between backends
along with all of the data that the state file contains.
• Task 1: Use Terraform’s default local backend
• Task 2: Migrate State to s3 backend
• Task 3: Migrate State to remote backend
• Task 4: Migrate back to local backend

#vi terraform.tf
terraform {
required_version = ">= 1.0.0"
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 3.0"
}
http = {
source = "hashicorp/http"
version = "2.1.0"
}
random = {
source = "hashicorp/random"
version = "3.1.0"
}
local = {
source = "hashicorp/local"
version = "2.1.0"
}
tls = {
source = "hashicorp/tls"
version = "3.1.0"
}
}
}

Validate your configuration and re-intialize to terraform’s default local backend.
terraform validate
terraform init -migrate-state
Build the infrastructure and state using a terraform apply

terraform apply
terraform state list

## Migrate State to s3 backend
vi terraform.tf
#Note: Don’t forget to update the configuration block below to specify your bucket name, key and
DynamoDB table name that were created in earlier labs.

terraform {
backend "s3" {
bucket = "my-terraform-state-ghm"
key = "prod/aws_infra"
region = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt = true
}
}

Validate your configuration and re-intialize to terraform’s s3 backend.
terraform validate
terraform init -migrate-state
terraform state list

## Migrate State to remote backend

terraform.tf
Note: Don’t forget to update the configuration block below to specify your Terraform Cloud
organization and workspace name that were created in earlier labs.
Example:
terraform {
backend "remote" {
hostname = "app.terraform.io"
organization = "Enterprise-Cloud"
workspaces {
name = "my-aws-app"
}
}
}

Validate your configuration and re-intialize to terraform’s remote backend.
terraform validate
terraform init -migrate-state
terraform state list

##  Migrate back to local backend
Now that we have migrated our state to several dierent backend types, let’s show how to restore the
Terraform state back to it’s default local backend.
Update the terraform configuration block within the terraform.tf and remove the backend. This
will indicate to Terraform to use it’s deafult local backend and store the contents of state inside a
terraform.tfstate file locally inside the working directory.
terraform {
required_version = ">= 1.0.0"
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 3.0"
}
http = {
source = "hashicorp/http"
version = "2.1.0"
}
random = {
source = "hashicorp/random"
version = "3.1.0"
}
local = {
source = "hashicorp/local"
version = "2.1.0"
}
tls = {
source = "hashicorp/tls"
version = "3.1.0"
}
}
}
Validate your configuration and re-intialize to terraform’s local backend.
terraform validate
terraform init -migrate-state
terraform state list

# 7e #### Terraform State Refresh
The terraform refresh command reads the current settings from all managed remote objects
found in Terraform state and updates the Terraform state to match.
Refreshing state is the first step of the terraform plan process: read the current state of any already-
existing remote objects to make sure that the Terraform state is up-to-date. If you wish to only perform
the first part of the terraform plan process you can execute the plan with a -refresh-only .


# 7f ## Terraform Backend Configuration
As we have seen the Terraform backend is configured for a given working directory within a terraform
configuration file. A configuration can only provide one backend block per working directory. You do
not need to specify every required argument in the backend configuration. Omitting certain arguments
may be desirable if some arguments are provided automatically by an automation script running
Terraform. When some or all of the arguments are omitted, we call this a partial configuration.

Task 1: Terraform backend block
Task 2: Partial backend configuration via a file
Task 3: Partial backend configuration via command line
Task 4: Declare backend configuration via interactive prompt
Task 5: Specifying multiple partial backend configurations
Task 6: Backend configuration from multiple locations
Task 7: Change state backend configuration back to default



# 7g ## Sensitive Data in Terraform State




#### Read, Generate, and Modify Configuration
# 8a ## Local variables
A local value assigns a name to an expression, so you can use it multiple times within a configuration
without repeating it. The expressions in local values are not limited to literal constants; they can also
reference other values in the configuration in order to transform or combine them, including variables,
resource attributes, or other local values.
You can use local values to simplify your Terraform configuration and avoid repetition. Local values
(locals) can also help you write a more readable configuration by using meaningful names rather than
hard-coding values. If overused they can also make a configuration hard to read by future maintainers
by hiding the actual values used.
Use local values only in moderation, in situations where a single value or result is used in many places
and that value is likely to be changed in future. The ability to easily change the value in a central place
is the key advantage of local values.

Add local values to your main.tf module directory:
locals {
service_name = "Automation"
app_team = "Cloud Team"
createdby = "terraform"
}

Update the aws_instance block inside your main.tf to add new tags to the web_server instance
using interpolation.
...
tags = {
"Service" = local.service_name
"AppTeam" = local.app_team
"CreatedBy" = local.createdby
}
...
Afer making these changes, rerun terraform plan. You should see that there will be some tagging
updates to your server instances. Execute a terraform apply to make these changes

# Using locals with variable expressions
Expressions in local values are not limited to literal constants; they can also reference other values in
the module in order to transform or combine them, including variables, resource attributes, or other
local values.
Add another local values block to your main.tf module configuration that references the local values
set in the previous portion of the lab.
locals {
# Common tags to be assigned to all resources
common_tags = {
Name = local.server_name
Owner = local.team
App = local.application
Service = local.service_name
AppTeam = local.app_team
CreatedBy = local.createdby
}
}
Update the aws_instance tags block inside your main.tf to reference the local.common_tags
value.
resource "aws_instance" "web_server" {
ami = data.aws_ami.ubuntu.id
instance_type = "t2.micro"
subnet_id = aws_subnet.public_subnets["public_subnet_1"].id
...
tags = local.common_tags
}
Afer making these changes, rerun terraform plan. You should see that there are no changes to
apply, which is correct, since the values contain the same values we had previously hard-coded, but
now we are grabbing those values through the use of locals variables.

un, including this one but you can ignore that. Scroll up and note that there are no additional
changes to the configuration.
...
No changes. Infrastructure is up-to-date.
This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.

#8a ## Variables
We don’t want to hardcode all of our values in the main.tf file. We can create a variable file for easier
use. In the variables block lab, we created a few new variables, learned how to manually set their
values, and even how to set the defaults. In this lab, we’ll learn the other ways that we can set the
values for our variables that are used across our Terraform configuration.
• Task 1: Set the value of a variable using environment variables
• Task 2: Declare the desired values using a tfvars file
• Task 3: Override the variable on the CLI

# Below is the order of variable precedence - command line has most priority
- Variable defaults
- Environment Variables
- terraform.tfvars file
- terraform.tfvars.json
- *.auto.tfvars or *.auto.tfvars.json
- Command line: -var and -var-file

Task 1: Set the value of a variable using environment variables
Oen, the default values won’t work and you will want to set a dierent value for certain variables.
In Terraform OSS, there are 3 ways that we can set the value of a variable. The first way is setting an
environment variable before running terraform plan or terraform apply command.
To set a value using an environment variable, we will use the TF_VAR_ prefix, which is followed by the
name of the variable. For example, to set the value of a variable named “variables_sub_cidr”, we would
need to set an environment variable called TF_VAR_variables_sub_cidr to the desired value.
On the CLI, use the following command to set an environment variable to set the value of our subnet
CIDR block:
$ export TF_VAR_variables_sub_cidr="10.0.203.0/24"

Run a terraform plan to see the results. You’ll find that Terraform wants to replace the subnet since
we updated the CIDR block of the subnet using an environment variable.

Let’s go ahead and apply our new configuration, which will replace the subnet with one using the
CIDR block of “10.0.203.0/24”. Run a terraform apply. Don’t forget to accept the changes by typing
yes.

#  Declare the desired values using a tfvars file
Another way we can set the value of a variable is within a tfvars file. This is a special file that Terraform
can use to retrieve specific values of variables without requiring the operator (you!) to modify the
variables file or set environment variables. This is one of the most popular ways that Terraform users
will set values in Terraform.
In the same Terraform directory, create a new file called terraform.tfvars. In that file, let’s add
the following code:
#vi terraform.tfvars
# Public Subnet Values
variables_sub_auto_ip = true
variables_sub_az = "us-east-1d"
variables_sub_cidr = "10.0.204.0/24"


Run a terraform plan to see the results. You’ll find that Terraform wants to replace the subnet since
we updated the CIDR block of the subnet using a tfvars file.

Let’s go ahead and apply our new configuration, which will replace the subnet with one using the
CIDR block of “10.0.204.0/24”. Run a terraform apply. Don’t forget to accept the changes by typing
yes.

# Override the variable on the CLI
Finally, the last way that you can set the value for a Terraform variable is to simply set the value on
the command line when running a terraform plan or terraform apply using a flag. You can
set the value of a single variable using the -var flag, or you can set one or many variables using the
-var-file flag and point to a file containing the variables and corresponding values.
On the CLI, run the following command:
$ terraform plan -var variables_sub_az="us-east-1e" -var variables_sub_cidr="10.0.205.0/24"

You’ll see that we’ve now set the variable variables_sub_az equal to “us-east-1e” and the variable
variables_sub_cidr to “10.0.205.0/24” which are dierent from our current infrastructure. As a
result, Terraform wants to replace the existing subnet. Terraform uses the last value it finds, overriding
any previous values

Let’s go ahead and apply our new configuration, which will replace the subnet with one using the
CIDR block of “10.0.204.0/24”. Run a terraform apply. Don’t forget to accept the changes by typing
yes.

#8a ## Outputs
Terraform generates a significant amount of metadata that is too tedious to sort through with
terraform show. Even with just one instance deployed, we wouldn’t want to scan 38 lines of
metadata every time. Outputs allow us to query for specific values rather than parse metadata in
terraform show.
• Task 1: Create output values in the configuration file
• Task 2: Use the output command to find specific values
• Task 3: Suppress outputs of sensitive values in the CLI

# Create output values in the configuration file
Outputs allow customization of Terraform’s output during a Terraform apply. Outputs define useful
values that will be highlighted to the user when Terraform is executed. Examples of values commonly
retrieved using outputs include IP addresses, usernames, and generated keys.
Create a new output value named “public_ip” to output the instance’s public_ip attributes. In the
outputs.tf file, add the following:
output "public_ip" {
description = "This is the public IP of my web server"
value = aws_instance.web_server.public_ip
}

# Run a Terraform Apply to view the outputs
Aer adding the new output blocks above, go ahead and run a terraform apply -auto-approve
to see the new output values. Since we didn’t change any resources, there is no risk of changes to our
environment. You can see the new output value. Notice that you only see the name of the output and
the value but you don’t see the description inthe output.

# Use the terraform output command to find specific values
Step 2.1 Try the terraform output command with no specifications
terraform output

Step 2.2 Query specifically for the public_dns attributes
terraform output public_ip

Step 2.3 Wrap an output query to ping the DNS record
ping $(terraform output -raw public_dns)

# Suppress outputs of sensitive values in the CLI
As you’ll find with many aspects of Terraform, you will sometimes be working with sensitive data.
Whether it’s a username and password, account numbers, or certicates, it’s very common that you’ll
want to obfuscate these from the CLI output. Fortunately, Terraform provides us with the sensitive
argument to use in the output block. This allows you to mark the value as sensitive (hence the name)
and prevent the value from showing in the CLI output. It does not, however, prevent the value from
being listed in the state file or anything like that.
In the outputs.tf file, add the new output block as shown below. Since a resource arn oen includes
the AWS account number, it might be a value we don’t want to show in the CLI console, so let’s obfuscate
it to protect our account.
output "ec2_instance_arn" {
value = aws_instance.web_server.arn
sensitive = true
}

Run a Terraform Apply to view the suppressed value
Aer adding the output blocks, run a terraform apply -auto-approve to see the new output
value (or NOT see the new output value). Since we didn’t change any resources, there is no risk of
changes to our environment.

# 8a ### Variable Validation and Suppression
We may want to validate and possibly suppress and sensitive information defined within our variables.
• Task 1: Validate variables in a configuration block
• Task 2: More Validation Options
• Task 3: Suppress sensitive information
• Task 4: View the Terraform State File
Task 1: Validate variables in a configuration block
Create a new folder called variable_validation with a variables.tf configuration file:
variable "cloud" {
type = string
validation {
condition = contains(["aws", "azure", "gcp", "vmware"], lower(var.cloud))
error_message = "You must use an approved cloud."
}
validation {
condition = lower(var.cloud) == var.cloud
error_message = "The cloud name must not have capital letters."
}
}
Perform a terraform init and terraform plan. Provide inputs that both meet and do not meet
the validation conditions to see the behavior.
terraform plan -var cloud=aws
terraform plan -var cloud=alibabba
Task 2: More Validation Options
Add the following items to the variables.tf
variable "no_caps" {
type = string
validation {
  condition = lower(var.no_caps) == var.no_caps
error_message = "Value must be in all lower case."
}
}
variable "character_limit" {
type = string
validation {
condition = length(var.character_limit) == 3
error_message = "This variable must contain only 3 characters."
}
}
variable "ip_address" {
type = string
validation {
condition = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.ip_address))
error_message = "Must be an IP address of the form X.X.X.X."
}
}

terraform plan -var cloud=aws -var no_caps=training
-var ip_address=1.1.1.1 -var character_limit=rpt

terraform plan -var cloud=all -var no_caps=Training
-var ip_address=1223.22.342.22 -var character_limit=ga

Task 3: Suppress sensitive information
Terraform allows us to mark variables as sensitive and suppress that information. Add the following
configuration into your main.tf:
variable "phone_number" {
type = string
sensitive = true
default = "867-5309"
}
locals {
contact_info = {
cloud = var.cloud
department = var.no_caps
cost_code = var.character_limit
phone_number = var.phone_number
}
my_number = nonsensitive(var.phone_number)
}
output "cloud" {
value = local.contact_info.cloud
}
output "department" {
value = local.contact_info.department
}
output "cost_code" {
value = local.contact_info.cost_code
}
output "phone_number" {
value = local.contact_info.phone_number
}
output "my_number" {
value = local.my_number
}
Execute a terraform apply with inline variables.

terraform apply -var cloud=aws -var no_caps=training
-var ip_address=1.1.1.1 -var character_limit=rpt

You will notice that the output block errors as it needs to have the sensitive = true value set.
Error: Output refers to sensitive values
on variables.tf line 73:
73: output "phone_number" {
To reduce the risk of accidentally exporting sensitive data that was intended to be onlsensitive data be explicitly marked as sensitive to confirm your intent.
If you do intend to export this data, annotate the output value as sensitive by adding sensitive = true
Update the output to set the sensitive = true attribute and rerun the apply.

output "phone_number" {
sensitive = true
value = local.contact_info.phone_number
}

terraform apply -var cloud=aws -var no_caps=training
-var ip_address=1.1.1.1 -var character_limit=rpt
Outputs:
cloud = "aws"
cost_code = "rpt"
department = "training"
my_number = "867-5309"
phone_number = <sensitive>

Task 4: View the Terraform State File
Even though items are marked as sensitive within the Terraform configuration, they are stored within
the Terraform state file. It is therefore critical to limit the access to the Terraform state file.
View the terraform.tfstate within your variable_validation diredtory.
{
"version": 4,
"terraform_version": "1.0.4",
"serial": 3,
"lineage": "5cfbccdd-b915-ee22-ea3c-17db83258332",
"outputs": {
"cloud": {
"value": "aws",
"type": "string"
},
"cost_code": {
"value": "rpt",
"type": "string"
},
"department": {
"value": "training",
"type": "string"
},
"my_number": {
"value": "867-5309",
"type": "string"
},
"phone_number": {
"value": "867-5309",
"type": "string",
"sensitive": true
}
},
"resources": []
}

TFC Integration
If you would like to see how variables are handled within Terraform Cloud, you can add the following
files to your variable_validation directory.
remote.tf

terraform {
backend "remote" {
organization = "<<ORGANIZATION NAME>>"
workspaces {
name = "variable_validation"
}
}
}

#vi terraform.auto.tfvars
cloud = "aws"
no_caps = "training"
ip_address = "1.1.1.1"
character_limit = "rpt"
Run a terraform init to migrate state to the TFC workspace, followed by a terraform apply to
show sensitive values with TFC.

# 8b ##  Secure Secrets in Terraform Code
When working with Terraform, it’s very likely you’ll be working with sensitive values. This lab goes
over the most common techniques you can use to safely and securely manage such secrets.
• Task 1: Do Not Store Secrets in Plain Text
• Task 2: Mark Variables as Sensitive
• Task 3: Environment Variables
• Task 4: Secret Stores (e.g., Vault, AWS Secrets manager)
Task 1: Do Not Store Secrets in Plain Text
Never put secret values, like passwords or access tokens, in .tf files or other files that are checked into
source control. If you store secrets in plain text, you are giving the bad actors countless ways to access
sensitive data. Ramifications for placing secrets in plain text include:
• Anyone who has access to the version control system has access to that secret.
• Every computer that has access to the version control system keeps a copy of that secret
• Every piece of soware you run has access to that secret.
• No way to audit or revoke access to that secret.
Task 2: Mark Variables as Sensitive
The first line of defense here is to mark the variable as sensitive so Terraform won’t output the value in
the Terraform CLI. Remember that this value will still show up in the Terraform state file:
In your variables.tf file, add the following code:
variable "phone_number" {
type = string
sensitive = true
default = "867-5309"
}
output "phone_number" {
value = var.phone_number
sensitive = true
}

Run a terraform apply to see the results of the sensitive variable. Notice how Terraform marks this
as sensitive.

Task 3: Environment Variables
Another way to protect secrets is to simply keep plain text secrets out of your code by taking advantage
of Terraform’s native support for reading environment variables. By setting the TF_VAR_<name>
environment variable, Terraform will use that value rather than having to add that directly to your
code.
In your variables.tf file, modify the phone_number variable and remove the default value so the
sensitive value is no longer in cleartext:
variable “phone_number” { type = string sensitive = true }
In your terminal, export the following environment variable and set the value:
export TF_VAR_phone_number="867-5309"
Note: If you are still using Terraform Cloud as your remote backend, you will need to set this environment
variable in your Terraform Cloud workspace instead.
Now, run a terraform apply and see that the plan runs just the same, since Terraform picked up the
value of the sensitive variable using the environment variable. This strategy prevents us from having
to add the value directly in our Terraform files and likely being committed to a code repository.

Task 4: Inject Secrets into Terraform using HashiCorp Vault
Another way to protect your secrets is to store them in secrets management solution, like HashiCorp
Vault. By storing them in Vault, you can use the Terraform Vault provider to quickly retrieve values
from Vault and use them in your Terraform code.
Download HashiCorp Vault for your operating system at vaultproject.io. Make sure the binary is moved to your $PATH so it can be executed from any directory. For help, check out
https://www.vaultproject.io/docs/install. Alternatively, you can use Homebrew (MacOS) or Chocolatey
(Windows). There are also RPMs available for Linux.
Validate you have Vault installed by running:
vault version

You should get back the version of Vault you have downloaded and installed.
In your terminal, run vault server -dev to start a Vault dev server. This will launch Vault in a
pre-configured state so we can easily use it for this lab. Note that you should never run Vault in a
production deployment by starting it this way.
Open a second terminal, and set the VAULT_ADDR environment variable. By default, this is set to
HTTPS, but since we’re using a dev server, TLS is not supported.
export VAULT_ADDR="http://127.0.0.1:8200"
Now, log in to Vault using the root token from the output of our Vault dev server. An example is below,
but your root token and unseal key will be dierent:

WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
and starts unsealed with a single unseal key. The root token is already
authenticated to the CLI, so you can immediately begin using Vault.
You may need to set the following environment variable:
$ export VAULT_ADDR='http://127.0.0.1:8200'
The unseal key and root token are displayed below in case you want to
seal/unseal the Vault or re-authenticate.
Unseal Key: 1zqTTWCHyAvEhTqOLurR2nQPeeoR1Sk2FMp95fRNEaU=
Root Token: s.Oi1tQPY98uwWQ6HOf9T7Elkg
Development mode should NOT be used in production installations!

Log in to Vault using the following command:
vault login <root token>
Now that we are logged into Vault, we can quickly add our sensitive values to be stored in Vault’s KV
store. Use the following command to write the sensitive value to Vault:
vault kv put /secret/app phone_number=867-5309
Back in Terraform, let’s add the code to use Vault to retrieve our secrets. Create a new directory called
vault and add a main.tf file. In your main.tf file, add the following code:
provider "vault" {
address = "http://127.0.0.1:8200"
token = <root token>
}

By the way, note that I am only using the root token as an example here. Root tokens should NEVER
be used on a day-to-day basis, nor should you use a root token for Terraform access. Please use a
dierent auth method, such as AppRole, which is a better solution to establish connectivity between
Terraform and Vault.
Now, add the following data block, which will use the Vault provider and token to retrieve the sensitive
values we need:
data "vault_generic_secret" "phone_number" {
path = "secret/app"
}
Finally, let’s an a new output block that uses the data retrieved from Vault. In your main.tf, add the
following code:
output "phone_number" {
value = data.vault_generic_secret.phone_number
}
Run a terraform init and a terraform apply. Notice that Terraform is smart enough to understand that since the value was retrieved from Vault, it needs to be marked as sensitive since it likely
contains sensitive information.
Add the sensitive configuration to the output block as follows:
output "phone_number" {
value = data.vault_generic_secret.phone_number
sensitive = true
}
Run a terraform apply again so Terraform retrieves that data from Vault. Note that the output
will be shown as sensitive, but we can still easily display the data. In the terminal, run the following
command to display the sensitive data retrieved from Vault:
terraform output phone_number
If you need ONLY the value of the data retrieved, rather than both the key and value and related JSON,
you can update the output to the following:
output "phone_number" {
value = data.vault_generic_secret.phone_number.data["phone_number"]
sensitive = true
}
Run a terraform output phone_number again to see that the value is now ONLY the phone_number string, rather than the JSON output as we saw before.

# 8c ## Terraform Collections and Structure Types

As you continue to work with Terraform, you’re going to need a way to organize and structure data.
This data could be input variables that you are giving to Terraform, or it could be the result of resource
creation, like having Terraform create a fleet of web servers or other resources. Either way, you’ll find
that data needs to be organized yet accessible so it is referenceable throughout your configuration.
The Terraform language uses the following types for values:
• string: a sequence of Unicode characters representing some text, like “hello”.
• number: a numeric value. The number type can represent both whole numbers like 15 and
fractional values like 6.283185.
• bool: a boolean value, either true or false. bool values can be used in conditional logic.
• list (or tuple): a sequence of values, like [“us-west-1a”, “us-west-1c”]. Elements in a list or tuple
are identified by consecutive whole numbers, starting with zero.
• map (or object): a group of values identified by named labels, like {name = “Mabel”, age = 52}.
Maps are used to store key/value pairs.
Strings, numbers, and bools are sometimes called primitive types. Lists/tuples and maps/objects
are sometimes called complex types, structural types, or collection types. Up until this point, we’ve
primarily worked with string, number, or bool, although there have been some instances where we’ve
provided a collection by way of input variables. In this lab, we will learn how to use the dierent
collections and structure types available to us.
• Task 1: Create a new list and reference its values using the index
• Task 2: Add a new map variable to replace static values in a resource
• Task 3: Iterate over a map to create multiple resources
• Task 4: Use a more complex map variable to group information to simplify readability

Task 1: Create a new list and reference its values
In Terraform, a list is a sequence of like values that are identified by an index number starting with
zero. Let’s create one in our configuration to learn more about it. Create a new variable that includes a
list of dierent availability zones in AWS. In your variables.tf file, add the following variable:
variable "us-east-1-azs" {
type = list(string)
default = [
  "us-east-1a",
"us-east-1b",
"us-east-1c",
"us-east-1d",
"us-east-1e"
]
}

In your main.tf file, add the following code that will reference the new list that we just created:

resource "aws_subnet" "list_subnet" {
vpc_id = aws_vpc.vpc.id
cidr_block = "10.0.200.0/24"
availability_zone = var.us-east-1-azs
}

Go and and run a terraform plan. You should receive an error, and that’s because the new variable
us-east-1-azs we just created is a list of strings, and the argument availability_zones is expecting a single string. Therefore, we need to use an identifier to select which element to use in the list
of strings.
Let’s fix it. Update the list_subnet configuration to specify a specific element referenced by its
indexed value from the list we provided - remember that indexes start at 0.
resource "aws_subnet" "list_subnet" {
vpc_id = aws_vpc.vpc.id
cidr_block = "10.0.200.0/24"
availability_zone = var.us-east-1-azs[0]
}

Run a terraform plan again. Check out the output and notice that the new subnet will be created in
us-east-1a, because that is the first string in our list of strings. If we used var.us-east-1-azs[1]
in the configuration, Terraform would have built the subnet in us-east-1b since that’s the second
string in our list.
Go ahead and run terraform apply to apply the new configuration and build the subnet.

Task 2 - Add a new map variable to replace static values in a resource

Let’s continue to improve our list_subnet so we’re not using any static values. First, we’ll work on
getting rid of the static value used for the subnet CIDR block and use a map instead. Add the following
code to variables.tf:
variable "ip" {
type = map(string)
default = {
prod = "10.0.150.0/24"
dev = "10.0.250.0/24"
}
}

Now, let’s reference the new variable we just created. Modify the list_subnet in main.tf:
resource "aws_subnet" "list_subnet" {
vpc_id = aws_vpc.vpc.id
cidr_block = var.ip["prod"]
availability_zone = var.us-east-1-azs[0]
}

Run terraform plan to see the proposed changes. In this case, you should see that the subnet will
be replaced. The new subnet will have an IP subnet of 10.0.150.0/24, because we are now referencing
the value of the prod key in our map.
Go ahead and run terraform apply -auto-approve to apply the new changes.
Before we move on, let’s fix one more thing here. We still have a static value that is “hardcoded” in our
list_subnet that we should use a variable for instead. We already have a var.environment that
dictates the environment we’re working in, so we can simply use that in our list_subnet.
Modify the list_subnet in main.tf and update the cidr_block argument to the following:
resource "aws_subnet" "list_subnet" {
vpc_id = aws_vpc.vpc.id
cidr_block = var.ip[var.environment]
availability_zone = var.us-east-1-azs[0]
}
Run terraform plan to see the proposed changes. In this case, you should see that the subnet will
again be replaced. The new subnet will have an IP subnet of 10.0.250.0/24, because we are now
using the value of var.environment to select the key in our map for the variable var.ip and the
default is dev.
Go ahead and run terraform apply -auto-approve to apply the new changes.

Task 3: Iterate over a map to create multiple resources
While we’re in much better shape for our list_subnet, we can still improve it. Oftentimes, you’ll
want to deploy multiple resources of the same type but each resource should be slightly dierent for
dierent use cases. In our example, if we wanted to deploy BOTH a dev and prod subnet, we would
have to copy the resource block and create a second one so we could refer to the other subnet in our
map. However, there’s a fairly simple way that we can iterate over our map in a single resource block
to create and manage both subnets.
To accomplish this, use a for_each to iterate over the map to create multiple subnets in the same AZ.
Modify your list_subnet to the following:
resource "aws_subnet" "list_subnet" {
for_each = var.ip
vpc_id = aws_vpc.vpc.id
cidr_block = each.value
availability_zone = var.us-east-1-azs[0]
}
Run a terraform plan to see the proposed changes. Notice that our original subnet will be destroyed
and Terraform will create two two subnets, one for prod with its respective CIDR block and one for
dev with its respective CIDR block. That’s because the for_each iterated over the map and will
create a subnet for each key. The other major dierence is the resource ID for each subnet. Notice
how it’s creating aws_subnet.list_subnet["dev"] and aws_subnet.list_subnet["prod"],
where the names are the keys listed in the map. This gives us a way to clearly understand what each
subnet is. We could even use these values in a tag to name the subnet as well.
Go ahead and apply the new configuration using a terraform apply -auto-approve.
Using terraform state list, check out the new resources:
$ terraform state list
...
aws_subnet.list_subnet["dev"]
aws_subnet.list_subnet["prod"]
You can also use terraform console to view the resources and more detailed information about
each one (use CTLR-C to get out when you’re done):
$ terraform console
> aws_subnet.list_subnet
{
"dev" = {
"arn" = "arn:aws:ec2:us-east-1:1234567890:subnet/subnet-052d26040d4b91a51"
"assign_ipv6_address_on_creation" = false
...

Task 4: Use a more complex map variable to group information to simplify readability
While the previous configuration works great, we’re still limited to using only a single availability zone
for both of our subnets. What if we wanted to use a single resource block but have unique settings
for each subnet? Well, we can use a map of maps to group information together to make it easier to
iterate over and, more importantly, make it easier to read for you and others using the code.
Create a “map of maps” to group information per environment. In variables.tf, add the following
variable:
variable "env" {
type = map(any)
default = {
prod = {
ip = "10.0.150.0/24"
az = "us-east-1a"
}
dev = {
ip = "10.0.250.0/24"
az = "us-east-1e"
}
}
}
In main.tf, modify the list_subnet to the following:
resource "aws_subnet" "list_subnet" {
for_each = var.env
vpc_id = aws_vpc.vpc.id
cidr_block = each.value.ip
availability_zone = each.value.az
}
Run a terraform plan to view the proposed changes. Notice that only the dev subnet will be
replaced since we’re now placing it in a dierent availability zone, yet the prod subnet remains
unchanged.
Go ahead and apply the configuration using terraform apply -auto-approve. Feel free to log
into the AWS console to check out the new resources.
Once you’re done, feel free to delete the variables and list_subnet that was created in this lab,
although it’s not required.

# 8c ## Terraform Collections and Structure Types

As you continue to work with Terraform, you’re going to need a way to organize and structure data.
This data could be input variables that you are giving to Terraform, or it could be the result of resource
creation, like having Terraform create a fleet of web servers or other resources. Either way, you’ll find
that data needs to be organized yet accessible so it is referenceable throughout your configuration.
The Terraform language uses the following types for values:
• string: a sequence of Unicode characters representing some text, like “hello”.
• number: a numeric value. The number type can represent both whole numbers like 15 and
fractional values like 6.283185.
• bool: a boolean value, either true or false. bool values can be used in conditional logic.
• list (or tuple): a sequence of values, like [“us-west-1a”, “us-west-1c”]. Elements in a list or tuple
are identified by consecutive whole numbers, starting with zero.
• map (or object): a group of values identified by named labels, like {name = “Mabel”, age = 52}.
Maps are used to store key/value pairs.
Strings, numbers, and bools are sometimes called primitive types. Lists/tuples and maps/objects
are sometimes called complex types, structural types, or collection types. Up until this point, we’ve
primarily worked with string, number, or bool, although there have been some instances where we’ve
provided a collection by way of input variables. In this lab, we will learn how to use the different
collections and structure types available to us.

Task 1: Create a new list and reference its values using the index
Task 2: Add a new map variable to replace static values in a resource
Task 3: Iterate over a map to create multiple resources
Task 4: Use a more complex map variable to group information to simplify readability
Task 1: Create a new list and reference its values
In Terraform, a list is a sequence of like values that are identified by an index number starting with
zero. Let’s create one in our configuration to learn more about it. Create a new variable that includes a
list of different availability zones in AWS. In your variables.tf file, add the following variable:
variable "us-east-1-azs" {
type = list(string)
default = [
"us-east-1a",
"us-east-1b",
"us-east-1c",
"us-east-1d",
"us-east-1e"
]
}
In your main.tf file, add the following code that will reference the new list that we just created:
rresource "aws_subnet" "list_subnet" {
vpc_id = aws_vpc.vpc.id
cidr_block = "10.0.200.0/24"
availability_zone = var.us-east-1-azs
}

Go and and run a terraform plan . You should receive an error, and that’s because the new variable
us-east-1-azs we just created is a list of strings, and the argument availability_zones is ex-
pecting a single string. Therefore, we need to use an identifier to select which element to use in the list
of strings.
Let’s fix it. Update the list_subnet configuration to specify a specific element referenced by its
indexed value from the list we provided - remember that indexes start at 0 .
resource "aws_subnet" "list_subnet" {
vpc_id = aws_vpc.vpc.id
cidr_block = "10.0.200.0/24"
availability_zone = var.us-east-1-azs[0]
}

Run a terraform plan again. Check out the output and notice that the new subnet will be created in
us-east-1a , because that is the first string in our list of strings. If we used var.us-east-1-azs[1]
in the configuration, Terraform would have built the subnet in us-east-1b since that’s the second
string in our list.
Go ahead and run terraform apply to apply the new configuration and build the subnet.

Task 2 - Add a new map variable to replace static values in a resource
Let’s continue to improve our list_subnet so we’re not using any static values. First, we’ll work on
getting rid of the static value used for the subnet CIDR block and use a map instead. Add the following
code to variables.tf :
variable "ip" {
  type = map(string)
default = {
prod = "10.0.150.0/24"
dev = "10.0.250.0/24"
}
}
Now, let’s reference the new variable we just created. Modify the list_subnet in main.tf :

resource "aws_subnet" "list_subnet" {
vpc_id  = aws_vpc.vpc.id
cidr_block = var.ip["prod"]
availability_zone = var.us-east-1-azs[0]
}

Run terraform plan to see the proposed changes. In this case, you should see that the subnet will
be replaced. The new subnet will have an IP subnet of 10.0.150.0/24, because we are now referencing
the value of the prod key in our map.
Go ahead and run terraform apply -auto-approve to apply the new changes.
Before we move on, let’s fix one more thing here. We still have a static value that is “hardcoded” in our
list_subnet that we should use a variable for instead. We already have a var.environment that
dictates the environment we’re working in, so we can simply use that in our list_subnet .
Modify the list_subnet in main.tf and update the cidr_block argument to the following:
resource "aws_subnet" "list_subnet" {
vpc_id = aws_vpc.vpc.id
cidr_block = var.ip[var.environment]
availability_zone = var.us-east-1-azs[0]
}

Run terraform plan to see the proposed changes. In this case, you should see that the subnet will
again be replaced. The new subnet will have an IP subnet of 10.0.250.0/24 , because we are now
using the value of var.environment to select the key in our map for the variable var.ip and the
default is dev .
Go ahead and run terraform apply -auto-approve to apply the new changes.

Task 3: Iterate over a map to create multiple resources
While we’re in much better shape for our list_subnet , we can still improve it. Oftentimes, you’ll
want to deploy multiple resources of the same type but each resource should be slightly different for
different use cases. In our example, if we wanted to deploy BOTH a dev and prod subnet, we would
have to copy the resource block and create a second one so we could refer to the other subnet in our
map. However, there’s a fairly simple way that we can iterate over our map in a single resource block
to create and manage both subnets.
To accomplish this, use a for_each to iterate over the map to create multiple subnets in the same AZ.
Modify your list_subnet to the following:
resource "aws_subnet" "list_subnet" {
for_each = var.ip
vpc_id = aws_vpc.vpc.id
cidr_block = each.value
availability_zone = var.us-east-1-azs[0]
}

Run a terraform plan to see the proposed changes. Notice that our original subnet will be destroyed
and Terraform will create two two subnets, one for prod with its respective CIDR block and one for
dev with its respective CIDR block. That’s because the for_each iterated over the map and will
create a subnet for each key. The other major difference is the resource ID for each subnet. Notice
how it’s creating aws_subnet.list_subnet["dev"] and aws_subnet.list_subnet["prod"] ,
where the names are the keys listed in the map. This gives us a way to clearly understand what each
subnet is. We could even use these values in a tag to name the subnet as well.
Go ahead and apply the new configuration using a terraform apply -auto-approve .
Using terraform state list , check out the new resources:
$ terraform state list
...
aws_subnet.list_subnet["dev"]
aws_subnet.list_subnet["prod"]
You can also use terraform console to view the resources and more detailed information about
each one (use CTLR-C to get out when you’re done):
$ terraform console
> aws_subnet.list_subnet
{
"dev" = {
"arn" = "arn:aws:ec2:us-east-1:1234567890:subnet/subnet-052d26040d4b91a51"
"assign_ipv6_address_on_creation" = false
...

Task 4: Use a more complex map variable to group information to simplify readability
While the previous configuration works great, we’re still limited to using only a single availability zone
for both of our subnets. What if we wanted to use a single resource block but have unique settings
for each subnet? Well, we can use a map of maps to group information together to make it easier to
iterate over and, more importantly, make it easier to read for you and others using the code.
Create a “map of maps” to group information per environment. In variables.tf , add the following
variable:
variable "env" {
type = map(any)
default = {
prod = {
ip = "10.0.150.0/24"
az = "us-east-1a"
}
dev = {
ip = "10.0.250.0/24"
az = "us-east-1e"
}
}
}
In main.tf , modify the list_subnet to the following:
resource "aws_subnet" "list_subnet" {
for_each = var.env
vpc_id = aws_vpc.vpc.id
cidr_block = each.value.ip
availability_zone = each.value.az
}

Run a terraform plan to view the proposed changes. Notice that only the dev subnet will be
replaced since we’re now placing it in a different availability zone, yet the prod subnet remains
unchanged.
Go ahead and apply the configuration using terraform apply -auto-approve . Feel free to log
into the AWS console to check out the new resources.
Once you’re done, feel free to delete the variables and list_subnet that was created in this lab,
although it’s not required.

#8d ## Working with Data Blocks

Cloud infrastructure, applications, and services emit data, which Terraform can query and act on using
data sources. Terraform uses data sources to fetch information from cloud provider APIs, such as disk
image IDs, or information about the rest of your infrastructure through the outputs of other Terraform
configurations.
• Task 1: Query existing resources using a data block
• Task 2: Export attributes from a data lookup

Task 1: Query existing resources using a data block
As you develop Terraform code, you want to make sure the code is developed with reusability in mind.
This oen means that your code needs to query data in order to get specific attributes or values to
deploy resources where needed. For example, if you manually created an S3 bucket in AWS, you might
to query information about that bucket so you can use it throughout your configuration. In this case,
you would require a data block in Terraform to grab information to be used. Note that in this case,
we’re going to query data that already exists in AWS, and not a resource that was created by Terraform
itself.
In the AWS console, create a new S3 bucket to use for this lab. Just create a bucket with all of the
defaults. Don’t worry, empty S3 buckets do not incur any costs.
In your main.tf file, let’s create a data block that retrieves information about our new S3 bucket:

data "aws_s3_bucket" "data_bucket" {
bucket = "my-data-lookup-bucket-btk"
}
Now, let’s use information from that data lookup to create a new IAM policy to permit access to our
new S3 bucket. In your main.tf file, add the following code:
resource "aws_iam_policy" "policy" {
name = "data_bucket_policy"
description = "Deny access to my bucket"
policy = jsonencode({
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Action": [
"s3:Get*",
"s3:List*"
],
"Resource": "${data.aws_s3_bucket.data_bucket.arn}"
}
]
})
}

Run a terraform plan to see the proposed changes. Notice how the new policy will be created and
the resource in the policy is the ARN of our new S3 bucket. Go ahead and apply the configuration using
a terraform apply -auto-approve.

Task 2: Export attributes from a data lookup
Now that we have a successful data lookup against our S3 bucket, let’s take a look at the attributes that
we can export. Browse to the Terraform AWS provider, click on S3 in the le navigation page, and click on
aws_s3_bucketunder Data Sources. (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/datasources/s3_bucket)
Note all of the dierent attributes that are exported. These are attributes that we can use throughout
our Terraform configuration. We’ve already used arn, but we could use other attributes as well.
In the main.tf file, add the following outputs so we can see some of the additional information:

output "data-bucket-arn" {
value = data.aws_s3_bucket.data_bucket.arn
}
output "data-bucket-domain-name" {
value = data.aws_s3_bucket.data_bucket.bucket_domain_name
}
output "data-bucket-region" {
value = "The ${data.aws_s3_bucket.data_bucket.id} bucket is located
in ${data.aws_s3_bucket.data_bucket.region}"
}

Run a terraform apply -auto-approve to see the new outputs. Remember that the data in these
outputs originated from our data lookup that we started with in this lab.
Once you’re done, feel free to delete the bucket, the data block, and the output blocks if you would
like.

# 8f ## Terraform Built-in Functions

As you continue to work with data inside of Terraform, there might be times where you want to modify
or manipulate data based on your needs. For example, you may have multiple lists or strings that you
want to combine. In contrast, you might have a list where you want to extract data, such as returning
the first two values.
The Terraform language has many built-in functions that can be used in expressions to transform and
combine values. Functions are available for actions on numeric values, string values, collections, date
and time, filesystem, and many others.
• Task 1: Use basic numerical functions to select data
• Task 2: Manipulate strings using Terraform functions
• Task 3: View the use of cidrsubnet function to create subnets

Task 1: Use basic numerical functions to select data
Terraform includes many dierent functions that work directly with numbers. To learn how they work,
let’s add some code and check it out. In your variables.tf file, let’s add some variables. Feel free to
use any number as the default value.

variable "num_1" {
type = number
description = "Numbers for function labs"
default = 88
}
variable "num_2" {
type = number
description = "Numbers for function labs"
default = 73
}
variable "num_3" {
type = number
description = "Numbers for function labs"
default = 52
}
In the main.tf, let’s add a new local variable that uses a numercial function:

locals {
maximum = max(var.num_1, var.num_2, var.num_3)
minimum = min(var.num_1, var.num_2, var.num_3, 44, 20)
}
output "max_value" {
value = local.maximum
}
output "min_value" {
value = local.minimum
}
Go ahead and run a terraform apply -auto-approve so we can see the result of our numerical
functions by way of outputs.

Task 2: Manipulate strings using Terraform functions
Now that we know how to use functions with numbers, let’s play around with strings. Many of the
resources we deploy with Terraform and the related aruments require a string for input, such as a
subnet ID, security group, or instance size.
Let’s modify our VPC to make use of a string function. Update your VPC resource in the main.tf file to
look something like this:
#Define the VPC
resource "aws_vpc" "vpc" {
cidr_block = var.vpc_cidr
tags = {
Name = upper(var.vpc_name)
Environment = upper(var.environment)
Terraform = upper("true")
}
enable_dns_hostnames = true
}
Go ahead and run a terraform apply -auto-approve so we can see the result of our string functions by way of the changes that are applied to our tags.

Task 2.1
Now, let’s assume that we have set standards for our tags across AWS, and one of the requirements is
that all tags are lower case. Rather than bothering our users with variable validations, we can simply
take care of it for them with a simply function.
In your main.tf file, update the locals block to the following:
locals {
# Common tags to be assigned to all resources
common_tags = {
Name = lower(local.server_name)
Owner = lower(local.team)
App = lower(local.application)
Service = lower(local.service_name)
AppTeam = lower(local.app_team)
CreatedBy = lower(local.createdby)
}
}
Before we test it out, let’s set the value of a variable using a .tfvars file. Create a new file called
terraform.auto.tfvars in the same working directory and add the following:
environment = "PROD_Environment"
Let’s test it out. Run terraform plan and let’s take a look at the proposed changes. Notice that our
string manipulations are causing some of the resource tags to be updated.
Go and apply the changes using terraform apply -auto-approve.
Task 2.2
When deploying workloads in Terraform, it’s common practice to use functions or expressions to
dynamically generate name and tag values based on input variables. This makes your modules
reuseable without worrying about providing values for more and more tags.
In your main.tf file, let’s update our locals block again, but this time we’ll use a join to dynamically
generate the value for Name based upon data we’re already providing or getting from data blocks.

locals {
# Common tags to be assigned to all resources
common_tags = {
Name = join("-", [local.application, data.aws_region.current.name, local.createOwner = lower(local.team)
App = lower(local.application)
Service = lower(local.service_name)
AppTeam = lower(local.app_team)
CreatedBy = lower(local.createdby)
}
}

Let’s test it out. Run terraform plan and let’s take a look at the proposed changes. Notice that our
string function is dynamically creating a Name for our resource based on other data we’ve provided or
obtained.
Go and apply the changes using terraform apply -auto-approve.

Task 3: View the use of cidrsubnet function to create subnets
There are many dierent specialized functions that come in handy when deploying resources in a
public or private cloud. One of these special functions can help us automatically generate subnets
based on a CIDR block that we provided it. Since the very first time you ran terraform apply in this
course, you’ve been using the cidrsubnet function to create the subnets.
In your main.tf file, view the resource blocks that are creating our initial subnets:
#Deploy the private subnets
resource "aws_subnet" "private_subnets" {
for_each = var.private_subnets
vpc_id = aws_vpc.vpc.id
cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value)
availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
tags = {
Name = each.key
Terraform = "true"
}
}

Note how this block (and the one to create the public subnets) is creating multiple subnets. The
resulting subnets were created based on the initial CIDR block, which was our VPC CIDR block. The
second value is the number of bits added to the original prefix, so in our case, it was /16, so resulting
subnets will be /24 since we’re adding 8 in our function. The last value needed is derived from the
value obtained from the value of each key in private_subnets since we’re using a for_each in this
resource block.
Free free to create other subnets using the cidrsubnet function and play around with the values to see
how it could best fit your requirements and scenarios.

# 8g ## Dynamic Blocks
A dynamic block acts much like a for expression, but produces nested blocks instead of a complex
typed value. It iterates over a given complex value, and generates a nested block for each element of
that complex value. You can dynamically construct repeatable nested blocks using a special dynamic
block type, which is supported inside resource, data, provider, and provisioner blocks.
• Task 1: Create a Security Group Resource with Terraform
• Task 2: Look at the state without a dynamic block
• Task 3: Convert Security Group to use dynamic block
• Task 4: Look at the state with a dynamic block
• Task 5: Use a dynamic block with Terraform map
• Task 6: Look at the state with a dynamic block using Terraform map
Task 1: Create a Security Group Resource with Terraform
Add an AWS security group resource to our main.tf
resource "aws_security_group" "main" {
name = "core-sg"
vpc_id = aws_vpc.vpc.id
ingress {
description = "Port 443"
from_port = 443
to_port = 443
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
description = "Port 80"
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
}

Task 2: Look at the state without a dynamic block
Run a terraform apply followed by a terraform state list to view how the security groups
are accounted for in Terraform’s State.
terraform state list
aws_security_group.main
terraform state show aws_security_group.main
# aws_security_group.main:
resource "aws_security_group" "main" {
arn = "arn:aws:ec2:us-east-1:508140242758:security-group/sg-00157description = "Managed by Terraform"
egress = []
id = "sg-00157499a6de61832"
ingress = [
{
cidr_blocks = [
"0.0.0.0/0",
]
description = "Port 443"
from_port = 443
ipv6_cidr_blocks = []
prefix_list_ids = []
protocol = "tcp"
security_groups = []
self = false
to_port = 443
},
{
cidr_blocks = [
"0.0.0.0/0",
]
description = "Port 80"
from_port = 80
ipv6_cidr_blocks = []
prefix_list_ids = []
protocol = "tcp"
security_groups = []
self = false
to_port = 80
},
]
name = "core-sg"
owner_id = "508140242758"
revoke_rules_on_delete = false
tags_all = {}
vpc_id = "vpc-0e3a3d76e5feb63c9"
}
Task 3: Convert Security Group to use dynamic block
Refactor the aws_security_group resource block created above to utilize a dynamic block to built
out the repeatable ingress nested block that is a part of this resource. We will supply the content for
these repeatable blocks via local values to make it easier to read and update moving forward.
locals {
ingress_rules = [{
port = 443
description = "Port 443"
},
{
port = 80
description = "Port 80"
}
]
}
resource "aws_security_group" "main" {
name = "core-sg"
vpc_id = aws_vpc.vpc.id
dynamic "ingress" {
for_each = local.ingress_rules
content {
description = ingress.value.description
from_port = ingress.value.port
to_port = ingress.value.port
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
}
}

Task 4: Look at the state with a dynamic block
Run a terraform apply followed by a terraform state list to view how the servers are accounted for in Terraform’s State.
terraform apply
terraform state list
aws_security_group.main
terraform state show aws_security_group.main
# aws_security_group.main:
resource "aws_security_group" "main" {
arn = "arn:aws:ec2:us-east-1:508140242758:security-group/sg-00157description = "Managed by Terraform"
egress = []
id = "sg-00157499a6de61832"
ingress = [
{
cidr_blocks = [
"0.0.0.0/0",
]
description = "Port 443"
from_port = 443
ipv6_cidr_blocks = []
prefix_list_ids = []
protocol = "tcp"
security_groups = []
self = false
to_port = 443
},
{
cidr_blocks = [
"0.0.0.0/0",
]
description = "Port 80"
from_port = 80
ipv6_cidr_blocks = []
prefix_list_ids = []
protocol = "tcp"
security_groups = []
self = false
to_port = 80
},
]
name = "core-sg"
owner_id = "508140242758"
revoke_rules_on_delete = false
tags = {}
tags_all = {}
vpc_id = "vpc-0e3a3d76e5feb63c9"
}

Task 5: Use a dynamic block with Terraform map
Rather then using the local values, we can refactor our dynamic block to utilize a variable named
web_ingress which is of map. Let’s first create the variable of type map, specifying some default
values for our ingress rules inside our variables.tf file.

variable "web_ingress" {
type = map(object(
{
description = string
port = number
protocol = string
cidr_blocks = list(string)
}
))
default = {
"80" = {
description = "Port 80"
port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
"443" = {
description = "Port 443"
port = 443
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
}
}
Then we will refactor our security group to use this variable rather then using local values.
resource "aws_security_group" "main" {
name = "core-sg"
vpc_id = aws_vpc.vpc.id
dynamic "ingress" {
for_each = var.web_ingress
content {
description = ingress.value.description
from_port = ingress.value.port
to_port = ingress.value.port
protocol = ingress.value.protocol
cidr_blocks = ingress.value.cidr_blocks
}
}
}
Task 6: Look at the state with a dynamic block using Terraform map
Run a terraform apply followed by a terraform state list to view how the servers are accounted for in Terraform’s State.
terraform state list
terraform state show aws_security_group.main
# aws_security_group.main:
resource "aws_security_group" "main" {
arn = "arn:aws:ec2:us-east-1:508140242758:security-group/sg-00157description = "Managed by Terraform"
egress = []
id = "sg-00157499a6de61832"
ingress = [
{
cidr_blocks = [
"0.0.0.0/0",
]
description = "Port 443"
from_port = 443
ipv6_cidr_blocks = []
prefix_list_ids = []
protocol = "tcp"
security_groups = []
self = false
to_port = 443
},
{
cidr_blocks = [
"0.0.0.0/0",
]
description = "Port 80"
from_port = 80
ipv6_cidr_blocks = []
prefix_list_ids = []
protocol = "tcp"
security_groups = []
self = false
to_port = 80
},
]
name = "core-sg"
owner_id = "508140242758"
revoke_rules_on_delete = false
tags = {}
tags_all = {}
vpc_id = "vpc-0e3a3d76e5feb63c9"
}

Best Practices
Overuse of dynamic blocks can make configuration hard to read and maintain, so it is recommend to
use them only when you need to hide details in order to build a clean user interface for a re-usable
module. Always write nested blocks out literally where possible

# 8h ## Terraform Graph
Terraform’s interpolation syntax is very human-friendly, but under the hood it builds a very powerful resource graph. When resources are created they expose a number of relevant properties and
Terraform’s resource graph allows it to determine dependency management and order of execution
for resource buildouts. Terraform has the ability to support the parallel management of resources
because of it’s resource graph allowing it to optimize the speed of deployments.
The resource graph is an internal representation of all resources and their dependencies. A humanreadable graph can be generated using the terraform graph command.
• Task 1: Terraform’s Resource Graph and Dependencies
• Task 2: Generate a graph against Terraform configuration using terraform graph
Task 1: Terraform’s Resource Graph and Dependencies
When resources are created they expose a number of relevant properties. Let’s look at portion of our
main.tf that builds out our AWS VPC, private subnets, internet gateways and private keys. In this
case, our private subnets and internet gateway are referencing our VPC ID and are therefore dependent
on the VPC. Our private key however has no dependencies on any resources.
resource "aws_vpc" "vpc" {
cidr_block = var.vpc_cidr
tags = {
Name = var.vpc_name
Environment = "demo_environment"
Terraform = "true"
}
enable_dns_hostnames = true
}
resource "aws_subnet" "private_subnets" {
for_each = var.private_subnets
vpc_id = aws_vpc.vpc.id
cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value)
availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
tags = {
Name = each.key
Terraform = "true"
}
}
resource "aws_internet_gateway" "internet_gateway" {
vpc_id = aws_vpc.vpc.id
tags = {
Name = "demo_igw"
}
}
resource "tls_private_key" "generated" {
algorithm = "RSA"
}
Because we have defined our infrastructure in code, we can build a data structure around it and then
work with it. Some of these nodes depend on data from other nodes which need to be spun up first.
Others might be disconnected or isolated. Our graph might look something like this, with the arrows
showing the the dependencies and order of operations.

Terraform walks the graph several times starting at the root node and using the providers: to collect
user input, to validate the config, to generate a plan, and to apply a plan. Terraform can determine
which nodes need to be created sequentially and which can be created in parallel. In this case our
private key can be built in parallel with our VPC, while our subnets and internet gateways are dependent
on the AWS VPC being built first.

Task 2: Generate a graph against Terraform configuration using terraform graph
The terraform graph command is used to generate a visual representation of either a configuration
or execution plan. The output is in the DOT format, which can be used by GraphViz to generate charts.
This graph is useful for visualizing infrastructure and dependencies. Let’s build out our infrastructure
and use terraform graph to visualize the output.
terraform init
terraform apply
terraform graph
digraph {
compound = "true"
newrank = "true"
subgraph "root" {
# ...
}
}
Paste that output into http://www.webgraphviz.com to get a visual representation of dependencies
that Terraform creates for your configuration.

We can find our resources on the graph and follow the dependencies, which is what Terraform does
everytime we exercise it’s workflow.

#8i ## Terraform Resource Lifecycles
Terraform has the ability to support the parallel management of resources because of it’s resource
graph allowing it to optimize the speed of deployments. The resource graph dictates the order in which
Terraform creates and destroys resources, and this order is typically appropriate. There are however
situations where the we wish to change the default lifecycle behavior that Terraform uses.
To provide you with control over dependency errors, Terraform has a lifecycle block. This lab
demonstrates how to use lifecycle directives to control the order in which Terraform creates and
destroys resources.
• Task 1: Use create_before_destroy with a simple AWS security group and instance
• Task 2: Use prevent_destroy with an instance

Task 1: Use create_before_destroy with a simple AWS security group and
instance
Terraform’s default behavior when marking a resource to be replaced is to first destroy the resource and
then create it. If the destruction succeeds cleanly, then and only then are replacement resources created. To alter this order of operation we can utilize the lifecycle directive create_before_destroy
which does what it says on the tin. Instead of destroying an instance and then provisioning a new one
with the specified attributes, it will provision first. So two instances will exist simultaneously, then the
other will be destroyed.
Let’s create a simple AWS configuration with a security group and an associated EC2 instance. Provision
them with terraform, then make a change to the security group. Observe that apply fails because
the security group can not be destroyed and recreated while the instance lives.
You’ll solve this situation by using create_before_destroy to create the new security group before
destroying the original one.
1.1: Add a new security group to the security_groups list of our server module
Add a new security group to the security_groups list of our server module by including
aws_security_group.main.id
module "server_subnet_1" {
source = "./modules/web_server"
ami = data.aws_ami.ubuntu.id
key_name = aws_key_pair.generated.key_name
user = "ubuntu"
private_key = tls_private_key.generated.private_key_pem
subnet_id = aws_subnet.public_subnets["public_subnet_1"].id
security_groups = [aws_security_group.vpc-ping.id, aws_security_group.ingress-ssh.id, }
}

Initialize and apply the change to add the security group to our server module’s security_groups
list.
terraform init
terraform apply

1.2: Change the name of the security group
In order to see how some resources cannot be recreated under the default lifecyle settings, let’s attempt to change the name of the security group from core-sg to something like core-sg-global.
resource "aws_security_group" "main" {
name = "core-sg-global"
vpc_id = aws_vpc.vpc.id
dynamic "ingress" {
for_each = var.web_ingress
content {
description = ingress.value.description
from_port = ingress.value.port
to_port = ingress.value.port
protocol = ingress.value.protocol
cidr_blocks = ingress.value.cidr_blocks
}
}
}

Apply this change.
terraform apply

Terraform used the selected providers to generate the following execution plan. Resource~ update in-place
-/+ destroy and then create replacement
Terraform will perform the following actions:
# aws_security_group.main must be replaced
-/+ resource "aws_security_group" "main" {
~ arn = "arn:aws:ec2:us-east-1:508140242758:security-group/sg-0~ egress = [] -> (known after apply)
~ id = "sg-00157499a6de61832" -> (known after apply)
~ name = "core-sg" -> "core-sg-global" # forces replacement
+ name_prefix = (known after apply)
~ owner_id = "508140242758" -> (known after apply)
- tags = {} -> null
~ tags_all = {} -> (known after apply)
# (4 unchanged attributes hidden)
}
# module.server_subnet_1.aws_instance.web will be updated in-place
~ resource "aws_instance" "web" {
id = "i-0fbb3100e8671a855"
tags = {
"Environment" = "Training"
"Name" = "Web Server from Module"
}
~ vpc_security_group_ids = [
- "sg-00157499a6de61832",
- "sg-00dc379cbd0ad7332",
- "sg-01fb306fc93cb941c",
- "sg-0e0544dac3596af26",
] -> (known after apply)
# (28 unchanged attributes hidden)
# (5 unchanged blocks hidden)
}
Plan: 1 to add, 1 to change, 1 to destroy.

Notice that the default Terraform behavior is to destroy then create this resource is shown by the
-/+ destroy and then create replacement statement.
Proceed with the apply.
Do you want to perform these actions?
Terraform will perform the actions described above.
Only 'yes' will be accepted to approve.
Enter a value: yes
NOTE: This action takes many minutes and eventually shows an error. You may choose to terminate
the apply action with ^C before the 15 minutes elapses. You may have to terminate twice to exit.
aws_security_group.main: Destroying... [id=sg-00157499a6de61832]
aws_security_group.main: Still destroying... [id=sg-00157499a6de61832, 10s elapsed]
aws_security_group.main: Still destroying... [id=sg-00157499a6de61832, 20s elapsed]
aws_security_group.main: Still destroying... [id=sg-00157499a6de61832, 30s elapsed]
....
aws_security_group.main: Still destroying... [id=sg-00157499a6de61832, 14m40s elapsed]
aws_security_group.main: Still destroying... [id=sg-00157499a6de61832, 14m50s elapsed]
aws_security_group.main: Still destroying... [id=sg-00157499a6de61832, 15m0s elapsed]
| Error: Error deleting security group: DependencyViolation: resource sg-00157499a6de618| status code: 400, request id: 80dc904d-9439-41eb-8574-4b173685e72f
|
|
This is occuring because we have other resources that are dependent on this security group, and
therefore the default Terraform behavior of destroying and then recreating the new security group is
causing a dependency violation. We can solve this by using the create_before_destroy lifecycle
directive to tell Terraform to first create the new security group before destroying the original.
1.3: Use create_before_destroy
Add a lifecycle configuration block to the aws_security_group resource. Specify that this resource should be created before the existing security group is destroyed.
resource "aws_security_group" "main" {
name = "core-sg-global"
vpc_id = aws_vpc.vpc.id
dynamic "ingress" {
for_each = var.web_ingress
content {
description = ingress.value.description
from_port = ingress.value.port
to_port = ingress.value.port
protocol = ingress.value.protocol
cidr_blocks = ingress.value.cidr_blocks
}
}
lifecycle {
create_before_destroy = true
}
}
Now provision the new resources with the improved lifecycle configuration.
terraform apply
Terraform used the selected providers to generate the following execution plan. Resourceindicated with the following symbols:
~ update in-place
+/- create replacement and then destroy
Terraform will perform the following actions:
# aws_security_group.main must be replaced
+/- resource "aws_security_group" "main" {
~ arn = "arn:aws:ec2:us-east-1:508140242758:security-group/sg-0~ egress = [] -> (known after apply)
~ id = "sg-00157499a6de61832" -> (known after apply)
~ name = "core-sg" -> "core-sg-global" # forces replacement
+ name_prefix = (known after apply)
~ owner_id = "508140242758" -> (known after apply)
- tags = {} -> null
~ tags_all = {} -> (known after apply)
# (4 unchanged attributes hidden)
}
# module.server_subnet_1.aws_instance.web will be updated in-place
~ resource "aws_instance" "web" {
id = "i-0fbb3100e8671a855"
tags = {
"Environment" = "Training"
"Name" = "Web Server from Module"
}
~ vpc_security_group_ids = [
- "sg-00157499a6de61832",
- "sg-00dc379cbd0ad7332",
- "sg-01fb306fc93cb941c",
- "sg-0e0544dac3596af26",
] -> (known after apply)
# (28 unchanged attributes hidden)
# (5 unchanged blocks hidden)
}
Plan: 1 to add, 1 to change, 1 to destroy.
Notice now that the Terraform behavior is to create then destroy this resource is shown by the
+/- create replacement and then destroy statement.
Proceed with the apply.
Do you want to perform these actions?
Terraform will perform the actions described above.
Only 'yes' will be accepted to approve.
Enter a value: yes
It should now succeed within a short amount of time as the new security group is created frist, applied
to our server and then the old security group is destroyed. Using the lifecyle block we controlled
the order in which Terraform creates and destroys resources, removing the dependency violation of
renaming a security group.
aws_security_group.main: Creating...
aws_security_group.main: Creation complete after 4s [id=sg-015f1eaa2c3f29f4c]
module.server_subnet_1.aws_instance.web: Modifying... [id=i-0fbb3100e8671a855]
module.server_subnet_1.aws_instance.web: Modifications complete after 5s [id=i-0fbb3100eaws_security_group.main (deposed object 5c96d2e2): Destroying... [id=sg-00157499a6de6183aws_security_group.main: Destruction complete after 1s
Apply complete! Resources: 1 added, 1 changed, 1 destroyed.
Task 2: Use prevent_destroy with an instance
Another lifecycle directive that we may wish to include in our configuraiton is prevent_destroy. This
warns if any change would result in destroying a resource. All resources that this resource depends on
must also be set to prevent_destroy. We’ll demonstrate how prevent_destroy can be used to
guard an instance from being destroyed.
2.1: Use prevent_destroy
Addprevent_destroy = trueto the samelifecyclestanza where you addedcreate_before_destroy.
resource "aws_security_group" "main" {
name = "core-sg-global"
# ...
lifecycle {
create_before_destroy = true
prevent_destroy = true
}
}
Attempt to destroy the existing infrastructure. You should see the error that follows.
terraform destroy -auto-approve
Error: Instance cannot be destroyed
on main.tf line 378:
378: resource "aws_security_group" "main" {
Resource aws_security_group.main has lifecycle.prevent_destroy set, but the plan calls 2.2: Destroy cleanly
Now that you have finished the steps in this lab, destroy the infrastructure you have created.
Remove the prevent_destroy attribute.
resource "aws_security_group" "main" {
name = "core-sg-global"
# ...
lifecycle {
create_before_destroy = true
# Comment out or delete this line
# prevent_destroy = true
}
}
Finally, run destroy.
terraform destroy -auto-approve
The command should succeed and you should see a message confirming Destroy complete!
The prevent_destroy lifecycle directive can be used on resources that are stateful in nature (s3
buckets, RDS instances, long lived VMs, etc.) as a mechanism to help prevent accidently destroying
items that have long lived data within them.


