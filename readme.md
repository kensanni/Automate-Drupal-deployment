# Deploying and securing a Drupal and CiviCRM application on AWS

This documentation below simply explain how I deploy and secure my drupal with CiviCRM application on AWS.

## Tools used

Below are the tools I used for deploying my drupal application
 - [`Terraform`](https://www.terraform.io/) - This is an infrastructure as code software by [`Hashicorp`](https://www.hashicorp.com/). It allows users to define a data center infrastructure in a high-level configuration language, from which it can create an execution plan to build the infrastructure in a service provider such as [`AWS`](https://aws.amazon.com), [`Google cloud platform`](http://cloud.google.com), [`Microsoft Azure`](https://azure.microsoft.com/en-us/?v=solutions-dropdown) e.t.c.
 - [`Ansible`](https://www.ansible.com/) - This is an open source software that automates software provisioning, configuration management, and application deployment. Ansible connects via SSH, remote PowerShell or via other remote APIs.

 - [`Packer`](https://packer.io/) - This is an open source tool for creating identical machine images for multiple platforms from a single source configuration. Packer is lightweight, runs on every major operating system, and is highly performant, creating machine images for multiple platforms in parallel.
 - [`LetsEncrypt`](https://letsencrypt.org/) - This is a free, automated and open Certificate Authority. I'm using this to generate a free SSL certificate for my application.
 - [`Nginx`](https://www.nginx.com/) - This is an open source software for web serving, reverse proxying, caching, load balancing, media streaming, and more. It started out as a web server designed for maximum performance and stability
 - [`Drupal`](https://www.drupal.org/) - Drupal is a free and open source content management framework written in PHP and distributed under the GNU General Public License. Drupal provides a back-end framework for at least 2.3% of all websites worldwide ranging from personal blogs to corporate, political, and government sites. Systems also use Drupal for [`knowledge management`](https://en.wikipedia.org/wiki/Knowledge_management) and for business collaboration.
 - [`CiviCRM`](https://civicrm.org/) - This is a web-based, open source, internationalized suite of computer software for constituency relationship management, that falls under the broad rubric of [`customer relationship management`](https://en.wikipedia.org/wiki/Customer_relationship_management). It is specifically designed for the needs of non-profit, non-governmental, and advocacy groups, and serves as an association management system.
  
   Basically, I'm using Packer to create a machine image with Ansible as the provisioner. A machine image is a single static unit that contains a pre-configured operating system and installed software which is used to quickly create new running machines. So I use Terraform to launch an instance with the machine Image on AWS.

## Prerequisites
This walkthrough was run on a MacOS but irrespective of your OS, this guide assumes the following

- Basic Linux skills
- Terraform, Packer and Ansible installed on your machine
- A domain name to use for SSL certificate
- AWS access and secret key

## Getting Started
Follow the instruction below to set up this infrastructure on your AWS account.

1. Clone the project into your local machine
    ```
    git clone 
    cd project-task
    ```
2.  Export your AWS credentials to environment variables
    ```
    export AWS_ACCESS_KEY= YOUR_AWS_ACCESS_KEY
    export AWS_SECRET_KEY= YOUR AWS_SECRET_KEY
    ```
3.  Create a machine image for both the database and Drupal application
    
    **For the database image**
   
    1. cd into the database image directory
        ```
        cd images/database
        ```
    2. Open the `database.yml` file and edit the vars to suit your needs
        ```
          vars:
            db_user: "database_user"
            db_password: "database_password"
            civicrm_db_name: "Civicrm_database_name"
            drupal_db_name: "Drupal_database_name"
            priv: "drupal.*:ALL/civicrm.*:ALL"
            root_db_password: "Your_root_password"
        ```
        This would create a database with the credentials specified above.
    3.  Open and edit the `database/roles/secureMysql/templates/.my.cnf` file to read your `root_db_password` as shown below
        ```
          [client]
          user=root
          password=your_root_db_password
        ```

    4. create the database image by running the command below
        ```
        packer build database.json
        ```

    **For the Drupal application image**

    1. cd into the drupalClient image directory
        ```
        cd images/drupalClient
        ```
    2. Open the `images/drupalClient/roles/nginxConfig/templates/nginx.conf` file and edit the `server_name` to your domain name
        ```
          server_name your_domain_name.com;
        ```
    3. create the Drupal image by running the command below
        ```
          packer build drupal.json
        ```
4. Deploy the infrastructure to AWS with terraform. Follow the step below to do that

    1. move into the terraform directory
        ```
          cd terraform
        ```
    2. Create a new file named `terraform.tfvars` and paste the code below
        ```
         access_key = "Your aws_access_key"
         secret_key = "Your aws_secret_key"
         public_key = "your public ssh key"
        ```
        To generate an ssh key, run the command below
        ```
        ssh-keygen
        ```
        Don't ever push this file or your AWS credentials to Github.
    3. Open the variables.tf and edit the `key_name` variable to the name of your public key as shown below
        ```
          variable "key_name" {
            description = "compucorp key pair"
            default     = "name_of_public_key"
          }
        ```
    4. Initialize terraform by running `terraform init` command

    5. Run `terraform plan` to see the resources that would be created on your AWS

    6. Run `terraform apply` to create the infrastructure on AWS.

        This would also print out the IP address of your database and Drupal application on your terminal, Copy and paste the `Drupal instance DNS or IP address` into your browser and follow the instruction to setup Drupal. Or you can log in into aws console and click on the `US East (Ohio)` to see the details of your instance.
5. Install the `CiviCRM` modules. Follow the instructions below to do that

     1. On your drupal homepage, click on `Modules` at the top navbar of your homepage
     2. click on the `Install new module` link
     3. paste the link below into the `Install from a URL` textbox
        ```
         https://download.civicrm.org/civicrm-5.6.0-drupal.tar.gz
        ```
     4. Click on the `Install`
     5. To activate the modules, go to `your_drupal_ip_address/sites/all/modules/civicrm/install/index.php` to activate the civicrm and fill in the box to suit your needs.

        Ensure the database credentials are correct for both CiviCRM and Drupal database.

        You need to `SSH` into your instance and grant this folder `/usr/share/nginx/html/drupal/drupal-7.60/sites/default` a write access
        ```
        ssh -i "your_ssh_key.pem" ubuntu@your_drupal_ip_address
        sudo chmod u+w /usr/share/nginx/html/drupal/drupal-7.60/sites/default
        ```
        Refresh your browser.
6. Setup SSL certificate for the domain. To set up HTTPS, ensure your IP address is mapped to your domain name then SSH into your server and run the command below
    
    ```
    sudo certbot --nginx -d your_domain_name -d www.your_domain_name
    ```
7.  Modify the Drupal settings files so that Drupal views can use the CiviCRM database. Follow the steps below
        
    1. Go to Drupal homepage and click on `Modules` at the top navbar
    2. click on `Install new module` link and paste the link below into the `Install from a  URL` text field to install `ctools` module
        ```
        https://ftp.drupal.org/files/projects/ctools-7.x-1.14.tar.gz
        ```
    3. Repeat the process above but change the link as specified below to install `views` modules
        ```
        https://ftp.drupal.org/files/projects/views-7.x-3.18.tar.gz
        ```
    4. Enable the `ctools` module by selecting the `Chaos tools` options under the `CHAOS TOOL SUITE` section and save the configuration

    5. Enable the `views` modules by selecting all the `Views` options under `VIEWS` section and save the configuration.
    
    6. Click on this [`Drupal view`](https://docs.civicrm.org/sysadmin/en/latest/integration/drupal/views/) to complete the setup.
    
8. Backup the database and upload backup data to Amazon S3 storage. Follow the steps below to do that

    1. SSH into the database instance
        ```
        ssh -i "your_ssh_key.pem" ubuntu@your_database_ip_address
        ```
    2. Create a new file named `.mylogin.cnf` and paste the code below
        ```
        [client]
        user = root
        password = Your MySQL root user's password
        ```
    3. Create a new directory named backups
        ```
        mkdir backups
        ```

    4. Run the `crontab -e` command and paste the code below
        ```
        57 23 * * * /usr/bin/mysqldump --defaults-extra-file=/home/ubuntu/.mylogin.cnf -u root --single-transaction --quick --lock-tables=false --all-databases > backups/full-backup-$(date +\%F).sql
        ```

        This means a backup would be created every day at 23:59 hours
    5. To deploy the backup file to Amazon S3 storage, run the `aws configure` command, This would ask for your aws access and secret key.
    6. Create a new `s3 bucket` to save the backup's by running the command below
        ```
        aws s3 mb s3://your-bucket-name
        ```
    7. With this in place, we want to make sure our backup is uploaded regularly. Run the `crontab -e` command again and add the code below to the file
        ```
        59 23 * * * /home/ubuntu/.local/bin/aws s3 cp backups  s3://your-bucket-name/ --recursive
        ```

        This would always upload our backup data to AWS S3 every day at 23:59 hours


