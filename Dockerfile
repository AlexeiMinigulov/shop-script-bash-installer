FROM ubuntu:16.04

WORKDIR /app

COPY . /app

RUN bash /app/docker/require.sh

EXPOSE 80

CMD ["/usr/bin/supervisord"]
