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

## Deployment

Deployment is automated via GitHub Actions (`.github/workflows/deploy.yml`) — every push to `main` builds the site with Hugo and pushes the output to the host over FTP.

FTP credentials are stored as GitHub repository secrets (`FTP_HOST`, `FTP_USER`, `FTP_PASS`, `FTP_REMOTE_PATH`) and are never committed to the repo.

### Manual deploy

A local `deploy.sh` script is also available for manual deploys, using credentials from a git-ignored `.env` file:

```bash
./deploy.sh
```

**Always dry-run before any deploy that uses `--delete`** — a full mirror-delete against the wrong remote path can wipe far more than intended. Confirm the remote path with `lftp` and `ls` before running for real.

## Pre-commit hooks

This repo uses [pre-commit](https://pre-commit.com) to catch build errors and accidental secrets before they're committed.

```bash
pip install pre-commit
pre-commit install
```

Hooks include: trailing whitespace/EOF fixes, YAML/TOML validation, large-file checks, secret scanning ([gitleaks](https://github.com/gitleaks/gitleaks)), a Hugo build check, and a guard against committing `.env`.

## License

The code in this repository (Hugo configuration, layouts, custom CSS, deployment workflows) is licensed under the [MIT License](LICENSE).

The written content under `content/posts/` is licensed separately under [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/) — you may share it with attribution, but not create derivative works.

The Congo theme (`themes/congo`) carries its own MIT license, included in that submodule.
