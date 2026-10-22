# Pi Zero — Setup Notes

Raspberry Pi Zero 2 W headless server.

## Device Info

| Item | Value |
|------|-------|
| Model | Raspberry Pi Zero 2 W |
| OS | Raspberry Pi OS Lite (64-bit) |
| Hostname | `homebridge` |
| SSH address | `homebridge.local` |
| Username | `emilioramarm` |
| Password | _(not stored here — kept private)_ |

## Localisation

| Item | Value |
|------|-------|
| Capital city | Mexico City (Mexico) |
| Time zone | America/Mexico_City |
| Keyboard layout | us |
| WiFi country | MX |

## Network

| Item | Value |
|------|-------|
| WiFi SSID | `Enzo y su Familia` (2.4 GHz — required by Zero 2 W) |
| Previous SSID | `Totalplay-2.4G-fcc0` (old house, pre 2026-08-29) |
| LAN IP | `192.168.50.146` (DHCP, ASUS router at 192.168.50.1) |
| SSH | Enabled (password auth + key) |

> The NetworkManager profile is still **named** `netplan-wlan0-Totalplay-2.4G-fcc0`
> but targets the new SSID — NM reused the existing profile instead of creating one.
> Cosmetic only; check `nmcli -g 802-11-wireless.ssid connection show <name>` for truth.

### Moving house / changing WiFi (no monitor needed)

The Pi can't be SSH'd into until it joins a network, so credentials go in via the SD
card. This image is **cloud-init** (`ds=nocloud` in `cmdline.txt`), not the old
`firstrun.sh` style, and `wpa_supplicant.conf` does nothing on Debian 13/NetworkManager.

1. Power off, put the microSD in the Mac → `bootfs` mounts (FAT32; rootfs is ext4 and
   invisible to macOS, so Homebridge data is untouchable from here).
2. Back up `network-config` and `cmdline.txt`.
3. Add the AP to `network-config` under `access-points:`. The password field takes a
   **64-hex PSK**, derived from passphrase *and* SSID — so an old PSK is useless for a
   new SSID. Derive with PBKDF2-HMAC-SHA1, 4096 iters, 32 bytes, SSID as salt:
   ```python
   hashlib.pbkdf2_hmac("sha1", pw.encode(), ssid.encode(), 4096, 32).hex()
   ```
   Sanity-check the implementation against the IEEE vector: SSID `IEEE` +
   passphrase `password` → `f42c6fc5…9710a12e`.
4. **Bump the instance id** in `cmdline.txt` (`i=rpi-imager-…` → append `-2`). Without
   this cloud-init considers it the same instance and ignores the new network config.
   Keep `cmdline.txt` on ONE line.
5. Eject, boot, wait 3-4 min.

Side effect: a new instance id makes cloud-init **regenerate the SSH host keys**, so the
Mac warns `HOST KEY HAS CHANGED`. Expected — clear it with
`ssh-keygen -R homebridge.local`.

**The plugs move too.** Feit/Tuya plugs store the old SSID as well and must be
re-paired in the Smart Life app — which mints new device IDs (see CLAUDE.md).

## Mac (control machine)

| Item | Value |
|------|-------|
| Keyboard layout | ABC (US) — also has Latin American available |
| microSD | 32 GB — shows as "Apple SDXC Reader Media" / `/dev/disk5` |

## Connect

```bash
ssh emilioramarm@homebridge.local
```

## Setup Progress

- [x] Step 1 — Flash Raspberry Pi OS Lite (64-bit) with OS customisation (hostname, SSH, WiFi, user)
- [x] Step 1b — Verified SD contents (cloud-init: hostname/user/ssh/wifi=Totalplay-2.4G-fcc0, regdom=MX) + safely ejected
- [x] Step 2 — Insert SD in Pi, power on, boot OK (first boot resized FS to 29 GB)
- [x] Step 3 — Connected via SSH (`ssh emilioramarm@homebridge.local`)
- [x] Step 4 — Added SSH public key (`~/.ssh/id_ed25519.pub`), keyless login working
- [x] Step 5 — SSH shortcut `ssh homebridge` added to ~/.ssh/config
- [x] Step 6 — System updated (apt full-upgrade), rebooted, verified clean after accidental power loss
- [x] Step 7 — Installed Homebridge 2.0.11 via official apt repo (repo.homebridge.io) → Node.js + Config UI X + systemd service
- [x] Step 8 — Installed @0x5e/homebridge-tuya-platform (fork), configured PaaS/Smart Home, login OK, 4 devices imported
- [ ] Step 9 — Pair Homebridge bridge with Apple Home (scan QR / setup code 736-38-110)

### Tuya plugin config that worked (@0x5e/homebridge-tuya-platform)
- Project Type: **PaaS** (Smart Home)
- App (appSchema): **Smart Life**  ← wrong value here was the cause of repeated `code=1106 permission deny`
- Country Code: **52** (Mexico)
- Username/Password: Smart Life **email** account (NOT Apple sign-in — social login does not work)
- Endpoint auto-selected: https://openapi.tuyaus.com (Western America)
- Devices imported: Desktop, Lámpara, Lava, Lamp (home "My Home", home_id 82410958)

### ⚠️ TODO security: regenerate Tuya Access Secret (was pasted in chat during setup)

## Homebridge

| Item | Value |
|------|-------|
| Version | 2.0.11 (apt repo `repo.homebridge.io stable`) |
| Service | `homebridge.service` (systemd, enabled + running) |
| Web UI | http://homebridge.local:8581 (or http://192.168.50.146:8581) |
| Purpose | Feit Electric WiFi smart plugs (Tuya-based, model BPPLUG/WIFI/3/MX) → Apple Home |
| RAM footprint | ~232 MB used / ~182 MB free; swap 414 MB (barely used) |

### Service commands
```bash
sudo systemctl status homebridge
sudo systemctl restart homebridge
sudo journalctl -u homebridge -f     # live logs
```

### Tuya IoT Cloud Project (created 2026-07-29)
- App used to control plugs: **Smart Life** (Tuya) — has built-in QR scanner for linking
- Project name: `homebridge`
- Data Center: **Western America**
- Access ID / Client ID: `uufg5kjdxkcyapgjvfvx`
- Access Secret: _(kept private — NOT stored here; consider regenerating)_
- Project Code: `p1785349675999v77py3`

### Next: Tuya plugin (to do via web UI)
- Link Feit/Smart Life app account to the Tuya project (QR scan) — makes devices visible
- In the Homebridge UI: Plugins → search "Tuya" → install `homebridge-tuya-platform`
- Configure with Access ID / Secret, Western America region, app account


## Live System (as of first setup)

| Item | Value |
|------|-------|
| Model | Raspberry Pi Zero 2 W Rev 1.0 |
| OS | Debian 13 (trixie) / Pi OS Lite 64-bit |
| Kernel | 6.18.34 aarch64 |
| LAN IP | 192.168.50.146 |
| RAM | 415 MB total |
| Disk | 29 GB (mmcblk0p2), ~8% used |

## Notes

<!-- Add your own notes below -->
