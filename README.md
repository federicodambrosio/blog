# blog.dambrosio.nl

Personal blog built with [Hugo](https://gohugo.io) and the [Congo](https://github.com/jpanther/congo) theme, deployed at [blog.dambrosio.nl](https://blog.dambrosio.nl).

## Stack

- **Hugo** (extended) — static site generator
- **Congo** — Hugo theme (Tailwind-based), included as a git submodule under `themes/congo`
- **GoatCounter** — privacy-friendly analytics
- Custom navy color scheme (`assets/css/schemes/navy.css`), based on `#004D81`

## Local development

```bash
git clone --recurse-submodules git@github.com:federicodambrosio/blog.git
cd blog
cd themes/congo && npm install && cd ../..
hugo server
```

Site will be available at `http://localhost:1313`.

If styles look broken after pulling changes, clear the cache and rebuild:

```bash
rm -rf resources/_gen public
hugo server --ignoreCache --disableFastRender
```

## Drafts

Draft posts live outside version control, in a `drafts/` folder at the repo root (git-ignored). Hugo mounts this folder into `content/posts` at build time, so drafts preview locally exactly like published posts:

```bash
hugo server -D
```

Move a post into `content/posts/` (and drop `draft: true` from its frontmatter, if set) once it's ready to publish. Production builds (`hugo --minify`, no `-D`) never include anything from `drafts/`.

A pre-commit hook (`check-draft-locations`) enforces the split: it fails if a file marked `draft: true` is committed under `content/posts/`, or if a file under `drafts/` is missing that marker.

## Deployment

Deployment is automated via GitHub Actions (`.github/workflows/deploy.yml`) — every push to `main` builds the site with Hugo and pushes the output to the host over FTP. FTP credentials are stored as GitHub repository secrets (`FTP_HOST`, `FTP_USER`, `FTP_PASS`, `FTP_REMOTE_PATH`) and are never committed to the repo.

### Manual deploy

A local `deploy.sh` script is also available, using credentials from a git-ignored `.env` file:

```bash
./deploy.sh
```

It will:

1. Warn if there are uncommitted local changes
2. Build the site and stamp it with the current commit SHA (`public/version.txt`)
3. Deploy over FTP, mirroring `public/` to the configured remote path

**Double-check `FTP_REMOTE_PATH` in `.env` before running.** A full mirror-delete against the wrong remote path can wipe far more than intended — this has happened once already. `set -euo pipefail` also stops the script immediately on any build/deploy error rather than continuing with a partial build.

### Checking the deployment is in sync

Every build stamps `public/version.txt` with the git commit SHA it was built from. To confirm the live site matches your latest local commit:

```bash
./scripts/check_deploy.sh
```

This compares `git rev-parse HEAD` against `https://blog.dambrosio.nl/version.txt` and reports whether they match.

## Pre-commit hooks

This repo uses [pre-commit](https://pre-commit.com) to catch build errors and accidental secrets before they're committed.

```bash
pip install pre-commit
pre-commit install
```

Hooks include: trailing whitespace/EOF fixes, YAML/TOML validation, large-file checks, secret scanning ([gitleaks](https://github.com/gitleaks/gitleaks)), a Hugo build check, a guard against committing `.env`, and a check that drafts/posts live in the correct folder (see [Drafts](#drafts)).

## License

The code in this repository (Hugo configuration, layouts, custom CSS, deployment workflows) is licensed under the [MIT License](LICENSE).

The written content under `content/posts/` is licensed separately under [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/) — you may share it with attribution, but not create derivative works. See `content/posts/LICENSE` for the same notice inline.

The Congo theme (`themes/congo`) carries its own MIT license, included in that submodule.
