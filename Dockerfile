FROM jsimonetti/alpine-edge

RUN	apk add --no-cache dovecot-lmtpd dovecot-pigeonhole-plugin rspamd-client

RUN	echo "!include /etc/dovecot/conf.d/*.conf" > /etc/dovecot/dovecot.conf && \
	addgroup -g 5000 vmail && adduser -u 5000 -G vmail -h /var/vmail -D -s /sbin/nologin vmail


VOLUME	[ "/var/vmail" ]

CMD	[ "/usr/sbin/dovecot", "-F" ]
