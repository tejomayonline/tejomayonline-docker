FROM ubuntu:latest

RUN locale-gen en_US.UTF-8 \
  && export LANG=en_US.UTF-8 \
  && apt-get update \
  && apt-get -y install apache2

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log
RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

VOLUME [ "/var/www/html" ]
WORKDIR /var/www/html

EXPOSE 80

ENTRYPOINT [ "/usr/sbin/apache2" ]
CMD ["-D", "FOREGROUND"]

RUN apt-get -y install  nano  libapache2-mod-php7.0 php7.0 php7.0-cli php7.0-zip nano  php-xdebug php7.0-mbstring sqlite3 php7.0-mysql php-imagick php-memcached php-pear curl imagemagick php7.0-dev php7.0-phpdbg php7.0-gd npm nodejs-legacy php7.0-json php7.0-curl php7.0-sqlite3 php7.0-intl apache2 vim git-core wget libsasl2-dev libssl-dev libsslcommon2-dev libcurl4-openssl-dev autoconf g++ make openssl libssl-dev libcurl4-openssl-dev pkg-config libsasl2-dev libpcre3-dev \
  && a2enmod headers \
  && a2enmod rewrite


RUN apt-get update


 ENV PATH "/composer/vendor/bin:$PATH"
 ENV COMPOSER_ALLOW_SUPERUSER 1
 ENV COMPOSER_HOME /composer
 ENV COMPOSER_VERSION 1.3.2

 RUN curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/5fd32f776359b8714e2647ab4cd8a7bed5f3714d/web/installer \
  && php -r " \
     \$signature = '55d6ead61b29c7bdee5cccfb50076874187bd9f21f65d8991d46ec5cc90518f447387fb9f76ebae1fbbacf329e583e30'; \
     \$hash = hash('SHA384', file_get_contents('/tmp/installer.php')); \
     if (!hash_equals(\$signature, \$hash)) { \
         unlink('/tmp/installer.php'); \
         echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
         exit(1); \
     }" \
  && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
  && rm /tmp/installer.php \
  && composer --ansi --version --no-interaction

 COPY ./docker-entrypoint/docker-entrypoint.sh /docker-entrypoint.sh


 ENTRYPOINT ["/docker-entrypoint.sh"]

 CMD ["composer"]


 #install mongodb
 EXPOSE 27017

 VOLUME /var/lib/mongodb
 VOLUME /var/log/mongod

 RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
  echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list 
 RUN apt-get -qq update && \
  apt-get install -y mongodb-org


#git
VOLUME /.ssh_host
RUN apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN  echo "    IdentityFile /.ssh/id_rsa" >> /etc/ssh/ssh_config
CMD 'git'

#node js
RUN apt-get update -y && apt-get install --no-install-recommends -y -q curl python build-essential git ca-certificates
RUN mkdir /nodejs && curl http://nodejs.org/dist/v0.10.30/node-v0.10.30-linux-x64.tar.gz | tar xvzf - -C /nodejs --strip-components=1
ENV PATH $PATH:/nodejs/bin

#gulp and bower
RUN npm install -g gulp-cli bower \
	; mkdir -p /var/cache/npm && chmod 777 /var/cache/npm \
	; npm config set cache /var/cache/npm


RUN pecl install xdebug
COPY ./xdebug/xdebug.ini /etc/php5/apache2/conf.d/20-xdebug.ini
RUN sed -i -e '1izend_extension=\'`find / -name "xdebug.so"` /etc/php5/apache2/conf.d/20-xdebug.ini

#laravel
RUN composer
RUN composer global require "laravel/installer"
RUN apt-get update
RUN apt-get install nano
RUN apt-get install gedit
COPY ~/.bash_aliases     ~/.bash_aliases