az stack sub create `
  --name "peering-stack" `
  --location westeurope `
  --template-file main.bicep `
  --parameters parameters\peering.bicepparam `
  --action-on-unmanage deleteResources `
  --deny-settings-mode none `
  --yes