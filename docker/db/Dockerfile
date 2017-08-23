FROM postgres:9.4

ENV POSTGRES_USER sod
ENV POSTGRES_PASSWORD 1234
ENV POSTGRES_DB sod

ADD deploy.sql /docker-entrypoint-initdb.d/

