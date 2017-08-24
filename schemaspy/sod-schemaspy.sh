#!/bin/bash
DB=sod
HOST=db:5432
USER=sod
PASSWORD=1234
docker run --rm --network docker_sod_default -v="$PWD/output":/output matthewdodds/docker-schemaspy-postgres bash -c "java -jar schemaSpy.jar -t pgsql -db $DB -host $HOST -dp postgresql-jdbc4.jar -u $USER -p $PASSWORD -s public -o /output"
