az stack sub create `
  --name "azure-vpn-client-stack" `
  --location westeurope `
  --template-file platform.bicep `
  --parameters parameters\azure-vpn-client.bicepparam `
  --action-on-unmanage deleteResources `
  --deny-settings-mode none `
  --yes