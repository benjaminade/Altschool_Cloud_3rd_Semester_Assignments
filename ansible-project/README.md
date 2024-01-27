The Assignment:

How can I create and configure an AWS EC2 instance using Ansible? I need to set up a basic EC2 instance with the following specifications:
    -Create your own vpc
    -Region: eu-west-1
    -Instance Type: t2.micro
    -AMI ID: A latest Amazon Linux 2 AMI (AMI ID may vary based on    the region)
    -Security Group: A security group allowing SSH (port 22) and HTTP (port 80) access
    -Key Pair: Use an existing key pair named MyKeyPair, created with Ansible
Additionally, I would like to install and start a web server (Apache or Nginx) on this instance once it is up and running.

Solution:

There are two plays in this singular playbook: 
Play1: Create an aws ec2 using ansible
Play2: Configure the EC2 instance by installing and starting apache on the instance.

Prerequisites: For Ansible to be able to communicate or interact with aws, 
install:
    - ansible
    - boto3 >= 1.26.0 : python library for interacting with aws
    - botocore >= 1.29.0
    - aws cli
    - pyhton >= 3.6


Ansible modules: 
    These are standalone scripts or programs that perform specific task on manged nodes. They are the building blocks of playbooks. When you write ansible playbooks, you are defining a series of tasks that are executed on the managed nodes.
    
    Each task corresponds to the invocation of a specific module to carry out certain action such as installing packages, copying files etc. Without modules, there would be no way for ansible to execute tasks and perform desired automation on the tareget systems.

    There are various categories of modules based on their fuctionality. Examples include 
        - system modules
        - command modules
        - database modules
        - network modules
        - cloud modules ( for interacting with cloud services e.g AWS, Azure etc0)
        - utilities modules
        - security modules 
        - and so on...

    For the purpose of this project, we shall be making use of some of these module categories, and most especially on the cloud modules.

    To use cloud modules in ansible, be sure that you have them installed. Cloud modules are part of "ansible collections" structure, typically organized by cloud providers.

    So, to get cloud modules, install the required collections For this project, the required cloud module collection is amazon.aws and can be installed by running the command below on your local host:

    ansible-galaxy collection install amazon.aws

    
