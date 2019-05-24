#!/bin/bash
set -e

RSPAMD_CONTROLLER_PASSWORD="${RSPAMD_CONTROLLER_PASSWORD:-q1}"
SPAM_FOLDER="${SPAM_FOLDER:-Junk}"
PUID="${PUID:-5000}"
PGID="${PGID:-5000}"

if [ "$1" = 'dovecot' ]; then
    if [ $(getent group vmail) ]; then
        delgroup vmail
    fi
    if [ $(getent passwd vmail) ]; then
        deluser vmail
    fi
    addgroup -g $PGID vmail && adduser -u $PUID -G vmail -h /var/vmail -D -s /sbin/nologin vmail
    mkdir -p /var/vmail/conf.d /var/vmail/auth.d
    chown -R vmail:vmail /var/vmail/conf.d
    chown -R dovecot:dovecot /var/vmail/auth.d/
    chown vmail:vmail /var/vmail
    chmod 500 /var/vmail/conf.d/
    chmod 750 /var/vmail/auth.d/
    
    echo "!include /config/*.conf" > /etc/dovecot/dovecot.conf
    rm -rf /config /usr/lib/dovecot/sieve/*.sieve /usr/lib/dovecot/sieve-pipe
    mkdir -p /config /usr/lib/dovecot/sieve-pipe
    cp /config.staged/*.conf /config
    cp /config.staged/*.sieve /usr/lib/dovecot/sieve
    cp /config.staged/rspamd-controller.conf.sh /etc/dovecot/rspamd-controller.conf.sh
    sed -i -e 's/logger -p mail.err/echo error:/g' -e 's/logger -p mail.debug/echo debug:/g' -e 's/exec //g' /config.staged/learn-spam.rspamd.script
    cp /config.staged/learn-spam.rspamd.script /usr/lib/dovecot/sieve-pipe/learn-spam.rspamd.script
    cp /config.staged/learn-spam.rspamd.script /usr/lib/dovecot/sieve-pipe/learn-ham.rspamd.script
    chmod +x /usr/lib/dovecot/sieve-pipe/*.script

    # replace spam folder from INBOX/Spam to Junk
    sed -i -e 's/INBOX\/Spam/'$SPAM_FOLDER'/g' /usr/lib/dovecot/sieve/*.sieve /config/*.conf

    for file in `ls /usr/lib/dovecot/sieve/*.sieve`; do
        sievec $file
    done

    echo $RSPAMD_CONTROLLER_PASSWORD > /etc/dovecot/rspamd-controller.password
    echo "RSPAMD_CONTROLLER_HOST=$RSPAMD_CONTROLLER_HOST" >> /etc/dovecot/rspamd-controller.conf.sh

    exec "$@"
fi

exec "$@"


