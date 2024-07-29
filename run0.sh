#!/bin/sh

sed \
	-i \
	's/ALLOW_REGISTRATION = os.environ.get("ALLOW_REGISTRATION", "True") or .*/ALLOW_REGISTRATION = os.environ.get("ALLOW_REGISTRATION", "True") == "True"/' \
	rustdesk_server_api/settings.py

export ALLOW_REGISTRATION=True

HOST=127.0.0.1 sh run.sh &

while true; do
	if ! curl -I HEAD 'http://127.0.0.1:21114/api/users'; then
		sleep 1
	else
		break
	fi
done

while IFS=$'\t' read -r USERNAME PASSWORD; do
	case "${USERNAME}" in
	\#*)
		continue
		;;
	esac
	curl \
		'http://127.0.0.1:21114/api/user_action?action=register' \
		--data "user=${USERNAME}" \
		--data "pwd=${PASSWORD}"
done 0<"${INITIAL_USERLIST}"

kill $(pidof python)

sleep 5s

export ALLOW_REGISTRATION=False

exec sh run.sh
