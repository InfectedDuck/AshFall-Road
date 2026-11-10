#!/usr/bin/env python3
"""Enemy curve check for GAMEPLAY_REVAMP_PLAN 4.4 and Phase R3.

Runs tools/combat_balance.gd for every adversary against the fighter and
avoider fixtures of the region it appears in, then prints how far each one sits
from its tier target (share of max HP the expected fighter loses reading tells)
and the avoider/fighter loss ratio.

    python tools/enemy_curve.py                  # every adversary, 200 seeds
    python tools/enemy_curve.py --seeds 400 --enemies toll_gang,kilnback
    python tools/enemy_curve.py --check          # exit 1 when a target is missed

Needs the Godot console binary: pass --godot or set GODOT.
"""
import argparse
import json
import os
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

DEFAULT_GODOT = r"C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe"
# Region (1-6) an adversary is tuned in; the Citadel pair is tuned against the
# R6 fixtures. Follows the 4.4 table.
REGION = {
    "shutter_skitters": 1, "feral_dogs": 1, "pox_dogs": 1, "road_bandits": 1, "gate_cutter_crew": 1,
    "mutant_crows": 2, "toll_gang": 2, "gate_toll_captain": 2,
    "marsh_leeches": 3, "reed_widow": 3, "bile_spewer": 3, "bog_raiders": 3, "gate_weir_raiders": 3,
    "vault_scavs": 4, "drone_swarm": 4, "kilnback": 4, "gate_foundry_sentinel": 4,
    "ossuary_hound": 5, "glass_cult": 5, "cinder_mauler": 5, "salt_colossus": 5, "gate_choir_champion": 5,
    "ash_stalkers": 6, "cable_eater": 6, "tunnel_hunters": 6, "reservoir_maw": 6, "gate_pack_leader": 6,
    "citadel_guard": 6, "warden_machine": 6,
}
# Forced fights. 4.1 gives each regional gate its own tier (a MODERATE teaching
# fight in R1 up to APEX in R6; "+" is read as halfway to the next tier) and 4.4
# puts the Citadel pair on the GATE tier. Their numbers are set by the R5 loop
# against the win bands and the cautious gate gradient, so they are shown
# against these targets for information and never fail the check.
GATE_TARGETS = {
    "gate_cutter_crew": ("MODERATE", 0.20), "gate_toll_captain": ("DANGEROUS", 0.28), "gate_weir_raiders": ("DANGER+", 0.32),
    "gate_foundry_sentinel": ("SEVERE", 0.36), "gate_choir_champion": ("SEVERE+", 0.40), "gate_pack_leader": ("APEX", 0.50),
    "citadel_guard": ("GATE", 0.45), "warden_machine": ("GATE", 0.45),
}
TIER_TARGETS = {"LOW": 0.12, "MODERATE": 0.20, "DANGEROUS": 0.28, "SEVERE": 0.36, "GATE": 0.45, "APEX": 0.50}
TOLERANCE = 0.05
RATIO_FROM_REGION = 4
RATIO_MIN = 1.6
TUNE = re.compile(r"TUNE enemy=(\S+) build=(\S+) win=([\d.]+) hp_lost=([\d.]+)% exchanges=([\d.]+)")


def tier_of(adversary):
    if adversary["id"] in GATE_TARGETS:
        return GATE_TARGETS[adversary["id"]][0]
    threat = int(adversary.get("threat", 0))
    return "APEX" if threat >= 18 else "SEVERE" if threat >= 16 else "DANGEROUS" if threat >= 14 else "MODERATE" if threat >= 12 else "LOW"


def run_region(godot, region, enemies, seeds):
    command = [godot, "--headless", "--path", ".", "--script", "res://tools/combat_balance.gd", "--",
               "--seeds", str(seeds), "--enemies", ",".join(enemies), "--builds", f"fighter_r{region},avoider_r{region}",
               "--output", f"res://builds/enemy_curve_r{region}.json"]
    done = subprocess.run(command, capture_output=True, text=True)
    rows = {}
    for match in TUNE.finditer(done.stdout):
        enemy, build, win, lost, exchanges = match.groups()
        rows.setdefault(enemy, {})[build.split("_")[0]] = {"win": float(win), "lost": float(lost) / 100.0, "exchanges": float(exchanges)}
    missing = [e for e in enemies if set(rows.get(e, {})) != {"fighter", "avoider"}]
    if missing:
        sys.stderr.write(done.stdout[-2000:] + done.stderr[-2000:])
        raise SystemExit(f"Region {region}: no result for {', '.join(missing)}")
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--godot", default=os.environ.get("GODOT", DEFAULT_GODOT))
    parser.add_argument("--seeds", type=int, default=200)
    parser.add_argument("--enemies", default="")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    with open("data/adversaries.json", encoding="utf-8") as handle:
        adversaries = {a["id"]: a for a in json.load(handle)["adversaries"]}
    unknown = sorted(set(adversaries) - set(REGION))
    if unknown:
        raise SystemExit(f"No region set in tools/enemy_curve.py for: {', '.join(unknown)}")
    wanted = [e.strip() for e in args.enemies.split(",") if e.strip()] or list(adversaries)
    by_region = {}
    for enemy in wanted:
        if enemy not in adversaries:
            raise SystemExit(f"Unknown adversary '{enemy}'")
        by_region.setdefault(REGION[enemy], []).append(enemy)

    results = {}
    with ThreadPoolExecutor(max_workers=6) as pool:
        for rows in pool.map(lambda item: run_region(args.godot, item[0], item[1], args.seeds), sorted(by_region.items())):
            results.update(rows)

    failures = []
    gates = 0
    print(f"{'enemy':<22} {'R':>1} {'tier':<9} {'HP':>4} {'damage':>7}  {'fighter win':>11} {'lost':>6} {'target':>6} {'exch':>5}  {'avoider win':>11} {'lost':>6} {'ratio':>5}  verdict")
    for region in sorted(by_region):
        for enemy in by_region[region]:
            adversary = adversaries[enemy]
            combat = adversary["combat"]
            tier = tier_of(adversary)
            gate = enemy in GATE_TARGETS
            target = GATE_TARGETS[enemy][1] if gate else TIER_TARGETS[tier]
            fighter, avoider = results[enemy]["fighter"], results[enemy]["avoider"]
            ratio = avoider["lost"] / fighter["lost"] if fighter["lost"] else 0.0
            notes = []
            if abs(fighter["lost"] - target) > TOLERANCE + 1e-9:
                notes.append("fighter loss %+.0f pts" % ((fighter["lost"] - target) * 100))
            if region >= RATIO_FROM_REGION and ratio < RATIO_MIN - 1e-9:
                notes.append(f"ratio under {RATIO_MIN}")
            if gate:
                gates += 1
                notes = ["forced fight, set by the win bands (%+.0f pts)" % ((fighter["lost"] - target) * 100)]
            elif notes:
                failures.append(f"{enemy}: {', '.join(notes)}")
            print(f"{enemy:<22} {region:>1} {tier:<9} {combat['max_health']:>4} {str(combat['damage_min']) + '-' + str(combat['damage_max']):>7}  "
                  f"{fighter['win']:>11.0%} {fighter['lost']:>6.0%} {target:>6.0%} {fighter['exchanges']:>5.1f}  {avoider['win']:>11.0%} {avoider['lost']:>6.0%} {ratio:>5.2f}  {'ok' if not notes else '; '.join(notes)}")
    print(f"\n{len(wanted) - gates - len(failures)} of {len(wanted) - gates} optional adversaries on target (fighter loss within {TOLERANCE:.0%} of tier target; avoider/fighter ratio >= {RATIO_MIN} from R{RATIO_FROM_REGION}). {gates} forced fights shown for information.")
    if args.check and failures:
        sys.exit(1)


if __name__ == "__main__":
    main()
