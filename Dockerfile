FROM jsimonetti/alpine-edge

RUN	apk add --no-cache dovecot-lmtpd dovecot-pigeonhole-plugin curl bash
COPY ./config /config.staged
RUN	\
	curl -o /config.staged/99-antispam_with_sieve.conf -L https://raw.githubusercontent.com/darix/dovecot-sieve-antispam-rspamd/master/99-antispam_with_sieve.conf && \
	curl -o /config.staged/learn-ham.sieve -L https://raw.githubusercontent.com/darix/dovecot-sieve-antispam-rspamd/master/learn-ham.sieve && \
	curl -o /config.staged/learn-spam.sieve -L https://raw.githubusercontent.com/darix/dovecot-sieve-antispam-rspamd/master/learn-spam.sieve && \
	curl -o /config.staged/global-spam.sieve -L https://raw.githubusercontent.com/darix/dovecot-sieve-antispam-rspamd/master/global-spam.sieve && \
	curl -o /config.staged/global-try-spam.sieve -L https://raw.githubusercontent.com/darix/dovecot-sieve-antispam-rspamd/master/global-try-spam.sieve && \
	curl -o /config.staged/learn-spam.rspamd.script -L https://raw.githubusercontent.com/darix/dovecot-sieve-antispam-rspamd/master/learn-spam.rspamd.script && \
	curl -o /config.staged/rspamd-controller.conf.sh -L https://raw.githubusercontent.com/darix/dovecot-sieve-antispam-rspamd/master/rspamd-controller.conf.sh


VOLUME	[ "/var/vmail" ]

EXPOSE 143/tcp 993/tcp 41901/tcp 41902/tcp 4190/tcp

COPY ./entrypoint.sh /
ENTRYPOINT [ "tini", "--", "/entrypoint.sh" ]
CMD	[ "dovecot", "-F" ]
