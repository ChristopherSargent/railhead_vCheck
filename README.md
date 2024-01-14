![alt text](rh_small_logo.jpg)
* This repository contains instructions for using vCheck at Railhead. For any additional details or inquiries, please contact us at christopher.sargent@sargentwalker.io.

* Original vCheck Page](https://github.com/alanrenouf/vCheck-vSphere)

# AWX Prerequisites
* Deploy VM in rdu1-vcenter.mgmt.adtihosting.com
* [Ubuntu 20.04 STIG Hardened FIPS Enabled](https://docs.google.com/document/d/1nEIavbELGl8xjHjZX4p22q5m32HCLkLH/edit#heading=h.gjdgxs)
1. ssh onrails@184.94.220.211
2. sudo -i
3. ip link set ens192 down
4. apt update && apt upgrade -y
5. apt -y install ansible apt-transport-https ca-certificates curl gnupg-agent software-properties-common
6. curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
7. add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
8. apt update && apt install docker-ce docker-ce-cli containerd.io -y && apt remove docker docker.io containerd runc
9. curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
10. chmod +x /usr/local/bin/docker-compose
11. docker version && docker-compose version
```
Client: Docker Engine - Community
 Version:           24.0.7
 API version:       1.43
 Go version:        go1.20.10
 Git commit:        afdd53b
 Built:             Thu Oct 26 09:08:01 2023
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          24.0.7
  API version:      1.43 (minimum version 1.12)
  Go version:       go1.20.10
  Git commit:       311b9ff
  Built:            Thu Oct 26 09:08:01 2023
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.26
  GitCommit:        3dd1e886e55dd695541fdcd67420c2888645a495
 runc:
  Version:          1.1.10
  GitCommit:        v1.1.10-0-g18a0cb0
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
docker-compose version 1.29.2, build 5becea4c
docker-py version: 5.0.0
CPython version: 3.7.10
OpenSSL version: OpenSSL 1.1.0l  10 Sep 2019
```
12. systemctl enable docker.service && systemctl start docker.service

# Install AWX
* Git clone AWX 23.5.1 , configure project, build images and deploy AWX containers
1. ssh onrails@184.94.220.211
2. sudo -i
3. cd /home && git clone -b 23.5.1 https://github.com/ansible/awx.git
4. cd /home && mv awx awx23 && cd /home/awx23/tools/docker-compose
5. vim inventory
```
localhost ansible_connection=local ansible_python_interpreter="/usr/bin/env python3"

[all:vars]

# AWX-Managed Database Settings
# If left blank, these will be generated upon install.
# Values are written out to tools/docker-compose/_sources/secrets/
pg_password="addpassword"
broadcast_websocket_secret="addpassword"
secret_key="addkey"

# External Database Settings
# pg_host=""
# pg_password=""
# pg_username=""
# pg_hostname=""

awx_image="ghcr.io/ansible/awx_devel"
# migrate_local_docker=false
```
* Note the following take a few minutes each
6. cd /home/awx23
7. make docker-compose-build
8. docker image ls
```
REPOSITORY                  TAG       IMAGE ID       CREATED          SIZE
ghcr.io/ansible/awx_devel   HEAD      8f12c183549f   49 seconds ago   2.05GB
quay.io/ansible/awx-ee      latest    2dfb71399e33   15 months ago    1.85GB
guacamole/guacd             latest    4ead91078479   15 months ago    271MB
guacamole/guacamole         latest    1986410fc9e8   15 months ago    432MB
nginx                       latest    2d389e545974   15 months ago    142MB
<none>                      <none>    9b7bff0a9ee9   16 months ago    1.8GB
quay.io/ansible/receptor    devel     981db0fc0f90   16 months ago    233MB
postgres                    12        f2f1f275f1a1   16 months ago    373MB
redis                       latest    dc7b40a0b05d   16 months ago    117MB
postgres                    13.4      113197da0347   2 years ago      371MB
```
9. cd /home/awx23 && make docker-compose COMPOSE_UP_OPTS=-d
10. docker exec tools_awx_1 make clean-ui ui-devel
11. docker exec -ti tools_awx_1 awx-manage createsuperuser
* Note. Save password.
```
Username: christopher.sargent
Email address: christopher.sargent@railhead.io
Password:
Password (again):
Superuser created successfully.
```
12. cp /root/.bashrc /root/.bashrc.ORIG
13. vi /root/.bashrc (add the following aliases)
```
alias awx21-start='cd /home/awx21/awx/tools/docker-compose/_sources/ && docker-compose up -d'
alias awx21-stop='cd /home/awx21/awx/tools/docker-compose/_sources/ && docker-compose down'
alias awx23-start='cd /home/awx23/tools/docker-compose/_sources && docker-compose up -d'
alias awx23-stop='cd /home/awx23/tools/docker-compose/_sources && docker-compose down'
alias awx='cd /var/lib/awx/projects/'
```
14. source /root/.bashrc
15. awx23-stop
```
Stopping tools_awx_1      ... done
Stopping tools_redis_1    ... done
Stopping tools_postgres_1 ... done
Removing tools_awx_1      ... done
Removing tools_redis_1    ... done
Removing tools_postgres_1 ... done
Removing network _sources_default
```
16. cp /home/awx23/tools/docker-compose/_sources/docker-compose.yml /home/awx23/tools/docker-compose/_sources/docker-compose.yml.ORIG

17. vim /home/awx23/tools/docker-compose/_sources/docker-compose.yml
* Note we are adding the bind mount - "/var/lib/awx/projects:/var/lib/awx/projects:rw", setting restart: always so the containers come back up on reboot and updating the ports from 8043:8043 to 443:8043
```
---
version: '2.1'
services:
  # Primary AWX Development Container
  awx_1:
    user: "0"
    image: "ghcr.io/ansible/awx_devel:HEAD"
    container_name: tools_awx_1
    hostname: awx_1
    command: launch_awx.sh
    environment:
      OS: " Operating System: Ubuntu 20.04.6 LTS"
      SDB_HOST: 0.0.0.0
      SDB_PORT: 7899
      AWX_GROUP_QUEUES: tower
      MAIN_NODE_TYPE: "${MAIN_NODE_TYPE:-hybrid}"
      RECEPTORCTL_SOCKET: /var/run/awx-receptor/receptor.sock
      CONTROL_PLANE_NODE_COUNT: 1
      EXECUTION_NODE_COUNT: 0
      AWX_LOGGING_MODE: stdout
      DJANGO_SUPERUSER_PASSWORD: IjSoBxodEzhvIpOjeXIB
      UWSGI_MOUNT_PATH: /
      RUN_MIGRATIONS: 1
    links:
      - postgres
      - redis_1
    working_dir: "/awx_devel"
    volumes:
      - "../../../:/awx_devel"
      - "../../docker-compose/supervisor.conf:/etc/supervisord.conf"
      - "../../docker-compose/_sources/database.py:/etc/tower/conf.d/database.py"
      - "../../docker-compose/_sources/websocket_secret.py:/etc/tower/conf.d/websocket_secret.py"
      - "../../docker-compose/_sources/local_settings.py:/etc/tower/conf.d/local_settings.py"
      - "../../docker-compose/_sources/nginx.conf:/etc/nginx/nginx.conf"
      - "../../docker-compose/_sources/nginx.locations.conf:/etc/nginx/conf.d/nginx.locations.conf"
      - "../../docker-compose/_sources/SECRET_KEY:/etc/tower/SECRET_KEY"
      - "../../docker-compose/_sources/receptor/receptor-awx-1.conf:/etc/receptor/receptor.conf"
      - "../../docker-compose/_sources/receptor/receptor-awx-1.conf.lock:/etc/receptor/receptor.conf.lock"
      # - "../../docker-compose/_sources/certs:/etc/receptor/certs"  # TODO: optionally generate certs
      - "/sys/fs/cgroup:/sys/fs/cgroup"
      - "~/.kube/config:/var/lib/awx/.kube/config"
      - "./tools_redis_socket_1:/var/run/redis/:rw"
      - "/var/lib/awx/projects:/var/lib/awx/projects:rw"
    privileged: true
    tty: true
    ports:
      - "7899-7999:7899-7999"  # sdb-listen
      - "6899:6899"
      - "8080:8080"  # unused but mapped for debugging
      - "8888:8888"  # jupyter notebook
      - "8013:8013"  # http
      - "443:8043"  # https
      - "2222:2222"  # receptor foo node
      - "3000:3001"  # used by the UI dev env
  redis_1:
    image: redis:latest
    container_name: tools_redis_1
    volumes:
      - "../../redis/redis.conf:/usr/local/etc/redis/redis.conf:Z"
      - "./tools_redis_socket_1:/var/run/redis/:rw"
    entrypoint: ["redis-server"]
    command: ["/usr/local/etc/redis/redis.conf"]
  # A useful container that simply passes through log messages to the console
  # helpful for testing awx/tower logging
  # logstash:
  #   build:
  #     context: ./docker-compose
  #     dockerfile: Dockerfile-logstash
  postgres:
    image: postgres:12
    container_name: tools_postgres_1
    # additional logging settings for postgres can be found https://www.postgresql.org/docs/current/runtime-config-logging.html
    command: postgres -c log_destination=stderr -c log_min_messages=info -c log_min_duration_statement=1000 -c max_connections=1024
    environment:
      POSTGRES_HOST_AUTH_METHOD: trust
      POSTGRES_USER: awx
      POSTGRES_DB: awx
      POSTGRES_PASSWORD: Butt3rT@Nk2#@!
    volumes:
      - "./awx_db:/var/lib/postgresql/data"

#volumes:
#  awx_db:
#    name: tools_awx_db
#  redis_socket_1:
#    name: tools_redis_socket_1
```
18. awx23-start
```
Creating network "_sources_default" with the default driver
Creating tools_redis_1    ... done
Creating tools_postgres_1 ... done
Creating tools_awx_1      ... done
```
19. https://rdu-awx01/ > Login to AWX

![Screenshot](resources/awxlogin.JPG)

* See AWX configuration details under awx_config/README.md

