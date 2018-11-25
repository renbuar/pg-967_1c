# vim:set ft=dockerfile:
FROM ubuntu:16.04

# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.10
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
&& apt-get purge -y --auto-remove ca-certificates wget

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.utf8

RUN mkdir /docker-entrypoint-initdb.d

ENV PG_MAJOR 9.6

RUN set -ex; \
    apt-get update;

RUN apt-get install -y -q apt-utils libgssapi-krb5-2 libldap-2.4-2 libssl1.0.0 \
    ssl-cert libxml2 libicu55 libxslt1.1 libperl5.22 libpython2.7 libpython3.5 libtcl8.6 libedit2 \
    postgresql-client-common postgresql-common

#RUN apt-get install -y apt-utils
#RUN apt-get install -y -q libgssapi-krb5-2
#RUN apt-get install -y -q libldap-2.4-2
#RUN apt-get install -y -q libssl1.0.0
#RUN apt-get install -y -q ssl-cert 
#RUN apt-get install -y -q libxml2 
#RUN apt-get install -y -q libicu55
#RUN apt-get install -y -q libxslt1.1
#RUN apt-get install -y -q libperl5.22
#RUN apt-get install -y -q libpython2.7
#RUN apt-get install -y -q libpython3.5
#RUN apt-get install -y -q libtcl8.6
#RUN apt-get install -y -q libedit2

RUN mkdir /tmp/pg_dist
ADD ./pg_dist/*.deb /tmp/pg_dist/   

RUN dpkg -i /tmp/pg_dist/libpq5_9.6.7-1.1C_amd64.deb
#RUN apt-get install -y -q postgresql-client-common

RUN dpkg -i /tmp/pg_dist/postgresql-client-9.6_9.6.7-1.1C_amd64.deb
#RUN apt-get install -y -q postgresql-common

RUN dpkg -i /tmp/pg_dist/postgresql-9.6_9.6.7-1.1C_amd64.deb; \
   dpkg -i /tmp/pg_dist/libpgtypes3_9.6.7-1.1C_amd64.deb; \
   dpkg -i /tmp/pg_dist/libecpg6_9.6.7-1.1C_amd64.deb; \
   dpkg -i /tmp/pg_dist/libecpg-compat3_9.6.7-1.1C_amd64.deb; \
   dpkg -i /tmp/pg_dist/libpq-dev_9.6.7-1.1C_amd64.deb; \
   dpkg -i /tmp/pg_dist/libecpg-dev_9.6.7-1.1C_amd64.deb; \
   dpkg -i /tmp/pg_dist/postgresql-9.6-dbg_9.6.7-1.1C_amd64.deb; \
   dpkg -i /tmp/pg_dist/postgresql-contrib-9.6_9.6.7-1.1C_amd64.deb; \
   dpkg -i /tmp/pg_dist/postgresql-doc-9.6_9.6.7-1.1C_all.deb; \
   dpkg -i /tmp/pg_dist/postgresql-plperl-9.6_9.6.7-1.1C_amd64.deb; \
   dpkg -i /tmp/pg_dist/postgresql-plpython-9.6_9.6.7-1.1C_amd64.deb; \
   dpkg -i /tmp/pg_dist/postgresql-plpython3-9.6_9.6.7-1.1C_amd64.deb; \
   dpkg -i /tmp/pg_dist/postgresql-pltcl-9.6_9.6.7-1.1C_amd64.deb; \
   dpkg -i /tmp/pg_dist/postgresql-server-dev-9.6_9.6.7-1.1C_amd64.deb

# make the sample config easier to munge (and "correct by default")
RUN mv -v "/usr/share/postgresql/$PG_MAJOR/postgresql.conf.sample" /usr/share/postgresql/ \
	&& ln -sv ../postgresql.conf.sample "/usr/share/postgresql/$PG_MAJOR/" \
	&& sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/postgresql.conf.sample

RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql

ENV PATH $PATH:/usr/lib/postgresql/$PG_MAJOR/bin
ENV PGDATA /var/lib/postgresql/data
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA" # this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)
VOLUME /var/lib/postgresql/data

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 777 /usr/local/bin/docker-entrypoint.sh \
    && ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
