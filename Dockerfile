FROM python:3.10-alpine3.15 AS builder

RUN addgroup -S pythonrunner && adduser -u 1000 -S -g pythonrunner pythonrunner

WORKDIR /app

RUN apt update && apt install vim

RUN apk add --update \
    python3 \
    python3-dev \
    build-base \
    wget \
    vim \
    gcc \
    g++ \
    make \
    libffi-dev \
    linux-headers \
    pcre-dev \
    zeromq-dev \
    py-cffi \
    openssl \
    zlib-dev \
    libmemcached \
    postgresql-dev

USER pythonrunner

COPY requirements.txt /tmp/requirements.txt

RUN pip3 install -U --no-cache-dir hypercorn pip setuptools wheel
RUN pip3 install --no-cache-dir --user -r /tmp/requirements.txt


EXPOSE 8080

CMD ["ash"]


FROM python:3.10-alpine3.15 AS prod-container

RUN addgroup -S pythonrunner && adduser -u 1000 -S -g pythonrunner pythonrunner

WORKDIR /app
RUN chown -R pythonrunner:pythonrunner /app

RUN apk --no-cache add \
    libpq \
    pcre

COPY --chown=pythonrunner:pythonrunner --from=builder /home/pythonrunner/.local /usr/local
COPY --chown=pythonrunner:pythonrunner src /app/

USER pythonrunner

EXPOSE 8080

CMD ["hypercorn", "--bind", "0.0.0.0:8080", "docker_django.asgi:application"]

FROM builder AS dev-container

USER root

COPY requirements.txt /tmp/requirements.txt
COPY requirements-dev.txt /tmp/requirements-dev.txt

RUN pip install --no-cache-dir -r /tmp/requirements-dev.txt
RUN cp -r /home/pythonrunner/.local/* /usr/local

WORKDIR /app/src
USER pythonrunner

CMD ["ash"]