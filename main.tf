terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 3.0"
        }   
    }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "rg" {
    name = "uptime-kuma-rg"
    location = "East US 2"
}

resource "azurerm_container_registry" "acr"{
    name = "uptimekumaacrjoar160"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku = "Basic"
    admin_enabled = true
    }

resource "azurerm_service_plan" "asp"{
    name = "uptimekuma_asp"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    os_type = "Linux"
    sku_name = "B1"
    }


resource "azurerm_linux_web_app" "webapp" {
    name = "uptime-kuma-webapp-joar"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    service_plan_id = azurerm_service_plan.asp.id

        app_settings = {
        WEBSITES_PORT = "3001"
    }
    
    site_config { 
        application_stack {
            docker_image_name        = "uptime-kuma:2"   
            docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
            docker_registry_username = azurerm_container_registry.acr.admin_username
            docker_registry_password = azurerm_container_registry.acr.admin_password
        }
    }
}