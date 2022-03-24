# Introduction

The purpose of this demo is to illustrate a common setup leveraging App Service Environment v3 with the hub and spoke networking architecture.

The App Service Environment will be of type internal, all ingress will be thru Azure Application Gateway with WAF and all egress thru the Azure Firewall.

# Prerequisites

First step is to Fork this repository.

Next, you will need to have a public domain name and a wildcard certificate. 

If you already own a public domain below some step to create a wildcard certificate using [Azure DNS Public Zone](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-portal).

# Generating SSL certificate with Azure DNS Public Zone

Here the tool you need to installe on your machine.

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

- [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1)

- Install the official [Powershell](https://github.com/rmbolger/Posh-ACME) **Let's Encrypt client**

Here the [list](https://letsencrypt.org/docs/client-options/) of all supported clients if you want to implement your own logic for the **Let's Encrypt Certificate**.

### Create Azure DNS Public Zone

This demo is using Azure Public DNS Zone, you will need to have a domain that you own from any register.  Once is done you need to configure your DNS in your domain register with Azure DNS Public Zone entry.

It's all explain [here](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-portal).


### Run this step ONLY if you don't have a SSL certificate

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

Be sure your **Service Principal** have access to modify your Azure Public DNS Zone.  If you want to use least priviledge refer to this [doc](https://github.com/rmbolger/Posh-ACME/blob/main/Posh-ACME/Plugins/Azure-Readme.md#create-a-custom-role).

*Be sure the username, password and certificate password are in double quotes**

When the command is finished, a new folder called **pa** will be created inside the scripts folder.

If you browse in it inside the last child folder of **acme-v02.api.letsencrypt.org** you will see those files. The important file is called cert.pfx.

# Get the base64 encoded value of your certificate

You will need to create GitHub secrets to configure this repository.  Two of them are related to your certificate needed to have SSL when communicating with the Application Gateway.

You will need to find the base64 value of your certificate and save it as

```
$fileContentBytes = get-content 'cert.pfx' -Encoding Byte
```

```
[System.Convert]::ToBase64String($fileContentBytes) | Out-File 'pfx-bytes.txt'
```

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