# modified from https://github.com/inonit/docker-pgbouncer/blob/master/Dockerfile

RUN             groupadd -r pgbouncer
RUN             useradd -rm -d /var/run/pgbouncer -s /usr/sbin/nologin -g pgbouncer pgbouncer

# Install build dependencies
RUN             apt-get update && apt-get upgrade -y
RUN             apt-get install -y --no-install-recommends build-essential libevent-dev libssl-dev libc-ares-dev
RUN             apt-get purge -y --auto-remove
RUN             rm -rf /var/lib/apt/lists/*

# Download source code
RUN             curl -SLO ${PGBOUNCER_TAR_URL} \
                && curl -SLO ${PGBOUNCER_SHA_URL} \
                && cat pgbouncer-${PGBOUNCER_VERSION}.tar.gz.sha256 | sha256sum -c - \
                && tar -zxf pgbouncer-${PGBOUNCER_VERSION}.tar.gz \
                && chown root:root pgbouncer-${PGBOUNCER_VERSION}

# Build PgBouncer source code
RUN             cd pgbouncer-${PGBOUNCER_VERSION} \
                && ./configure --prefix=/usr/local \
                    --with-libevent=libevent-prefix \
                    --with-cares=cares-prefix \
                    --with-openssl=openssl-prefix \
                && make && make install

RUN             mkdir /etc/pgbouncer
COPY            pgbouncer /etc/pgbouncer
VOLUME          pgbouncer

# Make sure pgbouncer user can read and write log files
RUN             mkdir -p /var/log/pgbouncer && chown -R pgbouncer:pgbouncer /var/log/pgbouncer

USER            pgbouncer
ENTRYPOINT      ["pgbouncer"]
CMD             ["/etc/pgbouncer/pgbouncer.ini"]