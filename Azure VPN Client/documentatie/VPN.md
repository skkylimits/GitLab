# VPN-notes

## Topologie

- Resource group VPN: `RG-VPN`
- VNet: `VNET-VPN`
- Workload subnet: `10.10.0.0/24`
- GatewaySubnet: `10.10.255.0/27`
- Point-to-site pool: `172.20.201.0/24`

## Ontkoppeling

Deze stack heeft bewust geen afhankelijkheid meer op `VNET-GitLab`.
Als je later routing naar GitLab wilt, doe je dat via VNet peering of via aanvullende routing-resources in een aparte stap.

## Authenticatie

De standaardconfiguratie in deze map gebruikt:

- `OpenVPN`
- `AAD` als `vpnAuthenticationTypes`
- Azure VPN Client als desktopclient

De Entra-waarden zijn al ingevuld op basis van de actieve Azure CLI-context:

- `aadTenant`: `https://login.microsoftonline.com/<tenant-id>/`
- `aadAudience`: `41b23e61-6c1e-4545-b367-cd054e0ed4b4`
- `aadIssuer`: `https://sts.windows.net/<tenant-id>/`

## Deployment flow

```powershell
./scripts/preflight.ps1
./scripts/deploy.ps1
```

## Opruimen

```powershell
./scripts/cleanup.ps1
```