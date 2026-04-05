param(
	[switch]$OpenConsentPage
)

$ErrorActionPreference = 'Stop'

$azureVpnAppId = '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
$context = az account show --query "{subscriptionId:id, subscriptionName:name, tenantId:tenantId}" -o json | ConvertFrom-Json
$aadTenant = "https://login.microsoftonline.com/$($context.tenantId)/"
$aadIssuer = "https://sts.windows.net/$($context.tenantId)/"
$adminConsentUrl = "https://login.microsoftonline.com/$($context.tenantId)/adminconsent?client_id=$azureVpnAppId"

Write-Host "Subscription : $($context.subscriptionName) [$($context.subscriptionId)]"
Write-Host "Tenant       : $($context.tenantId)"
Write-Host "aadTenant    : $aadTenant"
Write-Host "aadAudience  : $azureVpnAppId"
Write-Host "aadIssuer    : $aadIssuer"

az provider register --namespace Microsoft.Network --wait | Out-Null

Write-Host ""
Write-Host "Checking Azure VPN enterprise application in this tenant..."

$servicePrincipalJson = az ad sp show --id $azureVpnAppId -o json 2>$null

if (-not $servicePrincipalJson) {
	Write-Host "Azure VPN enterprise application not found. Attempting tenant provisioning..."

	$createdServicePrincipalJson = az ad sp create --id $azureVpnAppId -o json 2>$null

	if ($createdServicePrincipalJson) {
		$servicePrincipal = $createdServicePrincipalJson | ConvertFrom-Json
		Write-Host "Azure VPN enterprise application provisioned: $($servicePrincipal.displayName) [$($servicePrincipal.id)]"
	}
	else {
		Write-Warning "Automatic provisioning failed. A tenant admin likely needs to grant consent once."
		Write-Host "Admin consent URL: $adminConsentUrl"

		if ($OpenConsentPage) {
			Start-Process $adminConsentUrl
		}

		throw "Azure VPN enterprise application is not available in this tenant yet. Complete admin consent and rerun preflight."
	}
}
else {
	$servicePrincipal = $servicePrincipalJson | ConvertFrom-Json
	Write-Host "Azure VPN enterprise application already present: $($servicePrincipal.displayName) [$($servicePrincipal.id)]"
}

Write-Host ""
Write-Host "Preflight complete. Controleer daarna parameters/azure-vpn-client.bicepparam op namen, address spaces en client pool."