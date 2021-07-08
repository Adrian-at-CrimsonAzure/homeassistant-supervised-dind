FROM docker:dind

# Put our scripts in /usr/bin
ADD ha hassio-supervisor startup.sh /usr/bin/

    # Install the packages we need
RUN apk add --no-cache curl jq dbus; \
    # Generate a machine-id
    dbus-uuidgen > /etc/machine-id; \
    # Fix perms
    # Fix perms
    chmod +x /usr/bin/ha /usr/bin/hassio-supervisor /usr/bin/startup.sh;

EXPOSE 8123
VOLUME /usr/share/hassio

ENTRYPOINT ["/usr/bin/startup.sh"]
CMD ["sh"]