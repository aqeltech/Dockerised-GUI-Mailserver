FROM mailserver/docker-mailserver

# –––––––––––––––––––––––––––––––––––––––––––––––
# ––– Install Basic Software ––––––––––––––––––––
# –––––––––––––––––––––––––––––––––––––––––––––––

RUN apt-get -qq update && \
  apt-get -y --no-install-recommends install dovecot-mysql postfix-mysql && \
  # cleanup
  apt-get -qq autoclean && \
  apt-get -qq clean && \
  rm -rf /var/lib/apt/lists/* && \
  c_rehash 2>/dev/null
# –––––––––––––––––––––––––––––––––––––––––––––––
# ––– MySQL Postfix & Dovecot ––––––––––––––––---
# –––––––––––––––––––––––––––––––––––––––––––––––

COPY \
  target/dovecot/dovecot-sql.conf.ext \
  target/dovecot/dovecot-dict-sql.conf.ext \
  /etc/dovecot/

COPY \
  target/dovecot/10-master.conf \
  /etc/dovecot/conf.d/

COPY \
  target/postfix/sql/domains_maps.cf \
  target/postfix/sql/mailbox_maps.cf \
  target/postfix/sql/alias_domain_mailbox_maps.cf \
  target/postfix/sql/alias_maps.cf \
  target/postfix/sql/alias_domain_maps.cf \
  target/postfix/sql/alias_domain_catchall_maps.cf \
  /etc/postfix/sql/

# –––––––––––––––––––––––––––––––––––––––––––––––
# ––– Scripts & Miscellaneous –––––––––––––––––––
# –––––––––––––––––––––––––––––––––––––––––––––––

COPY \
  ./target/bin/* \
  ./target/scripts/*.sh \
  ./target/scripts/startup/*.sh \
  ./target/docker-configomat/configomat.sh \
  /usr/local/bin/

RUN \
  chmod +x /usr/local/bin/*
