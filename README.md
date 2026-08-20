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

## Notes

Maths on the design pages renders through KaTeX from CDN. Fonts are IBM Plex Sans and IBM Plex Mono from Google Fonts. Everything else is local.

## Licence

Site code MIT. The design documents describe work done at Logos Storage and are reproduced here under that project's open-source licence.
