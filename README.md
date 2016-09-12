## What is rtorrent/rutorrent

[![](https://images.microbadger.com/badges/version/vsense/rtorrent.svg)](http://microbadger.com/images/vsense/rtorrent "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/vsense/rtorrent.svg)](http://microbadger.com/images/vsense/rtorrent "Get your own image badge on microbadger.com")

rTorrent is a BitTorrent client.
[More info](https://github.com/rakshasa/rtorrent)

ruTorrent is a front-end for the popular Bittorrent client rtorrent.
[More info](https://github.com/Novik/ruTorrent)

## How to use this image

This Dockerfile sets up rtorrent with rutorrent, it is based on Alpine Linux and uses Nginx and php-fpm

This image contains 2 volumes that you can override with host or data container volumes:
- /downloads : your downloads folder
- /rutorrent : rutorrent files

```
docker run -d --name rtorrent --hostname rtorrent -p 6881:6881 -p 6881:6881/udp -p 51413:51413 -p 51413:51413/udp -v /srv/configs/rutorrent:/rutorrent -v /srv/seedbox:/downloads vsense/rtorrent
```

The ports used above are defined in the rtorrent configuration file (.rtorrentrc) and are shown as an example.

Of course you can mount as many volumes as you want, the base volumes existing to ensure image compatibility.

## Overriding rutorrent

Because rutorrent is often updated and saves your settings, it is possible to use git clone rutorrent locally on the host and mount it in the container, as in the example above. This will allow you to upgrade rtorrent with git pull (there is no auto-update for rutorrent) as well as to configure plugins and commit your modifications.

## Overriding `.rtorrentrc`

A sample `.rtorrentrc` file is available in this repo as `rtorrent.conf`

It is also possible to override it by mounting the file from host:

```
docker run -d --name rtorrent --hostname rtorrent -p 6881:6881 -p 6881:6881/udp -p 51413:51413 -p 51413:51413/udp -v /srv/configs/rutorrent:/rutorrent -v /srv/seedbox:/downloads vsense/rtorrent -v /srv/config/rtorrent/rtorrent.conf:/.rtorrentrc
```

## Init Script

You can use docker with --always to ensure container restart:

```
docker run --restart=always -d --name rtorrent --hostname rtorrent --rm -p 6881:6881 -p 6881:6881/udp -p 51413:51413 -p 51413:51413/udp -v /srv/configs/rutorrent:/rutorrent -v /srv/seedbox:/downloads vsense/rtorrent
```

Or you can use a systemd unit:

```
# /etc/systemd/system/rtorrent.service
[Unit]
Description=rtorrent & rutorrent web UI
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/rm /srv/seedbox/sessions/rtorrent.lock
ExecStartPre=-/usr/bin/docker pull vsense/rtorrent
ExecStart=/usr/bin/docker run --name rtorrent --hostname rtorrent --rm -p 6881:6881 -p 6881:6881/udp -p 51413:51413 -p 51413:51413/udp -v /srv/configs/rutorrent:/rutorrent -v /srv/seedbox:/downloads vsense/rtorrent
ExecStop=/usr/bin/docker stop rtorrent
ExecReload=/usr/bin/docker restart rtorrent
RestartSec=5

[Install]
WantedBy=multi-user.target
```

