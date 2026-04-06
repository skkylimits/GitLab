# 1

sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

docker --version

# 2

Top! 🚀

---

## **Stap 2: Directories voor persistent data aanmaken**

GitLab slaat alles op in `/etc/gitlab`, `/var/log/gitlab` en `/var/opt/gitlab`. Voor een POC kunnen we deze op de host mounten, zodat de data niet verloren gaat als de container herstart.

Voer dit uit op de GitLab VM:

```bash id="vyrxq2"
sudo mkdir -p /srv/gitlab/config /srv/gitlab/logs /srv/gitlab/data
sudo chown -R $USER:$USER /srv/gitlab
```

* `/srv/gitlab/config` → GitLab configuratie
* `/srv/gitlab/logs` → logs
* `/srv/gitlab/data` → repository en database data

Check dat de directories bestaan:

```bash id="4dzyn0"
ls -l /srv/gitlab
```


# 3

Goed, laten we de **GitLab container starten op poort 80**.

---

## **Stap 3: GitLab container draaien**

Op de GitLab VM, voer het volgende uit:

```bash id="x6b0ke"
docker run --detach \
  --hostname gitlab.local \
  --publish 80:80 \
  --name gitlab \
  --restart always \
  --volume /srv/gitlab/config:/etc/gitlab \
  --volume /srv/gitlab/logs:/var/log/gitlab \
  --volume /srv/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ee:latest
```

* `--hostname gitlab.local` → tijdelijke interne hostname voor POC
* `--publish 80:80` → maakt de GUI bereikbaar op poort 80
* Volumes → zorgen dat configuratie/data persistent blijft

Check of de container draait:

```bash id="qk7d5h"
docker ps
```

Je zou iets moeten zien als:

```
CONTAINER ID   IMAGE                STATUS       PORTS
abc123         gitlab/gitlab-ee     Up 1m        0.0.0.0:80->80/tcp
```

---

## **Stap 4: Eerste keer inloggen**

1. Open een browser op de GitLab VM zelf (of via een interne dev VM die verbinding kan maken met deze VM) en ga naar:

```
http://<private-ip-van-de-VM>
```

Bijvoorbeeld: `http://10.0.0.4`

2. Het vraagt om een root password. Vind het door:

```bash id="t2oxul"
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

3. Log in met `root` en dit password.
4. Zet direct een nieuw password. 9NrB56Rw8Gc5bTu56o5AcdOcD3yHfI4IjzbXen6jsvo=

✅ Conclusie stap 1 (POC GUI bereikbaarheid)
GitLab container draait op VM (docker ps → status up)
Poorten zijn correct gemapped (0.0.0.0:80->80/tcp)
NSG/VPN/firewall laat interne verbinding toe
Dev machine kan via interne IP de login redirect zien

Alles werkt dus voor deze eerste POC zonder publieke toegang.

# 4

Top! 🚀 Laten we root login doen en een eerste testproject aanmaken.

---

## **Stap 2a: Root password ophalen**

Op je GitLab VM:

```bash id="xw4p3k"
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

* Je ziet iets als:

```id="p4d8x1"
Password: Abc123!@#
```

* Dit is het tijdelijke root wachtwoord.

---

## **Stap 2b: Root login**

1. Open je browser op dev machine:

```id="vry4lf"
http://10.0.0.4/users/sign_in
```

2. Login met:

* **Gebruikersnaam:** `root`
* **Wachtwoord:** het tijdelijke wachtwoord uit de vorige stap

3. Je wordt gevraagd om **een nieuw wachtwoord** aan te maken. Doe dit direct.

---

## **Stap 2c: Eerste project aanmaken**

1. Klik in GitLab op **“New Project”** (of **“Create blank project”**)
2. Vul in:

* **Project name:** `poc-test`
* **Visibility:** Private (voor POC, kan intern)

3. Klik **Create project**

* Je krijgt een **Git URL**:

```id="q2mxjh"
http://10.0.0.4/root/poc-test.git
```

---

## **Stap 2d: Eerste commit en push testen**

Op je dev machine:

```bash id="h7tzq1"
git clone http://10.0.0.4/root/poc.git
cd poc
echo "# POC Test" > README.md
git add README.md
git commit -m "Initial commit"
git push origin main
```

* Als alles goed is, zie je je commit verschijnen in de GitLab GUI.

---

Als je dit werkt, heb je **een volledig functionerende interne GitLab setup** zonder publieke toegang.

Zeg **next** als je wilt dat ik de **volgende stap uitleg: repo push via private IP met VPN en voorbereiding Cloud-init**.

cd existing_repo
git remote add origin http://gitlab.local/root/poc.git
git branch -M main
git push -uf origin main


Perfect, ik snap je volledig. 🎯

We zitten nu op **de fase waarin we de POC handmatig werkend hebben**, en de volgende stap is **automatiseren via Cloud-init** zodat je bij het deployen van een nieuwe VM:

* GitLab container automatisch start
* Poorten correct gemapped zijn
* Init scripts draaien
* Private IP bereikbaar is
* (Later) SSL en SSO kunnen toegevoegd worden

Laten we dit stap voor stap opbouwen.

---

## **Stap 1: Basis Cloud-init structuur**

Een cloud-init YAML bestand voor een Ubuntu VM ziet er ongeveer zo uit:

```yaml
#cloud-config
package_update: true
package_upgrade: true
packages:
  - docker.io
  - docker-compose

runcmd:
  # Zorg dat docker start
  - systemctl enable docker
  - systemctl start docker

  # GitLab container starten
  - docker run --detach \
      --hostname gitlab.sp33ltu1n.xyz \
      --publish 80:80 --publish 443:443 --publish 22:22 \
      --name gitlab \
      --restart always \
      gitlab/gitlab-ee:latest
```

* `--hostname` → straks gebruikt voor je SSL en interne DNS
* `--publish 80/443/22` → mapping naar de VM poorten (intern, private IP)
* `--restart always` → container herstart bij VM reboot

> Voor een POC kunnen we HTTPS later toevoegen via GitLab config of Let's Encrypt, nu focus op interne deploy.

---

## **Stap 2: NSG / firewall voorbereid**

Zorg dat de VM NSG inbound rules heeft voor:

* 80 (HTTP) → VPN subnet / interne dev machines
* 443 (HTTPS) → VPN subnet (later)
* 22 (SSH) → alleen beheer (optioneel)

> Cloud-init kan firewall ook configureren met `runcmd` als je wilt, maar NSG is in Azure makkelijker voor beheer.

---

## **Stap 3: Test deploy**

1. Maak nieuwe VM in Azure (zelfde VNet/subnet)
2. Koppel dit Cloud-init bestand
3. Check na deploy:

```bash
docker ps
curl -v http://<private-ip>
```

* Je moet dezelfde redirect zien `/users/sign_in`
* GUI via private IP moet bereikbaar zijn

---

💡 **Tip voor next:** zodra dit werkt, kunnen we **HTTPS via je eigen domein gitlab.sp33ltu1n.xyz** toevoegen in GitLab config in cloud-init, zodat het volledig automatisch draait bij deploy.

---

Als je wilt, kan ik nu **het volledige Cloud-init voorbeeld voor deze POC schrijven**, inclusief alle stappen zodat bij deploy alles werkt op de interne private IP.

Wil je dat ik dat doe?


Ah perfect, je ziet hem: `sdb` = jouw 128 GB data disk. 🔥

---

## **Handmatig mounten (voor nu)**

1. Partitioneren en formatteren:

```bash
sudo parted /dev/sdb --script mklabel gpt
sudo parted /dev/sdb --script mkpart primary ext4 0% 100%
sudo mkfs.ext4 /dev/sdb1
```

2. Mountpoint maken en mounten:

```bash
sudo mkdir -p /mnt/gitlab_data
sudo mount /dev/sdb1 /mnt/gitlab_data
```

3. Check:

```bash
df -h
```

4. Automount bij reboot:

```bash
echo '/dev/sdb1 /mnt/gitlab_data ext4 defaults 0 2' | sudo tee -a /etc/fstab
sudo mount -a
```

Nu is de disk persistent op deze VM.

---

## **Volgende deploys automatisch**

Hier zijn de opties:

### 1️⃣ **Bicep**

* Je kan **data disk attachen aan VM** met Bicep
* Maar Bicep kan de disk **niet automatisch partitioneren, formateren en mounten** → dat moet nog via **Cloud-init of een script**

### 2️⃣ **Cloud-init**

* Ideale plek voor **alles OS-kant:**

  * Partitie maken (`parted`)
  * Filesystem maken (`mkfs.ext4`)
  * Mountpoint maken
  * Mounten en fstab aanpassen

💡 Conclusie: **Bicep attacht de disk**, **Cloud-init zorgt dat hij klaar is voor gebruik en persistentie**.

---

Als je wilt, kan ik nu een **Cloud-init snippet maken** die dit alles automatisch doet + de GitLab container start met de juiste volumes.

Wil je dat ik dat doe?


4️⃣ Idempotent redeploy in dezelfde tenant
Bicep template checkt:
Disk bestaat al → attach
Disk bestaat niet → create
VM bestaat al → update/replace
Cloud-init script mount / Docker container idempotent → safe herdeploys
Zo kan je altijd de VM afbreken en opnieuw deployen zonder dat GitLab-data verloren gaat.

De praktische uitwerking is nu:

- laat `deploy.ps1` eerst checken of `DATA-GitLab` bestaat en bootstrapt hem anders buiten de app stack
- zet een `CanNotDelete` lock op die disk
- laat de GitLab VM alleen een bestaande disk attachen met `deleteOption: 'Detach'`
- gebruik de app stack daarna alleen voor de disposable compute-laag