COMPOSE = docker compose -f compose.yml

.PHONY: up down go python frontend package-apt package-file

up:
	$(COMPOSE) up --detach --build

down:
	$(COMPOSE) down --remove-orphans

go:
	$(COMPOSE) up --detach --build go

python:
	$(COMPOSE) up --detach --build python

frontend:
	$(COMPOSE) up --detach --build frontend

package-apt:
	packaging/apt/build.sh

package-file:
	packaging/file/build.sh
