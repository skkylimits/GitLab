# pre

```
az cli
```

```
Connect-MgGraph -Scopes "Group.ReadWrite.All","Directory.Read.All"
```

```
az extension add --name ssh
```

# Deployment

## Persistent data disk

`deploy.ps1` zorgt nu eerst dat `DATA-GitLab` bestaat en deployt daarna pas de disposable GitLab stack. De disk blijft buiten de deployment stack en wordt alleen aangemaakt als hij nog niet bestaat.

```
./scripts/deploy.ps1
```

```
az stack sub create `
  --name "gitlab-stack" `
  --location "westeurope" `
  --template-file platform.bicep `
  --parameters parameters\gitlab.bicepparam `
  --action-on-unmanage deleteResources `
  --deny-settings-mode denyWriteAndDelete
```

# Verwijder stack lock

az stack sub create `
  --name "gitlab-stack" `
  --location westeurope `
  --template-file platform.bicep `
  --parameters parameters\gitlab.bicepparam `
  --action-on-unmanage deleteResources `
  --deny-settings-mode none `
  --yes


# show

```
az stack sub show --name gitlab-stack --query properties.outputs
```

# Delete

```
az stack sub delete `
  --name "gitlab-stack" `
  --action-on-unmanage deleteResources `
  --yes
```
```
az stack sub show `
  --name "gitlab-stack"
```

az deployment group create `
  -g TestRG `
  --template-file test.bicep `
  --parameters displayName='GitLabAdmins' uniqueName='gitlab-admins' mailNickname='gitlabadmins'

```
az group exists `
  --name "RG-GitLab"
```

# Debugger

```
az stack sub create `
  --name "gitlab-stack" `
  --location "westeurope" `
  --template-file platform.bicep `
  --parameters parameters\gitlab.bicepparam `
  --action-on-unmanage deleteResources `
  --deny-settings-mode denyWriteAndDelete --only-show-errors `
```

## 🔹 Wat doet een Deployment Stack?

```bash
az stack sub create \
  --name gitlab-stack \
  ...
  --action-on-unmanage deleteResources \
  --deny-settings-mode none
```

👉 Dit gebeurt:

* Azure maakt een **Deployment Stack**
* Die **beheert jouw resources** (RG, VM, netwerk, etc.)

---

## 🔹 Wat kan die stack doen?

Afhankelijk van je settings:

* 🔒 resources **beschermen** (locks)
* 🧹 resources **automatisch verwijderen** (als je ze uit Bicep haalt)

---

👉 Zie het als:

> “Azure houdt bij wat van jou is en zorgt dat het klopt met je code”

### 🧪 Lab

```bash
--deny-settings-mode none
```

* ✅ alles zelf verwijderen (RG, VM, etc.)
* ❌ geen bescherming
  👉 snel testen / slopen

---

### 🏭 Productie

```bash
--deny-settings-mode denyDelete
```

* ❌ je kan resources niet zomaar deleten
* ✅ bescherming tegen fouten
  👉 veilig

---

## 🔹 Belangrijk verschil

* `none` → jij hebt controle
* `denyDelete` → Azure beschermt je

---

## 🔹 Die andere setting (belangrijk!)

```bash
--action-on-unmanage deleteResources
```

👉 betekent:

* haal je iets uit Bicep → wordt automatisch verwijderd

---

## 🔥 TL;DR

* Lab → `none` (vrijheid)
* Prod → `denyDelete` (veiligheid)
* Best practice → **verwijderen via Bicep, niet handmatig**


# Architectuur en keuzes

## 1. Subscription-first bootstrapping (platform.bicep)
- `targetScope = 'subscription'`.
- Maakt of hergebruikt resource group (`RG`) als container.
- Deployt de applicatie-stack via module `app` in scope `resourceGroup(rg.name)`.
- Hierdoor is 1 commando voldoende om op te starten en te updaten.

## 1.5 GitLab host requirements (recommended)
- VM-size: `Standard_DS2_v2` (min 4 vCPU, 8 GB RAM)
- OS: Ubuntu 22.04 LTS
- OS disk: 30 GB
- Datadisk: 128 GB Premium SSD
- Geen publieke IP (private netwerk + bastion/jumpbox voor beheer)
- Eenvoudig te updaten met: `az deployment sub create ...` (idempotent)
- De data disk wordt apart gedeployed met een kleine losse resource-template en met een `CanNotDelete` lock beschermd

## 2. ResourceGroup + module hiërarchie
- `bootstrap.bicep` creëert RG.
- `main.bicep` draait per RG (`targetScope = 'resourceGroup'`).
- In `main.bicep` zitten resources: vnet/nsg/nic/vm, waar dependency flow duidelijk is.
- Dit volgt ARM scope model (sub -> RG -> resources) en werkt goed in grotere projecten.

### ASCII architectuur
```
Subscription scope (bootstrap.bicep)
|
|-- ResourceGroup RG-GitLab
|   |
|   |-- Module app (main.bicep) [resourceGroup scope]
|       |
|       |-- vnet module (vnet.bicep)
|       |-- nsg module (nsg.bicep)
|       |-- nic module (nic.bicep)
|       |-- vm module (vm.bicep)
|-- other potential RG modules...
```

## Netwerkrol

- `GitLab` is een spoke-workload VNet
- de VPN Gateway hoort in de aparte `Azure VPN Client` hub-stack
- on-premises of P2S/VPN-toegang naar GitLab loopt via VNet peering en remote gateway gebruik

## 3. Modulaire params & object model
- Params in `parameters/gitlab.bicepparam`:
  - `location` (string)
  - `rg` (object: name, tags)
  - `network`, `compute`, `identity`, `secrets` (objecten)
- Voordelen:
  - Zelfdocumenterend: alles gedefinieerd als domain-structuur.
  - Makkelijk uitbreidbaar: extra RG-properties, network rules, vm settings later toevoegen zonder refactor.
  - Eenvoudig testen per environment (dev/stage/prod) met aparte .bicepparam variants.

## 4. Idempotent deploy
- `az stack sub create` is safe om herhaald te runnen.
- maakt RG als niet-bestaat
- update state naar template-definitie
- status is consistent na elke run

## 4.5 Destroy / rebuild flow
- Voor een volledige reset: verwijder eerst de stack met `az stack sub delete --name gitlab-stack --action-on-unmanage deleteResources --yes`.
- Wacht tot de delete klaar is; de deny assignment wordt dan ook verwijderd.
- Deploy daarna opnieuw met `az stack sub create ...`.
- Wil je alleen locks uitzetten zonder te deleten, run dan opnieuw `az stack sub create ... --deny-settings-mode none`.
- De 128 GB data disk blijft buiten deze cleanup-flow en wordt opnieuw geattached door de VM deployment.

## 4.6 Data disk ownership
- `gitlab-stack` beheert de disposable laag: VM, NIC, NSG en VNet.
- `deploy.ps1` checkt eerst of `DATA-GitLab` bestaat en bootstrapt hem anders via `modules/storage/disk.bicep`.
- De VM attacht de bestaande disk met `deleteOption: 'Detach'`, zodat VM rebuilds de disk niet opruimen.

## 4.7 Cloud-init runtime
- cloud-init mount de data disk idempotent via UUID
- cloud-init installeert Docker en Docker Compose
- cloud-init schrijft een `docker-compose.yml` naar de data disk
- GitLab config, logs en data landen onder `/mnt/DATA-GitLab/gitlab`
- GitLab container SSH gebruikt hostpoort `2424`, zodat VM-beheer-SSH op poort `22` intact blijft

## 5. Waarom we niet `main.bicep` direct met RG t/m objecten
- `main.bicep` is clean resourceGroup-scope en herbruikbaar vanuit meerdere RG’'s/branches.
- `platform.bicep` is orchestrator en biedt single entrypoint (1 command).
- Dit scheidt verantwoordelijkheden voor onderhoud en multi-environment deployment.

az vm list-skus `
  --location westeurope `
  --size Standard_B `
  --output table


# TODO

Automatate entra groupen creation + koppeling op de vm RBAC
pipeline script -> vpn -> gitlab- > peering. vpn voegt azure app reg als die nog niet bestaat en checked. overal checks inbouwen