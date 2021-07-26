# Computer bot

This bot is a reborn of [this](https://github.com/Er2pkg/computer) bot,
but on Telegram.

Bot uses an OOP-style of lua
as [described on Wikipedia](https://is.gd/f0Vadk)

Also, bot automatically detects language installed in the client.

TODO: Rewrite core to C, [lua have C API](https://www.lua.org/manual/5.3/manual.html#4)
and C is faster.

# Installation

[Alpine Linux](https://alpinelinux.org), root:
  * Enable community repo (in wiki)

  * Install: `apk add sudo git lua5.3 luarocks openssl-dev`

  * Install dependencies: `luarocks-5.3 install luasec`

  * Create user: `adduser user`

    setup sudo and login to user

  * Get repo: `git clone https://github.com/Er2ch/comp-tg`

    and `cd comp-tg`

  * Change token and owner in `config.lua`

    TODO: Use env instaed of config

  * Run: `lua5.3 init.lua`
