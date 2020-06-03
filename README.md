# Theme
This is a sample code for scraping to build a database up. Don't do scraping too much!

## Build a docker env

```
$ docker-compose up --build
```

## Prepare database and tables from sql

```
$ docker-compose exec ruby /bin/bash
$ sqlite3 overseas_job_offers.db

sqlite> .read initial.sql
```

## Start scraping

```
$ docker-compose run ruby bundle exec ruby scraping.rb
```
