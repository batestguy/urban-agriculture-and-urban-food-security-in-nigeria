#!/usr/bin/env python
"""
fetch_osm_urban_ag.py — One-time Overpass API harvest for urban agriculture footprints.
Source: OpenStreetMap via Overpass API (attribution: OSM contributors, ODbL).
Frozen to data/raw/osm_<city>.csv + data/raw/provenance.json
Usage:
  conda activate C:\Users\TOSHIBA\ds-general
  python scripts/fetch_osm_urban_ag.py --city Abuja --city Lagos --out data/raw/osm_urban_ag.csv
"""
import argparse, json, csv, time, pathlib, sys
from datetime import datetime, timezone
try:
    import requests
except ImportError:
    requests = None

OVERPASS_URL = "https://overpass-api.de/api/interpreter"
CITIES = {
    "Abuja": (8.90, 7.15, 9.25, 7.65),       # approx bbox: (south, west, north, east)
    "Lagos": (6.35, 2.90, 6.75, 4.10),
    "Kano": (11.85, 8.35, 12.20, 8.70),
    "Port Harcourt": (4.70, 6.90, 4.95, 7.15),
    "Gombe": (10.20, 11.05, 10.40, 11.30),
}

QUERY_TEMPLATE = """
[out:json][timeout:90];
(
  nwr["landuse"="allotments"]({bbox});
  nwr["landuse"="farmland"]({bbox});
  nwr["landuse"="farmyard"]({bbox});
  nwr["leisure"="garden"]({bbox});
);
out center tags;
"""

def fetch_city(city, bbox):
    south, west, north, east = bbox
    bbox_str = f"{south},{west},{north},{east}"
    q = QUERY_TEMPLATE.format(bbox=bbox_str)
    headers = {"Content-Type": "application/x-www-form-urlencoded"}
    data = {"data": q}
    if requests is None:
        raise RuntimeError("requests not installed — conda install requests")
    r = requests.post(OVERPASS_URL, data=data, headers=headers, timeout=120)
    r.raise_for_status()
    j = r.json()
    return j.get("elements", [])

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--city", action="append", dest="cities", default=[], help="City name (repeatable)")
    p.add_argument("--out", default="data/raw/osm_urban_ag.csv")
    args = p.parse_args()
    cities = args.cities or list(CITIES.keys())
    out = pathlib.Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    rows = []
    for city in cities:
        bbox = CITIES.get(city)
        if not bbox:
            print(f"Unknown city {city}, skipping", file=sys.stderr)
            continue
        print(f"Fetching {city} {bbox} ...")
        try:
            els = fetch_city(city, bbox)
        except Exception as e:
            print(f"Failed {city}: {e}", file=sys.stderr)
            els = []
        for e in els:
            lat = e.get("lat") or e.get("center", {}).get("lat")
            lon = e.get("lon") or e.get("center", {}).get("lon")
            rows.append({"city": city, "osm_id": e.get("id"), "type": e.get("type"),
                         "lat": lat, "lon": lon,
                         "landuse": e.get("tags", {}).get("landuse"),
                         "leisure": e.get("tags", {}).get("leisure"),
                         "name": e.get("tags", {}).get("name","")})
        time.sleep(2)
    with open(out, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["city","osm_id","type","lat","lon","landuse","leisure","name"])
        w.writeheader(); w.writerows(rows)
    prov = pathlib.Path("data/raw/provenance.json")
    prov.parent.mkdir(parents=True, exist_ok=True)
    entry = {"source": "OpenStreetMap Overpass API", "url": OVERPASS_URL,
             "cities": cities, "out": str(out), "n_rows": len(rows),
             "timestamp_utc": datetime.now(timezone.utc).isoformat(),
             "license": "ODbL — © OpenStreetMap contributors"}
    if prov.exists():
        try:
            prev = json.loads(prov.read_text(encoding="utf-8"))
            if isinstance(prev, list): prev.append(entry)
            else: prev = [prev, entry]
        except: prev = [entry]
    else: prev = [entry]
    prov.write_text(json.dumps(prev, indent=2), encoding="utf-8")
    print(f"Wrote {len(rows)} rows to {out} and provenance to {prov}")

if __name__ == "__main__": main()
