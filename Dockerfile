FROM jsimonetti/alpine-edge

RUN	apk add --no-cache dovecot-lmtpd dovecot-pigeonhole-plugin curl bash
COPY ./config /config.staged

VOLUME	[ "/var/vmail" ]

EXPOSE 143/tcp 993/tcp 41901/tcp 41902/tcp 4190/tcp

COPY ./entrypoint.sh /
ENTRYPOINT [ "tini", "--", "/entrypoint.sh" ]
CMD	[ "dovecot", "-F" ]
