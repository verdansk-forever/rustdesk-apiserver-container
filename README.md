Self-hosted RustDesk API Server in Container
--

This repository has all the instructions to prepare [self-hosted RustDesk API server](https://github.com/xiaoyi510/rustdesk-api-server) in a distroless container.

To build image, do:

```
podman build -t localhost/rustdesk-api-server:latest -f Containerfile
```

To run it:

1. Make Podman secrets from configuration file templates in `conf`:

```
AUTHKEY="$(tr -dc a-zA-Z0-9] < /dev/urandom | head -c32)"
CRYPTKEY="$(tr -dc a-zA-Z0-9] < /dev/urandom | head -c46)"
sed "s/__AUTHKEY__/${AUTHKEY}/; s/__CRYPTKEY__/${CRYPTKEY}/" conf/config.yml.sample |
	podman secret create RUSTDESK-API-SERVER-CONFIG-YML -
podman secret create RUSTDESK-API-SERVER-APP-CONF conf/app.conf.sample
echo "Auth key: ${AUTHKEY}"
```

_NOTE: Save Auth Key as it is needed to register new accounts on server!_

2. Run the container:

```
podman run \
	-p 21114:21114 \
	--secret RUSTDESK-API-SERVER-CONFIG-YML,type=mount,target=/conf/config.yml \
	--secret RUSTDESK-API-SERVER-APP-CONF,type=mount,target=/conf/app.conf \
	localhost/rustdesk-api-server:latest
```

Register new account:

`https://<api-server-deployment-host:port>/api/reg?username=<username>&password=<password>&auth_key=<printed-auth-key>`

Using with RustDesk clients:

Set HTTPS URL of API server deployment as `API Server` in Settings -> ID/Relay Server 
