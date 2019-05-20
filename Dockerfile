FROM jsimonetti/alpine-edge

RUN	apk add --no-cache dovecot-lmtpd dovecot-pigeonhole-plugin rspamd-client

RUN	echo "!include /etc/dovecot/conf.d/*.conf" > /etc/dovecot/dovecot.conf && \
	addgroup -g 5000 vmail && adduser -u 5000 -G vmail -h /var/vmail -D -s /sbin/nologin vmail && \
	echo $' \n\
require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables"];\n\
\n\
if environment :matches "imap.user" "*" {\n\
  set "username" "${1}";\n\
}\n\
\n\
pipe :copy "sa-learn-spam.sh" [ "${username}" ];' > /usr/lib/dovecot/sieve/report-spam.sieve && \
	echo $' \n\
require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables"];\n\
\n\
if environment :matches "imap.mailbox" "*" {\n\
  set "mailbox" "${1}";\n\
}\n\
\n\
if string "${mailbox}" "Trash" {\n\
  stop;\n\
}\n\
\n\
if environment :matches "imap.user" "*" {\n\
  set "username" "${1}";\n\
}\n\
\n\
pipe :copy "sa-learn-ham.sh" [ "${username}" ];\n' > /usr/lib/dovecot/sieve/report-ham.sieve && \
	echo $' \n\
#!/bin/sh\n\
exec /usr/bin/rspamc -h $RSPAMD_HOST -P $RSPAMD_SECRET learn_spam\n' > /usr/lib/dovecot/sieve/sa-learn-spam.sh && \
	chmod +x /usr/lib/dovecot/sieve/sa-learn-spam.sh && \
	echo $' \n\
#!/bin/sh\n\
exec /usr/bin/rspamc -h $RSPAMD_HOST -P $RSPAMD_SECRET learn_ham\n' > /usr/lib/dovecot/sieve/sa-learn-ham.sh && \
	chmod +x /usr/lib/dovecot/sieve/sa-learn-ham.sh


VOLUME	[ "/var/vmail" ]

CMD	[ "/usr/sbin/dovecot", "-F" ]
