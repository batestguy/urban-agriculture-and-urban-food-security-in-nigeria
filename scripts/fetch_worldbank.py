#!/usr/bin/env python
"""
fetch_worldbank.py — World Bank Indicators API for Nigeria (urban + food security).
Frozen to data/raw/worldbank_ng.csv + data/raw/provenance.json
Indicators: SP.URB.TOTL (urban population), AG.PRD.FOOD.XD (food production index), SN.ITK.DEFC.ZS (undernourishment)
Usage:
  python scripts/fetch_worldbank.py --out data/raw/worldbank_ng.csv
"""
import argparse, json, csv, pathlib
from datetime import datetime, timezone
try:
    import requests
except ImportError:
    requests = None

INDICATORS = ["SP.URB.TOTL", "AG.PRD.FOOD.XD", "SN.ITK.DEFC.ZS"]
BASE = "https://api.worldbank.org/v2/country/NG/indicator/{ind}?format=json&per_page=100&date=2000:2024"

def fetch(ind):
    url = BASE.format(ind=ind)
    r = requests.get(url, timeout=30)
    r.raise_for_status()
    j = r.json()
    # j[1] is list of records
    return j[1] if len(j) > 1 else [], url

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--out", default="data/raw/worldbank_ng.csv")
    args = p.parse_args()
    out = pathlib.Path(args.out); out.parent.mkdir(parents=True, exist_ok=True)
    rows = []
    prov_entries = []
    for ind in INDICATORS:
        recs, url = fetch(ind)
        for rec in recs:
            rows.append({"indicator": rec.get("indicator",{}).get("id", ind),
                         "indicator_value": rec.get("indicator",{}).get("value"),
                         "country": rec.get("country",{}).get("id"),
                         "date": rec.get("date"), "value": rec.get("value"), "obs_status": rec.get("obs_status")})
        prov_entries.append({"indicator": ind, "url": url, "n": len(recs)})
    with open(out, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["indicator","indicator_value","country","date","value","obs_status"])
        w.writeheader(); w.writerows(rows)
    prov = pathlib.Path("data/raw/provenance.json")
    entry = {"source": "World Bank Indicators API", "indicators": INDICATORS, "out": str(out),
             "n_rows": len(rows), "details": prov_entries,
             "timestamp_utc": datetime.now(timezone.utc).isoformat(),
             "license": "CC BY-4.0"}
    if prov.exists():
        try:
            prev = json.loads(prov.read_text(encoding="utf-8"))
            if isinstance(prev, list): prev.append(entry)
            else: prev = [prev, entry]
        except: prev = [entry]
    else: prev = [entry]
    pathlib.Path("data/raw/provenance.json").write_text(json.dumps(prev, indent=2), encoding="utf-8")
    print(f"Wrote {len(rows)} rows to {out}")

if __name__ == "__main__": main()
