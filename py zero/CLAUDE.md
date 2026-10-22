# CLAUDE.md — Pi Zero / Homebridge

Instructions for Claude Code when working on this Raspberry Pi / Homebridge setup.
Full setup history and details are in `README.md` (same folder).

## What this is

A **Raspberry Pi Zero 2 W** (hostname `homebridge`) acting as a headless home server
running **Homebridge**, which bridges **Feit Electric WiFi smart plugs (Tuya-based)**
into Apple's native **Home** app. Control machine is Emilio's Mac.

## Connecting to the Pi

- Shortcut: `ssh homebridge` (configured in `~/.ssh/config`).
- Direct: `ssh emilioramarm@192.168.50.146` (LAN IP, DHCP — may change) or
  `ssh emilioramarm@homebridge.local` (mDNS — occasionally flaky, prefer IP for long ops).
- Auth is key-based (`~/.ssh/id_ed25519`), passwordless. `sudo` on the Pi is passwordless.
- **Prefer the IP over `.local` for long/automated commands** — restarting services
  (e.g. avahi) briefly kills mDNS and drops `.local` connections mid-command.

## Homebridge essentials

- Web UI: `http://homebridge.local:8581` (or `http://192.168.50.146:8581`).
  - From a browser on the Mac, LAN access needs macOS **Local Network** permission
    granted to that browser (Safari has it; Zen/Firefox must be enabled in
    System Settings → Privacy & Security → Local Network, then fully quit + reopen).
- Service: `homebridge.service` (systemd, enabled). Manage with:
  ```bash
  sudo systemctl status|restart homebridge
  ```
- **Logs are NOT in journald.** The detailed log (plugin output, Tuya, errors) is at
  `/var/lib/homebridge/homebridge.log`. journald only shows the supervisor start lines.
  ```bash
  sudo grep -iE 'tuya|error|device' /var/lib/homebridge/homebridge.log | tail -30
  ```
- Config: `/var/lib/homebridge/config.json` (owned by `homebridge:homebridge`).

## Editing config.json safely

Always: back up, edit with `jq --argjson`, validate with `jq empty`, restore ownership,
restart, then confirm via the log. Never hand-edit blindly.
```bash
sudo cp config.json config.json.bak.$(date +%Y%m%d-%H%M%S)
# ...jq edit into a temp file, validate, then...
sudo chown homebridge:homebridge config.json
```
The Tuya platform block is `.platforms[] | select(.platform=="TuyaPlatform")`;
its settings live under `.options`. Config contains the Tuya secret + Smart Life
password — avoid dumping the whole file; use `jq` to touch only what you need.

## Tuya plugin — @0x5e/homebridge-tuya-platform

Working config (do not change lightly):
- `projectType`: **PaaS** / Smart Home (project created with "Smart Home" method on iot.tuya.com)
- `appSchema`: **smartlife** (Smart Life app — NOT Tuya Smart)
- `countryCode`: **52** (Mexico)
- `username`/`password`: Smart Life **email** account. Apple/Google/social sign-in does NOT work.
- Endpoint auto-resolves to `https://openapi.tuyaus.com` (Western America data center).

Gotchas:
- `Login failed. code=1013, msg=request time is invalid` + a burst of
  `getaddrinfo EAI_AGAIN openapi.tuyaus.com` = **boot-order problem after a power cut**,
  not a credentials problem. The Zero 2 W has no RTC (`RTC time: n/a`), so on boot the
  clock is wrong until NTP syncs; Tuya signs requests with a timestamp and rejects the
  skew. The plugin burns its retries during that window and then **never retries login
  again** — Homebridge stays "up" with dead accessories until restarted.
  - Immediate fix: `sudo systemctl restart homebridge` (once network + clock are good).
  - Permanent fix (applied 2026-08-12): drop-in
    `/etc/systemd/system/homebridge.service.d/wait-for-net.conf` adds
    `After=/Wants=network-online.target systemd-time-wait-sync.service`, and
    `systemd-time-wait-sync.service` is enabled so boot blocks until NTP sets the clock.
    `NetworkManager-wait-online.service` must stay enabled or `network-online.target`
    is meaningless.
  - Diagnosing: `uptime -p` vs. the timestamp of the last Tuya log line — if the last
    login attempt is at boot time and hours old, this is it.
  - The log is binary-ish (ANSI codes); use `grep -a`, not plain `grep`.
- `code=28841002, msg=No permissions. Your subscription to cloud development plan has
  expired` = the **Tuya IoT Cloud trial lapsed** — nothing to do with credentials or the
  network. Login and MQTT still succeed; only `Fetching home list` fails, so every
  accessory goes dead. Tuya's free tier is 1 month from project creation
  (project made 2026-07-29 → first expiry 2026-08-29), extendable free.
  - Fix: iot.tuya.com → Cloud → Cloud Services → IoT Core → project `homebridge` →
    renew/extend, then `sudo systemctl restart homebridge`.
  - **Propagation takes ~2-10 min.** An immediate restart after renewing still shows
    28841002 — that is not a failed renewal, just wait and restart again.
- `Login failed. code=1106, msg=permission deny` = wrong `appSchema`/`countryCode`/
  credentials, OR the Smart Life account isn't linked to the Tuya cloud project.
- Switching Smart Life accounts requires re-linking (QR scan) in Tuya IoT → Devices →
  Link App Account, AND devices only belong to one account (re-pair to move them).
- **Noise DPs** (e.g. `switch_inching`) show as junk accessories. Hide them with a
  global `deviceOverrides` entry in `.options`:
  ```json
  "deviceOverrides": [
    { "id": "global", "schema": [ { "code": "switch_inching", "hidden": true } ] }
  ]
  ```
  Use `"id": "global"` to apply to all devices, or a specific device id.
  Advanced options: https://github.com/0x5e/homebridge-tuya-platform/blob/develop_1.7.0/ADVANCED_OPTIONS.md

## Current devices

`My Home` (home_id 82410958). After the house move (2026-08-29) the plugs were
re-provisioned onto the new WiFi and came back with **new Tuya device IDs**, so the
pre-move registrations are dead entries:

| Name | Device ID | State |
|------|-----------|-------|
| Lámpara 3 | `ebd96b9158ab0e377etdld` | online |
| Lamp 1 | `ebb683ad5d59c95e60aurm` | online |
| Lamp 4 | `ebf5a9a807ee5944d3yee8` | online |
| Lamp 2 | `ebb4b48477cf61662af4dq` | online |
| Desktop | `eb0c923ae006b74faaojou` | stale — delete |
| Power 1 | `eb2efccc2920dbc16f3qo7` | stale — delete |
| Power 2 | `eb021152a8ace0da07azsv` | stale — delete |

**Re-pairing a plug always mints a new device ID.** The old one lingers in the Tuya
account and shows in Apple Home as permanent "No Response". Delete stale devices in the
Smart Life app, then restart homebridge.

**HomeKit display names are sticky — renaming in Smart Life does NOT rename an
accessory HomeKit already knows.** The Tuya name is only used the first time an
accessory is added; after that the name belongs to HomeKit. Rename in the **Apple Home
app**. This is why names drift out of sync, e.g. after the 2026-08-29 move:

| Shows in Home as | Actually is | Device ID |
|---|---|---|
| Lámpara | Lámpara 3 | `ebd96b9158ab0e377etdld` |
| Lava | Lamp 4 | `ebf5a9a807ee5944d3yee8` |
| Lamp | Power 2 (dead) | `eb021152a8ace0da07azsv` |

Map by device ID, never by name — join `persist/TuyaDeviceList.*.json` against
`accessories/cachedAccessories` on `context.deviceID`.

## TP-Link Kasa plugin — homebridge-tplink-smarthome

Added 2026-08-30. Two **HS100(US) hw 2.0** plugs. Unlike Tuya this is **100% local
LAN** — no cloud account, no API subscription, no signed timestamps — so none of the
Tuya failure modes above apply to it.

| Alias | IP | MAC | Signal |
|-------|----|-----|--------|
| Lamp 5 | 192.168.50.120 | `68:FF:7B:C5:0A:A4` | -73 dBm (weak) |
| Lamp 6 | 192.168.50.223 | `68:FF:7B:C5:0F:A0` | -47 dBm (good) |

Config block in `config.json` pins them by IP:
```json
{ "platform": "TplinkSmarthome", "name": "TplinkSmarthome",
  "devices": [ { "host": "192.168.50.120" }, { "host": "192.168.50.223" } ] }
```

Gotchas:
- **The AP drops UDP broadcast**, so the plugin's normal auto-discovery finds nothing.
  Devices must be listed explicitly under `devices`. Symptom of this: UDP 9999/20002
  broadcast probes return zero replies while TCP 9999 to the device works fine.
- **Pinned IPs are DHCP leases.** Set DHCP reservations on the ASUS for both MACs
  (LAN → DHCP Server → Manual Assignment) or a lease change silently kills them.
- **HS100 accepts only ONE connection at a time on port 9999.** Once Homebridge is
  running, an external query (e.g. a discovery script) will time out — that is
  contention, not a dead device. Stop homebridge first if you need to probe directly.
- HS100 is **not** Matter-capable, so it genuinely needs Homebridge. Newer Kasa models
  (KP125M, EP25, KS205) pair straight into Apple Home and skip the Pi entirely.
- Probe scripts kept at `/tmp/kasa_discover.py` and `/tmp/kasa_query.py` on the Pi
  (legacy XOR-autokey protocol, key 171; TCP frames are 4-byte big-endian
  length-prefixed).

## Open TODO

- [ ] **Regenerate the Tuya Access Secret** — it was pasted in chat during setup.
  Reset in Tuya IoT → project → Overview, update `accessKey` in the plugin, restart,
  confirm login still succeeds in the log.
