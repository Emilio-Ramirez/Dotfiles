# Karabiner-Elements

## TV input switching

Page Down toggles the LG webOS TV's input over the network with
[bscpylgtv](https://github.com/chros73/bscpylgtv). Page Down loses its normal scrolling function.

| TV is on | Page Down switches to |
|---|---|
| HDMI_1 (this Mac) | HDMI_2 |
| HDMI_2 or anything else | HDMI_1 |

- **TV:** `192.168.50.117`. It needs a DHCP reservation in the router, or the rule breaks when
  the IP changes.
- **Rule:** `assets/complex_modifications/tv.json` (shown under *Add predefined rule*). Karabiner
  runs the enabled copy in `karabiner.json`, so update both when changing a rule.
- **Script:** `scripts/tv-toggle.sh` asks the TV for its input (`get_input`, which returns
  `com.webos.app.hdmi1`) and then sends `set_input`. Every path in it is absolute.

### Setup on a new Mac

```fish
brew install pipx
pipx install bscpylgtv
# Pair once: accept the prompt on the TV. Saves the key to ~/.aiopylgtv.sqlite
~/.local/bin/bscpylgtvcommand 192.168.50.117 set_input HDMI_1
```

Then go to Karabiner-Elements → Complex Modifications → Add predefined rule → enable the TV rule.

### Gotchas

- **Keep `-p` with the full path to the key file.** Karabiner runs `shell_command` without
  `HOME`, so without `-p` bscpylgtv looks for `/.aiopylgtv.sqlite`, fails with
  `sqlite3.OperationalError: unable to open database file`, and the key does nothing.
- **Use absolute paths.** Karabiner doesn't use your shell's `PATH`.
- **If the TV's IP changes:** bscpylgtv saves the pairing key per IP address. Find the new IP
  (the TV listens on ports 3000 and 3001), copy the key to it in `~/.aiopylgtv.sqlite`
  (`db[new] = db[old]` with `sqlitedict`, table `unnamed`) or pair again, then update
  `scripts/tv-toggle.sh`. On 2026-10-19 it moved from `.119` to `.117`.
- **`OSError: [Errno 65] No route to host`** means the Mac couldn't reach the TV: the TV is off or
  its Wi-Fi is asleep, or Karabiner lacks permission under System Settings → Privacy & Security →
  Local Network.
- Each press makes two network calls (read the input, then switch it), so the TV takes a moment
  to react. Press once and wait. A second press before it switches can send it back.

### Debugging

1. Open **Karabiner-EventViewer** and press the key. It should show `page_down`.
2. Open Karabiner-Elements → **Log**, or
   `~/.local/share/karabiner/log/console_user_server.log`. Each press logs either
   `{'returnValue': True}` or the command's error.
3. Run `scripts/tv-toggle.sh` by hand in Terminal to separate TV problems from Karabiner problems.
