# Generate a Random String for Uniqueness
resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}


resource "azurerm_service_plan" "service_plan" {
  name                = "plan-${random_string.random.result}-tfcustm"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "FC1"

  maximum_elastic_worker_count    = 1
  per_site_scaling_enabled        = false
  premium_plan_auto_scale_enabled = false
  zone_balancing_enabled          = false

  tags = var.tags
}


resource "azurerm_user_assigned_identity" "funcapp" {
  name                = "func-${random_string.random.result}-${var.distinguisher}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
}


# Create the Function App
# resource "azurerm_function_app_flex_consumption" "function_app" {
#   name                = "func-${random_string.random.result}-${var.distinguisher}"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   service_plan_id     = azurerm_service_plan.service_plan.id

#   storage_container_type            = var.storage_container_type
#   storage_container_endpoint        = var.storage_container_endpoint
#   storage_authentication_type       = "UserAssignedIdentity"
#   storage_user_assigned_identity_id = azurerm_user_assigned_identity.funcapp.id

#   runtime_name    = "python"
#   runtime_version = "3.11"

#   client_certificate_mode = "Required"

#   # identity {
#   #   type = "SystemAssigned"
#   # }

#   identity {
#     type         = "UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.funcapp.id]
#   }

#   site_config {

#     ip_restriction_default_action = "Allow"
#     cors {
#       allowed_origins     = ["https://portal.azure.com"]
#       support_credentials = false
#     }
#     scm_ip_restriction_default_action = "Allow"

#   }

#   tags = var.tags
# }


resource "azurerm_function_app_flex_consumption" "function_app" {
  name                = "func-${random_string.random.result}-${var.distinguisher}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.service_plan.id

  app_settings = {
    AzureWebJobsStorage__blobServiceUri  = "https://${var.storage_account_name}.blob.core.windows.net"
    AzureWebJobsStorage__queueServiceUri = "https://${var.storage_account_name}.queue.core.windows.net"
    AzureWebJobsStorage__tableServiceUri = "https://${var.storage_account_name}.table.core.windows.net"
    AzureWebJobsStorage__clientId        = azurerm_user_assigned_identity.funcapp.client_id
    AzureWebJobsStorage__credential      = "managedidentity"
  }

  client_certificate_enabled         = false
  client_certificate_exclusion_paths = ""
  client_certificate_mode            = "Required"
  enabled                            = true


  public_network_access_enabled = true

  storage_container_type            = var.storage_container_type
  storage_container_endpoint        = var.storage_container_endpoint
  storage_authentication_type       = "UserAssignedIdentity"
  storage_user_assigned_identity_id = azurerm_user_assigned_identity.funcapp.id

  runtime_name    = "python"
  runtime_version = "3.11"

  webdeploy_publish_basic_authentication_enabled = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.funcapp.id]
  }

  site_config {
    default_documents                 = ["Default.htm", "Default.html", "Default.asp", "index.htm", "index.html", "iisstart.htm", "default.aspx", "index.php"]
    elastic_instance_minimum          = 0
    http2_enabled                     = false
    load_balancing_mode               = "LeastRequests"
    managed_pipeline_mode             = "Integrated"
    minimum_tls_version               = "1.2"
    remote_debugging_enabled          = false
    runtime_scale_monitoring_enabled  = false
    scm_ip_restriction_default_action = "Allow"
    scm_minimum_tls_version           = "1.2"
    scm_use_main_ip_restriction       = false
    use_32_bit_worker                 = false
    websockets_enabled                = false
    worker_count                      = 1
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = false
    }
  }

  tags = var.tags
}
