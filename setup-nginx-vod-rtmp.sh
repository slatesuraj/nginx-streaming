#!/bin/bash

apt update
apt upgrade -y

apt install -y git gcc make
apt install -y build-essential ffmpeg libpcre3 libpcre3-dev libssl-dev zlib1g-dev

git clone https://github.com/sergey-dryabzhinsky/nginx-rtmp-module.git

mkdir -p /var/www
cp nginx-rtmp-module/stat.xsl /var/www/

sudo apt install -y build-essential libpcre3 libpcre3-dev libssl-dev

wget https://nginx.org/download/nginx-1.18.0.tar.gz
tar -xf nginx-1.18.0.tar.gz
cd nginx-1.18.0

./configure --with-http_ssl_module --add-module=../nginx-rtmp-module
make -j 1
sudo make install

cd /usr/local/nginx/conf
mv nginx.conf nginx.cong.bkp

echo "worker_processes  1;
 
events {
    worker_connections  1024;
}
 
rtmp {
    server {
        listen 1935;
 
        chunk_size 4000;
 
        # video on demand for flv files
        application vod {
            play /var/flvs;
        }
 
        # video on demand for mp4 files
        application vod2 {
            play /var/mp4s;
        }
    }
}
 
# HTTP can be used for accessing RTMP stats
http {
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
 
    server {
        # in case we have another web server on port 80
        listen      8080;
 
        # This URL provides RTMP statistics in XML
        location /stat {
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }
 
        location /stat.xsl {
            # XML stylesheet to view RTMP stats.
            # Copy stat.xsl wherever you want
            # and put the full directory path here
            root /var/www/;
        }
 
        location /hls {
            # Serve HLS fragments
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            alias /tmp/app;
            expires -1;
        }
    }
}" > nginx.conf

mkdir -p /var/log/nginx
mkdir -p /var/mp4s

/usr/local/nginx/sbin/nginx

echo "Save all mp4 files to /var/mp4s"
echo "Time to play. Use rtmp://<IP_OF_THE_SERVER>:1935/vod2/sample.mp4 "


