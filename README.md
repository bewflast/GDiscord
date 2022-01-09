# GDiscord
Simple chat integration between GMOD and Discord

# RU
### Установка:
1) Скачать [GWSockets](https://github.com/FredyH/GWSockets/releases/latest)
2) Скачать [CHTTP](https://github.com/timschumi/gmod-chttp/releases/latest)
3) Закинуть эти бинарки в папку `garrysmod/lua/bin`
4) Закинуть папку garrysmod в ... Угадайте, куда?
5) Установить бота, настроить его(!!!) - 9 строка main py
6) Отредактировать файл `garrysmod/addons/gdiscord/lua/gdisc/gdisc_config.lua`
7) Запустить бота
8) Наслаждаться

Примечание:
Если вы развертываете веб-сокет на той же машине, что и игровой сервер, то в поле ip указывайте 'localhost' !!! И в `main.py`, и в `gdisc_config.lua`!!!

# ENG
### Installation:
1) Download [GWSockets](https://github.com/FredyH/GWSockets/releases/latest)
2) Download [CHTTP](https://github.com/timschumi/gmod-chttp/releases/latest)
3) Put these binaries in `garrysmod/lua/bin`
4) Put the `garrysmod/addons/...` folder in... Guess, where?
5) Install the bot, configure it(!!!) - line 9 in main py
6) Configure `garrysmod/addons/gdiscord/lua/gdisc/gdisc_config.lua`
7) Start the bot
8) Enjoy

Short notice:
If you are deploying websocket on the same machine as game server, then specify ip as 'localhost' in both `main.py` and `gdisc_config.lua` files!!!