<div align="center">

# AFZ_maks2tg

**Мост из MAX в Telegram с пересылкой сообщений в реальном времени и ответами обратно**

[![Tests](https://github.com/AFETZ/AFZ_maks2tg/actions/workflows/tests.yml/badge.svg)](https://github.com/AFETZ/AFZ_maks2tg/actions/workflows/tests.yml)
[![Docker](https://github.com/AFETZ/AFZ_maks2tg/actions/workflows/docker-image.yml/badge.svg)](https://github.com/AFETZ/AFZ_maks2tg/actions/workflows/docker-image.yml)
![Python](https://img.shields.io/badge/Python-3.12%2B-3776AB?logo=python&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker&logoColor=white)

</div>

AFZ_maks2tg подключается к вашему аккаунту MAX как userbot, получает новые
сообщения через WebSocket и отправляет их в выбранный Telegram-чат. При
включённом режиме ответов под сообщениями появляется кнопка, позволяющая
отправить текст обратно в исходный чат MAX.

> [!WARNING]
> Это неофициальный проект, не связанный с MAX или Telegram. Он использует
> данные веб-сессии MAX и может перестать работать после изменения внутреннего
> API. Используйте его только для своих аккаунтов и с учётом правил сервисов.

## Возможности

- пересылка личных и групповых сообщений в реальном времени;
- текст, фото, видео, документы, аудио, стикеры, контакты, геолокации и ссылки;
- отображение пересланных и цитируемых сообщений;
- имена отправителей и названия групп;
- фильтрация по списку чатов MAX или прослушивание всех чатов;
- текстовые ответы из Telegram обратно в MAX;
- уведомления о подключении, потере связи и восстановлении;
- повторные попытки при таймаутах и Telegram rate limit;
- SOCKS5-прокси для Telegram;
- Docker Compose, ротация логов и автоматический перезапуск.

## Содержание

- [Быстрый старт](#быстрый-старт)
- [Получение данных доступа](#получение-данных-доступа)
- [Настройка](#настройка)
- [Использование](#использование)
- [Установка без Docker](#установка-без-docker)
- [Обновление и обслуживание](#обновление-и-обслуживание)
- [Решение проблем](#решение-проблем)
- [Разработка](#разработка)
- [Безопасность и правовой статус](#безопасность-и-правовой-статус)

## Быстрый старт

### Требования

- Linux-сервер, домашний компьютер или VPS с постоянным доступом в интернет;
- Docker Engine и Docker Compose v2;
- аккаунт на [web.max.ru](https://web.max.ru);
- Telegram-бот, созданный через [@BotFather](https://t.me/BotFather).

Входящие порты, webhook и доменное имя не нужны: приложение само устанавливает
исходящие соединения с MAX и Telegram.

### 1. Клонирование

```bash
git clone https://github.com/AFETZ/AFZ_maks2tg.git
cd AFZ_maks2tg
```

### 2. Конфигурация

```bash
cp .env.example .env
chmod 600 .env
```

Откройте `.env` и заполните как минимум четыре переменные:

```dotenv
MAX_TOKEN=...
MAX_DEVICE_ID=...
TG_BOT_TOKEN=...
TG_CHAT_ID=...

TG_READ_TIMEOUT=30
TG_WRITE_TIMEOUT=30
TG_MEDIA_WRITE_TIMEOUT=120
DOCKER_NETWORK_MODE=bridge
DEBUG=false
REPLY_ENABLED=true
```

Перед первым запуском обязательно отправьте своему Telegram-боту `/start`.

### 3. Запуск

```bash
docker compose up -d --build
docker compose ps
docker compose logs -f --tail=100
```

Успешный запуск выглядит примерно так:

```text
Telegram bot ready: @your_bot
Telegram polling started (reply → Max enabled)
Connected. Sending handshake...
Authorized!
```

Чтобы проверить полный цикл, отправьте сообщение в MAX с другого аккаунта. Оно
должно появиться в Telegram; при `REPLY_ENABLED=true` под ним будет кнопка
**💬 Ответить**.

## Получение данных доступа

### Telegram: `TG_BOT_TOKEN`

1. Откройте [@BotFather](https://t.me/BotFather).
2. Выполните `/newbot` и задайте имя и username.
3. Скопируйте выданный HTTP API token в `TG_BOT_TOKEN`.
4. Откройте нового бота и отправьте `/start`.

Если токен когда-либо попал в сообщение, лог или Git, отзовите его командой
`/revoke` в BotFather и создайте новый.

### Telegram: `TG_CHAT_ID`

После отправки боту `/start` временно загрузите `.env` и запросите обновления:

```bash
set -a
source .env
set +a
curl -sS "https://api.telegram.org/bot${TG_BOT_TOKEN}/getUpdates" \
  | python -m json.tool
```

Найдите число в `result[].message.chat.id`. Для группы или канала оно обычно
отрицательное. Запишите его в `TG_CHAT_ID`.

> [!TIP]
> Если `result` пуст, ещё раз отправьте боту `/start`. На время запроса
> `getUpdates` остановите другие экземпляры этого бота.

### MAX: `MAX_TOKEN` и `MAX_DEVICE_ID`

1. Войдите в свой аккаунт на [web.max.ru](https://web.max.ru) через Chrome или
   Firefox.
2. Откройте DevTools: `F12` или `Ctrl+Shift+I`.
3. Перейдите в **Application** (Chrome) или **Storage** (Firefox).
4. Откройте **Local Storage → https://web.max.ru**.
5. Найдите:
   - `__oneme_auth` — это JSON; скопируйте только значение поля `token` в
     `MAX_TOKEN`;
   - `__oneme_device_id` — скопируйте значение в `MAX_DEVICE_ID`.

Оба значения дают доступ к вашей сессии MAX. После выхода из веб-аккаунта,
завершения сессии или смены механизма авторизации их может потребоваться
обновить.

## Настройка

| Переменная | Обязательна | Значение по умолчанию | Назначение |
|---|:---:|---|---|
| `MAX_TOKEN` | да | — | Токен из поля `token` объекта `__oneme_auth` |
| `MAX_DEVICE_ID` | да | — | Значение `__oneme_device_id` |
| `MAX_CHAT_IDS` | нет | все чаты | ID чатов MAX через запятую |
| `TG_BOT_TOKEN` | да | — | HTTP API token Telegram-бота |
| `TG_CHAT_ID` | да | — | ID личного чата, группы или канала назначения |
| `REPLY_ENABLED` | нет | `false` | Разрешить текстовые ответы Telegram → MAX |
| `TG_PROXY` | нет | без прокси | SOCKS5 URL, например `socks5://user:pass@host:1080` |
| `TG_READ_TIMEOUT` | нет | библиотечное | Таймаут чтения Telegram API, секунды |
| `TG_WRITE_TIMEOUT` | нет | библиотечное | Таймаут обычной отправки, секунды |
| `TG_MEDIA_WRITE_TIMEOUT` | нет | библиотечное | Таймаут загрузки медиа, секунды |
| `DEBUG` | нет | `false` | Подробные логи и JSON-дампы в `debug/` |
| `LOG_DIR` | нет | `logs` | Каталог файловых логов внутри приложения |
| `DOCKER_NETWORK_MODE` | нет | `bridge` | Сетевой режим Compose-контейнера |

### Пересылка только выбранных чатов

По умолчанию пустой `MAX_CHAT_IDS` означает все чаты. Чтобы ограничить
пересылку, перечислите ID через запятую:

```dotenv
MAX_CHAT_IDS=250510035,-71237346476114
```

ID чатов отображаются в стартовых логах после строки `Known chats`.

### Прокси Telegram

Для обычного удалённого прокси достаточно:

```dotenv
TG_PROXY=socks5://user:password@proxy.example.com:1080
```

Если SOCKS5-прокси запущен на том же Linux-хосте и слушает только
`127.0.0.1`, контейнеру нужен host network:

```dotenv
TG_PROXY=socks5://127.0.0.1:1080
DOCKER_NETWORK_MODE=host
```

`host` network специфичен для Linux. На Docker Desktop используйте адрес
`host.docker.internal` и оставьте `DOCKER_NETWORK_MODE=bridge`.

### Отладка

```dotenv
DEBUG=true
```

Режим создаёт подробные JSON-дампы, которые могут содержать сообщения и
персональные данные. Не публикуйте каталоги `debug/` и `logs/`.

## Использование

### Получение сообщений

После запуска сервис слушает новые события MAX. История сообщений при старте не
импортируется. Личные и групповые чаты оформляются по-разному, а вложения
отправляются подходящим типом Telegram-сообщения.

### Ответ из Telegram в MAX

1. Установите `REPLY_ENABLED=true` и пересоздайте контейнер.
2. Нажмите **💬 Ответить** под пересланным сообщением.
3. Отправьте текст в ответ на подсказку бота.
4. Дождитесь подтверждения `✅ Отправлено`.

Отмена незавершённого ответа:

```text
/cancel
```

Сейчас обратное направление поддерживает текст. Медиа из Telegram обратно в
MAX не пересылаются. Обработчик принимает команды только из `TG_CHAT_ID`,
указанного в конфигурации.

## Установка без Docker

Требуется Python 3.12 или новее:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
cp .env.example .env
chmod 600 .env
python -m app.main
```

Для постоянного запуска используйте менеджер процессов. Пример systemd unit:

```ini
[Unit]
Description=AFZ_maks2tg bridge
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=max2tg
Group=max2tg
WorkingDirectory=/opt/AFZ_maks2tg
EnvironmentFile=/opt/AFZ_maks2tg/.env
ExecStart=/opt/AFZ_maks2tg/.venv/bin/python -m app.main
Restart=on-failure
RestartSec=10
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

## Обновление и обслуживание

### Просмотр состояния и логов

```bash
docker compose ps
docker compose logs -f --tail=200
tail -f logs/max2tg.log
```

Файл `logs/max2tg.log` ротируется при достижении 10 МБ; хранится до пяти
архивных файлов.

### Перезапуск и остановка

```bash
docker compose restart
docker compose down
```

### Обновление

```bash
git pull --ff-only
docker compose up -d --build
docker image prune -f
```

Перед обновлением проверьте изменения `.env.example`. Сам `.env` Git не
отслеживает и команда `git pull` его не заменяет.

## Решение проблем

| Симптом | Что проверить |
|---|---|
| `Missing required environment variables` | Заполнены ли четыре обязательных поля в `.env`; видит ли Compose файл |
| `Telegram ... Timed out` | Доступ к `api.telegram.org`, `TG_PROXY`, сетевой режим и значения таймаутов |
| `Unauthorized` или постоянный reconnect MAX | Обновите `MAX_TOKEN` и `MAX_DEVICE_ID` из активной веб-сессии |
| Бот не может написать первым | Отправьте боту `/start`, затем проверьте `TG_CHAT_ID` |
| `Conflict: terminated by other getUpdates request` | С тем же токеном запущен второй экземпляр бота |
| Медиа приходят повторно или не загружаются | Увеличьте `TG_MEDIA_WRITE_TIMEOUT`, например до `300` |
| Ответ не уходит в MAX | Проверьте `REPLY_ENABLED=true`, кнопку под исходным сообщением и статус WebSocket |
| Контейнер постоянно перезапускается | Выполните `docker compose logs --tail=200` и проверьте типы значений в `.env` |

Проверка итоговой Compose-конфигурации без запуска:

```bash
docker compose config --quiet
```

## Архитектура

```text
MAX account
    │ WebSocket events
    ▼
AFZ_maks2tg ── HTTP/SOCKS5 ──► Telegram Bot ──► TG_CHAT_ID
    ▲                                      │
    └─── text reply ◄── inline button ◄────┘
```

Основные модули:

```text
app/main.py          запуск и жизненный цикл
app/config.py        загрузка и проверка конфигурации
app/max_client.py    WebSocket-клиент и команды MAX
app/max_listener.py  преобразование событий и вложений
app/resolver.py      имена контактов и чатов
app/tg_sender.py     отправка в Telegram и retry
app/tg_handler.py    кнопка ответа и отправка текста в MAX
```

## Разработка

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt pytest pytest-asyncio
pytest -q
docker compose config --quiet
docker build -t afz-maks2tg:dev .
```

Pull request должен проходить тесты на Python 3.12. Правила работы описаны в
[CONTRIBUTING.md](CONTRIBUTING.md), а рекомендации по сообщениям об уязвимостях
— в [SECURITY.md](SECURITY.md).

## Безопасность и правовой статус

- `.env`, `logs/` и `debug/` исключены из Git;
- ограничьте права на `.env` командой `chmod 600 .env`;
- не включайте `DEBUG` без необходимости;
- используйте отдельного Telegram-бота для этого сервиса;
- после утечки немедленно перевыпускайте соответствующие credentials;
- не запускайте мост для чужого аккаунта без явного разрешения владельца.

AFZ_maks2tg основан на
[Aist/max2tg](https://github.com/Aist/max2tg). История исходных коммитов
сохранена. Подробности об авторстве, лицензировании и товарных знаках находятся
в [NOTICE.md](NOTICE.md).

---

<div align="center">

Если проект оказался полезен, поставьте ⭐ и приложите логи без секретов при
создании issue.

</div>
