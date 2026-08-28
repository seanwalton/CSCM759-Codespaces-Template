#!/usr/bin/env bash
# CSCM759 - runs automatically every time a Codespace is created.
# Safe to re-run by hand:  bash .devcontainer/post-create.sh
set -euo pipefail

say() { printf '\n\033[1;36m==> %s\033[0m\n' "$1"; }
warn() { printf '\n\033[1;33m!! %s\033[0m\n' "$1"; }

# ---------------------------------------------------------------------------
# 0. First-run bootstrap (only relevant before the Laravel app exists).
# ---------------------------------------------------------------------------
if [ ! -f composer.json ]; then
  warn "No composer.json found - this repo has no Laravel app in it yet."
  cat <<'MSG'

   To create one, run this in the terminal:

       composer create-project laravel/laravel . --no-interaction

   Then re-run:

       bash .devcontainer/post-create.sh

   ...and commit the result. Students will never see this message.

MSG
  exit 0
fi

# ---------------------------------------------------------------------------
# 1. PHP dependencies
# ---------------------------------------------------------------------------
say "Installing PHP dependencies (composer install)"
composer install --no-interaction --prefer-dist

# ---------------------------------------------------------------------------
# 2. Environment file
#
# .env is deliberately NOT in version control - see .gitignore.
# Every fresh Codespace therefore has to build one from .env.example.
# This is the exact thing the exam asks about, happening in front of them.
# ---------------------------------------------------------------------------
if [ ! -f .env ]; then
  if [ ! -f .env.example ]; then
    warn "No .env.example to copy from - skipping environment setup."
  else
    say "Creating .env from .env.example"
    cp .env.example .env
    php artisan key:generate --ansi
  fi
else
  say ".env already exists - leaving it alone"
fi

# Everything below needs a .env to edit.
if [ ! -f .env ]; then
  warn "No .env file - stopping here."
  exit 0
fi

# ---------------------------------------------------------------------------
# 3. Point APP_URL at this Codespace so url()/route() generate working links.
#    Without this, links come out as http://localhost and break in the browser.
# ---------------------------------------------------------------------------
if [ -n "${CODESPACE_NAME:-}" ]; then
  APP_URL="https://${CODESPACE_NAME}-8000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
  say "Setting APP_URL to ${APP_URL}"
  if grep -q '^APP_URL=' .env; then
    sed -i "s|^APP_URL=.*|APP_URL=${APP_URL}|" .env
  else
    printf '\nAPP_URL=%s\n' "${APP_URL}" >> .env
  fi
fi

# ---------------------------------------------------------------------------
# 4. SQLite database.
#    No server, no credentials, no separate container - it is one file.
# ---------------------------------------------------------------------------
say "Setting up the SQLite database"
mkdir -p database
touch database/database.sqlite

# Make sure .env actually points at SQLite (Laravel 11+ default, but be explicit)
if grep -q '^DB_CONNECTION=' .env; then
  sed -i "s|^DB_CONNECTION=.*|DB_CONNECTION=sqlite|" .env
else
  printf '\nDB_CONNECTION=sqlite\n' >> .env
fi

php artisan migrate --force --no-interaction || \
  warn "Migrations did not run. Try 'php artisan migrate' once the container has settled."

# ---------------------------------------------------------------------------
# 5. Front-end dependencies (only if this project uses them)
# ---------------------------------------------------------------------------
if [ -f package.json ]; then
  say "Installing front-end dependencies (npm install)"
  npm install --no-audit --no-fund
fi

# ---------------------------------------------------------------------------
# 6. Done
# ---------------------------------------------------------------------------
cat <<'MSG'

  ---------------------------------------------------------------
   Ready.

   Start the web server with:

       php artisan serve --host=0.0.0.0

   VS Code will pop up a notification with your link. The
   --host=0.0.0.0 part matters: without it the server only
   listens inside the container and the link will not work.

   Other things you will need:

       php artisan tinker        interactive shell
       php artisan migrate       apply database changes
       php artisan db:seed       load test data
       php artisan route:list    show every route

   Your database is database/database.sqlite - click it in the
   file explorer to browse the tables.
  ---------------------------------------------------------------

MSG
