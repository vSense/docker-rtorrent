## What is rtorrent/rutorrent

rTorrent is a BitTorrent client.
> [More info](https://github.com/rakshasa/rtorrent)

ruTorrent is a front-end for the popular Bittorrent client rtorrent.
> [More info](https://github.com/Novik/ruTorrent)

## How to use this images

This is a Dockerfile to set up "rtorrent with rutorrent" it based on Alpine Linux and uses Nginx and php-fpm

This image contains 2 volumes you can override with host or data containers volumes:
- /downloads : your downloads folder
- /rutorrent : rutorrent files

```
docker run -d --name rtorrent --hostname rtorrent -p 6881:6881 -p 6881:6881/udp -p 51413:51413 -p 51413:51413/udp -v /srv/configs/rutorrent:/rutorrent -v /srv/seedbox:/downloads vsense/rtorrent
```

The ports used above are define in the .rtorrentrc file.

Of course you can mount as many volumes as you want, the base volumes are here to ensure image compatibility.

## Overriding rutorrent

Because rutorrent is often updated and save your settings, it is possible to git clone rutorrent locally on the host and mount it in the container, as in the exemple above. This will allow you to upgrade rtorrent with git pull (there is no auto-update for rutorrent) as well as to configure plugins and commit your modifications.

## Overriding .rtorrentrc



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
