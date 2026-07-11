# VLESS VPN service (Xray-core)

Отдельный Railway-сервис с Xray-core, протокол VLESS поверх WebSocket.
TLS не настраивается внутри контейнера — его терминирует edge/прокси платформы
(Railway или Cloudflare, если домен подключён к Cloudflare), контейнер получает
обычный HTTP/WS-трафик.

## Деплой на Railway

1. Railway → New Service → Deploy from GitHub repo → выбрать этот репозиторий.
2. В настройках сервиса **Root Directory** указать `vpn`.
3. Settings → Networking → Generate Domain (порт должен совпадать с `PORT`,
   который Railway передаёт автоматически).
4. Variables → добавить:
   - `VLESS_UUID` — приватный UUID клиента (сгенерировать: `python3 -c "import uuid;print(uuid.uuid4())"` или `uuidgen`). **Не коммитить в репозиторий.**
   - `VLESS_WS_PATH` — путь WebSocket, по умолчанию `/vless` (можно оставить как есть или задать свой).

## Переменные окружения

| Переменная       | Обязательна | Описание                                  |
|------------------|-------------|--------------------------------------------|
| `PORT`           | да (авто)   | Задаётся Railway автоматически            |
| `VLESS_UUID`     | да          | UUID клиента VLESS                        |
| `VLESS_WS_PATH`  | нет         | Путь WS-транспорта, по умолчанию `/vless` |

## Клиентская ссылка

После деплоя и генерации домена (`xxx.up.railway.app`) ссылка для клиента
(v2rayNG, NekoBox, Shadowrocket, Xray клиенты и т.д.):

```
vless://<VLESS_UUID>@<ваш-домен>:443?encryption=none&security=tls&type=ws&host=<ваш-домен>&path=%2Fvless#mainfarm-vpn
```

Замените `<VLESS_UUID>` и `<ваш-домен>` на реальные значения. Порт всегда `443`,
`security=tls` — потому что клиент подключается по HTTPS/WSS к edge платформы,
которая сама заворачивает TLS-сессию к контейнеру уже как обычный WS.
