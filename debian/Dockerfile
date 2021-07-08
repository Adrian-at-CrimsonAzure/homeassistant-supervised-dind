##### https://github.com/docker-library/docker/blob/30d7b9bf7663c96fcd888bd75e9aaa547a808a23/20.10/Dockerfile
FROM debian:buster

RUN apt update; \
    apt install -y ca-certificates openssh-client wget

# set up nsswitch.conf for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/docker/docker-ce/blob/v17.09.0-ce/components/engine/hack/make.sh#L149
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
#RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV DOCKER_VERSION 20.10.6
# TODO ENV DOCKER_SHA256
# https://github.com/docker/docker-ce/blob/5b073ee2cf564edee5adca05eee574142f7627bb/components/packaging/static/hash_files !!
# (no SHA file artifacts on download.docker.com yet as of 2017-06-07 though)

RUN set -eux; \
	\
	wget -O docker.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-20.10.6.tgz"; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
	docker --version

COPY modprobe.sh /usr/local/bin/modprobe

###### DIND part starts here https://github.com/docker-library/docker/blob/30d7b9bf7663c96fcd888bd75e9aaa547a808a23/20.10/dind/Dockerfile
RUN set -eux; \
	apt install -y btrfs-progs e2fsprogs iptables openssl uidmap xfsprogs xz-utils pigz

# Fix iptables
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy; \
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN set -eux; \
	adduser --system --group dockremap; \
	echo 'dockremap:165536:65536' >> /etc/subuid; \
	echo 'dockremap:165536:65536' >> /etc/subgid

# https://github.com/docker/docker/tree/master/hack/dind
ENV DIND_COMMIT 42b1175eda071c0e9121e1d64345928384a93df1

RUN set -eux; \
	wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
	chmod +x /usr/local/bin/dind


VOLUME /var/lib/docker
EXPOSE 2375 2376

ENTRYPOINT ["dockerd"]
CMD ["sh"]