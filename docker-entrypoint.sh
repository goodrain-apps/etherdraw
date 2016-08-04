#!/usr/bin/env bash

echo "now sleep 10 for prepare db or config..."
sleep 10

export RESET=${RESET:-0}
export PORT=${PORT:-5000}
export DB_TYPE=${DB_TYPE:-'dirty'}
if [[ ${DB_TYPE} = 'dirty' ]]; then
    echo "you choose dirty store data."
    export DIRTY_DB=${DIRTY_DB:-"/data/dirty.db"}
else
    echo "you choose mysql store data."
    export MYSQL_HOST=${MYSQL_HOST:-$MYSQL_PORT_3306_TCP_ADDR}
    if [[ -z "${MYSQL_HOST}" ]]; then
        echo "you set db_type is mysql but we does not discover mysql, so use dirty now."
        export DB_TYPE='dirty'
        export DIRTY_DB='/data/dirty.db'
    else
        echo "we discover mysql, now check database."
        export MYSQL_USER=${MYSQL_USER:-root}
        export MYSQL_PASS=${MYSQL_PASS:-$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
        export MYSQL_PORT=${MYSQL_PORT:-$MYSQL_PORT_3306_TCP_PORT}
        if [[ -z ${MYSQL_PORT} ]];then
            export MYSQL_PORT=${MYSQL_PORT_3306_TCP_PORT}
        else
            if [[ ${#MYSQL_PORT} -gt 8 ]]; then
                export MYSQL_PORT=${MYSQL_PORT_3306_TCP_PORT}
            else
                export MYSQL_PORT=${MYSQL_PORT}
            fi
        fi
        export MYSQL_DATABASE=${MYSQL_DATABASE:-'etherdraw'}
    fi
fi


if [[ ${RESET} -ne 0 ]]; then
    echo "now clear all db and config"
    if [[ ${DB_TYPE} = 'dirty' ]]; then
        rm -rf /data/dirty.db
    else
        echo "clear mysql db"
        cat > clear.sql <<EOF
DROP DATABASE IF EXISTS ${MYSQL_DATABASE};
EOF
        mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASS} -P${MYSQL_PORT} < clear.sql
    fi
    rm -rf /data/*
fi

if [[ ${DB_TYPE} = 'mysql' ]]; then
    cat > init.sql <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
EOF
    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASS} -P${MYSQL_PORT} < init.sql
    echo "config mysql host:${MYSQL_HOST} port:${MYSQL_PORT} user:${MYSQL_USER} pass:${MYSQL_PASS}"
fi


export SSL_KEY=${SSL_KEY:-''}
export SSL_CERT=${SSL_CERT:-''}
if [[ ${SSL_KEY} != '' ]]; then
    curl -sL --retry=3 ${SSL_KEY} -o /data/key.key
fi
if [[ ${SSL_CERT} != '' ]]; then
    curl -sL --retry=3 ${SSL_CERT} -o /data/cert.cert
fi

cd /app/draw

if [[ -f /data/settings.json ]]; then
    cp /data/settings.json /app/draw/
    chown -R rain:rain /app
else
    cat > settings.json <<EOF
{
  "ip" : "0.0.0.0",
  "port" : ${PORT},
  "dbType" : "${DB_TYPE}",
EOF

    if [[ ${DB_TYPE} = 'dirty' ]]; then
        cat >> settings.json <<EOF
  "dbSettings" : {
     "filename" : "${DIRTY_DB}"
  },
EOF
    else
        cat >> settings.json <<EOF
  "dbSettings" : {
    "user"    : "${MYSQL_USER}",
    "host"    : "${MYSQL_HOST}",
    "password": "${MYSQL_PASS}",
    "port"    : ${MYSQL_PORT},
    "database": "${MYSQL_DATABASE}"
  },
EOF
    fi

    if [[ ${SSL_KEY} != '' ]]; then
        cat >> settings.json <<EOF
  "ssl" : {
    "key": "/data/key.key",
    "cert": "/data/cert.crt"
  },
EOF
    fi

    cat >> settings.json <<EOF
  "tool": "brush"
}
EOF

    cp settings.json /data
fi


if [[ $1 = "bash" ]]; then
    /bin/bash
else
    bin/run.sh
fi



