FROM fluent/fluentd:stable-debian-onbuild
MAINTAINER Duan Shiqiang <duan@perxtech.com>

RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev" \
  && apt-get update \
  && apt-get install -y --no-install-recommends $buildDeps \
  && sudo gem install --no-document \
        fluent-plugin-google-cloud \
        fluent-plugin-detect-exceptions \
        fluent-plugin-to_js \
        fluent-plugin-systemd \
        fluent-plugin-prometheus \
        fluent-plugin-record-modifier \
        fluent-plugin-record-reformer \
        fluent-plugin-kubernetes_metadata_filter \
        fluent-plugin-s3 \
  && sudo gem sources --clear-all \
  && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
  && rm -rf /var/lib/apt/lists/* \
            /home/fluent/.gem/ruby/2.3.0/cache/*.gem \
  && mkdir -p /fluentd/etc/config.d

ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"

ENTRYPOINT []

CMD exec /usr/local/bin/fluentd -c /fluentd/etc/${FLUENTD_CONF} -p /fluentd/plugins $FLUENTD_OPT
