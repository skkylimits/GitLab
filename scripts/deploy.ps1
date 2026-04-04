# load .env
Get-Content .\.env | ForEach-Object { 
    if ($_ -match "=") { Set-Item -Path Env:\$($_.Split('=')[0]) -Value $_.Split('=')[1] }
}

# stack deployment
az stack sub create `
    --name "gitlab-stack" `
    --location westeurope `
    --template-file platform.bicep `
    --parameters parameters\gitlab.bicepparam `
    --action-on-unmanage deleteResources `
    --deny-settings-mode none `
    --yes