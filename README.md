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
│   ├── raw/          # frozen API dumps + provenance.json  (.gitkeep)
│   ├── processed/    # cleaned / joined layers            (.gitkeep)
│   └── external/     # GADM/HDX shapefiles (not committed if large)
├── scripts/
│   ├── fetch_osm_urban_ag.py
│   ├── fetch_worldbank.py
│   ├── fetch_nasa_power.py
│   └── fetch_fao.py
├── analysis/
│   └── spatial/
│       ├── 01_clean.R
│       ├── 02_spatial_stats.R
│       └── 03_maps.R
├── manuscript/
│   ├── manuscript.qmd   # Quarto source → docx (TNR 12pt, 1.5, ≤12pp)
│   ├── _quarto.yml
│   ├── references.bib
│   └── manuscript.docx  # generated — the submission artifact
├── docs/
│   ├── theme-verification.md
│   └── flyer-transcription.md
├── references/           # PDFs / notes
├── Screenshot 2026-08-25 054719.png
└── WhatsApp Image 2026-08-24 at 9.23.15 PM.jpeg
```

**Dual persistence:** Working directory *is* the git clone on `D:\` ; every `git push` mirrors local Drive D → `batestguy/urban-agriculture-and-urban-food-security-in-nigeria`. No separate copy needed. `PROGRESS.md` is the running log in both places.

---

## 5. Progress Log

See **`PROGRESS.md`** for dated entries. Latest snapshot:

- **2026-08-25 06:07 UTC** — GitHub repo created: `batestguy/urban-agriculture-and-urban-food-security-in-nigeria` (public). Local `D:\YohannaPaper` initialized, `safe.directory` set to `D:/YohannaPaper`, remote `origin` added.
- **2026-08-25** — Workspace scaffolded (data/scripts/analysis/spatial/manuscript/docs), `.gitignore` + placeholder `.gitkeep`s, API fetch scripts stubbed, Quarto manuscript template created with flyer-compliant Word styling.
- **2026-08-25** — Theme verification completed (sub-theme 6 primary / 10,13 secondary / 17 fallback) — documented in `docs/theme-verification.md`.
- **Next:** Run `scripts/fetch_osm_urban_ag.py --city Abuja --out data/raw/osm_abuja.csv` + World Bank fetch → `data/raw/worldbank_ng.csv`; then `Rscript analysis/spatial/01_clean.R`.

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

- [ ] Abstract 150–300w + ≤6 keywords — email to `fpksstconf2026@gmail.com` by **5 Oct 2026**
- [ ] Full manuscript `manuscript/manuscript.docx` — TNR 12pt, 1.5 spacing, **≤12 pages** — by **9 Oct 2026**
- [ ] Figures/tables within page limit; references formatted; ethics & reflection sections included (Hull Ch 3 criteria)
- [ ] All numbers/figures reproducible from `data/raw/provenance.json` + scripts

---

## 8. References & Contact

- Conference contacts: +234(0)7066118734 | +2349095355158 | +234(0)7057200157
- Flyer: `WhatsApp Image 2026-08-24 at 9.23.15 PM.jpeg` — Bank: First Bank Plc, *School Of Science Conference Fpk*, **2047116096**
- Prior Hull marking: `Screenshot 2026-08-25 054719.png`

*Last updated: 2026-08-25 — Progress mirrored on Drive D (`D:\YohannaPaper\PROGRESS.md`) and GitHub (this README).*
