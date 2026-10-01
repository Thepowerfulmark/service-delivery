# Поставка сервиса: dev и пакет

Шаблон поднимает три заготовки: Go, Python и статический фронт. Свой проект подставляется вместо каталога `apps/go`, `apps/python` или `apps/frontend`. Обвязка (`Makefile`, Compose, пакет и файловый архив) остаётся.

Секретов в репозитории нет. В примерах конфигов пароль записан как `change-me`.

## Что внутри

| Каталог | Что заменить |
|---|---|
| `apps/go` | исходник и `Dockerfile` вашего бинарника |
| `apps/python` | `app.py` и зависимости |
| `apps/frontend` | собранная статика и `nginx.conf` |

Порты заготовок: фронт `8080`, Go `8081`, Python `8082`. Проверка: `GET /healthz` отвечает `ok`.

## Dev на машине с Docker

```bash
cp .env.example .env
make up
```

Отдельные сервисы: `make go`, `make python`, `make frontend`. Остановка: `make down`.

Это локальный запуск через Docker Compose. Он не ставит пакеты в `/opt` и не трогает systemd.

## CI

Push и pull request в `main` запускают GitHub Actions: `shellcheck`, синтаксис Python, `go vet`, сборка трёх образов и `make package-apt`. Готовые `.deb` лежат в артефактах job. Тег `v*` публикует эти пакеты в GitHub Release.

## Пакет APT

```bash
make package-apt
```

В `dist/` появятся три `.deb`:

- `app-go` кладёт бинарник в `/opt/app-go`
- `app-python` кладёт `app.py` в `/opt/app-python` и зависит от `python3`
- `app-frontend` кладёт статику в `/opt/app-frontend` и зависит от `nginx`

`postinst` только создаёт `config.env` из примера, если файла ещё нет, и делает `systemctl daemon-reload`. Уже существующий `config.env` не перезаписывается. Сервис не включается и не стартует.

Запуск после установки пакета:

```bash
sudo systemctl enable --now app-go
sudo systemctl enable --now app-python
sudo systemctl enable --now app-frontend
```

## Файловый архив

```bash
make package-file
```

Архив `dist/stack-0.1.0.tar.gz` содержит те же файлы и скрипт `stack-ctl`.

```bash
tar -xzf dist/stack-0.1.0.tar.gz
cd stack-0.1.0
sudo ./stack-ctl install app-go
sudo ./stack-ctl enable app-go
sudo ./stack-ctl status
```

`install` копирует файлы в `/opt` и unit в systemd. Если `config.env` уже есть, он остаётся. Процесс при `install` не запускается. Старт делает только `enable`.

Имена для `install` и `enable`: `app-go`, `app-python`, `app-frontend`.
