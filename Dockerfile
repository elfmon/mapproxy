FROM python:3.7
MAINTAINER Mon <elfmon@gmail.com>

ENV MAPPROXY_PROCESSES 2
ENV MAPPROXY_THREADS 2

# 更新阿里云的wheezy版本包源
RUN echo "deb http://mirrors.aliyun.com/debian buster main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian buster main contrib non-free" >> /etc/apt/sources.list  && \
    echo "deb http://mirrors.aliyun.com/debian buster-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian buster-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list

RUN set -x \
  && apt-get update --fix-missing \
  && apt-get install -y libgeos-dev python-lxml libgdal-dev \
    python-shapely build-essential python-dev libjpeg-dev \
    zlib1g-dev libfreetype6-dev libproj13\
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /mapproxy \
  && chown 0755 /mapproxy \
  && pip install -i https://mirrors.aliyun.com/pypi/simple/ PyYAML Shapely Pillow requests geojson uwsgi pycryptodome\
  && mkdir -p /docker-entrypoint-initmapproxy.d

COPY . /code
RUN cd ./code && python3 ./setup.py install && cd .. && rm -rf ./code

COPY docker-entrypoint.sh /
RUN chmod 0755 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["mapproxy"]

VOLUME ["/mapproxy"]
EXPOSE 8080
# Stats
EXPOSE 9191
