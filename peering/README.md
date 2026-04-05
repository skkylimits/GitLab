# Peering

Deze stack beheert alleen de koppeling tussen bestaande VNets.

Waarom hier geen `platform.bicep` is:

- deze stack maakt geen nieuwe resource groups aan
- deze stack deployt alleen peerings op bestaande VNets in bestaande resource groups
- een extra orchestratie-laag zou hier geen functioneel voordeel geven

De stack maakt twee peerings aan:

- `VNET-VPN` -> `VNET-GitLab` met `allowGatewayTransit`
- `VNET-GitLab` -> `VNET-VPN` met `useRemoteGateways`

Voorwaarde voor dit ontwerp:

- `VNET-VPN` is de hub met de enige VPN Gateway
- `VNET-GitLab` is een spoke en hoort dus geen eigen VPN Gateway te gebruiken

Deploy volgorde:

1. Deploy `Azure VPN Client`
2. Deploy `GitLab`
3. Deploy `peering`