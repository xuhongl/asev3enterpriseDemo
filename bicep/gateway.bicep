param gwSubnetId string
param location string
param weatherApiFQDN string
param customDomainWeatherApiFQDN string
param identityId string

param certificate_data string
param certificate_password string

var suffix = uniqueString(resourceGroup().id)
var appgwName = 'appgwprv-${suffix}'

var appGwId = resourceId('Microsoft.Network/applicationGateways',appgwName)

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
                    data: certificate_data
                    password: certificate_password
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
                name: 'https-settings'
                properties: {
                    port: 443
                    protocol: 'Https'
                    cookieBasedAffinity: 'Disabled'
                    pickHostNameFromBackendAddress: true
                    requestTimeout: 20
                    probe: {                                                
                        id: '${appGwId}/probes/weatherApiProbe'
                    }
                }
            }                        
        ]
        httpListeners: [
            {
                name: 'https-listener'
                properties: {
                    frontendIPConfiguration: {
                        id: '${appGwId}/frontendIPConfigurations/appGwPublicFrontendIp'
                    }
                    frontendPort: {
                        id: '${appGwId}/frontendPorts/port_443'
                    }
                    sslCertificate: {
                        id: '${appGwId}/sslCertificates/wild'
                    }
                    hostName: customDomainWeatherApiFQDN
                    protocol: 'Https'
                    requireServerNameIndication: true
                }
            }                  
        ]
        requestRoutingRules: [
            {
                name: 'https-rule'
                properties: {
                    ruleType: 'Basic'
                    httpListener: {
                        id: '${appGwId}/httpListeners/https-listener'
                    }
                    backendAddressPool: {
                        id: '${appGwId}/backendAddressPools/weatherApiPool'
                    }
                    backendHttpSettings: {
                        id: '${appGwId}/backendHttpSettingsCollection/https-settings'
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
