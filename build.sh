#!/bin/bash

mvn clean package
cp target/sod.war docker/app/sod.war
cd docker ; docker-compose up --build
