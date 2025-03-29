# Avoidit

# Getting started

Avoidit can be run either directly from source or in docker compose.

## Required ENV VARS

SECRET_KEY_BASE=```mix phx.gen.secret```
TOKEN_SIGNING_SECRET=```mix phx.gen.secret```
MAILGUN_DOMAIN=yourdomain
MAILGUN_API_KEY=yourapikey
EMAIL_FROM=yourmailgun@address.com
LINK_DOMAIN=https://avoidit.yourdomain.com
PHX_SERVER=true
DATABASE_URL=postgresql://user:pass@server:port/database
ADMIN_EMAIL=your@email.com
ADMIN_PASSWORD=yourPassword
PHX_HOST=avoidit.yourdomain.com

if you are running in docker compose you'll also want
POSTGRES_PASSWORD=yourdbpassword

## Run locally

1. Download the source
2. ```mix deps.get```
3. ```mix ecto.setup```
4 ```iex -S mix phx.server```

## Run in Docker
1. Copy the docker-compose.yaml and Caddyfile to your server
2. Update the domain in Caddyfile
3. Create a .env file with the ENV VARs above
4. ```docker compose up```

