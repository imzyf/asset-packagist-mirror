# asset-packagist-mirror

A tiny self-hosted mirror of [asset-packagist.org](https://asset-packagist.org)
for the few `bower-asset/*` packages a Yii2 project actually uses — so Composer
no longer has to download and search the 18 MB upstream index from inside China.

## How it works

Upstream uses the Composer v1 provider protocol, three levels deep:

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
6. regenerate `public/packages.json` with `providers-url` built from `RAW_BASE`.

To add a package: add a line to `bin/packages.dist.txt`, run `make sync`, commit.

Requirements: `bash`, `curl`, `jq`, `make`.

## Configure the served URL (`.env`)

`RAW_BASE` is the public base URL of the mirror, read from `.env` (falls back to
this repo's GitHub raw URL). Copy and edit:

```bash
cp .env.example .env
```

- GitHub raw: `RAW_BASE=https://raw.githubusercontent.com/imzyf/asset-packagist-mirror/main/public`
- Self-hosted nginx (`root .../public;`): `RAW_BASE=https://composer.example.com`

Re-run `make sync` after changing `RAW_BASE` so `packages.json` is regenerated.

## Use it in a project

```json
"repositories": [
    {
        "type": "composer",
        "url": "https://raw.githubusercontent.com/imzyf/asset-packagist-mirror/main/public/",
        "only": ["bower-asset/*", "npm-asset/*"]
    }
]
```

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
