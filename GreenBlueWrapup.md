# Blue-Green Wrapup Plan — wiki.golly.life

## Context

Green stack (MW 1.39 + MySQL 8.0) is live and confirmed working at wiki.golly.life. This plan covers the complete cleanup: removing the blue stack, consolidating the `_new` naming back to canonical names, renaming volumes, updating all scripts (both rendered `.sh` and `.j2` templates), and verifying backups still work.

**Lessons from prior migration:** Container names didn't line up, old images kept getting run, MySQL data format mismatches caused volume nuke + restore. This plan is sequenced to avoid all of those failure modes.

## Current State

| Component | Blue (old, stopped) | Green (live) |
|-----------|-------------------|-------------|
| MW container | `ambivalent_mw` (exited) | `ambivalent_mw_new` (running) |
| MySQL container | `ambivalent_mysql` (exited) | `ambivalent_mysql_new` (running) |
| MW volume | `pod-golly-wiki_ambivalent_mw_data` (9.7GB) | `pod-golly-wiki_ambivalent_mw_new_data` (8.8GB) |
| MySQL volume | `pod-golly-wiki_ambivalent_mysql_data` (1.0GB) | `pod-golly-wiki_ambivalent_mysql_new_data` |
| Build dir | `g-mediawiki/` (MW 1.35) | `g-mediawiki-new/` (MW 1.39) |
| Build dir | `g-mysql/` (MySQL 5.7) | `g-mysql-new/` (MySQL 8.0) |
| Docker image | `pod-golly-wiki_ambivalent_mw` (829MB) | `pod-golly-wiki_ambivalent_mw_new` (981MB) |
| Docker image | `pod-golly-wiki_ambivalent_mysql` (581MB) | `pod-golly-wiki_ambivalent_mysql_new` (786MB) |
| Nginx | `https.wiki.golly.life.conf.blue` | `https.wiki.golly.life.conf` → `ambivalent_mw_new:8989` |

**Orphan volumes (empty, safe to delete):** `ambivalent_mw_data`, `ambivalent_mw_new_data`

**Disk free:** 3.9GB — volume copies must be sequenced carefully.

---

## Phase 1: Pre-flight Backup

Take a fresh backup from the live green DB before touching anything.

```bash
source /home/charles/pod-golly-wiki/environment
GOLLY_WIKI_MYSQL_CONTAINER=ambivalent_mysql_new \
  /home/charles/pod-golly-wiki/scripts/backups/wikidb_dump.sh
```

Verify:
- Dump file ends with `-- Dump completed on ...`
- Dump file is >50MB

---

## Phase 2: Edit docker-compose.yml

**Remove** the entire blue stack (services `ambivalent_mysql` and `ambivalent_mw`).

**Rename** green services to canonical names:
- Service `ambivalent_mysql_new` → `ambivalent_mysql`
- `container_name: ambivalent_mysql_new` → `container_name: ambivalent_mysql`
- Service `ambivalent_mw_new` → `ambivalent_mw`
- `container_name: ambivalent_mw_new` → `container_name: ambivalent_mw`
- `MYSQL_HOST=ambivalent_mysql_new` → `MYSQL_HOST=ambivalent_mysql`
- `depends_on: ambivalent_mysql_new` → `depends_on: ambivalent_mysql`
- Volume `ambivalent_mysql_new_data` → `ambivalent_mysql_data` (both in service mount and `volumes:` section)
- Volume `ambivalent_mw_new_data` → `ambivalent_mw_data` (both in service mount and `volumes:` section)

**Remove** the `# ========== GREEN STACK` / `# ========== END GREEN STACK` comment markers.

**Remove** old volume declarations (the ones that were for the blue stack).

Build contexts stay as `g-mediawiki-new` and `g-mysql-new` for now (changed in Phase 4).

---

## Phase 3: Update Nginx Config

**`g-nginx/conf.d/https.wiki.golly.life.conf`:**
- Change `proxy_pass http://ambivalent_mw_new:8989/` → `proxy_pass http://ambivalent_mw:8989/`

**Delete:**
- `g-nginx/conf.d/https.wiki.golly.life.conf.blue`
- `g-nginx/conf.d/https.wiki.golly.life.conf.green`

---

## Phase 4: Consolidate Build Directories

Remove old blue build dirs, rename green to canonical:

```bash
rm -rf g-mediawiki/
mv g-mediawiki-new/ g-mediawiki/

rm -rf g-mysql/
mv g-mysql-new/ g-mysql/
```

Update `docker-compose.yml` build contexts:
- `build: g-mediawiki-new` → `build: g-mediawiki`
- `context: g-mysql-new` → `context: g-mysql`

---

## Phase 5: Update Maintenance Scripts

### Scripts that use env var defaults (already correct after container rename):
These use `${GOLLY_WIKI_MYSQL_CONTAINER:-ambivalent_mysql}` or similar — the defaults will be correct once containers are renamed. **No changes needed** to:
- `scripts/backups/wikidb_dump.sh`
- `scripts/backups/wikifiles_dump.sh`
- `scripts/backups/wikidb_restore_test.sh`
- `scripts/mysql/restore_database.sh`

### Scripts with hardcoded names (already correct after container rename):
These hardcode `NAME="ambivalent_mw"` which will be correct. **No changes needed** to:
- `scripts/mw/fix_LocalSettings.sh` — but update `MW_DIR` path from `g-mediawiki` (still correct after Phase 4 rename)
- `scripts/mw/fix_extensions_dir.sh` — same
- `scripts/mw/fix_skins.sh` — same
- `scripts/mw/update_wikidb.sh` — same
- `scripts/mw/change_passwd.sh` — same

### Migration scripts to DELETE (no longer needed):
- `scripts/mw/fix_LocalSettings_new.sh`
- `scripts/mw/fix_extensions_dir_new.sh`
- `scripts/mw/fix_skins_new.sh`
- `scripts/mw/update_wikidb_new.sh`
- `scripts/mw/migrate_db_to_new.sh`
- `scripts/mw/migrate_images_to_new.sh`
- `scripts/mw/build_extensions_dir_139.sh`
- `scripts/switchover_to_green.sh`
- `scripts/rollback_to_blue.sh`

### Jinja Templates
The `.j2` templates for systemd services don't reference container names directly (they call scripts via the environment file). No template changes needed for container names. But verify after Phase 4 that any `.j2` templates referencing `g-mediawiki-new` or `g-mysql-new` paths are updated if they exist.

---

## Phase 6: Volume Rename + Container Switchover

**This is the critical phase.** Docker has no `volume rename` command — we must create new volumes and copy data. Disk is tight (3.9GB free), so order matters.

### Step 6.1: Stop everything
```bash
docker compose down
```

### Step 6.2: Remove old blue containers
```bash
docker rm ambivalent_mw ambivalent_mysql
```

### Step 6.3: Remove old blue Docker images
```bash
docker rmi pod-golly-wiki_ambivalent_mw pod-golly-wiki_ambivalent_mysql
```
*(Frees ~1.4GB of image layers)*

### Step 6.4: Rename MySQL volume (small, do first)
```bash
# Delete old blue MySQL volume (frees 1GB)
docker volume rm pod-golly-wiki_ambivalent_mysql_data

# Create canonical volume and copy green data into it
docker volume create pod-golly-wiki_ambivalent_mysql_data
docker run --rm \
  -v pod-golly-wiki_ambivalent_mysql_new_data:/from:ro \
  -v pod-golly-wiki_ambivalent_mysql_data:/to \
  alpine sh -c 'cp -a /from/. /to/'

# VERIFY: start a temp MySQL 8.0 container against the new volume
docker run --rm -d --name mysql_verify \
  -v pod-golly-wiki_ambivalent_mysql_data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=verify_temp \
  mysql:8.0

# Wait for it to start, then check tables
docker exec mysql_verify mysql -uroot -pverify_temp -e "USE wikidb; SELECT COUNT(*) FROM page;"

# If the above succeeds, clean up and remove old green volume
docker stop mysql_verify
docker volume rm pod-golly-wiki_ambivalent_mysql_new_data
```

**⚠️ If the MySQL verify step fails: STOP. Do not remove `pod-golly-wiki_ambivalent_mysql_new_data`. Investigate.**

### Step 6.5: Rename MW volume (large, do after freeing space)
```bash
# Delete old blue MW volume (frees ~9.7GB — critical for space)
docker volume rm pod-golly-wiki_ambivalent_mw_data

# Create canonical volume and copy green data into it
docker volume create pod-golly-wiki_ambivalent_mw_data
docker run --rm \
  -v pod-golly-wiki_ambivalent_mw_new_data:/from:ro \
  -v pod-golly-wiki_ambivalent_mw_data:/to \
  alpine sh -c 'cp -a /from/. /to/'

# Verify file count matches
docker run --rm -v pod-golly-wiki_ambivalent_mw_data:/d alpine sh -c 'find /d/images -type f | wc -l'
# Should be 62778

# Remove old green volume
docker volume rm pod-golly-wiki_ambivalent_mw_new_data
```

### Step 6.6: Remove orphan volumes
```bash
docker volume rm ambivalent_mw_data ambivalent_mw_new_data
```

### Step 6.7: Rebuild and bring up
```bash
docker compose up -d --build
```

### Step 6.8: Reload nginx config
```bash
docker exec ambivalent_nginx nginx -s reload
```

---

## Phase 7: Verify Everything Works

- [ ] `docker ps` — shows `ambivalent_mw`, `ambivalent_mysql`, `ambivalent_nginx`, `ambivalent_nginxexporter` (no `_new` suffixes)
- [ ] `docker volume ls | grep ambivalent` — shows only `pod-golly-wiki_ambivalent_mysql_data` and `pod-golly-wiki_ambivalent_mw_data`
- [ ] `docker images | grep ambivalent` — shows only `pod-golly-wiki_ambivalent_mw` and `pod-golly-wiki_ambivalent_mysql` (no `_new`, no old 1.35/5.7)
- [ ] Wiki loads at https://wiki.golly.life (logged out AND logged in)
- [ ] Images display correctly
- [ ] Can log in and edit a page

---

## Phase 8: Verify Backups

```bash
source /home/charles/pod-golly-wiki/environment
/home/charles/pod-golly-wiki/scripts/backups/wikidb_dump.sh
/home/charles/pod-golly-wiki/scripts/backups/wikifiles_dump.sh
```

Confirm both scripts complete successfully against the canonical container names.

---

## Phase 9: Clean Up Docker

```bash
docker image prune -f
docker system df
df -h /
```

Expected: significant disk space reclaimed (~20GB freed from duplicate volumes + old images).

---

## Summary of What Gets Deleted

| Item | Type | Size |
|------|------|------|
| `ambivalent_mw` container | container | — |
| `ambivalent_mysql` container | container | — |
| `pod-golly-wiki_ambivalent_mw` image | image | 829MB |
| `pod-golly-wiki_ambivalent_mysql` image | image | 581MB |
| `pod-golly-wiki_ambivalent_mysql_data` volume (old blue) | volume | 1.0GB |
| `pod-golly-wiki_ambivalent_mw_data` volume (old blue) | volume | 9.7GB |
| `pod-golly-wiki_ambivalent_mysql_new_data` volume (after copy) | volume | ~1GB |
| `pod-golly-wiki_ambivalent_mw_new_data` volume (after copy) | volume | ~8.8GB |
| `ambivalent_mw_data` orphan volume | volume | 4KB |
| `ambivalent_mw_new_data` orphan volume | volume | 4KB |
| `g-mediawiki/` directory (old MW 1.35) | directory | — |
| `g-mysql/` directory (old MySQL 5.7) | directory | — |
| `https.wiki.golly.life.conf.blue` | file | — |
| `https.wiki.golly.life.conf.green` | file | — |
| 9 migration/switchover scripts | files | — |
