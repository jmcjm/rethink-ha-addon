# ReThink Cloud add-on (unofficial fork)

Runs the [jmcjm/rethink](https://github.com/jmcjm/rethink) fork (`deploy` branch) of
[anszom/rethink](https://github.com/anszom/rethink) — a fully-local cloud server for
LG ThinQ devices — directly on Home Assistant OS. On top of upstream, the fork adds a
handler for the RH90V9_WW heat-pump dryer and extended remote control for the
Y_V8_Y___W.B32QEUK washer (EU). Not affiliated with upstream.

## How it works

LG devices resolve `common.lgthinq.com`; your router must hijack that DNS name to the
Home Assistant host IP (and DNAT stray DNS/NTP from the IoT VLAN). The add-on runs with
host networking and binds:

| Port  | Role                          |
| ----- | ----------------------------- |
| 443   | HTTPS (ThinQ2 API)            |
| 8884  | MQTTS (device connection)     |
| 1884  | plain MQTT (local debugging)  |
| 46030 | ThinQ1 HTTPS                  |
| 47878 | ThinQ1 plain                  |
| 44401 | management panel              |

The management panel is available at `http://<ha-host>:44401`.

## Configuration

All state lives in the add-on configuration directory
(`/addon_configs/<slug>_rethink/`), which maps to `/config` inside the container:

```
config.json   main configuration
ca.key        CA private key   — losing this forces re-provisioning of all devices
ca.cert       CA certificate
state/        bridge state (oauth2 token, device registrations)
```

On first start a default `config.json` is created. Edit it and restart the add-on.

### Migrating from an existing rethink instance

1. Install the add-on but do not start it yet.
2. Copy your entire data directory (`config.json`, `ca.key`, `ca.cert`, `state/`)
   into `/addon_configs/<slug>_rethink/` (Samba/SSH add-on or the Studio Code Server
   add-on will do).
3. **Do not change `hostname`** in `config.json` — it must keep matching the CN of
   the existing `ca.cert`, otherwise the server generates a fresh CA and every LG
   device has to be re-provisioned through its SoftAP.
4. Point `homeassistant.mqtt_url` at the local broker, e.g.
   `mqtt://localhost:1883`, and put the broker credentials into
   `homeassistant.mqtt_user` / `homeassistant.mqtt_pass`.
5. Start the add-on and watch the log; devices should reconnect within a minute or
   two of their next DNS lookup.

## Notes

- `boot` is `manual` by default — switch it to auto once you have verified the setup.
- Port 443 must be free on the host; HAOS itself does not use it, but another add-on
  (e.g. NGINX proxy) might.
