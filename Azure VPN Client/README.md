# Azure VPN Client

Losse, idempotente VPN-stack voor Azure VPN Client, opgezet met dezelfde orchestratie als `GitLab`:

- `platform.bicep` op subscription-scope
- `main.bicep` op resource-group-scope
- losse netwerkmodules onder `modules/network`
- environment-specifieke waarden in `parameters/*.bicepparam`
- PowerShell scripts onder `scripts/`

Deze map wijzigt niets in `GitLab` en trekt alleen de VPN-opzet los naar een eigen deployment-pad.
De deployment draait nu volledig zelfstandig in `RG-VPN` met een eigen `VNET-VPN`.
Later kun je `VNET-VPN` peeren met `VNET-GitLab`, maar dat is bewust geen onderdeel van deze stack zodat de VPN-deployment zelfstandig en idempotent blijft.

De stack beheert nu zelf:

- `VNET-VPN`
- `SUBNET-VPN`
- `GatewaySubnet`
- `VPN-PIP-VPN`
- `VNG-VPN`

## Deploy

```powershell
./scripts/preflight.ps1
./scripts/deploy.ps1
```

De deployment gebruikt een Azure Deployment Stack en blijft daarmee idempotent:

- opnieuw draaien update de bestaande resources
- resources die je later uit Bicep haalt worden door de stack opgeruimd

## Belangrijkste parameters

Pas in `parameters/azure-vpn-client.bicepparam` minimaal dit aan als nodig:

- resource group naam
- VNet naam
- VNet address space
- workload subnet prefix
- `GatewaySubnet` prefix
- VPN client address pool
- gateway SKU

## Azure VPN Client-profiel ophalen

Na succesvolle deployment kun je het clientprofiel genereren met:

```powershell
az network vnet-gateway vpn-client generate `
  --resource-group RG-VPN `
  --name VNG-VPN `
  --processor-architecture Amd64
```

Het commando retourneert een URL naar een zip-bestand. Importeer daarna het XML-profiel in Azure VPN Client.