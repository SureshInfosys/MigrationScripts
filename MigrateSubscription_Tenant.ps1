#Login to Source Tenant
Login-AzureRmAccount
#Replace <Subscription ID> below with Subscription ID you want to migrate
$subscriptionId = "<Subscription ID>"
if (-not (Get-Module AzureRm.Profile)) {
    Import-Module AzureRm.Profile
}

$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
if (-not $azureRmProfile.Accounts.Count) {
        Write-Error "Please make sure you have logged in before calling this function."
}

$currentAzureContext = Get-AzureRmContext
if(!$currentAzureContext){
    Write-Error "Please make sure you have logged in before calling this function."
}
 
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
Write-Debug ("Getting access token for tenant" + $currentAzureContext.Subscription.TenantId)
$token = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId)

$token = $token.AccessToken
$uri = "https://management.azure.com/subscriptions/$subscriptionId/providers/Microsoft.Subscription/changeTenantRequest/default?api-version=2019-10-01-preview" 

#Replace <UPN> below with User UPN (from the corresponding tenant) who will accept the tenant change request
$jsonnewreq = '{ “properties”: { “destinationEmail”: “xyz@abc.com” } }' 
Invoke-WebRequest -Uri $uri -Headers @{Authorization = "Bearer $token" } -Method PUT -ContentType application/json -Body $jsonnewreq
Logout-AzureRmAccount