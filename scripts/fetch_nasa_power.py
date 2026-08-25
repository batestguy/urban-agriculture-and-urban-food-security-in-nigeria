#!/usr/bin/env python
"""
fetch_nasa_power.py — NASA POWER daily point API for growing-season climate.
Frozen to data/raw/nasa_power_<city>.csv
Usage:
  python scripts/fetch_nasa_power.py --city Abuja --start 20230101 --end 20231231
Coords: Abuja 9.0765,7.3986; Lagos 6.5244,3.3792; Kano 12.0022,8.5920; PH 4.8156,7.0498; Gombe 10.2896,11.1677
API: https://power.larc.nasa.gov/api/temporal/daily/point?parameters=T2M,PRECTOTCORR,RH2M&community=AG&longitude={lon}&latitude={lat}&start={start}&end={end}&format=JSON
"""
import argparse, json, csv, pathlib, sys
from datetime import datetime, timezone
try:
    import requests
except ImportError:
    requests = None

CITY_COORDS = {"Abuja": (9.0765,7.3986), "Lagos": (6.5244,3.3792), "Kano": (12.0022,8.5920), "Port Harcourt": (4.8156,7.0498), "Gombe": (10.2896,11.1677)}

def fetch(lat, lon, start, end):
    url = f"https://power.larc.nasa.gov/api/temporal/daily/point?parameters=T2M,PRECTOTCORR,RH2M&community=AG&longitude={lon}&latitude={lat}&start={start}&end={end}&format=JSON"
    r = requests.get(url, timeout=60)
    r.raise_for_status()
    return r.json(), url

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--city", default="Abuja")
    p.add_argument("--start", default="20230101")
    p.add_argument("--end", default="20231231")
    p.add_argument("--out", default=None)
    args = p.parse_args()
    lat, lon = CITY_COORDS.get(args.city, CITY_COORDS["Abuja"])
    j, url = fetch(lat, lon, args.start, args.end)
    params = j.get("properties",{}).get("parameter",{})
    dates = sorted(next(iter(params.values())).keys()) if params else []
    out = pathlib.Path(args.out) if args.out else pathlib.Path(f"data/raw/nasa_power_{args.city.lower().replace(' ','_')}.csv")
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["date","T2M","PRECTOTCORR","RH2M"])
        w.writeheader()
        for d in dates:
            w.writerow({"date": d, "T2M": params.get("T2M",{}).get(d), "PRECTOTCORR": params.get("PRECTOTCORR",{}).get(d), "RH2M": params.get("RH2M",{}).get(d)})
    prov = pathlib.Path("data/raw/provenance.json")
    entry = {"source": "NASA POWER API", "url": url, "city": args.city, "lat": lat, "lon": lon, "start": args.start, "end": args.end, "out": str(out), "timestamp_utc": datetime.now(timezone.utc).isoformat()}
    if prov.exists():
        try:
            prev = json.loads(prov.read_text(encoding="utf-8"))
            prev = prev + [entry] if isinstance(prev, list) else [prev, entry]
        except: prev = [entry]
    else: prev = [entry]
    prov.write_text(json.dumps(prev, indent=2), encoding="utf-8")
    print(f"Wrote {out}")

if __name__ == "__main__": main()
