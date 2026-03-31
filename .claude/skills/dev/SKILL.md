---
name: dev
description: Manage Docker Compose environment for the Attendance project (up, down, build, logs, stats)
argument-hint: "[up|build|down|restart|rebuild|logs|stats|prune]"
---

# /dev — Docker Environment Management

Manage the Docker Compose environment for the Attendance project.

## Usage
`/dev [action]`

- `/dev` — show current status (`make ps`)
- `/dev up` — start containers (`make up`)
- `/dev build` — start + rebuild images (`make up-build`)
- `/dev down` — stop and remove containers (`make down`)
- `/dev restart` — restart all containers (`make restart`)
- `/dev rebuild` — full clean rebuild (down → remove volumes → build → up)
- `/dev logs [api|client|db]` — tail logs (`make logs[-api|-client|-db]`)
- `/dev stats` — live resource usage (`make stats`)
- `/dev prune` — remove stopped containers and dangling images

## What to do
Based on the action argument above, run the appropriate `make` command from `/Users/trucnguyen/Documents/projects/training/`.
If no argument given, run `make ps` and show the container status.
For destructive actions (rebuild, down with volumes), confirm with the user first.
