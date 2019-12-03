FROM python:3.6
MAINTAINER Mon <elfmon@gmail.com>

ENV MAPPROXY_PROCESSES 4
ENV MAPPROXY_THREADS 2

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    python-pil \
    python-yaml \
    libproj13 \
    libgeos-dev \
    python-lxml \
    libgdal-dev \
    build-essential \
    python-dev \
    libjpeg-dev \
    zlib1g-dev \
    libfreetype6-dev \
    python-virtualenv \
  && rm -rf /var/lib/apt/lists/* \
  && useradd -ms /bin/bash mapproxy \
  && mkdir -p /mapproxy \
  && chown mapproxy /mapproxy \
  && pip install Shapely Pillow requests geojson uwsgi pycryptodome\
  && mkdir -p /docker-entrypoint-initmapproxy.d

COPY . /code
RUN ls ./code && cd ./code && python3 ./setup.py install && cd .. && rm -rf ./code

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["mapproxy"]

USER mapproxy
VOLUME ["/mapproxy"]
EXPOSE 8080
# Stats
EXPOSE 9191
