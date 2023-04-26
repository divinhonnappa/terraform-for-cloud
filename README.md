## Terraform-on-cloud-basic-starter
Terraform starter kit to get started on any or all 3 major cloud providers AWS, Azure and GCP
In terms of cost, this can be done on Azure and Google cloud for free using the credits provided on both of these platforms.
There will be a very small charge on AWS if testing multiple times


## Credentials
From the cloud console get the credentials for the account

### aws credentials
    Get aws credentials from aws console
        aws_access_key = "******************"
        aws_secret_key = "***************************************"

### google credentials
    Create service account and download the credentials file for the service account.
        google_credentials_file = ""
        google_project_id       = ""

### azure credentials
    Refer to [azurerm guide by terraform](https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html) to avoid unauthorized Service Principal error
        azure_subscription_id = ""
        azure_client_id       = ""
        azure_client_secret   = ""
        azure_tenant_id       = ""

## Usage
### Variables - not related to credentials
    Update the terraform.tfvars 

    `cloud_platform` variable is created as a list of strings with no default and expects to be passed during terraform apply.
    The user can provide one or more among "aws", "azure" and "google" as an input to this variable.
    Based on the input respective cloud module will set a local variable is_"${cloud}" to 1 or 0.
    This local variable is used to set the count of resources. If the local variable is set to 1, 
    then one set resources of all the resources defined in the modules will be created and 0 would mean
    do not create resource or delete created resources.

    # Warning!!!! - What would delete resources other than destroy
    1. Running a `terraform apply` with an empty list `[]` will delete all the provisioned resources
    even though you are doing an apply.
    2. Creating resource on one platform e.g., passing ["azure"] for `cloud_platform` during first run
    of terraform apply and then running `terraform apply` with ["aws","google"] for `cloud_platform` will delete resources on azure.
    Reason: since we use this `cloud_platform` to count number of resources and count will be set to 0
    if the platform is not passed, resulting in destroying the resources. 

### Custom application image
    User would need to create a custom image with the contents of the simple-python3-app deployed at
    /home/ubuntu/app/ on the instance along with creating ssh keys for and updating public key inside authorized keys.
    All the three modules have a variable with suffix ""_instance_key_location. Update them with 
    respective key location strings and terraform will start the app and output the final ip 
    from where you can access the simple app deployed on the cloud.

### Final terraform steps
    Nothing out of ordinary here. `terraform init`, `terraform plan` (always a good practice to view what is changing), 
    terraform apply and terraform destroy (Don't forget to destroy resources once you are done. 
    Also validate once in the console that nothing was left out by terraform.) 
