#!/bin/sh
set -e

setup () {
CONFIG=$1

KEY=$(dd if=/dev/urandom bs=1 count=16 2>/dev/null | od -A n -t u1 | awk '{printf "["} {for(i = 1; i< NF; i++) {printf "%s, ", $i}} {printf "%s]\n", $NF}' | head -n 1)

cat > ${CONFIG} <<EOF
homeassistant: false
permit_join: false
mqtt:
  base_topic: zigbee2mqtt
  server: '${MQTT_HOST}'
  user: ${MQTT_USER}
  password: ${MQTT_PASS}
serial:
  port: '${GIVELINK_PORT}'
advanced:
  network_key: ${KEY}
  log_output:
  - console
  cache_state: false
EOF
}

update_serial_port() {
    sed -i "s@server:.*@server: '${MQTT_HOST}'@" $1
    sed -i "s@user:.*@user: ${MQTT_USER}@" $1
    sed -i "s@password:.*@password: ${MQTT_PASS}@" $1
    sed -i "s@port:.*@port: '${GIVELINK_PORT}'@" $1
}

if [ ! -z "$ZIGBEE2MQTT_DATA" ]; then
    DATA="$ZIGBEE2MQTT_DATA"
else
    DATA="/app/data"
fi

echo "Using '$DATA' as data directory"

if [ -f "$DATA/configuration.yaml" ]; then
    echo "Update configuration file..."
    update_serial_port "$DATA/configuration.yaml"
else
    echo "Creating configuration file..."
    setup "$DATA/configuration.yaml"
fi

exec "$@"
