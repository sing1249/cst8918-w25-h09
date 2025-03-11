terraform {
  required_version = ">= 1.1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.22.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.3"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "56d67ba7-7129-4796-810e-a6159bb4b456"
}

provider "cloudinit" {
  # Configuration options
}

# Resource group
resource "azurerm_resource_group" "aks_rg" {
  name     = "talwinder-rg"
  location = "canadacentral"
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "akscluster"

  default_node_pool {
    name                = "systempool"
    node_count          = 1
    vm_size             = "Standard_B2s"
    min_count           = 1
    max_count           = 3
    auto_scaling_enabled = true
    type                = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "dev"
  }
}

# Output kubeconfig
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true
}
