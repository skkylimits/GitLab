vnet → subnetId
   ↓
nsg → nsgId
   ↓
nic → gebruikt subnet + nsg → geeft nicId + publicIP
   ↓
vm → gebruikt nicId

az deployment group create \
  --resource-group rg-gitlab \
  --parameters infra/parameters/gitlab.bicepparam