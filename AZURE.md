## 🔹 1. VNet (Virtual Network)

**Wat het is:**

* Een **virtueel netwerk** in Azure.
* Het is als een **privé LAN in de cloud** waar je al je resources (VMs, databases, etc.) in zet.
* Binnen een VNet kunnen resources **met elkaar praten** zonder naar het publieke internet te gaan.

**Belangrijk:**

* Je definieert een **adresruimte**, bijvoorbeeld: `10.0.0.0/16` → dat is de IP-range die binnen je VNet gebruikt kan worden.
* Alles wat binnen die range valt, zit “binnen je eigen netwerk”.

**Analogie:** een kantoorgebouw met een intern netwerkadres (10.x.x.x) waar alle computers in zitten.

---

## 🔹 2. Subnet

**Wat het is:**

* Een **subnet** is een **gedeelte van een VNet**.
* Je verdeelt je VNet in stukken, bijvoorbeeld voor verschillende toepassingen of beveiliging.

**Waarom handig:**

* Je kan verschillende subnetten **van elkaar isoleren** via NSGs (firewall rules).
* Bijvoorbeeld:

  * `Subnet-Frontend` → voor webservers
  * `Subnet-Backend` → voor databases

**Analogie:** het VNet is een kantoor, een subnet is een **afdeling** binnen dat kantoor (IT-afdeling, HR-afdeling, etc.).

---

## 🔹 3. NIC (Network Interface)

**Wat het is:**

* Een **virtuele netwerkkaart** die je VM verbindt met een subnet.
* Zonder NIC kan een VM **niet communiceren** met het netwerk.

**Belangrijk:**

* Je kan een NIC meerdere IP-adressen geven, private of public.
* De NIC **maakt de verbinding** tussen de VM en subnet (dus het VNet).

**Analogie:** de NIC is de **ethernet- of wifi-kaart in je laptop**.

---

## 🔹 4. NSG (Network Security Group)

**Wat het is:**

* Een **firewall** voor je subnet of NIC.
* Bepaalt welke verkeer **toegestaan of geblokkeerd** wordt.

**Belangrijk:**

* Je kan het op **subnet-niveau** of **NIC-niveau** toepassen.
* Rules hebben meestal: `source IP`, `destination IP`, `poort`, `action (allow/deny)`

**Analogie:** een **deurbeleid**: wie mag naar binnen en via welke deur.

---

## 🔹 Hoe ze samenwerken in Azure

1. **VNet** = je volledige netwerk
2. **Subnet** = een “gedeelte” van dat netwerk
3. **NIC** = de netwerkkaart van je VM, verbonden met subnet
4. **NSG** = firewall die bepaalt welk verkeer naar die NIC of dat subnet mag

```text id="network-stack"
[VNet: 10.0.0.0/16]
  ├─ Subnet-Frontend: 10.0.0.0/24
  │    └─ VM1
  │         └─ NIC1
  │              └─ NSG (rules)
  └─ Subnet-Backend: 10.0.1.0/24
       └─ VM2
            └─ NIC2
                 └─ NSG (rules)
```

* VM1 en VM2 kunnen communiceren **als NSG het toestaat**
* VM1 kan publiek internet bereiken **als er een public IP/NAT is**

