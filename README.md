# asev3enterpriseDemo
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
#20.121.185.68 asehgtest.scm.p.azurewebsites.net