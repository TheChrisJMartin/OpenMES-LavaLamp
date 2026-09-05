# OpenMES LavaLamp

Jakarta servlet WAR + PostgreSQL rewrite of ChrisMES / OpenMES. ReqSuite epic **E019**, release **LL-0.3.0**.

Source: [TheChrisJMartin/OpenMES-LavaLamp](https://github.com/TheChrisJMartin/OpenMES-LavaLamp). PHP reference: [`/home/chris/grok/openmes-og`](../openmes-og). Live PHP: [openmes-dev.donotpassgo.co.uk](https://openmes-dev.donotpassgo.co.uk).

Architecture, decisions, and release notes: **[DECISIONS.md](DECISIONS.md)**.

## Build

```bash
./mvnw -B verify
```

Produces `target/openmes.war`. Java 17+, Maven Wrapper (no system `mvn` required after wrapper install).

## Deploy

Set `OPENMES_DB_*` in Tomcat’s environment (`setenv.example.sh`). For a first-time empty `users` table also set `OPENMES_BOOTSTRAP_PASSWORD` (seeds `admin`). Then:

```bash
./deploy.sh
```

`deploy.sh` does **not** run SQL. On startup the WAR applies `db/migration/*` then `db/seed/*` and `/openmes/health` goes 200.

## Layout

```
src/main/java/uk/co/donotpassgo/openmes/   application
src/main/resources/db/migration/           schema patches (in the WAR)
src/main/resources/db/seed/                reference seed (in the WAR)
src/main/webapp/                           WAR static + web.xml
```
