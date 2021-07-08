#!/bin/sh

/usr/local/bin/dockerd &

# Hass needs this for system control
/usr/bin/dbus-daemon --config-file=/usr/share/dbus-1/system.conf  --print-address

# Wait to make sure docker is running
until docker version > /dev/null 2>&1
do
  sleep 1
done

docker image pull homeassistant/amd64-hassio-supervisor

/usr/sbin/hassio-supervisor