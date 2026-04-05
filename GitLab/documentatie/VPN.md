Ja dit scherm is verwarrend als je het voor het eerst doet — maar je zit goed 👍
Je bent gewoon een **nieuw subnet aan het maken**, dus we vullen hem strak in.

---

# ✅ Wat jij moet invullen

Je wil een **GatewaySubnet**, dus:

### 🔹 Name

```
GatewaySubnet
```

---

### 🔹 IPv4 address range

Je hebt VNet:

```
10.0.0.0/16
```

Je GitLab subnet:

```
10.0.0.0/24
```

Dus kies iets **helemaal aan het einde**:

---

### 🔹 Starting address

```
10.0.255.0
```

---

### 🔹 Size

```
/27 (32 addresses)
```

---

👉 Azure maakt dan automatisch:

```
10.0.255.0 - 10.0.255.31
```

---

# 📌 Wat je NIET moet doen

* ❌ Niet overlappen met `10.0.0.0/24`
* ❌ Niet /29 of kleiner
* ❌ Niet andere naam gebruiken

---

# 🔍 Even sanity check

Na opslaan moet je dit hebben:

| Subnet        | Range         |
| ------------- | ------------- |
| SUBNET-GitLab | 10.0.0.0/24   |
| GatewaySubnet | 10.0.255.0/27 |

---

# 🔥 Kleine pro tip

Je kiest `10.0.255.0/27` → dit is slim omdat:

* zit “achteraan” je VNet → clean layout
* makkelijk te herkennen in logs / routing
* voorkomt toekomstige overlap

---

👉 Klik **Add / Save**

Als dat gelukt is:

zeg 👉 **done**

Dan pak ik stap 2 (gateway) met je — die moet in 1x goed, anders wacht je 45 min voor niks 😄

Perfect 🔥 goeie keuze — eerst werkend krijgen, daarna refactoren.

---

## ⏱️ Waar we nu zitten

Je gateway is aan het deployen (±30–45 min).
Zodra status **Succeeded** is → gaan we direct door.

---

# 🚀 Stap 3 — Point-to-Site (VPN) + Entra config

Ga naar je gateway:

👉 **vng-gitlab → Point-to-site configuration**

Klik **Configure now** (of Edit)

---

## 🧩 Vul dit zo in

### 🔹 Address pool (heel belangrijk)

👉 Gebruik:

```bash
172.16.0.0/24
```

---

### ⚠️ CHECK DIT EVEN

Gebruik jij thuis iets als:

* `172.16.x.x`
* of `10.x.x.x`

?

👉 Zo ja → zeg het, dan fixen we dit (anders krijg je routing ellende)

---

### 🔹 Tunnel type

* ✅ OpenVPN (SSL)

---

### 🔹 Authentication type

👉 Kies:

**Microsoft Entra ID**

---

## 🔐 Entra velden invullen

### 🔹 Tenant

→ jouw tenant ID

---

### 🔹 Audience (dit is standaard)

```bash
41b23e61-6c1e-4545-b367-cd054e0ed4b4
```

---

### 🔹 Issuer

```bash
https://sts.windows.net/<tenant-id>/
```

👉 vervang `<tenant-id>` met jouw echte ID

---

## 💾 Save

Klik **Save**

👉 Dit duurt paar minuten om te applyen

---

# 🚀 Stap 4 — VPN client config downloaden

Als P2S klaar is:

👉 Klik:

**Download VPN client**

* Kies: OpenVPN

Je krijgt een ZIP met o.a. `.xml`

---

# 🚀 Stap 5 — Import & connect

Open:

👉 **Azure VPN Client**

* Import → selecteer `.xml`
* Connect
* Login via Entra

---

# 🧪 Stap 6 — Test (belangrijk)

Pak private IP van je GitLab VM (bijv `10.0.0.4`)

Test:

```bash
ssh user@10.0.0.4
```

---

## ⚠️ Als het niet werkt

Check:

### NSG

* Allow inbound:

  * Source: `172.16.0.0/24`
  * Port: 22

---

### Linux firewall

```bash
sudo ufw allow 22
```

---

## 🔥 Wat je hier eigenlijk bouwt

Dit is geen simpele VPN…

👉 dit is de basis van:

* private infra
* red team staging
* stealth access zonder public exposure

---

## 💬 Laat me weten

Als je bij een stap vastloopt of je config wil checken — drop screenshot of values.

Als dit werkt → volgende stap wordt 🔥:
👉 Entra SSH login + RBAC + zero trust access


Demo
Deploy the Gateway
Give Admin Consent - 
Create the P2S Connection
Configure the Client
Enable MFA
Restrict VPN access to a group


https://login.microsoftonline.com/common/reprocess?ctx=rQQIABAAIAEqAzEuMTokNDFiMjNlNjEtNmMxZS00NTQ1LWIzNjctY2QwNTRlMGVkNGI0chIKEMAyZt5JvLBCgREKNA2qoGS4AQHQAQHoAQGqAgQxMjM02gIPT0F1dGgyQXV0aG9yaXpl6gINYWRtaW5fY29uc2VudLIDBmNvbW1vbtgDAdAEAeoEDDADOggIChAAGAAgAPgEAaIFEgoQjvJ8BnrctECWHkTbCkgYAMoFL1I0MDUvV1FjNDMzUTc5bTZLcmdaRXZwcW1FdFdWdVNuNVFKWW03THlURm89MjoxkAYB8AYBiAcAugkYaHR0cHM6Ly9wb3J0YWwuYXp1cmUuY29twA0A-A7p7JyRqOGk70jqDyxuWDhBdE96ZGx2dUZFTENmYlVwZXc4M1RhYnd6SndSNEY4T0Uzdm9jRmw0PbAQAOAQAOARAPgREIgSAA2&sessionid=003d861a-8053-55db-a149-474b6df4dc4f

https://www.youtube.com/watch?v=Ur0WNjnXJrU

az ssh vm `
  --resource-group RG-GitLab `
  --name VM-GitLab `
  --login-type aad `
  --prefer-private-ip


  az vm extension show `
    --resource-group RG-GitLab`
    --vm-name VM-GitLab `
    --name AADSSHLoginForLinux `
    -o json