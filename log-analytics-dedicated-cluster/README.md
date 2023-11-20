# Log Analytics Dedicated Cluster Deployment

The code is written in Azure CLI (Command Line Interface), a tool that allows you to manage Azure resources directly from the command line. This script is used to create and configure a Log Analytics workspace in Azure Monitor, which is a service that collects and analyzes log data from Azure resources.

The first command creates a resource group named "nl-stu-jvw-la-dedicated" in the "westeurope" location. A resource group in Azure is a logical container for resources that are deployed within an Azure subscription.

The next set of commands creates a Log Analytics cluster and three workspaces within the previously created resource group. The az monitor log-analytics cluster create command creates a Log Analytics cluster named "la-dedicated-cluster2" with a capacity of 500. The az monitor log-analytics workspace create commands create three workspaces named 'nl-stu-jvw-la-ws1', 'nl-stu-jvw-la-ws2', and 'nl-stu-jvw-la-ws3' respectively.

The last part of the script links the created workspaces to the cluster. The az monitor log-analytics cluster list command is used to get the resource ID of the cluster. This ID is stored in the variable $clusterResourceId. The az monitor log-analytics workspace linked-service create commands then create linked services that connect each workspace to the cluster using the cluster's resource ID. The --write-access-resource-id parameter is used to specify the resource ID of the cluster, which gives the linked service write access to the cluster.