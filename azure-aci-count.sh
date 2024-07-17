#!/bin/bash

# Initialize variables
aci_count=0

# Get all subscriptions
subscriptions=$(az account list --query "[].id" -o tsv)

# Loop through each subscription
for subscription in $subscriptions
do
    echo "Subscription: $subscription"
   
    # Set the current subscription
    az account set --subscription $subscription

    # Get resource groups in the current subscription
    resource_groups=$(az group list --query "[].name" -o tsv)

    # Loop through each resource group
    for resource_group in $resource_groups
    do
        echo "  Resource Group: $resource_group"

        # Get list of all Azure Container Instances in the Resource Group
        aci_instance_names=$(az container list --resource-group $resource_group --query "[].name" -o tsv)

        #Check each ACI for running state
        for aci_instance_name in $aci_instance_names
        do
            if [ "$(eval "az container show -g $resource_group -n $aci_instance_name --query "instanceView.state" -o tsv")" = "Running" ]; then
                echo "    Running ACI Instance: $aci_instance_name"
                
                # Add to total count
                aci_count=$((aci_count + 1))
            fi
        done
    done
done

# Output total ACI count across all subscriptions
echo "Total Running ACI Count: $aci_count"