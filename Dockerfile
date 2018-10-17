FROM ubuntu:16.04

COPY . /app

RUN bash /app/require.sh
