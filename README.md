Self-hosted RustDesk API Server in Container
--

This repository has all the instructions to prepare [self-hosted RustDesk API server](https://github.com/kingmo888/rustdesk-api-server) in container.
It can handle list of users to be registered in a form of a file that can be kept as container / cloud secret.


To build image, do:

```
podman build -t localhost/rustdesk-api-server:latest -f Containerfile
```

To run it:

1. Prepare userlist somewhere in temporary directory like:

```
# Format:
# <user-name><tab><password>
# First user becomes super-admin!
admin	password
user	user
```

NOTE: First user registered on start-up becomes super-admin!

2. Make Podman secret from configuration file:

```
podman secret create RUSTDESK-API-SERVER-USERLIST <path-to-user-file>
```

2. Run the container:

```
podman run \
	-p 21114:21114 \
	--env INITIAL_USERLIST=/etc/secrets/userlist \
	--secret RUSTDESK-API-SERVER-USERLIST,type=mount,target=/etc/secrets/userlist \
	localhost/rustdesk-api-server:latest
```

Register new account:

`curl 'https://<api-server-deployment-host:port>/api/user_action?action=register' --data 'user=<username>' --data='pwd=<password>'`

NOTE: This may fail if `ALLOW_REGISTRATION` environment variable passed to container is set to `False`

Using with RustDesk clients:

Set HTTPS URL of API server deployment as `API Server` in Settings -> ID/Relay Server 
