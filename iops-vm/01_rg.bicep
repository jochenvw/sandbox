// Deploys the rersource group for the resources
// used to test the high-IOPs VM
targetScope='subscription'

// Parameters
param location string = 'eastus'

// Variables
var rgName = 'msft-nl-stu-jvw-fastbox-rg'

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: rgName
  location: location
}
