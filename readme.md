# Azure FunctionApp

The repository contains code to create a function app with flex consumption plan in a diffrenet ways.

- Using a Terraform Azure Validate Module
- Using a Terraform custom module
- Using Terraform and AzApi provider
- Using Bicep


## Summary

The crucial elements are environmenal variables which act as pre-requisiutes for function deployments.

The following five variables are required:
- AzureWebJobsStorage__blobServiceUri
- AzureWebJobsStorage__clientId
- AzureWebJobsStorage__credential
- AzureWebJobsStorage__queueServiceUri
- AzureWebJobsStorage__tableServiceUri

The best way as of now appears to be Bicep and custom module.
Though the custom module tends to create two more variables which have to be manually removed and thet are not re-created after consequent terraform apply.
- AzureWebJobsStorage
- DEPLOYMENT_STORAGE_CONNECTION_STRING


The other two deployment types, using AzAPI and AVM module, do not allow the use of a User assigned identity as a means of authentication the function app uses towards the storage due to a bug. The User assigned identity appers to be one of environmnet variables required by the funcion app deployment.

Also when the function app is created manually in the portal a user assigned identity is created as part of the deployment.
