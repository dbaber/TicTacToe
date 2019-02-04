# TicTacToe

A REST API using the Dancer2 Perl web application framework and an SQLite database that provides a backend API to
support playing Tic Tac Toe. The game object model or engine was borrowed from
[Games::TicTacToe](https://metacpan.org/pod/Games::TicTacToe) on [CPAN](https://metacpan.org) and modified quite a bit
to allow for the unique interaction and play style that is needed for a REST API and accounted for in the design.

__Technical Note__: Please see the [API design doc](design/API.md) for full API documentation and the current status of
this project as well as any technical discussion about existing caveats and issues.

## Installation

In order to run the application one must first install the latest version of Docker CE using the [Docker CE installation
instructions](https://docs.docker.com/install/overview/) appropriate for your Linux distribution. It may also prove
convenient and useful to also install the lastest version of docker-compose via these official [dock-compose
installation instructions](https://docs.docker.com/compose/install/).

### Setting Up The Database

Since we are using SQLite3 as the backend database you must also make sure that this is installed on your system as
well. The current version used as of the last commit to this repository is shown below.

```
$ sqlite3 --version
3.16.2 2017-01-06 16:32:41 a65a62893ca8319e89e48b8a38cf8a59c69a8209
```

In order to initialize the development database, the following command can be run:
```
$ sqlite3 db/tictactoe.db < db/tictactoe.sql
```

This should create the development database so you can then run the Dancer2 application and hit the REST API.

## Builing the Docker Image

Once Docker CE and docker-compose are installed and the SQLite development database setup, we simply need to run the
following command to build the docker image via docker-compose:

```
$ docker-compose up --build
<snip>
Successfully installed Data-Page-2.02
Successfully installed DBD-SQLite-1.62
Successfully installed Path-Class-0.37
Successfully installed Module-Find-0.13
Successfully installed Class-XSAccessor-1.19
Successfully installed Sub-Name-0.21
Successfully installed Class-Accessor-Grouped-0.10014
Successfully installed Variable-Magic-0.62
Successfully installed B-Hooks-EndOfScope-0.24
Successfully installed namespace-clean-0.27
Successfully installed Scope-Guard-0.21
Successfully installed Data-Dumper-Concise-2.023
Successfully installed Algorithm-C3-0.10
Successfully installed Class-C3-0.34
Successfully installed Class-C3-Componentised-1.001002
Successfully installed DBIx-Class-0.082841
Successfully installed DBICx-Sugar-0.0200
Successfully installed Dancer2-Plugin-DBIC-0.0100
Successfully installed Dir-Self-0.11
Successfully installed UUID-Tiny-1.04
Successfully installed Types-UUID-0.004
129 distributions installed
Complete! Modules were installed into /local
+ rm -rf /local/cache
+ rm -rf /root/.cpanm
Removing intermediate container c706ae6d4342
 ---> 6997fb211de5
Step 10/16 : COPY bin /opt/tictactoe/bin
 ---> 5f2ac2403278
Step 11/16 : COPY environments /opt/tictactoe/environments
 ---> 29360ac54900
Step 12/16 : COPY lib /opt/tictactoe/lib
 ---> 921f43aa0e16
Step 13/16 : COPY public /opt/tictactoe/public
 ---> 9b2918fef55a
Step 14/16 : COPY views /opt/tictactoe/views
 ---> 6c836c45947c
Step 15/16 : COPY config.yml /opt/tictactoe/
 ---> b168016f7cad
Step 16/16 : WORKDIR /opt/tictactoe
 ---> Running in f5b067ddcc7e
Removing intermediate container f5b067ddcc7e
 ---> 457274ae73ab
Successfully built 457274ae73ab
Successfully tagged tictactoe_api:latest
Recreating tictactoe_api ... done
Attaching to tictactoe_api
api_1  | Watching lib bin/lib bin/app.psgi for file updates.
api_1  | HTTP::Server::PSGI: Accepting connections at http://0:5000/
```

There will be quite a bit of output as all the Perl dependencies are installed. When all is said and done we should have
a `tictactoe_api` docker image built for our Dancer2 REST API backend and an `api` service defined in docker-compose as
well. Make note of these names because they can then be used to run various commands with both `docker-compose exec` and
`docker run`.

## Run the Application Locally

After the docker image is initially built we may want to start things up by running the following command so as not to
have to wait for the image to build in subsequent runs.

```
$ docker-compose up
tictactoe_api is up-to-date
Attaching to tictactoe_api
api_1  | Watching lib bin/lib bin/app.psgi for file updates.
api_1  | HTTP::Server::PSGI: Accepting connections at http://0:5000/
```

You could also run it as follows if you want to run it in the background detached.
```
docker-compose up -d
```

Here you can then use `docker-compose ps`, `docker-compose stop`, etc. See `docker-compose help` for more information.

## Run the Tests

You can run all the tests with the following docker-compose command after first running `docker-compose up`.

```
docker-compose exec api carton exec prove -rlv t/
```

Alternatively we can issue the following `docker` command to run all the tests.

```
docker run -it --rm -v $PWD:/opt/tictactoe tictactoe_api carton exec prove -rlv t/
```

## Update cpanfile and cpanfile.snapshot

For posterity's sake I just wanted to mention that if you make any changes to the `cpanfile` you can then update the `cpanfile.snapshot` by runnning the following:

```
docker run -it --rm -v $PWD:/src tictactoe_api carton install --cpanfile=/src/cpanfile
```
