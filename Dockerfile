FROM nginx:1.26.1

# we are going to replace the packaged nginx with our own build
RUN apt-get --yes remove nginx

# install build depdendencies
RUN apt-get update && \
    apt-get --yes install build-essential git libssl-dev libpcre3-dev zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# build our fork of nginx
COPY . /opt/src/nginx
RUN { set -eux; \
    cd /opt/src/nginx; \
    # this is essentially the same configure options that the official upstream image used (nginx -V)
    ./auto/configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    # --with-http_dav_module \
    # --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    # --with-http_mp4_module \
    # --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-cc-opt='-g -O2 -ffile-prefix-map=/opt/src/nginx=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
    --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie'; \
    make install; \
    mkdir -p /var/cache/nginx; \
    chown -R nginx: /var/cache/nginx; \
    rm -r /opt/src/nginx; \
    }
