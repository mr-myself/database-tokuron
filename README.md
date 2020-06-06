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

## Others

I've prepared some sample queries in sample_query.txt. Check it out please if you're interested in.
