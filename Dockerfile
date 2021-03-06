FROM ubuntu:latest

MAINTAINER Patrick Leckey <pat.leckey@gmail.com>

RUN apt-get update
RUN apt-get install -y curl wget build-essential software-properties-common supervisor

# install the nginx/stable repo
RUN add-apt-repository -y ppa:nginx/stable

# install HHVM repo
RUN wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
RUN echo deb http://dl.hhvm.com/ubuntu trusty main | sudo tee /etc/apt/sources.list.d/hhvm.list

# update sources and install nginx / HHVM
RUN apt-get update
RUN apt-get install -y nginx hhvm

# stop and disable the services - supervisor runs them
RUN service hhvm stop
RUN service nginx stop
RUN update-rc.d -f nginx remove
RUN update-rc.d -f hhvm remove

# link HHVM to the php-cli
RUN /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60

# install composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

# configure HHVM
ADD hhvm.conf /etc/nginx/
ADD hhvm.ini /etc/supervisord.d/

# disable nginx default site
RUN unlink /etc/nginx/sites-enabled/default

ADD nginx.conf /etc/nginx/
ADD nginx.ini /etc/supervisord.d/
ADD web.conf /etc/nginx/sites-available/app
RUN ln -s /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app

# expose port 80
EXPOSE 80
