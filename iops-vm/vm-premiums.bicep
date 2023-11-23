// parameters
param location string = 'eastus'
param adminName string = 'serveradmin'
@secure()
param adminPass string

// variables
var resourcePrefix = 'fastbox-iops-'

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: '${resourcePrefix}vnet'
  location: location
  properties:{
    addressSpace:{
      addressPrefixes:[
          '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties:{
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'Default'
        properties:{
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource bastionPIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: '${resourcePrefix}bastion-pip'
  location: location
  sku:{
    name: 'Standard'
  }
  properties:{
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    deleteOption: 'Delete'    
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2023-05-01' = {
  name: '${resourcePrefix}bastion'
  location: location
  sku: {
    name: 'Standard'
  }  
  properties:{
    disableCopyPaste: false
    enableFileCopy: true   
    enableTunneling: true 

    ipConfigurations:[
      {
        name: 'bastionIpConfig'
        properties:{
          subnet:{
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress:{
            id: bastionPIP.id
          }
        }
      }
    ]
  }
}

resource disk1 'Microsoft.Compute/disks@2023-04-02' = {
  name: '${resourcePrefix}premiumv2-disk1'
  location: location
  sku:{
    name: 'PremiumV2_LRS'
  }
  zones: [
    '1'
  ]
  properties:{    
    diskSizeGB: 1024
    diskIOPSReadWrite: 80000
    diskMBpsReadWrite: 1200
    creationData:{
      createOption: 'Empty'
    }
  }
}

resource disk2 'Microsoft.Compute/disks@2023-04-02' = {
  name: '${resourcePrefix}premiumv2-disk2'
  location: location
  sku:{
    name: 'PremiumV2_LRS'
  }
  zones: [
    '1'
  ]
  properties:{    
    diskSizeGB: 1024
    diskIOPSReadWrite: 80000
    diskMBpsReadWrite: 1200
    creationData:{
      createOption: 'Empty'
    }
  }
}


resource disk3 'Microsoft.Compute/disks@2023-04-02' = {
  name: '${resourcePrefix}premiumv2-disk3'
  location: location
  sku:{
    name: 'PremiumV2_LRS'
  }
  zones: [
    '1'
  ]
  properties:{    
    diskSizeGB: 1024
    diskIOPSReadWrite: 80000
    diskMBpsReadWrite: 1200
    creationData:{
      createOption: 'Empty'
    }
  }
}


resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: '${resourcePrefix}nic'
  location: location
  properties:{
    ipConfigurations:[
      {
        name: 'ipconfig1'
        properties:{
          subnet:{
            id: vnet.properties.subnets[1].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }      
    ]
    enableAcceleratedNetworking: true
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: '${resourcePrefix}vm'
  location: location
  zones: [
    '1'
  ]
  properties: {    

    hardwareProfile: {
      vmSize: 'Standard_E48bds_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftsqlserver'
        offer: 'sql2008r2sp3-ws2008r2sp1'
        sku: 'standard'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
      }
      dataDisks: [
        {
          name: disk1.name
          lun: 0
          caching: 'None'
          createOption: 'Attach'
          managedDisk: {
            id: disk1.id
          }
        }, {
          name: disk2.name
          lun: 1
          caching: 'None'
          createOption: 'Attach'
          managedDisk: {
            id: disk2.id
          }
        }, {
          name: disk3.name
          lun: 2
          caching: 'None'
          createOption: 'Attach'
          managedDisk: {
            id: disk3.id
          }
        }
      ]
    }
    additionalCapabilities: {
      ultraSSDEnabled: true
    }
    osProfile: {
      computerName: 'fastbox'
      adminUsername: adminName
      adminPassword: adminPass
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
