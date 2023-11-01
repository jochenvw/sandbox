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
  properties:{
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


resource ultraDisk 'Microsoft.Compute/disks@2023-04-02' = {
  name: '${resourcePrefix}ultra-disk'
  location: location
  sku:{
    name: 'UltraSSD_LRS'
  }
  zones: [
    '1'
  ]
  properties:{    
    diskSizeGB: 1024
    diskIOPSReadWrite: 160000
    diskMBpsReadWrite: 4000
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
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      diskControllerType: 'NVMe'
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
      }
      dataDisks: [
        {
          name: ultraDisk.name
          lun: 0
          createOption: 'Attach'
          managedDisk: {
            id: ultraDisk.id
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
