#!/bin/sh
set -e

CONF=/config/config.json
OPTS=/data/options.json

# With manual_config enabled the add-on never touches config.json — edit it by hand
# in the add-on configuration directory instead.
if [ "$(jq -r '.manual_config' "$OPTS")" = "true" ]; then
    if [ ! -f "$CONF" ]; then
        echo "manual_config is enabled but $CONF does not exist" >&2
        exit 1
    fi
else
    jq '{
        hostname: .hostname,
        homeassistant: {
            mqtt_url: .mqtt_url,
            mqtt_user: .mqtt_user,
            mqtt_pass: .mqtt_pass,
            discovery_prefix: .discovery_prefix,
            rethink_prefix: .rethink_prefix
        },
        ca_key_file: "ca.key",
        ca_cert_file: "ca.cert",
        https_port: .https_port,
        mqtts_port: .mqtts_port,
        mqtt_port: .mqtt_port,
        thinq1_https_port: .thinq1_https_port,
        thinq1_port: .thinq1_port,
        management_port: .management_port,
        bridge: { storage_path: "./state" },
        log: .log
    }' "$OPTS" > "$CONF"
fi

exec node /app/dist/rethink-cloud.js "$CONF"
