FROM docker:dind

# Make all of our directories
RUN mkdir -p /usr/share/hassio/docker
VOLUME /usr/share/hassio

RUN apk add curl jq dbus

RUN dbus-uuidgen > /etc/machine-id

# Put our files where they need to be
ADD ha /usr/bin/
ADD hassio-supervisor /usr/sbin/
ADD startup.sh /app/

# Fix perms
RUN chmod +x /usr/bin/ha /usr/sbin/hassio-supervisor /app/startup.sh

EXPOSE 8123

ENTRYPOINT ["/app/startup.sh"]

CMD ["sh"]