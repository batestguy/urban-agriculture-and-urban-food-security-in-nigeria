#!/usr/bin/env python
"""
fetch_fao.py — FAOSTAT (or WFP) food-price placeholder. Writes stub + provenance.
FAOSTAT API: https://fenixservices.fao.org/faostat/api/v1/en/data/FS?area=159&area_cs=NG (requires fallback if 403)
Usage: python scripts/fetch_fao.py --out data/raw/fao_food_security.csv
If live fetch fails, writes a provenance-noted stub so pipeline still runs.
"""
import argparse, json, csv, pathlib
from datetime import datetime, timezone
try:
    import requests
except ImportError:
    requests = None

URL = "https://fenixservices.fao.org/faostat/api/v1/en/data/FS?area=159"

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--out", default="data/raw/fao_food_security.csv")
    args = p.parse_args()
    out = pathlib.Path(args.out); out.parent.mkdir(parents=True, exist_ok=True)
    rows = []
    status = "stub"
    try:
        if requests:
            r = requests.get(URL, timeout=30)
            if r.status_code == 200:
                j = r.json()
                data = j.get("data", [])[:500]
                for rec in data:
                    rows.append({"Area": rec.get("Area"), "Year": rec.get("Year"), "Value": rec.get("Value"), "Item": rec.get("Item")})
                status = f"live:{len(rows)}"
            else:
                status = f"http_{r.status_code}_stub"
    except Exception as e:
        status = f"error_{e}_stub"
    if not rows:
        rows = [{"Area": "Nigeria", "Year": "2023", "Value": "", "Item": "Food Security stub — replace with FAOSTAT dump in data/external/"}]
    with open(out, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["Area","Year","Value","Item"])
        w.writeheader(); w.writerows(rows)
    prov = pathlib.Path("data/raw/provenance.json")
    entry = {"source": "FAOSTAT API (or stub)", "url": URL, "status": status, "out": str(out), "timestamp_utc": datetime.now(timezone.utc).isoformat()}
    if prov.exists():
        try:
            prev = json.loads(prov.read_text(encoding="utf-8"))
            prev = prev + [entry] if isinstance(prev, list) else [prev, entry]
        except: prev = [entry]
    else: prev = [entry]
    prov.write_text(json.dumps(prev, indent=2), encoding="utf-8")
    print(f"Wrote {out} [{status}]")

if __name__ == "__main__": main()
