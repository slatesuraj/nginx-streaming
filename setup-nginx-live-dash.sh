#!/bin/bash

sudo apt update
sudo apt install build-essential git -y

sudo apt install libpcre3-dev libssl-dev zlib1g-dev -y
cd /tmp
git clone https://github.com/arut/nginx-rtmp-module.git
git clone https://github.com/nginx/nginx.git
cd nginx
./auto/configure --add-module=../nginx-rtmp-module
make
sudo make install


echo "

#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}

rtmp {
    server {
        listen 1935;
        application live {
            live on;
            interleave on;
            dash on;
            dash_path /tmp/dash;
            dash_fragment 15s;
        }
    }
}

http {
    default_type  application/octet-stream;

    server {
        listen       80;
        server_name  localhost;

        location / {
            root /tmp/dash;
        }
    }

    types {
        text/html html;
        application/dash+xml mpd;
    }

}" > nginx.conf

cp nginx.conf /usr/local/nginx/conf/nginx.conf

/usr/local/nginx/sbin/nginx -t

/usr/local/nginx/sbin/nginx

apt install ffmpeg -y

wget https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_1920_18MG.mp4

ffmpeg  -re -stream_loop -1 -i test.mp4 -loop -1 -vcodec copy -c:a aac -b:a 160k -ar 44100 -flvflags no_duration_filesize -strict -2 -f flv rtmp://127.0.0.1/live/bbb
