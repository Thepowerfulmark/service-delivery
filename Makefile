COMPOSE = docker compose -f compose.yml

.PHONY: up down go python frontend lint package-apt package-file

lint:
	shellcheck packaging/apt/build.sh packaging/apt/postinst-go packaging/apt/postinst-python packaging/apt/postinst-frontend packaging/file/build.sh packaging/file/stack-ctl
	python3 -m py_compile apps/python/app.py

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
