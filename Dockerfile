FROM vsense/baseimage:alpine

MAINTAINER vSense <docker@vsense.fr>

RUN apk add --update \
    rtorrent \
    nginx \
    php7@community \
    php7-fpm@community \
    php7-json@community \
    curl \
    gzip \
    zip \
    unrar \
    supervisor \
    git \
    geoip \
    ffmpeg \
    && git clone https://github.com/Novik/ruTorrent.git /rutorrent \
    && mkdir -p /tmp/nginx/client-body /downloads/incoming /downloads/completed /downloads/watched /downloads/sessions /tmp/rtorrent \
    && adduser -D -h / -u 5001 rtorrent \
    && chown -R rtorrent:rtorrent /downloads /rutorrent /tmp/rtorrent /var/lib/nginx \
    && sed -i \
        -e 's/group =.*/group = rtorrent/' \
        -e 's/user =.*/user = rtorrent/' \
        -e 's/listen\.owner.*/listen\.owner = rtorrent/' \
        -e 's/listen\.group.*/listen\.group = rtorrent/' \
        -e 's/error_log =.*/error_log = \/dev\/stdout/' \
        /etc/php7/php-fpm.d/www.conf \
    && sed -i \
        -e '/open_basedir =/s/^/\;/' \
        /etc/php7/php.ini \
    && sed -i \
        -e "/curl/ s/''/'\/usr\/bin\/curl'/" \
        -e "/php/ s/''/'\/usr\/bin\/php7'/" \
        /rutorrent/conf/config.php \
    && rm -rf /var/cache/apk/*

COPY supervisord-rtorrent.ini /etc/supervisor.d/supervisord-rtorrent.ini

COPY nginx.conf /etc/nginx/nginx.conf

COPY auth_file /etc/nginx/auth_file

COPY rtorrent.conf /.rtorrent.rc

VOLUME /downloads /rutorrent

EXPOSE 80 5000 6881 51413

CMD ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
