param gwSubnetId string
param certLink string
param location string
param weatherApiFQDN string
param customDomainWeatherApiFQDN string
param identityId string

var suffix = uniqueString(resourceGroup().id)
var appgwName = 'appgwprv-${suffix}'

resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
    name: 'gwpip'
    location: location
    sku: {
        name: 'Standard'
    }
    properties: {
        publicIPAddressVersion: 'IPv4'
        publicIPAllocationMethod: 'Static'
        idleTimeoutInMinutes: 4
    }
}

resource appgw 'Microsoft.Network/ApplicationGateways@2020-06-01' = {
    name: appgwName
    location: location
    dependsOn: [
        pip
    ]
    identity: {
        type: 'UserAssigned'
        userAssignedIdentities: {
            '${identityId}': {}
        }
    }
    properties: {
        sku: {
            name: 'WAF_v2'
            tier: 'WAF_v2'
            capacity: 2            
        }
        autoscaleConfiguration: {
          minCapacity: 1
          maxCapacity: 10
        }
        gatewayIPConfigurations: [
            {
                name: 'appGatewayConfig'
                properties: {
                    subnet: {
                        id: gwSubnetId
                    }
                }
            }
        ]
        sslCertificates: [
            {
                name: 'wild'
                properties: {
                    keyVaultSecretId: certLink
                }
            }
        ]
        trustedRootCertificates: []
        frontendIPConfigurations: [
            {
                name: 'appGwPublicFrontendIp'
                properties: {
                    privateIPAllocationMethod: 'Dynamic'
                    publicIPAddress: {
                        id: pip.id
                    }
                }
            }
        ]
        frontendPorts: [
            {
                name: 'port_443'
                properties: {
                    port: 443
                }
            }
        ]
        backendAddressPools: [
            {
                name: 'weatherApiPool'
                properties: {
                    backendAddresses: [
                        {
                            fqdn: weatherApiFQDN
                        }
                    ]
                }
            }     
        ]
        backendHttpSettingsCollection: [
            {
                name: 'https-setting'
                properties: {
                    port: 443
                    protocol: 'Https'
                    cookieBasedAffinity: 'Disabled'
                    pickHostNameFromBackendAddress: true
                    requestTimeout: 20
                    probe: {
                        id: resourceId('Microsoft.Network/applicationGateways/probes',appgwName,'weatherApiProbe')
                    }
                }
            }                        
        ]
        httpListeners: [
            {
                name: 'https-listener'
                properties: {
                    frontendIPConfiguration: {
                        id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appgwName, 'appGwPublicFrontendIp')
                    }
                    frontendPort: {
                        id: resourceId('Microsoft.Network/applicationGateways/frontendPorts',appgwName,'port_443')
                    }
                    sslCertificate: {
                        id: resourceId('Microsoft.Network/applicationGateways/sslCertificates',appgwName,'wild')
                    }
                    hostName: customDomainWeatherApiFQDN
                    protocol: 'Https'
                    requireServerNameIndication: true
                }
            }                  
        ]
        requestRoutingRules: [
            {
                name: 'http-routingrule'
                properties: {
                    ruleType: 'Basic'
                    httpListener: {
                        id: resourceId('Microsoft.Network/applicationGateways/httpListeners',appgwName,'https-listener')
                    }
                    backendAddressPool: {
                        id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools',appgwName,'weatherApiPool')
                    }
                    backendHttpSettings: {
                        id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection',appgwName,'backendHttpSettingsCollection')
                    }
                }
            }                              
        ]
        probes: [
            {
                name: 'weatherApiProbe'
                properties: {
                    protocol: 'Https'                    
                    path: '/healthz'
                    interval: 30
                    timeout: 30
                    unhealthyThreshold: 3
                    pickHostNameFromBackendHttpSettings: true
                    minServers: 0
                    match: {}
                }
            }                
        ]
        enableHttp2: false
        webApplicationFirewallConfiguration: {
            enabled: true
            firewallMode: 'Prevention'
            ruleSetType: 'OWASP'
            ruleSetVersion: '3.1'
            requestBodyCheck: true
            maxRequestBodySizeInKb: 128
            fileUploadLimitInMb: 100
            disabledRuleGroups: [
                {
                    ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
                    rules: [                        
                        942200
                        942100
                        942110
                        942180
                        942260
                        942340
                        942370
                        942430
                        942440                        
                    ]
                }
                {
                    ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
                    rules: [                        
                        920300
                        920330                     
                    ]
                }   
                {
                    ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
                    rules: [                        
                        931130                                             
                    ]
                }                                    
            ]
        }        
    }
}
