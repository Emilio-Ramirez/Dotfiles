# yabai en macOS 27 — notas de instalación

Estado del stack de ventanas desde el 2026-10-21 (macOS 27.0.1 "Golden Gate", Apple Silicon):

| Herramienta | Versión | Origen |
|---|---|---|
| yabai | v7.1.27 (fork macOS 27) | tap `venuscrazy/yabai` |
| borders (JankyBorders) | v1.9.0 | tap `felixkratz/formulae` |
| skhd | v0.3.9 | sin cambios, sigue el de siempre |

## Por qué un fork

El yabai oficial (`asmvik/formulae`, antes koekeishiya) **no soporta macOS 27**:
cambiaron los offsets del Dock que usa el scripting addition, el chequeo de versión
rechaza major 27, y el Dock ya no auto-carga el scripting addition. El fork
"Golden Gate" ([aryanmendpara/homebrew-yabai](https://github.com/aryanmendpara/homebrew-yabai),
repo [VenusCrazy/yabai](https://github.com/VenusCrazy/yabai)) parchea las tres cosas.

```sh
brew install venuscrazy/yabai/yabai
```

Cuando el upstream soporte macOS 27: desinstalar, untap, e instalar
`asmvik/formulae/yabai` (habrá que re-otorgar Accesibilidad y regenerar el sudoers).

## Prerrequisitos que ya están puestos (no tocar)

- SIP parcial: Filesystem Protections y Debugging Restrictions deshabilitados
  (`csrutil status` dice "Custom Configuration").
- `nvram boot-args=-arm64e_preview_abi`.

## Scripting addition en macOS 27

Como el Dock ya no lo auto-carga, hay dos piezas:

1. **Regla sudoers** en `/private/etc/sudoers.d/yabai`, con el binario anclado
   por hash SHA-256 para que `sudo yabai --load-sa` no pida contraseña:

   ```
   emilio ALL=(root) NOPASSWD: sha256:<hash> /opt/homebrew/bin/yabai --load-sa
   ```

2. **Dos líneas al inicio de `yabairc`** (ya están): la señal `dock_did_restart`
   que re-inyecta cuando el Dock se reinicia, y un `--load-sa` inicial.

## ⚠️ Después de cada `brew upgrade yabai`

1. El hash del binario cambia → **regenerar la regla sudoers**:
   ```sh
   set BIN (command -v yabai)
   echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $BIN | cut -d ' ' -f 1) $BIN --load-sa" \
     | sudo tee /private/etc/sudoers.d/yabai
   sudo visudo -c -f /private/etc/sudoers.d/yabai
   ```
2. La firma (ad-hoc) cambia → **re-otorgar Accesibilidad** en
   Ajustes del Sistema → Privacidad y seguridad → Accesibilidad. Ojo: macOS deja
   la entrada vieja y agrega la nueva *apagada*; hay que prender la nueva.
   Esto aplica igual a borders.

## Troubleshooting

- **yabai no corre y el log dice `could not access accessibility features`**:
  falta el permiso de Accesibilidad del binario nuevo (ver arriba). launchd deja
  de reintentar; después de otorgarlo:
  `launchctl kickstart -k gui/501/com.asmvik.yabai`
- **`failed to inject payload into Dock.app`**: versión de yabai vieja para el
  macOS actual. Cada release de macOS mueve los offsets del Dock.
- **Espacios no cambian pero las ventanas sí se acomodan**: el scripting addition
  no está cargado; correr `sudo yabai --load-sa`.
- Logs del servicio: `/tmp/yabai_emilio.err.log` y `.out.log`.
- **Borde fantasma de borders sobre espacio vacío**: es una app oculta con ⌘H
  (pasó con Mail). Des-ocultar la app lo "atrapa"; cerrarla o des-ocultarla lo quita.
- Launch agent viejo `~/Library/LaunchAgents/com.koekeishiya.yabai.plist`
  (dic 2024): borrar si sigue ahí — compite con `com.asmvik.yabai.plist` al login.

## Historial

- **2026-10-21**: migración a macOS 27. yabai 7.1.5 → fork 7.1.27 (requirió
  actualizar Command Line Tools a Xcode 27.0); borders 1.6.0 → 1.9.0
  (`brew trust --formula felixkratz/formulae/borders` porque el tap estaba sin
  confiar); regla sudoers nueva con hash; dos líneas de carga del SA en yabairc;
  typo corregido en yabairc (`yabai -m mouse_drop_action` → `yabai -m config
  mouse_drop_action`). skhd no necesitó cambios.
