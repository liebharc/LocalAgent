#!/usr/bin/bash

docker-compose up -d localai searchmcp
docker-compose run --rm --build agent
