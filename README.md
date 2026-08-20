# egonat.me

Source for [egonat.me](https://egonat.me), the personal site of **Eric Mastro**, distributed systems and protocol engineer.

Currently **open to staff-level individual contributor and engineering leadership roles**. Remote preferred, based in Sydney, Australia. Reach me at **hireme@egonat.me**, or see [github.com/emizzle](https://github.com/emizzle).

## What's here

| Page | |
|---|---|
| [`/`](https://egonat.me) | Career summary and selected work |
| [`/slot-reservations`](https://egonat.me/slot-reservations) | Mechanism design for a decentralised storage market, with an adversarial analysis of six named attacker classes |
| [`/marketplace-state-restoration`](https://egonat.me/marketplace-state-restoration) | Benchmarked comparison of two on-chain architectures; worst-case gas cut by a factor of ten |
| [`/recoverability-analysis`](https://egonat.me/recoverability-analysis) | Per-state crash, exception and cancellation analysis of a distributed sales state machine |
| [`/how-i-work`](https://egonat.me/how-i-work) | One feature traced from research proposal through epic breakdown, implementation and specification |

The three design documents are real protocol work from Logos Storage (formerly Codex), published with permission of their open-source licence. Markdown sources sit alongside the rendered pages.

## Local

To spin up a local web server, run:
```shell
npm i
npm start
```

## Deploy

GitHub pages runs off the `main` branch, so push to `main` to deploy.

## Monitoring

Three scheduled workflows watch the live site. Both monitors report through GitHub issues, so alerts arrive by email without any external service.

| Workflow | When | What it does |
|---|---|---|
| [`uptime.yml`](.github/workflows/uptime.yml) | Hourly | Checks that `https://egonat.me/` returns 200. Opens an issue labelled `uptime` when it does not, updates that issue in place with a running downtime figure on each subsequent failure, and closes it on recovery. |
| [`link-check.yml`](.github/workflows/link-check.yml) | Weekly, and on every push to `main` | Runs [lychee](https://github.com/lycheeverse/lychee) over every page and reports links that do not resolve, under the `broken-links` label. |
| [`keepalive.yml`](.github/workflows/keepalive.yml) | Monthly | Pushes an empty commit to the orphan `keepalive` branch. Nothing to do with the site — see below. |

Both monitors can be run on demand from the Actions tab. `uptime.yml` takes an optional URL, which is the easiest way to exercise the whole open → update → close cycle without waiting for an outage:

```shell
gh workflow run uptime.yml -f url=https://egonat.me/definitely-not-a-page
```

A couple of things worth knowing:

- **Downtime figures are approximate.** The clock starts at the first *failed check*, not the true start of the outage, so at hourly cadence a reported duration is accurate to about ±1 hour. Scheduled runs are also delayed by GitHub under load, which is why downtime is measured from the issue's creation time rather than by counting checks.
- **False positives belong in [`lychee.toml`](lychee.toml)**, not in the workflow. Some hosts serve 403 to anything that is not a browser, and `rel="preconnect"` hints are not navigable URLs. Each existing entry there says why it is there.
- **`keepalive.yml` exists because GitHub disables scheduled workflows** in a public repository after 60 days without repository activity, which would silently switch off the two monitors. A monthly empty commit to a throwaway branch keeps them running while leaving this branch's history clean. If GitHub ever does disable them, it emails the repository admin and they can be switched back on from the Actions tab.

## Notes

Maths on the design pages renders through KaTeX from CDN. Fonts are IBM Plex Sans and IBM Plex Mono from Google Fonts. Everything else is local.

## Licence

Site code MIT. The design documents describe work done at Logos Storage and are reproduced here under that project's open-source licence.
