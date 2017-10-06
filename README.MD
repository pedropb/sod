# SOD (Painel de Risco)

The goal of this project is to build an enterprise web application that allows business to perform Segregation of Duties.

Segregation of Duties, in a general idea, consists of 2 simple steps:
1. identify all operations performed by employees within a company that are subject to *conflict of interests*.
2. distribute these operations to multiple agents.

## Features

- Identify conflicts of interests for users and users groups.
- Dashboard to visualize in realtime how many conflicts exists and their evolution through time.
- Import, Export, Search and Filter functions.
- Reports.
- Access request workflow
- Reminders workflow
- Multi user access


## Architecture

The tech stack currently in use:
- Java 7 (Tomcat)
- Javascript (ExtJS 4.2)
- PostgreSQL
- Docker 17.06V

See `pom.xml` for all dependencies.
There is no ORM in place.

## Building and running

```bash
$ git clone https://github.com/pedropb/sod.git
$ cd sod
$ mvn install
$ cd docker
$ docker-compose up
// to end the server press Ctrl-c.
```

Browse to http://localhost:8081/sod.

Default user/password: `admin/sod_admin`.

### After making changes to the source...

```bash
$ mvn install
$ cd docker
$ docker-compose build web
$ docker-compose up
// to end the server press Ctrl-c.
```

## Future

The plans for the future are:
- Drop ExtJs for React or Angular, due to licensing reasons.
- Reengineer the back end for microservices to deploy using cloud infrastructure
    - Remove tomcat and use node
    - Switch from PostgreSQL to NoSQL, probably Mongo
- Maybe mobile ?
- Expand with more features


