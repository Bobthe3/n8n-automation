#!/bin/sh

# check if port variable is set or go with default
if [ -z ${PORT+x} ]; then echo "PORT variable not defined, leaving N8N to default port."; else export N8N_PORT=$PORT; echo "N8N will start on '$PORT'"; fi

# regex function
parse_url() {
  eval $(echo "$1" | sed -e "s#^\(\(.*\)://\)\?\(\([^:@]*\)\(:\(.*\)\)\?@\)\?\([^/?]*\)\(/\(.*\)\)\?#${PREFIX:-URL_}SCHEME='\2' ${PREFIX:-URL_}USER='\4' ${PREFIX:-URL_}PASSWORD='\6' ${PREFIX:-URL_}HOSTPORT='\7' ${PREFIX:-URL_}DATABASE='\9'#")
}

# received url as argument
ARG_URL=${1:-""}

# override if config vars detected
if [ "$DATABASE_URL" ]
then
    ARG_URL=$DATABASE_URL
	echo $DATABASE_URL;
	echo "postgre config detected"

elif [ "$MONGODB_URI" ]
then
    ARG_URL=$MONGODB_URI
	echo "mongo config detected"

else
    echo "no config vars found"
fi

# prefix variables to avoid conflicts and run parse url function on arg url
PREFIX="N8N_DB_" parse_url "$ARG_URL"

echo "$N8N_DB_SCHEME://$N8N_DB_USER:$N8N_DB_PASSWORD@$N8N_DB_HOSTPORT/$N8N_DB_DATABASE"

# Separate host and port
N8N_DB_HOST="$(echo $N8N_DB_HOSTPORT | sed -e 's,:.*,,g')"

N8N_DB_PORT="$(echo $N8N_DB_HOSTPORT | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"

# DB switch
if [ $N8N_DB_SCHEME == 'postgres' ]
then
    echo "indentified DB in use postgreSQL"
	export DB_TYPE=postgresdb
	export DB_POSTGRESDB_HOST=$N8N_DB_HOST
	export DB_POSTGRESDB_PORT=$N8N_DB_PORT
	export DB_POSTGRESDB_DATABASE=$N8N_DB_DATABASE
	export DB_POSTGRESDB_USER=$N8N_DB_USER
	export DB_POSTGRESDB_PASSWORD=$N8N_DB_PASSWORD

elif [ $N8N_DB_SCHEME == 'mongodb' ]
then
    echo "indentified DB in use mongoDB"
	export DB_TYPE=mongodb
	export DB_MONGODB_CONNECTION_URL=$ARG_URL

else
	echo "invalid url arg"
fi

export DOMAIN_NAME=$DOMAIN_NAME
export GENERIC_TIMEZONE=$GENERIC_TIMEZONE
export N8N_BASIC_AUTH_ACTIVE=$N8N_BASIC_AUTH_ACTIVE
export N8N_BASIC_AUTH_PASSWORD=$N8N_BASIC_AUTH_PASSWORD
export N8N_BASIC_AUTH_USER=$N8N_BASIC_AUTH_USER
export N8N_HOST=$N8N_HOST
export N8N_PROTOCOL=$N8N_PROTOCOL
export SSL_EMAIL=$SSL_EMAIL
export SUBDOMAIN=$SUBDOMAIN
export WEBHOOK_URL=$WEBHOOK_URL
export N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY

# kickstart nodemation
n8n
