# load .env
Get-Content .\.env | ForEach-Object { 
    if ($_ -match "=") { Set-Item -Path Env:\$($_.Split('=')[0]) -Value $_.Split('=')[1] }
}

$resourceGroupName = 'RG-GitLab'
$location = 'westeurope'
$dataDiskName = 'DATA-GitLab'
$diskDefinition = '{"name":"DATA-GitLab","sizeGB":128,"sku":"Premium_LRS"}'

az group create `
    --name $resourceGroupName `
    --location $location | Out-Null

$existingDisk = az disk show `
    --resource-group $resourceGroupName `
    --name $dataDiskName `
    --query id `
    --output tsv 2>$null

if (-not $existingDisk) {
    az deployment group create `
        --resource-group $resourceGroupName `
        --name "gitlab-data-disk" `
        --template-file modules\storage\disk.bicep `
        --parameters location=$location disk=$diskDefinition | Out-Null
}

# stack deployment
az stack sub create `
    --name "gitlab-stack" `
    --location "westeurope" `
    --template-file platform.bicep `
    --parameters parameters\gitlab.bicepparam `
    --action-on-unmanage deleteResources `
    --deny-settings-mode none `
    --yes