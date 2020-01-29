FROM ruby:2.6.5-buster as base

# WORKDIR needs to be the same as in the final base image or compiled gems will point to an invalid directory
# NOTE: For the compiled gems to be shared across services then the WORKDIR needs to be same for all images
RUN mkdir -p /home/rails/services/app
WORKDIR /home/rails/services/app
ENV GEM_HOME=/usr/local/bundle/ruby/2.6.0
ENV PATH $GEM_HOME/bin:$PATH

# Install gems that need compiling first b/c they can take a long time to compile
RUN gem install \
    nokogiri:1.10.7 \
    ffi:1.11.3 \
    grpc:1.23.0 \
    mini_portile2:2.4.0 \
    msgpack:1.3.1 \
    pg:1.2.1 \
    nio4r:2.5.2 \
    puma:4.3.1 \
    eventmachine:1.2.7

RUN gem install bundler:2.1.2

# NOTE: Copy in a generic Gemfile and the dependent gem's gemspecs so that their dependencies are also installed
COPY services/Gemfile* ./
COPY lib/core/*.gemspec ../../lib/core/
COPY lib/sdk/*.gemspec ../../lib/sdk/

# Don't use the --deployment flag since this is a container. See: http://bundler.io/man/bundle-install.1.html#DEPLOYMENT-MODE
ARG GEM_SERVER
ARG bundle_string='development test'
RUN bundle config set without ${bundle_string}
# Build a layer with gems from just the common Gemfile
# Remove reference to git in spec.files
RUN sed -i '/git/d' ../../lib/sdk/*.gemspec \
 && bundle install \
 && find /usr/local/bundle -iname '*.o' -exec rm -rf {} \; \
 && find /usr/local/bundle -iname '*.a' -exec rm -rf {} \; \
 && mv Gemfile ..

# Remove reference to gems loaded from a path so bundle doesn't blow up
# RUN sed -i '/path/d' Gemfile
ARG project=user
COPY services/${project}/Gemfile* ./
COPY services/${project}/cnfs-${project}.gemspec ./

RUN bundle install \
 && find /usr/local/bundle -iname '*.o' -exec rm -rf {} \; \
 && find /usr/local/bundle -iname '*.a' -exec rm -rf {} \;

# Runtime container
FROM ruby:2.6.5-slim-buster

# Install OS packages and create a non-root user to run the application
# To compile pg gem: libpq-dev
# To install pg client to run via bash: postgresql-client
ARG os_packages='libpq5 git less'

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends ${os_packages} \
 && apt-get clean

ARG PUID=1000
ARG PGID=1000

RUN [ $(getent group $PGID) ] || addgroup --gid ${PGID} rails \
 && useradd -ms /bin/bash -d /home/rails --uid ${PUID} --gid ${PGID} rails \
 && mkdir -p /home/rails/services/app \
 && echo 'set editing-mode vi' > /home/rails/.inputrc.vi \
 && echo "alias ivi='cp /home/rails/.inputrc.vi /home/rails/.inputrc; set -o vi'" > /home/rails/.bash_aliases \
 && echo "alias rspec='spring rspec $@'\nalias src='ss; rc'\nalias ss='spring stop'\nalias rs='rails server -b 0.0.0.0 --pid /tmp/server.pid'\nalias rc='ivi; spring rails console'\nalias rk='spring rake'" >> /home/rails/.bash_aliases \
 && chown ${PUID}:${PGID} /home/rails -R \
 && echo 'rails ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Rails operations
WORKDIR /home/rails/services/app

# TODO: Replace rails:rails with ${PUID}:${PGID} when CircleCI is at 19.03
COPY --chown=rails:rails lib/core/. ../../lib/core/
COPY --chown=rails:rails lib/sdk/. ../../lib/sdk/
COPY --chown=rails:rails services/Gemfile ../Gemfile
COPY --chown=rails:rails .rubocop.yml ../../.rubocop.yml
COPY --chown=rails:rails .rubocop_todo.yml ../../.rubocop_todo.yml

# workaround for buildkit not setting correct permissions
RUN sed -i '/git/d' ../../lib/sdk/*.gemspec \
 && chown rails: /home/rails/lib

EXPOSE 3000

# Boot the application; Override this from the command line in order to run other tools
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-P", "/tmp/server.pid"]

# CircleCI docker version is old, it doesn't expand ARGs or ENVs for "COPY --chown" directive
# TODO: Replace rails:rails with ${PUID}:${PGID} when CircleCI is at 19.03
COPY --chown=rails:rails --from=base /usr/local/bundle /usr/local/bundle

USER ${PUID}:${PGID}

# Copy in the project files
ARG project=user
COPY --chown=rails:rails services/${project}/. ./

ARG rails_env=production
ENV GEM_HOME=/usr/local/bundle/ruby/2.6.0
ENV PATH $GEM_HOME/bin:$PATH
ENV RAILS_ENV=${rails_env} EDITOR=vim TERM=xterm RAILS_LOG_TO_STDOUT=yes
