# Docker container for Drupal 8

FROM php:7.2.9-apache

RUN apt-get update && apt-get install -yqq --no-install-recommends \
  rsyslog \
  supervisor \
  cron \
  mysql-client \
  libpng-dev \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  locales \
  git \
  wget \
  ca-certificates \
  && a2enmod rewrite \
  && a2enmod expires \
  && a2enmod headers \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install mysqli pdo_mysql zip mbstring gd exif pcntl opcache \
  && pecl install apcu xdebug \
  && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini \
  && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/php/pecl-php-uploadprogress.git /tmp/php-uploadprogress && \
  cd /tmp/php-uploadprogress && \
  phpize && \
  ./configure --prefix=/usr --enable-uploadprogress && \
  make && \
  make install && \
  echo 'extension=uploadprogress.so' > /usr/local/etc/php/conf.d/uploadprogress.ini && \
  rm -rf /tmp/*

ENV DOCKERIZE_VERSION v0.2.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

COPY config /var/www/html
COPY config/docker/web/base/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config/docker/web/base/default.conf /etc/apache2/sites-available/000-default.conf
RUN a2ensite 000-default.conf
COPY config/docker/web/base/drush.yml /etc/drush/drush.yml
COPY config/docker/web/base/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY config/docker/web/base/rsyslog.conf /etc/rsyslog.conf
COPY config/docker/web/base/crontab /etc/cron.d/drupal
COPY config/docker/web/base/wait-for-db.sh /wait-for-db.sh
RUN chmod 644 /etc/cron.d/drupal && touch /cron-env
COPY config/docker/web/base/php.ini /usr/local/etc/php/php.ini

ENV PATH="${PATH}:/var/www/html/vendor/bin"

EXPOSE 80

WORKDIR /var/www/html

CMD ["/usr/bin/supervisord"]

ONBUILD ARG gitref=unknown
ONBUILD ENV GITREF $gitref
ONBUILD LABEL gitref $gitref
