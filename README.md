# Axolotl Adventures — CSCM759

This is your starting point for the web development labs. Everything you need
is already installed. You do not have to set up PHP, Composer, a database or a
web server on your own machine.

---

## Getting started (once)

1. Click the green **Code** button at the top of this repository.
2. Choose the **Codespaces** tab, then **Create codespace on main**.
3. Wait. The first build takes a couple of minutes — it is installing PHP,
   Composer, Node and your database. Later starts are much faster.

When it finishes you will have VS Code running in your browser, with a terminal
at the bottom.

---

## Starting the web server

In the terminal:

```bash
php artisan serve --host=0.0.0.0
```

A notification will pop up with a link to your running site. Click it.

**Why `--host=0.0.0.0`?** Your code is running inside a container on a machine
somewhere else. Without that flag the web server only accepts connections from
inside the container, so your browser cannot reach it. This is the same
client/server separation you met in Lecture 1 — you are just seeing it from the
other side.

Press `Ctrl+C` to stop the server.

---

## Commands you will use

| Command | What it does |
|---|---|
| `php artisan serve --host=0.0.0.0` | Start the web server |
| `php artisan tinker` | Interactive shell — create and query models |
| `php artisan migrate` | Apply your database changes |
| `php artisan migrate:fresh --seed` | Wipe the database and rebuild it from scratch |
| `php artisan db:seed` | Load test data |
| `php artisan route:list` | Show every route in the application |
| `php artisan make:model Axolotl -m` | Create a model and its migration |

---

## Your database

There is no database server. Your entire database is a single file:

```
database/database.sqlite
```

Click it in the file explorer on the left and VS Code will show you the tables
and their contents. If you break your data beyond repair:

```bash
php artisan migrate:fresh --seed
```

---

## Saving your work

Your Codespace keeps its files, but **committing is how you actually save**.
Use the Source Control panel on the left (the branch icon), or:

```bash
git add .
git commit -m "Week 3: added Axolotl and Story models"
git push
```

Commit at the end of every lab, at minimum. If something breaks badly, a commit
you can go back to is the difference between losing ten minutes and losing the
session.

---

## A thing worth noticing

Look at `.gitignore`. Two entries matter:

```
/vendor
.env
```

`vendor/` holds every library Composer downloaded. It is not in version control
because `composer install` can rebuild it from `composer.json` at any time.

`.env` holds your application key, your database settings, and in a real
deployment your passwords and API keys. It is **never** committed. That is why
this project ships a `.env.example` instead — placeholders showing which
settings are needed, without any of the actual values.

When your Codespace was created, a script copied `.env.example` to `.env` and
generated a fresh application key for you. Every developer joining a project
does this same step.

You will be asked about this.

---

## If something goes wrong

Re-run the setup script — it is safe to run as many times as you like:

```bash
bash .devcontainer/post-create.sh
```

If that does not help, delete the Codespace and create a new one. Your committed
work is safe on GitHub; anything you have not committed is not. See above.
