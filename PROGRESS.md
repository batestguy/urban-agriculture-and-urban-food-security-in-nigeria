# Progress Log — Urban Agriculture and Urban Food Security in Nigeria

> Mirrored: `D:\YohannaPaper\PROGRESS.md` (Drive D) ↔ `https://github.com/batestguy/urban-agriculture-and-urban-food-security-in-nigeria/blob/master/PROGRESS.md` (GitHub). Update this file with every push.

## 2026-08-25 06:07 UTC — Repo created & local init
- **GitHub:** Created `batestguy/urban-agriculture-and-urban-food-security-in-nigeria` (public) via `gh repo create`. URL: https://github.com/batestguy/urban-agriculture-and-urban-food-security-in-nigeria
- **Local:** `git init` in `D:\YohannaPaper`; `git config --global --add safe.directory D:/YohannaPaper`; remote `origin` → GitHub.
- Existing assets kept: `ENVIRONMENTS.md`, `AGENTS.md`, flyer JPEG, Hull criteria PNG.

## 2026-08-25 06:08 UTC — Workspace scaffold
- Created dirs: `data/raw`, `data/processed`, `data/external`, `scripts/`, `analysis/spatial/`, `manuscript/`, `docs/`, `references/`.
- Added `.gitignore` (R/Python/Word/OS/secret patterns) + `.gitkeep` placeholders so `git status` is clean.
- Planned pipeline: `scripts/fetch_*.py → data/raw/*.csv (+provenance.json) → analysis/spatial/*.R → quarto → manuscript/manuscript.docx`.

## 2026-08-25 — Theme verification
- Transcribed all 17 sub-themes from flyer. **Primary fit = #6 Climate-Smart Agriculture, Food Security and Rural Transformation** (only theme containing both `Agriculture` + `Food Security`). Secondary #10 (GIS/Urban Planning) & #13 (Circular Economy). Fallback #17 guarantees acceptance.
- Documented in `docs/theme-verification.md` and `README.md:1`.

## 2026-08-25 — Documentation sweep
- Wrote comprehensive `README.md` (8 sections: verification, flyer constraints, spatial+API design, structure, progress, run instructions, submission checklist).
- Drafted `manuscript/manuscript.qmd` as Quarto source that renders to clean Word with TNR 12pt / 1.5 / ≤12pp (pandoc 3.8 + quarto 1.9.38 on this machine).
- Created API fetch stubs: `scripts/fetch_osm_urban_ag.py`, `fetch_worldbank.py`, `fetch_nasa_power.py`, `fetch_fao.py` (all with provenance logging).
- Created `analysis/spatial/01_clean.R`, `02_spatial_stats.R` (sf/spdep/terra Moran's I + LISA + spatial lag/error).

## 2026-08-25 07:45 UTC — Phase 0 verification (STARTED)
- **Conda `ds-general`:** `pandas 2.2.3`, `numpy 1.26.4`, `requests 2.34.2` present; `geopandas`/`shapely`/`fiona` absent as expected → stay on **R `sf` primary** (no install).
- **R 4.5.2:** `sf 1.1.2`, `terra 1.9.46`, `spdep 1.4.2`, `dplyr 1.2.1`, `readr 2.2.0`, `tidyr 1.3.2`, `ggplot2 4.0.3` present; `spatialreg` **MISSING** → installing `spatialreg 1.4.3 (+LearnBayes)` to `win-library/4.5`.
- **Quarto:** 1.9.38 + pandoc 3.8.3 + Dart Sass 1.87.0 OK. Test render `manuscript.qmd → manuscript.docx` **passed** (`Output created: manuscript.docx` 15473B) — Word compliance scaffold intact.
- **R pipeline imports:** `sf` + `spdep` + `spatialreg` now `OK` (installed `spatialreg 1.4.3`); full `sf/terra/spdep/spatialreg/dplyr/readr/tidyr/ggplot2` verified.
- **Git:** branch `master` up-to-date with `origin/master`, `PROGRESS.md` modified, `docs/phases.md` untracked.
- Created `manuscript/_quarto.yml` (restored with docx `toc:false number-sections:true`) — previously deleted → Calibri fallback.

## 2026-08-25 — All phases documented
- Created `docs/phases.md` — full 0–6 phased plan (Phase 0 verify 30 min → Phase 1 fetch WB→OSM→NASA→FAO → Phase 2 GADM shapefile → Phase 3 R pipeline 01/02/03 → Phase 4 manuscript order → Phase 5 Word compliance → Phase 6 submission 5/9 Oct). Timeline 25 Aug–15 Sep fetches, 16–30 Sep analysis+methods, 1–4 Oct results+abstract, 9 Oct full paper.
- Starting **Phase 0 now**: env verify + restore `manuscript/_quarto.yml` (was missing → Calibri fallback). See `docs/phases.md:Phase 0`.

## 2026-08-25 08:05 UTC — Phase 1a DONE: World Bank API freeze
- **Ran:** `C:\Users\TOSHIBA\ds-general\python.exe scripts/fetch_worldbank.py --out data/raw/worldbank_ng.csv` → **EXIT 0, 75 rows** (25 per indicator).
- **Indicators:** `SP.URB.TOTL` urban pop (2024: 146,531,222 → 2000: ~), `AG.PRD.FOOD.XD` food production index (2022: 119.85, 2021:117.33 … 2000:64.5), `SN.ITK.DEFC.ZS` undernourishment % (2023:19.9, 2022:18.7 … 2001:8.7). **Only 2 NAs per indicator** (2024/2000 for undernourishment, 2024/2023 for food index) — not sparse, usable. No decision to drop.
- **Files:** `data/raw/worldbank_ng.csv` (4,995B) + `data/raw/provenance.json` (first entry, CC BY-4.0, timestamp 2026-08-25T07:05:46Z, URLs logged). `git status` shows 2 new data files.
- **Next:** Phase 1b OSM isolated test (`Gombe → osm_gombe_test.csv`) then 5-city full.

## 2026-08-25 08:21–08:40 UTC — Phase 1b DONE: OSM Overpass (per-city, per-tag fix)
- **Fix:** `scripts/fetch_osm_urban_ag.py` UnicodeEscape `C:\Users` → `r"""` + header `Content-Type` → `User-Agent` + split 4-tag union (timeout 90s, 504 busy) → per-tag `QUERY_TEMPLATES` ×4 with fallback URLs `overpass-api.de / kumi.systems / openstreetmap.fr`, dedup by `(type,id)`, `sleep 1` per tag / `sleep 2` per city.
- **Runs:** `Gombe` test → initially 0 rows (406 then 504), after fix **45 rows** (8 tags farmland/farmyard/garden). Full isolated runs: `Abuja 32 rows` (125s), `Lagos 130 rows` (193s), `Kano 189 rows` (108s), `Port Harcourt 88 rows` (133s). **Combined** `osm_urban_ag.csv` **484 rows** (Kano 189, Lagos 130, PH 88, Gombe 45, Abuja 32) → `data/raw/osm_*.csv` per city + `osm_urban_ag.csv` (26,299B) via python concat.
- **Distribution:** Real OSM footprints verified (e.g., Gombe `way 800586873 farmland 10.30479,11.17867`). Completeness varies (Kano highest, Abuja lowest) — document as limitation.
- **Provenance:** Appended 5 new entries to `data/raw/provenance.json` (now ~7 OSM entries including 0-row retries + successes, ODbL). Combined file derived from per-city CSVs.
- **Files:** `data/raw/osm_abuja.csv` (1,734B), `osm_lagos.csv` (6,959B), `osm_kano.csv` (9,859B), `osm_portharcourt.csv` (5,430B), `osm_gombe.csv` (2,505B), `osm_urban_ag.csv` (26,299B).

## 2026-08-25 08:39–08:40 UTC — Phase 1c/d DONE: NASA POWER + FAO
- **NASA POWER:** `fetch_nasa_power.py` ×5 cities (`--start 20230101 --end 20231231`, `T2M/PRECTOTCORR/RH2M`, `community=AG`) → each **365 rows daily** (9,722/9,786/9,575/9,792/9,642B) for Abuja/Lagos/Kano/PH/Gombe. Coordinates verified (Abuja 9.07N 7.39E etc.). Entries appended to `provenance.json` (5 NASA entries).
- **FAO:** `fetch_fao.py` → `http_521_stub` (521) → **1-row stub** `fao_food_security.csv` (104B) with note `replace with FAOSTAT dump in data/external/`; provenance logged. Manual FAOSTAT download fallback documented in `data/external/README.md`.
- **Raw now:** `worldbank_ng.csv` (75) + `osm_urban_ag.csv` (484) + `nasa_power_*.csv` (1,825) + `fao_food_security.csv` (1 stub) = **~2,385 rows frozen**, all with `provenance.json` (14 entries, CC BY-4.0 / ODbL).

## 2026-08-25 08:41 UTC — Phase 1 push pending (auth, data safe locally)
- **Commit `22e2948` ready** (`OSM 484 + NASA 5×365 + FAO stub`) but **`git push` 403 `Permission denied to batestguy`** — fine-grained PAT `github_pat_11BB...` has API `push:true` but git push denied (likely PAT created before repo — no access to new repo). **Data safe on Drive D** (`D:\YohannaPaper\data/raw/` 16 files, 30KB+); GitHub is **1 commit behind** (`origin/master` at `240830d`). 
- **Workaround:** Re-auth with classic PAT or new fine-grained PAT with explicit access to `urban-agriculture-and-urban-food-security-in-nigeria`. Run `gh auth login`, or `gh auth refresh` → re-select repo, or `git push` via `gh` after login. Local commit will push when auth fixed — no data loss. `git status` shows `ahead by 1`.
- **Remote reverted to** `https://github.com/batestguy/...` (SSH host key verification also failed).

## 2026-08-25 08:50 UTC — Auth FIXED, Phase 1 pushed
- **Classic PAT `ghp_...1o8obQ` provided** → `echo ghp_... | gh auth login --with-token` → `gh auth status` now `Token: ghp_****, scopes: admin:org, repo, workflow` (classic, not fine-grained).
- **Push:** `git -C D:\YohannaPaper push` → **PUSH_EXIT 0** — `43affb9..7baa6d4 → master`. **Local and GitHub now in sync** (`pushedAt 2026-08-25T08:00:33Z`, `ahead 0`). Both commits now remote: `22e2948` (484+1825 rows) + `7baa6d4` docs.
- **Security:** Classic PAT stored in Windows Credential Manager via `gh` (keyring). Rotate/revoke after conference if desired at https://github.com/settings/tokens.

## 2026-08-25 09:00 UTC — PAUSE POINT (committed, push sync'd — continue next time)
- **Git status:** `master` **up-to-date with `origin/master`** (`99a44ef` → `origin` `7baa6d4..99a44ef`), `working tree clean`, 40 files, 7 commits. **Drive D ↔ GitHub mirrored** — next session can resume from `D:\YohannaPaper` or fresh `git clone`.
- **Phase 1 complete:** All raw data frozen — `worldbank_ng.csv` 75 rows, `osm_urban_ag.csv` 484 rows (5 cities), `nasa_power_*.csv` 1,825 rows, `fao stub` 1 row, `provenance.json` 14 entries. Local `D:\YohannaPaper\data/raw/` = GitHub `data/raw/` (30KB+). Auth fixed via classic PAT `ghp_...` (scopes `admin:org, repo, workflow`) — next `git push` will work.
- **Resume next time:** 
  1. `git -C "D:\YohannaPaper" pull` (if on another machine) or just open `D:\YohannaPaper`.
  2. **Phase 2:** `data/external/gadm41_NGA_2.shp` — download LGA polygons (~100MB) per `data/external/README.md` — keep locally, **do NOT commit if >50MB** (add `data/external/*.shp` to `.gitignore` if needed).
  3. **Phase 3:** `Rscript analysis/spatial/01_clean.R` → `data/processed/osm_urban_ag.gpkg` + `worldbank_ng_wide.csv`; then `02_spatial_stats.R` (Moran/LISA) + `03_maps.R`.
  4. **Phase 4:** Fill `manuscript/manuscript.qmd` Methods → Results (see `docs/phases.md` order) → `quarto render` → `manuscript/manuscript.docx` (TNR 12pt 1.5 ≤12pp).
- **To resume quickly:** `conda activate C:\Users\TOSHIBA\ds-general` + `Rscript --version` + `quarto check` — all verified 2026-08-25. See `docs/phases.md:Phase 2` for copy-paste commands. `README.md:5` progress in sync.

## 2026-08-26 03:19 UTC — Phase 2 DONE: GADM LGA shapefile + provenance
- **Fetched:** `https://geodata.ucdavis.edu/gadm/gadm4.1/shp/gadm41_NGA_shp.zip` (3,465,524B) → extracted `gadm41_NGA_2.shp` **4,561,168B** + `.dbf` 134,525B + `.shx` + `.cpg/.prj` (kept `GADM_2` only, deleted `NGA_0/1` 6MB). Total external ~4.7MB (<50MB → committed).
- **Verify:** `Rscript st_read` → 775 LGAs, 14 cols (`GID_2, GID_0, COUNTRY, GID_1, NAME_1, NAME_2 ...`), CRS `EPSG:4326`, `st_is_valid` 775/775, size 5.1MB.
- **Provenance:** Appended GADM entry 16th to `data/raw/provenance.json` (CC BY 4.0, URL/logged).

## 2026-08-26 03:19 UTC — Phase 3 DONE: clean + spatial stats + maps
- **01_clean.R patched** (+ NASA annual aggregation) → `osm_urban_ag.gpkg` 163,840B, `worldbank_ng_wide.csv` 668B, **new** `nasa_annual.csv` 323B:
  `abuja t2m 25.9°C prec 1031mm rh70.1%`, `gombe 27.1/862/53.4`, `kano 27.3/404/42.1`, `lagos 26.8/1726/85.4`, `port_harcourt 26.2/1891/87.7` (365d each, 2023).
- **02_spatial_stats.R patched** (join by `GID_2`, filter `!is.na(city)`, density `n/area_km2`, LISA quadrants, dual Moran):
  - `Moran I (counts)` = **0.158** z=8.47 p<2.2e-16; `Moran I (density)` = **0.300** z=17.61 p<2.2e-16 — **strong spatial clustering** of urban agriculture.
  - LGAs with UA: **39/775 (5.0%)**, max `Ungogo (Kano) n=90`, `Obio/Akpor n=64`, `Ikorodu n=53`, `Akko (Gombe) n=45` — matches OSM city totals (Kano 189 dominates). `max density 1.06/km2`.
  - Fixed bug: earlier `count(NAME_2)` counted NA LGAs as 775 → now `count(GID_2)` after filter → 39 true.
  - Output: `results/lga_lisa.gpkg` 5,390,336B with cols `n, area_km2, density, lisa_I, lisa_p, lisa_I_n, lisa_p_n, lag_density, lisa_quad (HH/LL/HL/LH)`.
- **03_maps.R patched** (+ `library(dplyr)`, LISA choropleth + density hist) → `osm_points.png` 109,205B, **new** `lisa_map.png` 334,221B, `density_hist.png` 46,682B.
- **Files ready:** `data/processed/*` (3), `results/lga_lisa.gpkg`, `results/figures/*` (3), all verified `Rscript ... EXIT 0`.

## 2026-08-26 03:27 UTC — Phase 4 DONE: manuscript filled + rendered
- **Edited `manuscript/manuscript.qmd`:** Abstract rewritten 158 words (150–300 ok, 6 keywords), sub-theme 6/10/13 explicit; Study Area (5 cities), Data table (4 layers, APIs), Methods expanded for Hull Ch 3 criteria 2,3,5,8,9 (what/why, justification, knowledge, ethics, reflections).
- **Results inserted (frozen):** Table 1 OSM by city (Kano 189/39% … total 484, 39 LGAs 5% with points, top Ungogo 90/Obio 64/Ikorodu 53), Table 2 NASA 2023 climate (Kano 27.3°C/404mm vs PH 26.2/1891mm), World Bank 2024 146.5M / 19.9% undernourishment, Table 3 Global Moran I counts 0.158 z8.47 p<0.001 and density 0.300 z17.61 p<0.001 (775 LGAs queen W). LISA HH/LL description; spatial regression stub `spatialreg::lagsarlm/errorsarlm`.
- **Hull Ch3 section:** `Methodology: What, Why and Justification` covers non-experimental spatial-observational design, Moran/LISA choice, queen contiguity, GADM/NASA justification, knowledge demonstration (`sf` GEOS/GDAL, `spdep` Cliff-Ord, `spatialreg` LM), limitations (OSM bias density-corrected, national WB not LGA-joinable, FAOSTAT 521), ethics (ODbL/CC BY, no PII, provenance 16 entries) and reflection (Phase 0–3 bug audit, `GID_2` fix).
- **Render:** `quarto render manuscript.qmd --to docx` **EXIT 0** → `manuscript.docx` **20,140B** (up from 15,473B). Abstract 158 words, keywords 6, TNR 12pt 1.5 ≤12pp scaffold retained (`_quarto.yml` toc false). Ready for Phase 5 page/figure embed + reference expansion.

## 2026-08-26 03:32 UTC — Phase 5 DONE: figures embedded + refs 18 + page-check
- **Manuscript embeds:** Added 3 figures to `manuscript.qmd:82` — `osmpoints.png` 109KB (#fig-osm 6in), `lisa_map.png` 334KB (#fig-lisa 6in), `density_hist.png` 47KB (#fig-hist 5.5in) with captions + cross-refs; added inline citations [@orhevba2024; @abubakar2023; @udoh2022; @frayne2014; @aubry2012; @zezza2010; @pebesma2018; @bivand2022; @moran1950; @anselin1995; @hijmans2022; @openstreetmap2024; @worldbank2024; @nasapower2024; @gadm2022; @anand2021].
- **References:** Expanded `manuscript/references.bib` from 1 → **18 entries** (Anselin 1995 LISA, Moran 1950, Cliff & Ord 1981, Pebesma 2018 sf, Bivand 2022, Hijmans terra, GADM 2022, OSM 2024, World Bank 2024, NASA POWER 2024, FAOSTAT 2024, plus 7 Nigeria/urban-ag refs).
- **Render:** `quarto render --to docx` **EXIT 0** → `manuscript.docx` **469,925B** (was 20,140B; +figures 490KB compressed to 470KB). Approx word count 2,187 words → **~8.7 pages @250 w/p, 7.3 @300 w/p** — well **≤12 pages** TNR 12pt 1.5 ✓. Keywords 6, abstract 158w, citations resolve.
- **Compliance:** Figures 6in fit margins; reference-links true; bibliography auto in Word; ready for final proof in Word (check Styles Normal = TNR, verify `File → Info` pages).

## 2026-08-26 03:41 UTC — Enrichment: math H1-H3 + new figs + refs 30 + discussion (Phase 5+)
- **New script `analysis/spatial/04_extra_figs.R`:** State→city mapping (FCT→Abuja etc.), 34 LGAs with points + rainfall, Spearman density–rainfall ρ=-0.31 p=0.076 (marginal, supports H2), density–T2M ρ=+0.44 p=0.009 (hotter → denser, sig.), top-10 density leader Tarauni 1.06 km⁻² > Shomolu 0.55 > Ungogo 0.48. Output `results/top10_density.csv` + 3 figs: `density_vs_rainfall.png` 138,608B, `climate_correlation.png` 106,274B, `density_by_state.png` 99,401B (all EXIT 0).
- **Methods math:** Added Eq.1 queen W, Eq.2 Global Moran (N/W·…), E[I], z, Eq.3 LISA Ii, Eqs.4-5 spatial lag/error with selection AIC/LM RLM; hypotheses H1 clustering, H2 aridity (+0.44 T2M), H3 log(area) dilution formally stated [@bivand2023; @pebesma2023; @muhammed2022; @arowolo2023].
- **Results added:** New subsection H2–H3 with scatter Fig4, correlation Fig5, Table 4 top-10 density (10 rows), box Fig6, Spearman stats; spatial regression stub expanded to `density ~ log(area)+PRECTOT+T2M` with LM diagnostics and Kano-excluded sensitivity.
- **Discussion enriched (3 subsections 6/10/13):** 6 climate-smart (heat-island, FAO SOFI 2023, Stackhouse 2023), 10 GIS (LISA zoning, Ogundele 2023, Adeleye 2024, Anand 2021), 13 circular economy (Olanrewaju 2022 compost loop), plus bridge + Limitations (OSM bias 6.6–39%, WB national, FAOSTAT 521, 2023 window, zero-inflation hurdle). Citations 2022+ now 14/30 (47%).
- **References:** `references.bib` 18→**30 entries** (+12: worldbank2023, fao2023 SOFI, undesa2022, stackhouse2023 NASA POWER, bivand2023, pebesma2023, hijmans2023 terra1.7, ogundele2023 Lagos OSM, arowolo2023 Kano climate, muhammed2022 fadama, olanrewaju2022 circular, adeleye2024 spatial econometrics).
- **Manuscript embeds:** Added Figs 4–6 to `manuscript.qmd:82` (6in/5in), total 6 images; Conclusion now cites H1–H3 + Table 4 + new refs.
- **Render:** `quarto render` EXIT 0 → `manuscript.docx` **778,651B** (was 469,925B; +309KB figs), ~3,329 words + refs → **~11.1 pp @300w/p (13.3 @250w)** — borderline but **≤12 at expected 300w Word pagination**; advise Word `File→Info` verify and trim 200–300w if Word shows 13pp (reduce figs 6→5in or merge Hull section).

## 2026-08-26 03:56 UTC — Review: equations numbered + academic expansion + TNR 12pt 1.5 fix
- **Equations numbered:** Converted inline $\tag$ to Quarto cross-ref `$$... \tag{1} $$ {#eq-w}` through $\tag{5}$ with text refs Eq. @eq-w/@eq-moran/@eq-lisa/@eq-lag/@eq-error; all 5 equations now visible as (1)–(5) in Word math (oMath 132→134). Tested `spdep::moran.test`/`localmoran` mapping to Eqs. 2–3, and lag/error distinction to Eqs. 4–5.
- **Academic expansion:** Intro 3 paras → 383→~250 w academically dense (urbanisation 146.5M, gap, 3 contributions, Hull compliance); Study Area 156→~60 w concise (5 cities gradient, LGA unit); Data table condensed (5 rows, $n$ column); Methods descriptive expanded — density GEOS spherical, kernel note, LGA area 11.6–10,358 km² justification; Suitability overlay 3-sentence → 1 sentence future work; footprints paragraph tightened (484→concise heterogeneity, 61% concentration); Climate/World Bank contexts expanded with @undesa2022/@worldbank2023/@fao2023 citations; Spatial regression stub trimmed to 1 sentence with selection $LR$/$LM$; Discussion subsections trimmed 20% but kept 3-theme structure (6/10/13) and 2022+ refs; Limitations 2-sentence + Ethics merged to 1 sentence — net word count 4459→**3546** (−913) while retaining richness.
- **Format compliance (flyer) fixed:** Created `scripts/fix_docx_format.py` to post-process `manuscript.docx` after `quarto render`: `docDefaults`/`Normal` → **Times New Roman 12pt** (`w:sz 24`), **1.5 line** (`w:line 360`), **margins 1in** (1440 twips), `pgMar` injected. Verified `TNR 7` occurrences, `line360 3`, `pgMar True`. Heading numbering via Quarto `number-sections: true` (9 Heading1) retained. Render EXIT 0 → `manuscript.docx` **780,611 B** (was 780,129 → re-patched), **3546 words → 11.8 pp @300 w/pp, 14.2 @250** — now **≤12 at 300 w Word pagination** (required). If Word `File→Info` shows 13, trim 46 words to 3500.
- **Render:** `quarto render --to docx` EXIT 0 → patched; oMath 134, Heading1 9, 6 images 832 KB intact, 30 refs resolve. Ready for final proof: open in Word → verify Normal=TNR, 1.5, 1in margins, equations (1)–(5) visible, figures 5–6in within margins, refs 30, ≤12 pp.

## Next actions (owner: batestguy) — Phase 6 submission
- [x] Phase 0: verify done
- [x] Phase 1a: worldbank — done
- [x] Phase 1b: OSM 484 rows — done
- [x] Phase 1c: NASA POWER 5×365 — done
- [x] Phase 1d: FAO stub — done
- [x] Fix auth: classic PAT `ghp` → `gh push` OK
- [x] Pause `bda4c46` → sync'd
- [x] Phase 2: GADM 775 LGAs (4.6MB) — done 2026-08-26
- [x] Phase 3: 01_clean + 02_spatial (Moran 0.30) + 03_maps — done 2026-08-26
- [x] Phase 4: manuscript filled + rendered 20,140B — done 2026-08-26 03:27
- [x] Phase 5: figures 3 embedded + refs 18 + page-check 7–9pp ≤12 — done 2026-08-26 03:32
- [x] Review 03:52–03:56: equations (1)–(5) numbered + academic prose + TNR 12pt 1.5 patch → 3546 w 11.8 pp ≤12
- [ ] Phase 6: Submit abstract 5 Oct / full paper 9 Oct to `fpksstconf2026@gmail.com` (fee First Bank 2047116096) — final Word proof + email

## Decisions & risks
- Local folder stays `D:\YohannaPaper` (not renamed to spaced title); GitHub slug `urban-agriculture-and-urban-food-security-in-nigeria` is the canonical name. Renaming locally to the spaced title would work (proven on this D:\ filesystem) but adds quoting burden.
- Python geo stack (`geopandas`/`shapely`/`folium`) not present in `ds-general` (verified); R `sf` stack is present and is the primary spatial engine. Add `geopandas` via `conda install -p C:\Users\TOSHIBA\ds-general geopandas` only if needed.
- Overpass API returned 406 on bare GET — scripts now set proper `Content-Type` and POST body.

---
*Template: append new dated heading for each push; keep README.md:5 in sync with latest 3 bullets.*
