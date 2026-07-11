# VLESS VPN service (Xray-core)

Отдельный Railway-сервис с Xray-core, протокол **VLESS+TCP+REALITY**.
Изначально был WS+TLS через HTTP-домен Railway, но такой транспорт легко
распознаётся и блокируется DPI/TSPU на уровне провайдера (короткие запросы
проходят, длинные — обрываются). REALITY маскирует TLS-соединение под
настоящий сайт (`dest`) и не завязан на HTTP-домен PaaS, поэтому гораздо
устойчивее к такой блокировке.

Xray сам терминирует TLS и подделывает handshake под `REALITY_DEST` —
поэтому сервис должен торчать наружу как **raw TCP**, не HTTP-домен.

## Деплой на Railway

1. Railway → New Service → Deploy from GitHub repo → выбрать этот репозиторий.
2. Settings → **Root Directory** → `vpn`.
3. Settings → Networking → **TCP Proxy** → добавить прокси на внутренний порт,
   заданный переменной `PORT` (см. ниже). Railway выдаст публичный адрес вида
   `<region>.proxy.rlwy.net:<внешний_порт>` — этот адрес и внешний порт
   используются в клиентской ссылке.
   (Обычный HTTP-домен, если был создан раньше, можно удалить — он для этого
   транспорта не нужен и работать не будет.)
4. Variables → добавить:
   - `VLESS_UUID` — приватный UUID клиента.
   - `REALITY_PRIVATE_KEY` / соответствующий `PublicKey` — пара сгенерирована
     через `xray x25519`. Публичный ключ идёт в клиентскую ссылку (`pbk=`),
     приватный — только в переменную сервиса, **не коммитить**.
   - `REALITY_SHORT_ID` — короткий hex ID (`openssl rand -hex 4` или
     `python3 -c "import secrets;print(secrets.token_hex(4))"`).
   - `REALITY_DEST` / `REALITY_SERVER_NAME` — сайт, под который маскируемся
     (по умолчанию `www.microsoft.com:443` / `www.microsoft.com`).
   - `PORT` — фиксированный внутренний порт (по умолчанию `8443`, если не
     задан). Должен совпадать с портом, указанным при создании TCP Proxy.

## Переменные окружения

| Переменная             | Обязательна | Описание                                        |
|-------------------------|-------------|--------------------------------------------------|
| `PORT`                  | нет (авто `8443`) | Внутренний порт, должен совпадать с TCP Proxy |
| `VLESS_UUID`             | да          | UUID клиента VLESS                              |
| `REALITY_PRIVATE_KEY`    | да          | Приватный ключ REALITY (`xray x25519`)          |
| `REALITY_SHORT_ID`       | да          | Короткий hex ID (shortId)                       |
| `REALITY_DEST`           | нет (авто) | `хост:порт` сайта-маски, напр. `www.microsoft.com:443` |
| `REALITY_SERVER_NAME`    | нет (авто) | SNI/serverName, обычно домен из `REALITY_DEST` без порта |

## Клиентская ссылка

```
vless://<VLESS_UUID>@<TCP-PROXY-HOST>:<TCP-PROXY-PORT>?security=reality&encryption=none&pbk=<REALITY_PUBLIC_KEY>&fp=chrome&sni=<REALITY_SERVER_NAME>&sid=<REALITY_SHORT_ID>&type=tcp&flow=xtls-rprx-vision#mainfarm-vpn
```

Замените плейсхолдеры на реальные значения. `<TCP-PROXY-HOST>` и
`<TCP-PROXY-PORT>` — это адрес, который Railway выдаёт при создании TCP
Proxy (шаг 3 выше), не домен `*.up.railway.app`.
