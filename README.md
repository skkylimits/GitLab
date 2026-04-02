# Deployment

```powershell
az deployment sub create `
  --name GitLab `
  --location westeurope `
  --template-file bootstrap.bicep `
  --parameters @parameters/gitlab.bicepparam
```

# Architectuur en keuzes

## 1. Subscription-first bootstrapping (bootstrap.bicep)
- `targetScope = 'subscription'`.
- Maakt of hergebruikt resource group (`RG`) als container.
- Deployt de applicatie-stack via module `app` in scope `resourceGroup(rg.name)`.
- Hierdoor is 1 commando voldoende om op te starten en te updaten.

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
|
|-- other potential RG modules...
```

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
- `az deployment sub create` is safe om herhaald te runnen.
- maakt RG als niet-bestaat
- update state naar template-definitie
- status is consistent na elke run

## 5. Waarom we niet `main.bicep` direct met RG t/m objecten
- `main.bicep` is clean resourceGroup-scope en herbruikbaar vanuit meerdere RG’'s/branches.
- `bootstrap.bicep` is orchestrator en biedt single entrypoint (1 command).
- Dit scheidt verantwoordelijkheden voor onderhoud en multi-environment deployment.
