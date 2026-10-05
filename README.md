# OneTV Server — Docker, NAS and Proxmox

TV recording server for **[OneTV Connect](https://onetvconnect.com/server)** (iPhone, iPad, Apple TV, Mac).
Schedule recordings in the app; OneTV Server records them, even when your devices are off.
Included with OneTV Connect Pro. Full guide: **https://onetvconnect.com/server**

```
docker run -d --name onetv-server --network host --restart unless-stopped \
  -e TZ=Europe/Paris -v /path/to/data:/data -v "/path/to/recordings":/recordings \
  ghcr.io/seidel76/onetv-server:latest
```

Host networking is required (Bonjour/mDNS discovery). `--restart unless-stopped` = starts with the machine.

**Away from home**: the apps reach the recordings through the OneTV relay `dvr.onetvconnect.com`
(end-to-end encrypted, it stores nothing) or a direct encrypted connection it negotiates (UDP 47824,
NAT hole punching started by the server). **Nothing to open or forward on your router.** Each device
turns remote access on in its own settings; the server can refuse it (`remoteHub`).

**Web page**: `http://<address>:47821/` on your home network (Unraid: the container's **WebUI**) shows
the recording in progress (programme, channel, size, recording time, stream state) with Stop / +30 min,
upcoming and finished recordings. Other computers enter the access code shown in OneTV Connect
(Settings › Recording › Advanced) or by `docker exec onetv-server onetv-server web-code`.
Image: `ghcr.io/seidel76/onetv-server` (amd64, arm64, armv7), rebuilt for every release from the
published, checksum-verified binaries.

| System | How |
|---|---|
| **Synology DSM 7** | Package Center › Manual install of `OneTV-Server-<arch>.spk` from onetvconnect.com/server — or Container Manager › Project › [`compose/docker-compose.yml`](compose/docker-compose.yml) |
| **QNAP QTS / QuTS hero** | Container Station › Applications › Create › [`compose/docker-compose.yml`](compose/docker-compose.yml) |
| **TrueNAS SCALE 24.10+** | Apps › Discover › ⋮ › Install via YAML › [`compose/docker-compose.yml`](compose/docker-compose.yml) |
| **Unraid** | Docker › Add Container › Template URL [`unraid/onetv-server.xml`](unraid/onetv-server.xml) |
| **CasaOS / ZimaOS** | App Store › + › Install a customized app › Import [`casaos/docker-compose.yml`](casaos/docker-compose.yml) |
| **UGREEN, TerraMaster, Asustor, OpenMediaVault, Portainer** | Docker / Compose with [`compose/docker-compose.yml`](compose/docker-compose.yml) |
| **OpenMediaVault, UGOS Pro, Debian, Ubuntu, Raspberry Pi OS** | `curl -fsSL https://onetvconnect.com/server/install.sh \| sudo sh` |
| **Proxmox VE** | node › Shell: `curl -fsSL https://onetvconnect.com/server/proxmox.sh \| sh` (Debian 12 container, starts with Proxmox) |
| **Home Assistant OS** | [onetv-homeassistant](https://github.com/Seidel76/onetv-homeassistant) |
| **Windows, Mac** | installer / app on https://onetvconnect.com/server |
