FROM ubuntu

MAINTAINER Antonio Cheong (windo.ac@gmail.com)

RUN apt-get update  && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install libpam-radius-auth freeradius apache2 mysql-server php php-cli libapache2-mod-php php-mysql php-ldap php-mbstring && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 1812/udp 1813/udp 80 443

VOLUME /var/lib/mysql

COPY . /MOTP

#ENTRYPOINT ["sleep","infinity"]

RUN mv /etc/freeradius/3.0/mods-config/files/authorize /etc/freeradius/3.0/mods-config/files/authorize.org && \
    mv /etc/freeradius/3.0/sites-available/default /etc/freeradius/3.0/sites-available/default.org && \
    ln -s /MOTP/HTML /var/www/html/motp && \
    cp /MOTP/Setup/apache2/redirect-http.conf /etc/apache2/sites-available/redirect-http.conf && \
    cp /MOTP/Setup/apache2/index.html /var/www/html/index.html && \
    cp /MOTP/Setup/Freeradius/users /etc/freeradius/3.0/mods-config/files/authorize && \
    cp /MOTP/Setup/Freeradius/dynamic-clients /etc/freeradius/3.0/sites-available/dynamic-clients && \
    cp /MOTP/Setup/Freeradius/default /etc/freeradius/3.0/sites-available/default && \
    ln -s /etc/freeradius/3.0/sites-available/dynamic-clients /etc/freeradius/3.0/sites-enabled/dynamic-clients && \
    chown freerad:freerad /etc/freeradius/3.0/mods-config/files/authorize /etc/freeradius/3.0/sites-available/dynamic-clients /etc/freeradius/3.0/sites-available/default /etc/freeradius/3.0/sites-enabled/dynamic-clients && \
    chmod 640 /etc/freeradius/3.0/mods-config/files/authorize /etc/freeradius/3.0/sites-available/dynamic-clients /etc/freeradius/3.0/sites-available/default && \
    a2enmod ssl && \
    a2enmod rewrite && \
    a2ensite default-ssl && \
    a2ensite redirect-http && \
    rm /etc/apache2/sites-enabled/000-default.conf && \
    ln -sf /dev/stderr /var/log/mysql/error.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    chmod 755 /MOTP/entrypoint.sh

ENTRYPOINT ["/MOTP/entrypoint.sh"]
