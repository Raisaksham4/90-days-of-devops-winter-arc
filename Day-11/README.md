# Day 11 - Docker Storage and Networking

This lab deploys PostgreSQL with persistent Docker storage, verifies container-to-container communication through a custom bridge network, demonstrates Docker DNS behavior, diagnoses a host-port conflict, and creates a file-level volume backup.

## Objectives

- Create and inspect a named Docker volume and custom bridge network.
- Persist PostgreSQL data across container removal and recreation.
- Connect to PostgreSQL from another container using Docker DNS.
- Compare name resolution on the default and custom bridge networks.
- Reproduce and fix a host-port allocation conflict.
- Back up the PostgreSQL volume and safely restart the database.

## Lab Configuration

| Resource | Value |
|---|---|
| Custom network | `app-net` |
| Named volume | `pgdata` |
| PostgreSQL container | `db` |
| PostgreSQL image | `postgres:16-alpine` |
| Database | `shop` |
| Database user | `admin` |
| Web containers | `w1`, `w2` |
| Published ports | `18080`, `18081` |
| Backup archive | `pgdata-backup.tgz` |

The password used during the exercise was a local lab credential and is intentionally not documented here.

## Storage and Persistence

The `pgdata` named volume was mounted at `/var/lib/postgresql/data`. A `notes` table was created and the following row was inserted:

```text
 id |  message
----+------------
  1 | I survive!
```

The `db` container was then removed and recreated with the same volume. Querying the table after recreation returned the original row, proving that the data lived in the named volume rather than the deleted container's writable layer.

## Container Networking and DNS

A temporary PostgreSQL client container joined `app-net` and successfully connected to PostgreSQL using `db` as the hostname. No PostgreSQL host port was required for this container-to-container connection.

DNS behavior was also compared:

- On Docker's default bridge, `db` failed to resolve with `bad address 'db'`.
- On the user-defined `app-net` bridge, `db` resolved to its container IP and responded successfully.

This demonstrates the automatic name-based service discovery provided by user-defined bridge networks.

## Port Mapping Troubleshooting

The first Nginx container published container port `80` on host port `18080` and returned `HTTP/1.1 200 OK`.

Starting a second container on the same host port failed with:

```text
Bind for :::18080 failed: port is already allocated
```

The failed container was removed and recreated with host port `18081`, which returned `HTTP/1.1 200 OK`. Multiple containers can listen on the same internal port, but they cannot bind the same host IP and port simultaneously.

## Volume Backup

PostgreSQL was stopped before the file-level backup to prevent database writes during the archive operation. The `pgdata` volume was mounted into a temporary Alpine container and archived as:

```text
pgdata-backup.tgz - 6.5 MB
```

After the backup, PostgreSQL restarted successfully, `pg_isready` reported that it was accepting connections, and the `I survive!` row remained available.

For a production database, a database-aware backup method such as `pg_dump` should be used and restoration should be tested regularly.

## Issue Encountered and Resolution

The initial insert command placed `I survive!` inside a double-quoted Bash argument. Bash treated the exclamation mark as history expansion and returned:

```text
-bash: !': event not found
```

The command was corrected by using a single-quoted shell argument with PostgreSQL dollar quoting:

```bash
docker exec db psql -U admin -d shop \
  -c 'INSERT INTO notes (message) VALUES ($$I survive!$$);'
```

## Key Learnings

- A container's writable layer is temporary, while a named volume has an independent lifecycle.
- Recreating a container does not remove data stored in an attached named volume.
- User-defined bridge networks provide automatic DNS resolution by container name.
- Container ports may be reused, but each published host port must be unique.
- A volume is live storage; a backup is a separate recovery copy.
- File-level database backups require a consistent state, and a backup is useful only when restoration has been verified.

## Evidence

| Evidence | Result |
|---|---|
| [Network and volume](evidence/01-network-volume.png) | `app-net` and `pgdata` created |
| [PostgreSQL running](evidence/02-postgres-running.png) | Database accepting connections |
| [Data before recreation](evidence/03-data-before-recreation.png) | Test row inserted |
| [Data persistence](evidence/04-data-persistence.png) | Row survived container replacement |
| [Container networking](evidence/05-container-networking.png) | Separate client queried `db` by name |
| [DNS comparison](evidence/06-dns-test.png) | Default bridge failed; `app-net` succeeded |
| [Port conflict and fix](evidence/07-port-conflict-and-fix.png) | Conflict reproduced and resolved on `18081` |
| [Volume backup](evidence/08-volume-backup.png) | 6.5 MB archive created; database restarted |

## Interview Readiness

**What is a Docker volume?**
A Docker-managed storage location that exists independently of a container's writable layer and can be reattached to replacement containers.

**What proved that the PostgreSQL data persisted?**
The row was inserted, the original container was removed, a new container was attached to the same volume, and the original row was queried successfully.

**Why use a user-defined bridge network?**
It isolates application containers and provides automatic DNS resolution by container name.

**Why did the host-port conflict occur?**
Both containers attempted to bind host port `18080`. Only one process or container can own the same host IP and port combination at a time.

**What is the difference between a volume and a backup?**
A volume is active application storage. A backup is a separate copy intended for recovery if the live storage is lost or corrupted.

**Why was PostgreSQL stopped for this archive?**
Copying database files while PostgreSQL is writing can produce an inconsistent file-level backup.
