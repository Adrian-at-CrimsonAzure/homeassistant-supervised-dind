# [Home Assistant in Docker with add-on support](https://github.com/Adrian-at-CrimsonAuzre/homeassistant-supervised-dind)
Home Assistant Supervised inside a Docker container with full add-on support.

## Installation
Note: as of this commit this image only supports the `amd64-hassio-supervisor` image, it should be trivial to modify this if there's demand.
### Docker run (bind):
```bash
docker run --privileged -p 8123:8123 --mount type=bind,source="[HASSIO STORAGE]",target=/usr/share/hassio --mount type=bind,source="[DOCKER STORAGE]",target=/var/lib/docker --name hass crimsonazure/homeassistant-supervised-dind 
```
### Docker run (named volumes):
```bash
docker volume create hass_data
docker volume create hass_docker_data
docker run --privileged -p 8123:8123 -v hass_data:/usr/share/hassio -v hass_docker_data:/var/lib/docker --name hass crimsonazure/homeassistant-supervised-dind
```
### Docker compose:
```yaml
version: "3.8"

volumes:
  data:
  docker_data:

services:
  launch_hass:
    image: crimsonazure/homeassistant-supervised-dind
    privileged: true
    volumes:
      - data:/usr/share/hassio
      - docker_data:/var/lib/docker
    ports:
      - 8123:8123
```
### Docker swarm:
```yaml
version: "3.8"

volumes:
  data:
    name: hass_data
  docker_data:
    name: hass_docker_data
  
services:
  launch_hass:
    image: docker
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: sh -c "docker stop hass || true && docker rm hass || true && docker run --privileged -p 8123:8123 -v hass_data:/usr/share/hassio -v hass_docker_data:/var/lib/docker --network='Hass_default' --name hass crimsonazure/homeassistant-supervised-dind"

networks:
  default:
    attachable: true
```
Unfortunately even though `privileged: true` is technically supported in swarm it doesn't seem to work. This is a little workaround shamelessly stolen from [Bret Fisher](https://github.com/BretFisher/dogvscat/blob/master/stack-rexray.yml) to start the container with the `--privileged` flag within a swarm stack.

## Limitations
Obviously you aren't running on bare metal, so any hardware you wish to interface directly into Home Assistant will need to be passed through Docker. Thankfully the ``--privileged`` flag does that for us, but you may still encounter issues. 

## Issues
**You are running an unsupported installation**

|   |                                     |                                                                                                                               |
|---|-------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| 1 | Docker Configuration                | DIND doesn't support  `overlay2`  and  `journald` only works when systemd is installed                                        |
| 2 | AppArmor is not enabled on the host | No kernel support from the base image, I don't want to create a custom kernel for a docker image either                       |
| 3 | Systemd                             | Not installed, would have to build it from source, and the only examples I've found don't work                                |
| 4 | Operating System                    | Well we're running Alpine and I don't feel like recreating the base Docker and DIND images in Debian. Plus Alpine is lighter. |
| 5 | Network Manager                     | I have a feeling that implementing this would break other things.                                                             |

In the debian folder of this repo is a version of DIND that runs on Buster, but `systemd`, `apparmor`, and `networkmanager` don't work anyways so there's really no point.

## Contributing
I am open to PRs that add features or fix issues. If you have an idea, submit a Feature Request.