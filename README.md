# asset-packagist-mirror

A tiny self-hosted mirror of [asset-packagist.org](https://asset-packagist.org)
for the few `bower-asset/*` and `npm-asset/*` packages a Yii2 project actually uses — so Composer
no longer has to download and search the 18 MB upstream index from inside China.

## Use it in a project

```json
"repositories": [
    {
        "type": "composer",
        "url": "https://zyf.im/asset-packagist-mirror/",
        "only": ["bower-asset/*", "npm-asset/*"]
    }
]
```

## How it works

[Upstream](https://cdn.asset-packagist.org/packages.json) uses the Composer v1 provider protocol, three levels deep:

```txt
packages.json                          (~240 B)
  └─ provider-includes → p/provider-latest/{hash}.json   (~18 MB, 167k packages)
       └─ providers["bower-asset/jquery"].sha256 = {pkgHash}
            └─ p/bower-asset/jquery/{pkgHash}.json        (real version + dist data)
```

This mirror **flattens** that: the `providers` map is written directly into our
own small `packages.json`, so Composer never fetches the 18 MB file.

## Layout

```txt
.
├── Makefile
├── .env.example          # RAW_BASE=...  (copy to .env)
├── bin/
│   ├── sync.sh           # the sync script
│   └── packages.dist.txt # wanted packages, one per line
└── public/               # << web root (serve this folder)
    ├── index.html
    ├── packages.json     # generated
    ├── generated-at.txt  # generated, last sync time (UTC)
    └── p/...             # provider files
```

Only `public/` is meant to be served; `bin/`, `.env`, and the cache stay private.

## Sync

`make sync` (→ `bin/sync.sh`) will:

1. read the wanted packages from `bin/packages.dist.txt`;
2. fetch the tiny upstream `packages.json` to learn the current `provider-latest` hash;
3. download the 18 MB `provider-latest.json` **only when that hash changed** (cached in `.cache/`);
4. resolve each package's current `sha256` and download any missing `public/p/{package}/{hash}.json`;
5. **prune** any stale provider files no longer referenced;
6. regenerate `public/packages.json` with `providers-url` built from `RAW_BASE`;
7. write `public/generated-at.txt` with the current UTC build time.

Everything under `public/` it produces (`packages.json`, `generated-at.txt`, `p/`) is
gitignored — it's CI-generated output, not source. To add a package: add a line to
`bin/packages.dist.txt` and push to `main`; GitHub Actions runs the sync and deploys
`public/` to Pages (see [Deploy](#deploy)). Run `make sync` locally only to preview
the result before pushing.

Requirements: `bash`, `curl`, `jq`, `make`.

## Configure the served URL (`.env`)

`RAW_BASE` is the public base URL of the mirror, read from `.env` (falls back to
`/`, i.e. root-relative). It must end with a trailing slash. Copy and edit:

```bash
cp .env.example .env
```

- **GitHub Pages (default):** `RAW_BASE=/asset-packagist-mirror/` — the site is
  served at `https://<user>.github.io/<repo>/`, so a root-relative path that is
  just the repo name works. It does not hard-code the domain, so it stays
  portable across forks and custom domains.
- Self-hosted nginx (`root .../public;`): `RAW_BASE=https://composer.example.com/`

Re-run `make sync` after changing `RAW_BASE` so `packages.json` is regenerated. CI
has no `.env` of its own — it copies `.env.example` verbatim (see
[Deploy](#deploy)), so to change the deployed `RAW_BASE` edit `.env.example` itself.

## Deploy

`.github/workflows/sync-and-deploy.yml` runs on every push to `main` (and via
manual `workflow_dispatch`): it checks out the repo, copies `.env.example` to
`.env`, runs `make sync`, then uploads `public/` as a Pages artifact and deploys
it. Nothing generated needs to be committed — the workflow rebuilds
`packages.json`, `generated-at.txt`, and `p/` from scratch on each run.

## Self-hosted nginx

Point the web root at `public/`:

```nginx
server {
    server_name composer.example.com;
    root /srv/asset-packagist-mirror/public;
    location / { try_files $uri $uri/ =404; }
}
```

Then set `RAW_BASE=https://composer.example.com` in `.env`, run `make sync`,
and use that URL as the `composer` repository.
