- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Generate SSL Certificat](#generating-ssl-certificate-with-azure-dns-public-zone-(optional))
  - [Create Azure DNS Public Zone](#create-azure-dns-public-zone)
  - [Run the Powershell script](#run-the-powershell-script)
- [Create the environment](#create-the-environment)
  - [Get the base64 encoded value of your certificate](#get-the-base64-encoded-value-of-your-certificate)

# Introduction

The purpose of this demo is to illustrate a common setup leveraging App Service Environment v3 (ASE) with a hub and multiple spokes.

The App Service Environment will be of type internal, all ingress will be going into Azure Application Gateway with WAF and all egress thru the Azure Firewall when they need to consume other resources from other spokes or the Internet.

# Architecture

This diagram illustrates the architecture for this demo repository.  The networking topology used its [hub and spoke](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli).

<img src=https://raw.githubusercontent.com/hugogirard/asev3enterpriseDemo/main/diagram/architecture.png />

Here you have two APIs hosted in the ASE, the Weather API doesn't consume any other Azure Resources and doesn't egress thru the firewall.  

The fibonacci API will calculate a [fibonacci number](https://en.wikipedia.org/wiki/Fibonacci_number) based on a len passed in parameters.

Before calculating the sequence, the API will validate if the result its present in an Azure Redis Cache.  If it's the case, no calculation will be done at the API level and the cached result will be returned.

If the sequence is not present in the cache, it will be calculated and saved in the cache for future reference. 

When retrieving/writing values from the cache, all traffic will go thru the Azure Firewall.  **Neither spoke is peered together, all the traffic between them flow thru the Azure Firewall.**

# Prerequisites

First step is to Fork this repository.

Next, you will need to have a public domain name and a wildcard certificate. 

If you already own a public domain but you don't have a wild certificate here some step to create one using [Azure DNS Public Zone](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-portal).

# Generating SSL certificate with Azure DNS Public Zone (optional)

Here the tool you need to installe on your machine.

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

- [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1)

- Install the official [Powershell](https://github.com/rmbolger/Posh-ACME) **Let's Encrypt client**

Here the [list](https://letsencrypt.org/docs/client-options/) of all supported clients if you want to implement your own logic for the **Let's Encrypt Certificate**.

## Create Azure DNS Public Zone

This demo is using Azure Public DNS Zone, you will need to have a domain that you own from any register.  Once it is done, you need to configure your DNS in your domain register with Azure DNS Public Zone entry.

It all explain [here](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-portal).


## Run the Powershell script

Be sure you already configured your **Azure Public DNS Zone**.

First create a service principal running the following command.

```Bash
$ az ad sp create-for-rbac --name <ServicePrincipalName> --sdk-auth --role contributor
```

Take note of the output you will need it to create Github Secrets.

Now go to the folder scripts, there you have a powershell called **letsEncrypt.ps1**.

This script will connect to your Azure Subscription passed in parameters and create a **TXT** challenge in your **Azure DNS Public Zone**.  

First run this command in a PowerShell terminal

```bash
$ Set-PAServer LE_PROD
```

Now with the information retrieved when you created the **service principal** you can create your certificate.

Be sure your **Service Principal** have access to modify your Azure Public DNS Zone.  If you want to use least privilege refers to this [doc](https://github.com/rmbolger/Posh-ACME/blob/main/Posh-ACME/Plugins/Azure-Readme.md#create-a-custom-role).

*Be sure the username, password and certificate password are in double quotes**

When the command is finished, a new folder called **pa** will be created inside the scripts folder.

If you browse in it inside the last child folder of **acme-v02.api.letsencrypt.org** you will see those files. The important file is called cert.pfx.

# Create the Azure Resources

## Get the base64 encoded value of your certificate

You will need to create GitHub secrets to configure this repository.  Two of them are related to your certificate and needed when communicating with the Application Gateway.

You will need to find the base64 value of your certificate and save it in a GitHub Secret.  To do so run the following command and get the value from the text file generated.

```
$fileContentBytes = get-content 'cert.pfx' -Encoding Byte
[System.Convert]::ToBase64String($fileContentBytes) | Out-File 'pfx-bytes.txt'
```

## Create Github Secrets

You will need to create some [GitHub repository secrets](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-encrypted-secrets-for-your-repository-and-organization-for-codespaces#adding-secrets-for-a-repository) first.  Here the list of secrets you will need to create.

| Secret Name | Value | Link
|-------------|-------|------|
| AZURE_CREDENTIALS | The service principal credentials needed in the Github Action | [GitHub Action](https://github.com/marketplace/actions/azure-login)
| AZURE_SUBSCRIPTION | The subscription ID where the resources will be created |
| CERTIFICATE_DATA | The base64 value of your pfx certificate file |
| CERTIFICATE_PASSWORD | The password of your pfx file |
| CUSTOM_DOMAIN_FIBONACCI_API | The custom domain of the fibonacci API like fibonacciapi.contoso.com |
| CUSTOM_DOMAIN_WEATHER_API | The custom domain of the weather API like weatherapi.contoso.com |
| PA_TOKEN | Needed to create GitHub repository secret within the GitHub action |  [Github Action](https://github.com/gliech/create-github-secret-action)
| VM_PASSWORD | The password needed for the Github Self Runner |
| VM_USERNAME | The username needed for the Github Self Runner |

## Run Create Azure Resources GitHub Action

Now you can go to the Actions tab and Run the Create Azure Resources [GitHub Actions](https://docs.github.com/en/actions).

This GitHub Action can take up to 3 hours to run.  Once is completed you should have 3 resources groups created in Azure.



## Configure the Github Runner

Because the Application Service Environment is of type internal, you will need to deploy the APIs using [GitHub Self Runner](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners).

Connect to VM created in the resource group and follow the installation procedure.

If you want to run the runner agent as a service (recommended) follow this [link](https://docs.github.com/en/actions/hosting-your-own-runners/configuring-the-self-hosted-runner-application-as-a-service) after the installation.

<!-- # asev3enterpriseDemo
Github with ASEv3 implemented Enterprise edition

# Associate Route Table
Associate route table to subnet

# Create DNAT rule 

| Source | Port | Protocol | Destination | Translated Address | Translated Port | Action |
|--------|------|----------|-------------|--------------------|-----------------|--------|
*|443|TCP| Public Firewall IP | Public External ASE IP | 443 | Dnat

# Add in your DNS those entries

If you modify you Windows Host go to

c:\windows\system32\drivers\etc\hosts

You will need to add something like this, the public IP represent your firewall IP

#20.121.185.68 helloworldhg2.asehgtest.p.azurewebsites.net
#20.121.185.68 helloworldhg2.scm.asehgtest.p.azurewebsites.net
#20.121.185.68 asehgtest.scm.p.azurewebsites.net -->