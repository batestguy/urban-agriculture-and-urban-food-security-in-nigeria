# AGENTS.md — YohannaPaper

## What this repo is
- Conference paper: **Urban Agriculture and Urban Food Security in Nigeria** — targeting **Federal Polytechnic Kaltungo 2nd Annual Multidisciplinary Conference, 13–15 Oct 2026** (sub-theme 6: Climate-Smart Agriculture, Food Security and Rural Transformation; secondary 10,13; fallback 17) + dissertation **Chapter 3 (Methodology)** re-marked against Hull criteria.
- **Git:** `D:\YohannaPaper` is the clone on Drive D, mirrored to **GitHub `batestguy/urban-agriculture-and-urban-food-security-in-nigeria`** (public, created 2026-08-25). Remote `origin` already set; local = Drive D copy. Every push mirrors Drive D → GitHub.
- Windows 11, `D:\YohannaPaper` is the project root. OpenCode reports workspace root as `/` but it maps to `D:\` on this machine.

## Structure — verified 2026-08-25 (now git-tracked, scaffolded 2026-08-25)
- `ENVIRONMENTS.md` — sole routing reference for all 10 interpreters. **Source of truth** for which env to use. Not a package inventory; for pinned lists run `conda list -p <prefix>`.
- `Screenshot 2026-08-25 054719.png` — Hull Chapter 3 criteria table (criteria 2,3,5,8,9 all `Excellent`; 1,4,6,7 belong to other chapters).
- `WhatsApp Image 2026-08-24…jpeg` — Conference flyer (sub-themes, payment, contacts).
- `D:\ds-general.yml` holds the `ds-general` conda spec (python 3.12, pandas 2.2.3, etc.) — not inside `YohannaPaper/`.
- `README.md` / `PROGRESS.md` — dual persistence log (Drive D ↔ GitHub README). `docs/theme-verification.md` holds verbatim 17 sub-themes + fit justification.
- `data/raw|processed|external/` (with `.gitkeep`), `scripts/fetch_*.py` (Overpass/World Bank/NASA POWER/FAO → frozen `data/raw/*.csv` + `provenance.json`), `analysis/spatial/*.R` (sf/spdep/terra Moran/LISA/spatial regression), `manuscript/manuscript.qmd` → clean `manuscript/manuscript.docx` (TNR 12pt 1.5 ≤12pp).
- No `raw\*.json` or `raw\r_packages.csv` inside this folder; referenced by `ENVIRONMENTS.md` as external full inventories if they exist elsewhere.

## Paper constraints (from flyer — trust executable source if conflicting)
- Abstract: 150–300 words, MS Word, ≤6 keywords. Body: Times New Roman 12pt, 1.5 spacing, ≤12 pages. Submit to `fpksstconf2026@gmail.com`.
- Deadlines: abstract 5 Oct 2026, full paper 9 Oct 2026.
- Methodology doc must cover: explain what/why, justify methods, demonstrate knowledge of methods, discuss ethics, reflect on process.

## Environments — activation traps
Use `ENVIRONMENTS.md:9-23` task→env table. Defaults:

| Task | Activate |
|---|---|
| Generic/unsure | `conda activate C:\Users\TOSHIBA\ds-general` |
| Causal inference | `conda activate causality-handbook` |
| Deep learning / RL | `conda activate homl3` |
| Bayesian (Python) | `conda activate bap3` |
| Bayesian (R, preferred) | R 4.5.2 |
| Time-series | `conda activate prophet-env` |
| Stats/tidyverse/papers | R 4.5.2 |
| Web API / no DS deps | `C:\Users\TOSHIBA\appdev-env\Scripts\activate` (venv) |

Gotchas (`ENVIRONMENTS.md:77-92`):
- `ds-general` is a **prefix env** at `C:\Users\TOSHIBA\ds-general`. `conda activate ds-general` and `conda list -n ds-general` **fail**; use `conda activate C:\Users\TOSHIBA\ds-general` / `conda list -p C:\Users\TOSHIBA\ds-general`. Habitually use `-p <prefix>`.
- `appdev-env` is a **venv, not conda**. Interpreter is `C:\Users\TOSHIBA\appdev-env\Scripts\python.exe`; no `python.exe` at folder root. `conda activate` won't work.
- **numpy split:** 1.x in `bap3`/`homl3`/`ds-general`/`causality-handbook` (1.24–1.26) vs 2.x in `prophet-env`/`mlops-env`/`base`/system (2.4–2.5). **pandas split:** 3.0 in `causality-handbook`/`prophet-env`/`base`/system vs 2.1–2.2 in others. Expect API breaks.
- Python 3.14 (`appdev-env`, `C:\Python314`) has few scientific wheels — don't use for numeric work.
- Never install into `base` (19 GB incl. 3.6 GB shared `pkgs` cache). R has one install: 4.5.2, 1027 pkgs.

## Tooling
- `quarto 1.9.38` is global (any env). Node 24.15.0 / npm 11.16.0 / pnpm 10.33.2 / git 2.53.0 / uv 0.11.28 / conda 26.1.1+mamba.
- No formatter/linter/CI configured in this folder. If you add code, create its own `pyproject.toml`/`requirements` and document the env explicitly.

## Workflow for agents
- Read `ENVIRONMENTS.md` before choosing an interpreter. Verify with `conda list -p <prefix>` if unsure.
- Keep paper artifacts in `D:\YohannaPaper`; do not scatter into `D:\` or `C:\Users\TOSHIBA\`.
- Use `pwsh` with absolute Windows paths; quote paths with spaces. Prefer `workdir: D:\YohannaPaper` param over `cd`.
- If you initialize git, do so inside `D:\YohannaPaper` explicitly (`git init`), not at `D:\`.
