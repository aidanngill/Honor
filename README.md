# Honor
Discord bot project made to learn Elixir. Constant work in progress considering this is my first Elixir program ever. The bot will save a message to the channel you set, given that it receives enough star reacts. You may invite the bot [here](https://discord.com/api/oauth2/authorize?client_id=859516226031452180&permissions=388176&scope=bot), although uptime is not guaranteed.

## Requirements
* Elixir (1.12)
* Discord bot

For brevity, setting up a new Discord bot account will not be explained here.

## Getting Started
```bash
git clone git@github.com:ramadan8/Honor.git
cd Honor
```

The following environment variables will be necessary to run the bot and do migrations.
```bash
export HONOR_TOKEN="your_discord_token"
export HONOR_DB_NAME="honor"
export HONOR_DB_USER="honor"
export HONOR_DB_PASS="super_secret_password"
export HONOR_DB_HOST="localhost"
export HONOR_DB_PORT="5432"
```

From here, you may then fetch dependencies and migrate the database.
```bash
mix deps.get
mix ecto.migrate
```

Finally, you can run the bot with the following command.
```bash
mix run --no-halt
```

Heading onto Discord, invite the bot and type the following commands to set the destination channel for starred messages to `#pins`, and the amount of reacts necessary for a message to be saved to `3`.
```
>channel #pins
>threshold 3
```