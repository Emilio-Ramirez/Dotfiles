# Red de Casa — Diagnóstico y Registro

Registro técnico de la red doméstica (SSID **Enzo y su Familia**).
Creado el **2026-08-24** a raíz de lag en League of Legends por WiFi.

**Artifact con la versión visual:** https://claude.ai/code/artifact/7eca7a09-a834-4a27-8b94-6c8f9ce69b9f

---

## TL;DR — Veredicto

> **La Mac se queda pegada a un canal 2.4 GHz saturado. Todo lo demás está sano.**

El lag **no** viene del ISP, ni del doble NAT, ni del router AX10, ni del backhaul del mesh.
El mismo cable que atraviesa toda esa cadena entrega **1.8 ms de jitter y cero stalls**.
El único eslabón que falla es el salto inalámbrico.

| | WiFi | Cable |
|---|---|---|
| Peor stall | **1250 ms** | **29 ms** |
| Jitter | 113.7 ms | 1.8 ms |

**Solución de hoy:** cable Ethernet. **No comprar** mesh nuevo (ver [Qué NO comprar](#qué-no-comprar)).

---

## Topología

```
Infinitum / Huawei  →  TP-Link AX10  →  Deco M4 principal  →  Deco M4 satélite
                                              │
                                              └── Mac (WiFi 2.4 GHz ← el problema)
```

| Dato | Valor |
|---|---|
| Gateway | `192.168.1.254` — MAC `78:b4:6a:0d:14:1e` |
| Subred | `192.168.1.0/24` |
| DNS | `192.168.1.254`, `2806:10a0:ffff:3::e`, `2806:10a8:ffff:3::e` |
| MAC WiFi de la Mac | `46:8A:A4:2D:E6:6B` (privada, modo *Fixed*) |
| Tarjeta WiFi | `0x14E4 / 0x4388` — soporta a/b/g/n/ac/**ax**, capaz de 6 GHz |
| Adaptador cable probado | AX88179A (USB-C) |
| macOS | 15.6.1 (24G90) |

---

## Los sospechosos

| Sospechoso | Veredicto | Evidencia |
|---|---|---|
| ISP · Telmex / Infinitum | ✅ Inocente | 7.1 ms mínimo a 8.8.8.8 |
| Doble NAT · Huawei / PPPoE | ✅ Inocente | El cable lo atraviesa a 9.7 ms promedio |
| Router AX10 negro | ✅ Inocente | En la ruta del cable · 0 stalls |
| Backhaul del mesh Deco M4 | ✅ Inocente | Nunca estuvo en la ruta (nodo principal confirmado) |
| AWDL · AirDrop / Continuity | ⚠️ Cómplice | Causaba el packet loss (8.3% → 0%), **no** los stalls |
| **Banda 2.4 GHz · canal 10** | 🔴 **Culpable** | Tasa degradada con señal perfecta · vecino en canal 6 |

---

## Las cuatro pruebas

Comando idéntico en todas: `ping -c 300 -i 0.2 8.8.8.8` (300 paquetes, 60 s).
Todos los valores en milisegundos. *Jitter* = desviación estándar del RTT.

| # | Escenario | Pérdida | Mín | Prom | Jitter | >100 ms | Peor |
|---|---|---|---|---|---|---|---|
| 1 | WiFi lejos · AWDL activo | 8.3 % | 8.76 | 30.96 | 127.2 | 2.2 % | **1370** |
| 2 | WiFi lejos · AWDL apagado | 0.0 % | 8.57 | 31.04 | 113.7 | 3.0 % | **1250** |
| 3 | WiFi pegado al nodo (−28 dBm) | 0.0 % | 10.92 | 24.06 | 17.9 | 0.7 % | **229** |
| 4 | **Cable al Deco principal** | 0.0 % | 7.13 | **9.65** | **1.8** | **0 %** | **29** |

> **Para LoL, el número que importa es el jitter, no el promedio.**
> El promedio de 31 ms del WiFi se ve aceptable en cualquier speed test — por eso los
> tests de velocidad no detectan este problema. El daño está en los picos.

### Pruebas auxiliares

| Prueba | Resultado |
|---|---|
| 100 pkt a 8.8.8.8 | 0 % pérdida · 9.31 / 14.10 / 31.77 · σ 4.46 |
| 30 pkt a 8.8.8.8 | 0 % pérdida · 8.83 / 14.67 / 25.40 · σ 3.62 |
| 20 pkt a 1.1.1.1 | 0 % pérdida · 10.67 / 25.52 / 136.08 · σ 26.86 |
| 150 pkt al gateway | 66 % "pérdida" → **artefacto**, es rate-limiting de ICMP |
| `networkQuality` | Timeout (`NSURLErrorDomain -1001`) en el primer intento |

---

## La firma del problema

Los picos no llegan sueltos, llegan en **ráfaga descendente**:

```
1437.8 ms
1241.1 ms
1009.4 ms
 766.0 ms
 532.1 ms
 260.6 ms
  55.8 ms
```

Esa escalera es **una cola vaciándose**: la radio se detuvo, los paquetes se apilaron,
y luego salieron todos juntos con retrasos decrecientes.
Es **contención de airtime** — no pérdida de señal, no congestión del ISP.

---

## La prueba que señala al canal

Muestreo de señal y tasa **pegado al nodo**, cada 3 segundos:

| Señal | Ruido | Tasa | MCS |
|---|---|---|---|
| −31 dBm | −89 dBm | 144 Mbps | 14 |
| −26 dBm | −86 dBm | 144 Mbps | 14 |
| −24 dBm | −91 dBm | 144 Mbps | 15 |
| −24 dBm | −92 dBm | **130 Mbps** | 15 |
| −27 dBm | −91 dBm | **117 Mbps** | 14 |
| −28 dBm | −91 dBm | **130 Mbps** | 14 |

A −24 dBm estás prácticamente tocando la antena. Con el canal limpio la tasa debería
quedarse clavada en 144 Mbps. **En vez de eso oscila y se cae hasta 117.**
Una tasa que se degrada con señal impecable solo significa una cosa: **el canal está ocupado**.

---

## El aire alrededor

| Red | Canal | Ancho | Señal | Nota |
|---|---|---|---|---|
| **Enzo y su Familia** | 10 · 2.4 GHz | 20 MHz | −28 dBm | ← Conectado aquí |
| Enzo y su Familia | 44 · 5 GHz | 80 MHz | −44 dBm | Mismo SSID · **sin usar** |
| EVB-510-050-231 | 6 · 2.4 GHz | 20 MHz | −41 dBm | Vecino · **interfiere** |
| INFINITUM6C46_5 | 140 · 5 GHz | 80 MHz | — | **SSID 5 GHz separado** |
| INFINITUM6C46_2.4 | 1 · 2.4 GHz | 20 MHz | — | Del Huawei |

El router transmite en canal 10 a **40 MHz** de ancho, ocupando aprox. del canal 6 al 14.
`EVB-510-050-231` está en el canal 6, justo encima. En 2.4 GHz solo existen **tres canales
que no se traslapan**; usar 40 MHz ahí garantiza colisiones.

### Por qué la Mac no se cambia sola

macOS elige el AP con **la señal más fuerte**, y 2.4 GHz siempre se ve más fuerte porque
penetra mejor las paredes. La Mac ve 2.4 GHz a −28 dBm y 5 GHz a −44 dBm, y elige "el mejor".
Está funcionando como fue diseñada.

El trabajo del *band steering* es contrarrestar eso, y el **Deco M4 no lo hace con suficiente
fuerza — ni permite separar los SSID por banda** para quitarle la decisión al cliente.

Comprobado en la condición más favorable posible: red olvidada, MAC nueva, reasociación desde
cero, pegado al nodo. **Siguió eligiendo el canal 10.**

---

## La ruta, salto por salto

```
1  192.168.1.254      6.164 ms   ← único salto privado
2  200.38.193.226    12.170 ms   ← Telmex (público)
3  201.154.113.110   11.290 ms
4  72.14.242.160      9.864 ms   ← Google
```

Solo aparece **una capa privada**. Si hubiera doble NAT en la ruta de la Mac, deberían verse
dos antes de salir a público.

⚠️ **Advertencia honesta:** muchos ONT de ISP no responden ICMP time-exceeded y se vuelven
invisibles en traceroute. Esto es **indicio, no prueba**.

Pero para efectos prácticos da igual: el cable atraviesa esa cadena completa y entrega
9.7 ms con 1.8 ms de jitter. Sea cual sea la configuración entre el Huawei y el AX10,
**no cuesta ni un milisegundo**. Arreglar el doble NAT tiene sentido solo si algún día
necesitas port forwarding o NAT abierto en consola — nunca por latencia.

---

## Qué hacer

### 1. Hoy — Cable Ethernet para jugar
Probado con el adaptador AX88179A: cero stalls, 1.8 ms de jitter. Para ranked, tema cerrado.
Aplica igual para la Xbox.

### 2. Antes de jugar por WiFi — Apagar AWDL
```bash
sudo ifconfig awdl0 down
```
Elimina el packet loss del 8.3 %. **No arregla los stalls.** Se reactiva solo al reiniciar,
hay que repetirlo.

### 3. Gratis — Probar la red 5 GHz del Huawei
`INFINITUM6C46_5` ya está transmitiendo y **es un SSID separado** — exactamente lo que el M4
no puede dar. La contraseña viene en la etiqueta del Huawei ("WLAN Key" / "Clave WiFi").
Si sale limpia, hay WiFi decente sin gastar un peso.

**⏳ PENDIENTE — esta es la prueba que falta.**

### 4. Router — Bajar el 2.4 GHz a 20 MHz en canal 1 u 11
Quita el traslape con el vecino del canal 6. Ayuda a todos los dispositivos que sigan en
2.4 GHz, aunque no resuelve lo de la Mac.

### Qué NO comprar

**Mesh tri-banda por el backhaul dedicado** (XE75, Asus, etc.).
Es su argumento estrella, y **el backhaul ni siquiera estaba en la ruta** — la Mac estaba en
el nodo principal. Sería pagar por arreglar algo que no está roto.
El XE75 además **tampoco separa 2.4/5 GHz**.

> **Si algún día compras, el único criterio que importa es que permita separar las bandas
> por nombre.** Ni velocidad, ni WiFi 7, ni backhaul dedicado.
> Ahí es donde Asus (ZenWiFi / ROG) gana y Deco pierde por diseño.

---

## Correcciones sobre la marcha

Hipótesis que se cayeron al medirlas. Van aquí para que el registro sea honesto.

| Hipótesis | Estado | Qué la tumbó |
|---|---|---|
| «AWDL causa los stalls» | ❌ Falso | Se apagó y los stalls siguieron: 1250 ms, 3.0 % |
| «La señal fuerte prueba que estás en el nodo principal» | ❌ Inválido | La señal indica cercanía, no identidad del nodo. Se confirmó después en la app Deco |
| «66 % de pérdida al gateway» | ⚠️ Artefacto | Rate-limiting de ICMP del router. El tráfico que lo *atraviesa* tiene 0 % de pérdida |
| «Cambiar la MAC privada forzaría 5 GHz» | ❌ Sin efecto | Ya estaba en modo *Fixed*. Se probó y siguió en canal 10 |

---

## Comandos para repetir el diagnóstico

```bash
# Prueba principal: 300 paquetes, 60 segundos
ping -c 300 -i 0.2 8.8.8.8

# Contar stalls por encima de 100 ms
ping -c 300 -i 0.2 8.8.8.8 | awk -F'time=' '/time=/{split($2,a," ");t=a[1]+0;n++;if(t>100)s++}
  END{printf "%d de %d stalls >100ms (%.1f%%)\n", s, n, s*100/n}'

# Banda, canal, señal y tasa actual
system_profiler SPAirPortDataType | sed -n '/Current Network/,/Other Local/p'

# Escanear redes vecinas (canales y traslapes)
system_profiler SPAirPortDataType | sed -n '/Other Local Wi-Fi Networks/,$p'

# Apagar AWDL antes de jugar
sudo ifconfig awdl0 down

# Ver qué interfaz tiene la ruta por defecto
netstat -rn -f inet | grep '^default'

# Capas de NAT en el camino
traceroute -n -m 5 -w 2 -q 1 8.8.8.8
```

---

## Notas

**Sobre la MAC.** Está en modo privado *Fixed*, y **cambia cada vez que olvidas la red**.
Por eso la Mac aparece como «unknown» en la app Deco y desaparece de la lista tras reconectar.
Los otros dispositivos «unknown» de la lista son equipos con MAC privada, probablemente varios
de la casa. MAC anterior: `32:DE:07:2E:39:11` → actual: `46:8A:A4:2D:E6:6B`.

**Condiciones de las pruebas.** VPN y Firewall inactivos en todo momento.
`Limit IP address tracking` no afecta el tráfico de juego ni las mediciones de ping.

---

*Todas las cifras provienen de mediciones directas en el equipo. Ninguna es estimada.*
