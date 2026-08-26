# Urban Agriculture and Urban Food Security in Nigeria

> **Conference:** Federal Polytechnic Kaltungo, School of Science and Technology — **2nd Annual National Multidisciplinary Conference 2026** (13–15 Oct 2026, Multipurpose Hall, Gombe State)  
> **Theme:** *Bridging Knowledge Frontiers Through Science and Technology: Smart Innovations for Security, Sustainable Economic Development, and Community Resilience in Nigeria*  
> **Local workspace:** `D:\YohannaPaper` (also the git repo — every push mirrors Drive D → GitHub)  
> **GitHub:** `batestguy/urban-agriculture-and-urban-food-security-in-nigeria` → https://github.com/batestguy/urban-agriculture-and-urban-food-security-in-nigeria

---

## 1. Theme Verification — Why this topic fits

**Flyer source:** `WhatsApp Image 2026-08-24 at 9.23.15 PM.jpeg` (17 sub-themes transcribed verbatim).

| # | Sub-theme (verbatim) | Fit |
|---|---|---|
| **6** | **Climate-Smart Agriculture, Food Security and Rural Transformation** | **Primary — exact keywords `Agriculture` + `Food Security`.** Urban agriculture is a recognized sub-domain; `Climate-Smart` framing (urban heat island, water scarcity, waste-to-compost circularity, rooftop/peri-urban) links directly to main theme's *sustainable development & community resilience*. Gap `Urban` vs `Rural` bridged as complementary: rural–urban food-system linkages, shortened supply chains, reduced rural pressure. |
| **10** | GIS, Urban Planning and Infrastructural Innovations | **Secondary** — covers the *Urban* spatial dimension (land-use mapping of urban farms, suitability analysis). |
| **13** | Environmental Sustainability, Circular Economy and Community Resilience | **Secondary** — urban food-system resilience & circularity. |
| **17** | Any other topic related to the theme | **Guaranteed fallback** — accepts any paper aligned to the main theme. |

> **Recommendation accepted:** Submit under **Sub-theme 6** (primary), cross-reference 10 & 13. Use the exact phrase *"Climate-Smart Agriculture, Food Security"* in abstract/keywords to mirror reviewer expectations. No exact verbatim `urban agriculture` string exists in 1–16 — this is the nearest semantic match and strongest fit.

**Evidence:** See `docs/theme-verification.md` for full transcription.

---

## 2. Paper Constraints (flyer — executable source prevails if conflict)

- **Abstract:** 150–300 words, MS Word, ≤6 keywords → submit to `fpksstconf2026@gmail.com`
- **Full paper:** MS Word, **Times New Roman 12pt, 1.5 spacing, ≤12 pages**, Deadline **full paper 9 Oct 2026** (abstract **5 Oct 2026**)
- **Fees:** Physical ₦13,000 / Virtual ₦10,000 / Students ₦5,000 / Extra certificate ₦3,000 — First Bank Plc, Acct Name: *School Of Science Conference Fpk*, Acct No: **2047116096**
- **Methodology standard:** Hull Ch 3 criteria (see `Screenshot 2026-08-25 054719.png` — criteria 2,3,5,8,9 rated *Excellent*): explain what/why, justify methods, demonstrate methodological knowledge, discuss ethics, reflect on process.
- **Submission artifact lives in:** `manuscript/` (Quarto source → clean `.docx` with TNR 12pt / 1.5 / ≤12pp enforced).

---

## 3. Research Design — Spatial Statistics + API Data

### 3.1 Question
How does the spatial distribution and intensity of urban agriculture in Nigerian cities relate to urban food-security outcomes, and what climate-smart, circular-economy levers improve resilience?

### 3.2 Data Sources (all via APIs — no manual scraping in app; freeze to CSV for reproducibility)

| Layer | API / Source | Endpoint | What we pull | Script |
|---|---|---|---|---|
| **Urban agriculture footprints** | **OpenStreetMap Overpass API** | `https://overpass-api.de/api/interpreter` | `landuse=allotments`, `landuse=farmland` + `farmyard`, `leisure=garden` within urban extents (Abuja, Lagos, Kano, Port Harcourt, Gombe) — real, attributed OSM data | `scripts/fetch_osm_urban_ag.py` |
| **Urban extents / population** | **World Bank Indicators API** | `https://api.worldbank.org/v2/country/NG/indicator/SP.URB.TOTL;AG.PRD.FOOD.XD;SN.ITK.DEFC.ZS` | Urban population, food production index, prevalence of undernourishment — national + sub-national where available | `scripts/fetch_worldbank.py` |
| **Climate / agro-weather** | **NASA POWER API** | `https://power.larc.nasa.gov/api/temporal/daily/point` | Precipitation, temperature, humidity for growing-season analysis | `scripts/fetch_nasa_power.py` |
| **Food prices / markets** | **FAOSTAT / WFP VAM (if open)** | `https://fenixservices.fao.org/faostat/api/v1/en/data/FS` | Food Consumer Price Index, market prices | `scripts/fetch_fao.py` (fallback: `data/external/` manual FAOSTAT dump) |
| **Administrative boundaries** | **GADM / Humanitarian Data Exchange** | `https://data.humdata.org` | LGA / state polygons for spatial joins | `data/external/README.md` |
| **Ground truth (optional)** | **HDX / NBS Nigeria** | — | Nigeria Living Standards Survey, GHS panel | — |

All API pulls are **one-time, provenance-tracked** to `data/raw/*.csv` + `data/raw/provenance.json` (timestamp, URL, query). The paper and analysis read **only** the frozen CSVs.

### 3.3 Spatial Statistics Stack

**Primary: R 4.5.2** (`sf 1.1.2`, `terra 1.9.46`, `spdep 1.4.2`, `spData` — verified on this machine; `tmap`/`leaflet` absent — install if maps needed) — see `ENVIRONMENTS.md`.
- **Descriptive:** density of allotments/km² by city, nearest-neighbor, kernel density (`spatstat.*`).
- **Autocorrelation:** Global Moran's I & LISA ( `spdep::moran.test`, `localmoran`) on food-security indicator by LGA.
- **Regression:** Spatial lag / spatial error models (`spatialreg::lagsarlm`, `errorsarlm`) — urban ag density + climate covariates → food-security outcome, controlling for population density.
- **Suitability:** Weighted overlay (`terra`) — proximity to markets, water, land availability.

**Secondary: Python** (`ds-general` env, Python 3.12) for API harvesting + `geopandas`/`shapely` if added — `conda list -p C:\Users\TOSHIBA\ds-general` to verify before use.

### 3.4 Repro Pipeline
```
scripts/fetch_*.py  → data/raw/*.csv (+ provenance.json)
        ↓
R: analysis/spatial/01_clean.R → data/processed/
R: analysis/spatial/02_spatial_stats.R → results/tables, figures
quarto render manuscript/manuscript.qmd → manuscript/manuscript.docx (clean Word, ≤12pp)
```

---

## 4. Repository Structure

```
D:\YohannaPaper\
├── AGENTS.md                       # agent bootstrap — env traps, paper constraints
├── ENVIRONMENTS.md                 # 10-env routing reference (Windows 11)
├── README.md                       # this file — progress + submission guide
├── PROGRESS.md                     # dated log (mirrored here and on GitHub)
├── .gitignore
├── data/
│   ├── raw/          # frozen API dumps + provenance.json  (.gitkeep) — 484 OSM pts, 75 WB, 1,825 NASA, 775 LGAs
│   ├── processed/    # cleaned / joined layers            (.gitkeep) — osm_urban_ag.gpkg, nasa_annual.csv, worldbank_ng_wide.csv
│   └── external/     # GADM/HDX shapefiles — gadm41_NGA_2.shp (4.56 MB, 775 LGAs)
├── scripts/
│   ├── fetch_osm_urban_ag.py       # per-tag Overpass, 3 endpoints, dedup
│   ├── fetch_worldbank.py
│   ├── fetch_nasa_power.py
│   ├── fetch_fao.py
│   ├── fix_docx_format.py          # TNR 12pt 1.5, 1in margins, tables single
│   └── compact_tables.py           # Table 5–6 compaction for 12 pp
├── analysis/
│   └── spatial/
│       ├── 01_clean.R              # → osm_urban_ag.gpkg + nasa_annual.csv
│       ├── 02_spatial_stats.R      # → results/lga_lisa.gpkg (Moran/LISA)
│       ├── 03_maps.R
│       ├── 04_extra_figs.R         # → density_vs_rainfall, top10
│       ├── run_regression.R        # → Tables 5–6 (log area + climate)
│       └── check_sensitivity.R     # → rook vs queen, Kano-excluded
├── manuscript/
│   ├── manuscript.qmd   # Quarto source → docx (TNR 12pt, 1.5, ≤12pp, 2,307 w, 12 pdf pp)
│   ├── _quarto.yml
│   ├── references.bib   # 20 refs (50% ≥2022)
│   └── manuscript.docx  # generated — the submission artifact (470 KB, 12 pp)
├── docs/
│   ├── theme-verification.md
│   ├── section-scores.md          # 0–5 per section, overall 5.0
│   ├── methodology.qmd            # detailed methodology source (typst)
│   ├── methodology.pdf            # 10 pp, 406 KB, equations + layman boxes
│   ├── methodology.typ            # typst intermediate
│   ├── references.bib             # copy for typst root
│   └── flyer-transcription.md
├── results/
│   ├── lga_lisa.gpkg              # 775 LGAs + density, lisa_I/p, quad
│   ├── top10_density.csv
│   └── figures/                   # 2 figs at 2in (lisa_map, density_vs_rainfall) + 4 archived
├── Screenshot 2026-08-25 054719.png
└── WhatsApp Image 2026-08-24 at 9.23.15 PM.jpeg
```

**Dual persistence:** Working directory *is* the git clone on `D:\` ; every `git push` mirrors local Drive D → `batestguy/urban-agriculture-and-urban-food-security-in-nigeria`. No separate copy needed. `PROGRESS.md` is the running log in both places.

---

## 5. Progress Log

See **`PROGRESS.md`** for dated entries. Latest snapshot (2026-08-26):

- **2026-08-25 06:07 UTC** — GitHub repo created: `batestguy/urban-agriculture-and-urban-food-security-in-nigeria` (public). Local `D:\YohannaPaper` initialized, `safe.directory` set to `D:/YohannaPaper`, remote `origin` added.
- **2026-08-25** — Workspace scaffolded, theme verification (sub-theme 6 primary / 10,13 secondary) — `docs/theme-verification.md`.
- **2026-08-26 03:19 UTC** — Phase 2–3: GADM 775 LGAs (4.56 MB) + clean → `nasa_annual.csv` + Moran $I_{density}=0.300$ ($z=17.6$) + LISA + maps; Phase 4–5: manuscript 2,307 w → 12 pdf pages (TNR 12pt 1.5) + 2 figs 2in + 4 tables compact + 20 refs.
- **2026-08-26 05:21 UTC** — **Detailed methodology PDF** `docs/methodology.pdf` (10 pp, 406 KB, typst) with equations (1)–(5) and layman boxes for every step from API downloads to regression — `quarto render docs/methodology.qmd --to typst` → `docs/methodology.pdf` (see §8).
- **Next:** Final Word proof `manuscript/manuscript.docx` (`File→Info` 12 pp) → email abstract 5 Oct / full paper 9 Oct to `fpksstconf2026@gmail.com` (First Bank 2047116096).

---

## 6. How to Run (Windows 11, pwsh, absolute paths)

```pwsh
# 1. Activate env (see ENVIRONMENTS.md for traps)
conda activate C:\Users\TOSHIBA\ds-general   # Python API harvest
# or
Rscript --version   # R 4.5.2 for spatial stats

# 2. Fetch (one-time, frozen)
C:\Users\TOSHIBA\ds-general\python.exe scripts/fetch_osm_urban_ag.py --city Abuja --out data/raw/osm_abuja_allotments.csv
C:\Users\TOSHIBA\ds-general\python.exe scripts/fetch_worldbank.py --out data/raw/worldbank_ng.csv

# 3. Analyze
Rscript analysis/spatial/01_clean.R
Rscript analysis/spatial/02_spatial_stats.R

# 4. Render manuscript to Word (≤12pp, TNR 12pt, 1.5)
quarto render manuscript/manuscript.qmd --to docx
# check: manuscript/manuscript.docx → verify 12pp in Word before emailing to fpksstconf2026@gmail.com

# 5. Track & push (mirrors Drive D → GitHub)
git -C "D:\YohannaPaper" status
git -C "D:\YohannaPaper" add .
git -C "D:\YohannaPaper" commit -m "feat: ..."
git -C "D:\YohannaPaper" push origin master  # or main, depending on init
```

**Traps:** `ds-general` is a **prefix env** (`-p C:\Users\TOSHIBA\ds-general`, not `-n ds-general`); `appdev-env` is a venv at `Scripts\python.exe`; `git` on `D:\` needs `safe.directory` (already set). See `AGENTS.md` for full list.

---

## 7. Submission Checklist (from flyer)

- [x] Abstract 150–300w + ≤6 keywords — email to `fpksstconf2026@gmail.com` by **5 Oct 2026** — **158 w, 6 keywords** in `manuscript/manuscript.qmd:7-9`
- [x] Full manuscript `manuscript/manuscript.docx` — TNR 12pt, 1.5 spacing, **12 pdf pages** (2,307 w, 470 KB, 2 figs 2in + 4 tables compact) — **at limit** via `scripts/fix_docx_format.py` — by **9 Oct 2026**
- [x] Figures/tables within page limit; references formatted (20 refs, 50% ≥2022); ethics & positionality plus process reflection included (paragraph form, no Hull, 0 bullets)
- [x] All numbers/figures reproducible from `data/raw/provenance.json` + scripts (`provenance.json` 16 entries, `R 4.5.2` pinned)
- [x] Detailed methodology **PDF** `docs/methodology.pdf` (10 pp, 406 KB, typst) with equations (1)–(5) and layman boxes for every step from API downloads to regression — see §8

---

## 8. Detailed Methodology — Equations and Layman Explanations

**PDF:** [`docs/methodology.pdf`](docs/methodology.pdf) (10 pages, 406 KB, typst, toc, numbered sections) — **companion to the 12-page conference paper**. Covers every step with **formal equations** and **plain-English blue boxes**: World Bank/Overpass/NASA POWER/FAOSTAT/GADM downloads (endpoints, scripts, why each source, 484 OSM points, 75 World Bank rows, 1,825 NASA daily, 775 LGAs), cleaning (`01_clean.R` → `osm_urban_ag.gpkg`, `nasa_annual.csv`), area/density (`n/area`, GEOS spherical, 11.6–10,358 km²), weight matrix $\mathbf{W}$ queen vs rook ($I$ 0.300 vs 0.306), Global Moran $I$ (Eq.2, $z$), LISA $I_i$ (Eq.3, HH/LL), lag $y=\rho Wy+X\beta+\varepsilon$ (Eq.4) vs error $y=X\beta+u$ (Eq.5), estimates Tables 5–6 (775 $N$ $\rho=0.419$ AIC −2577.5; 34 $N$ PRECTOT $p=0.018$), Spearman, top-10, maps, reproducibility (`R 4.5.2`, `ds-general` 3.12, seeds, `provenance.json`), ethics/positionality, and re-run commands.

**Build:** `quarto render docs/methodology.qmd --to typst` → `docs/methodology.pdf` (requires `docs/references.bib` copy of `manuscript/references.bib` for typst project-root access). Source `docs/methodology.qmd` (22307 B) is fully commentable.

**Why separate PDF:** Conference paper must stay ≤12 pp and paragraph-focused (0 bullets, no Hull); this PDF is the **audit trail** for reviewers who want every equation and why.

---

## 9. References & Contact

- Conference contacts: +234(0)7066118734 | +2349095355158 | +234(0)7057200157
- Flyer: `WhatsApp Image 2026-08-24 at 9.23.15 PM.jpeg` — Bank: First Bank Plc, *School Of Science Conference Fpk*, **2047116096**
- Prior Hull marking: `Screenshot 2026-08-25 054719.png`

*Last updated: 2026-08-26 — Progress mirrored on Drive D (`D:\YohannaPaper\PROGRESS.md`) and GitHub (this README). Methodology PDF `docs/methodology.pdf` (10 pp) added as companion to 12-page conference paper.*
