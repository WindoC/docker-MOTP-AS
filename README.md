# docker-motp-as

## setup

1. create folder to save the dataabase.

```shell
mkdir -p /data/motp-as/db
```

2. create container

```shell
docker pull windoac/docker-motp-as
```

```shell
docker container create \
  --name=motp-as \
  --hostname `hostname` \
  --network host \
  -v /data/motp-as/db:/var/lib/mysql \
  --restart unless-stopped \
  --log-opt max-size=10m --log-opt max-file=3 \
  windoac/docker-motp-as
```

3. start the container

```shell
docker container start motp-as
```
