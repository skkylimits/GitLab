<#
.SYNOPSIS
Preflight script voor GitLab sp33ltu1n lab.
- Connect met Microsoft Graph (MFA)
- Check / maak Entra groepen aan (admins + users)
- Upload SSH public key naar KeyVault
- Schrijf group IDs naar .env voor latere deploy scripts
#>

# 0️⃣ Config
$envFile = ".\.env"
$kvName = "KV-GitLab"
$pubKeyPath = "$env:USERPROFILE\.ssh\gitlab_rsa.pub"

# 1️⃣ Connect Microsoft Graph (MFA)
Write-Host "Logging in to Microsoft Graph..."
Connect-MgGraph -Scopes "Group.ReadWrite.All","Directory.Read.All"

# 2️⃣ Defineer groepen
$groups = @{
    "gitlab-sp33ltu1n-overlords" = "admin"
    "gitlab-sp33ltu1n-testers"   = "user"
}

# 3️⃣ Check / maak groepen en schrijf naar .env
foreach ($groupName in $groups.Keys) {

    # Check of groep bestaat
    $groupId = az ad group list --filter "displayName eq '$groupName'" --query "[0].id" -o tsv

    if (-not $groupId) {
        Write-Host "Group $groupName does not exist. Creating..."
        $groupId = az ad group create --display-name $groupName --mail-nickname $groupName --query id -o tsv
        Write-Host "Group created: $groupName -> $groupId"
    } else {
        Write-Host "Group $groupName already exists: $groupId"
    }

    # Schrijf naar .env
    Add-Content -Path $envFile -Value "$($groupName.ToUpper().Replace('-','_'))_ID=$groupId"
}

# 4️⃣ KeyVault: SSH public key uploaden
if (Test-Path $pubKeyPath) {
    $pubKey = Get-Content $pubKeyPath -Raw
    az keyvault secret set --vault-name $kvName --name "gitlab-ssh-pub" --value $pubKey | Out-Null
    Write-Host "SSH public key uploaded to KeyVault $kvName as 'gitlab-ssh-pub'"
} else {
    Write-Warning "SSH public key not found at $pubKeyPath. Skipping KeyVault upload."
}

Write-Host "✅ Preflight complete. .env file updated with group IDs."