# NEW YORK CITY TAXI DATA PIPELINE WITH AZURE AND TERRAFORM

## Project Description

The [New York City (NYC) yellow taxi trip database](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) is a famous dataset with more than 1.6 billion records spanning from January 2009 to October 2022 (and counting). In its current version, all data is available through parquet files.

This project aims to create a Data Engineering pipeline to collect all these parquet files and save them in an Azure Data Lake Storage Gen2 folder, organized by year and month. From there, other analytical tools can manipulate and serve the data. For example, an Azure Synapse Analytics serverless SQL pool can create an external table with this data, and Power BI could connect to this external table and then present visualizations from the NYC yellow taxi trips.

We used an Azure Data Factory pipeline to connect to the NYC taxi trip website and save the parquet files later in the Data Lake. Besides, all the infrastructure needed to complete this project is deployed by Terraform, currently one of the most popular tools for Infrastructure as Code (IaC). 

## REQUIRED SUBSCRIPTIONS AND PROGRAMS

* One active Azure subscription 
* Azure CLI (to run commands in a Linux terminal)
* Terraform

## FIRST STEPS

```sh
# clone the repository
git clone https://github.com/fabricius1/nyc-taxi-pipeline.git

# move into the folder
cd nyc-taxi-pipeline

# copy this file with a new name
cp template_tfvars.txt terraform.tfvars

# login to Azure using Azure CLI
az login

# initialize Terraform
terraform init

# run terraform validate
terraform validate
```

## CONFIGURING SENSITIVE VARIABLES IN THE `terraform.tfvars` FILE

Open the `terraform.tfvars` file. There are seven Terraform variables there, all them of the string type.

Don't change the value for `adlsg2_key` yet. We will only have this information after we create the data lake together with the other Azure resources.

Choose a value for `adminuser` and `password`. These will be used for SQL logins in the Azure synapse analytics workspace. Remember that these and other sensitive information will be stored in plain text by Terraform inside the future `terraform.tfstate` file. Thus, be really careful with it and with the `terraform.tfvars` files.

Below there are some extra Azure CLI commands. The first two commands will help you to choose valid, available names for both your storage account and synapse analytics workspace. The last two will print on the terminal the user object id and tenant id for the current user logged in Azure CLI.

```sh
# check if a storage account name is available
az storage account check-name --name "your-adls2-name"

# check if an Azure synapse analytics workspace name is available
az synapse workspace check-name --name "your_synapse_name"

# get current user object id
az ad signed-in-user show --query id --output tsv

# get current user tenant id (REPLACE your_email@email.com FOR YOUR OWN EMAIL)
az account list --query "[?contains(user.name, 'your_email@email.com')].tenantId" --output tsv
```

## RUN TERRAFORM TO DEPLOY THE AZURE RESOURCES

The following Terraform commands will deploy the 16 resources we will need to run our pipeline.

```sh
# run terraform commands
terraform fmt
terraform plan -out=plan.out

# command to deploy the resources in Azure. This will take a few minutes 
terraform apply plan.out
```

Now, run the command below to print the storage account first access key. Again, be very careful with that information, since it gives full access to all content in your storage account.

```sh
# run this command to print, on your terminal, the storage account primary access key
# (REPLACE <YOUR_STORAGE_ACCOUNT_NAME> FOR THE CORRECT INFO)
az storage account keys list -n <YOUR_STORAGE_ACCOUNT_NAME> --query "[0].value" --output tsv
```

Copy this key and paste it in the `terraform.tfvars` file, as value for the `adlsg2_key` Terraform variable.

Now, we need to run Terraform again, so that the correct storage account key information be saved in the correspondent Data Factory linked service. Thus, only one resource will be updated now.

```sh
terraform plan -out=plan.out
terraform apply plan.out
```

## RUN THE PIPELINE

Using the Azure portal, open the Azure Data Factory Studio. Locate the `pl_main` pipeline and run it.

Then, open the Data Lake and, in `containers`, locate the `1-raw/yellow_tripdata` folder. Refresh this page and check how the parquet files will be saved there. Once the pipeline finishes running, you will have new folders, from 2009 to 2022 and, inside them, one parquet file per month.
