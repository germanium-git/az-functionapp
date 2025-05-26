output "id" {
  value = azurerm_function_app_flex_consumption.function_app.id
}

# output "function_app_principal_id" {
#   value = azurerm_function_app_flex_consumption.function_app.identity[0].principal_id
# }

output "function_app_principal_id" {
  value = azurerm_user_assigned_identity.funcapp.principal_id
}
