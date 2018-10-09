FROM php:7.0-apache

ENV HUGO_VERSION 0.48
ENV HUGO_BINARY hugo_${HUGO_VERSION}_Linux-64bit.deb

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y git curl unzip python3 python3-pip libyaml-dev

RUN pip3 install awscli

RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer require phpmailer/phpmailer

RUN a2enmod rewrite

ADD https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} /tmp/hugo.deb
RUN dpkg -i /tmp/hugo.deb && \
    rm /tmp/hugo.deb

RUN mkdir -p /usr/share/blog

COPY . /tmp/pmpc-build/

WORKDIR /tmp/pmpc-build/site/

RUN build/build.sh && \
    cp -r public/ /usr/share/blog/public/ && \
    cd / && rm -rf /tmp/pmpc-build

COPY 000-default.conf /etc/apache2/sites-enabled/

CMD apache2-foreground
