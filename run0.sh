#!/bin/sh

# If initial userlist is present, start RD API server first with registration
# enabled but listening on localhost, add users and restart with registration
# disabled

sed \
	-i \
	's/ALLOW_REGISTRATION = os.environ.get("ALLOW_REGISTRATION", "True") or .*/ALLOW_REGISTRATION = os.environ.get("ALLOW_REGISTRATION", "True") == "True"/' \
	rustdesk_server_api/settings.py

sed \
	-i \
	-e "s/salt = \"xiaomo\"/salt = \"$(tr -dc A-Za-z0-9 </dev/urandom | head -c32)\"/" \
	-e 's/EFFECTIVE_SECONDS = 7200/EFFECTIVE_SECONDS = 4000000000/' \
	api/views_front.py

# If initial SQL is present, import it to db/db.sqlite3

if [ -f "${INITIAL_USERLIST}" ]; then
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
elif [ -f "${INITIAL_SQL}" ]; then
	sqlite3 db/db.sqlite3 0<"${INITIAL_SQL}"
fi

export ALLOW_REGISTRATION=False

exec sh run.sh
