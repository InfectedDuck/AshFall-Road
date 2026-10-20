"""Summarize builds/playthrough/<policy>.json files into a Markdown balance report.

Usage (from the project root):
    python tools/playthrough_report.py [builds/playthrough] [output.md]

Reads every <policy>.json written by tools/playthrough_analytics.gd in the
directory and writes report.md next to them. The numbers are simulated player
models, not human completion or retention estimates.
"""
import glob
import json
import os
import sys
from collections import defaultdict

ORDER = ["random", "novice", "cautious", "informed", "aggressive"]
REGIONS = ["Shattered Outskirts", "Salt Flats", "Drowned Marches", "Hollow Industrial", "Glass Wastes", "The Underrail"]


def load(directory):
    policies = {}
    meta = {}
    for path in glob.glob(os.path.join(directory, "*.json")):
        name = os.path.basename(path)[:-5]
        if name in ("smoke",):
            continue
        with open(path, encoding="utf-8") as handle:
            data = json.load(handle)
        for policy, agg in data.get("policies", {}).items():
            policies[policy] = agg
        meta = {k: v for k, v in data.items() if k != "policies"}
    ordered = {p: policies[p] for p in ORDER if p in policies}
    ordered.update({p: a for p, a in policies.items() if p not in ordered})
    return ordered, meta


def content():
    events, adversaries, items = {}, {}, {}
    for path in glob.glob("data/*.json"):
        with open(path, encoding="utf-8") as handle:
            data = json.load(handle)
        if not isinstance(data, dict):
            continue
        for event in data.get("events", []) if isinstance(data.get("events"), list) else []:
            if isinstance(event, dict) and "id" in event:
                events[event["id"]] = {"title": event.get("title", ""), "file": os.path.basename(path), "choices": event.get("choices", [])}
        if os.path.basename(path) == "adversaries.json":
            for adv in data["adversaries"]:
                adversaries[adv["id"]] = adv
        if os.path.basename(path) == "items.json":
            for item in data["items"]:
                items[item["id"]] = item
    return events, adversaries, items


def pct(n, d):
    return f"{100.0 * n / d:.1f}%" if d else "–"


def mean(n, d, digits=1):
    return f"{n / d:.{digits}f}" if d else "–"


def table(headers, rows):
    out = ["| " + " | ".join(headers) + " |", "|" + "|".join("---" for _ in headers) + "|"]
    for row in rows:
        out.append("| " + " | ".join(str(c) for c in row) + " |")
    return "\n".join(out)


def threat_label(threat):
    if threat >= 18:
        return "APEX"
    if threat >= 16:
        return "SEVERE"
    if threat >= 14:
        return "DANGEROUS"
    if threat >= 12:
        return "MODERATE"
    return "LOW"


def main():
    directory = sys.argv[1] if len(sys.argv) > 1 else "builds/playthrough"
    output = sys.argv[2] if len(sys.argv) > 2 else os.path.join(directory, "report.md")
    policies, meta = load(directory)
    events, adversaries, items = content()
    lines = []
    w = lines.append
    w("# Playthrough analytics report\n")
    w(f"Analytics v{meta.get('analytics_version')} · combat rules v{meta.get('rules_version')} · "
      f"living road {'on' if meta.get('living_road_enabled') else 'off'} · {meta.get('runs_per_policy')} runs per model · seed base {meta.get('seed_base')}.\n")
    w("Simulated player models, not human completion or retention estimates. Every decision is legal and every roll comes from the run's seeded RNG.\n")
    w("- **random**: uniform legal action, no eating/healing between events (old soak baseline)\n"
      "- **novice**: random event choices, eats when starving, heals under 50% HP, mostly attacks\n"
      "- **cautious**: highest success chance, avoids fights, flees when it can\n"
      "- **informed**: expected-value choices from the shown stakes and odds, reads enemy tells, heals/treats/flees at thresholds, builds toward mastery\n"
      "- **aggressive**: takes every fight offered, reads tells, never flees\n")

    # 1. Outcomes
    w("## 1. Outcomes\n")
    rows = []
    for p, a in policies.items():
        r = a["runs"]
        fights = sum(e["fights"] for e in a["enemies"].values())
        rows.append([p, r, pct(a["victories"], r), pct(a["deaths"], r), a["unfinished"], mean(a["regions_sum"], r, 2),
                     mean(a["events_sum"], r), mean(a["level_sum"], r, 2), mean(fights, r, 2),
                     pct(a["runs_with_starvation"], r), a["errors"]])
    w(table(["model", "runs", "victory", "death", "unfinished", "mean regions", "mean events", "mean level", "fights/run", "runs that starved", "engine errors"], rows))
    w("")

    # 2. Funnel
    w("## 2. Region funnel (share of runs that reached each region)\n")
    rows = []
    for p, a in policies.items():
        r = a["runs"]
        reached = [a["arrivals"].get(str(i), {}).get("count", 0) for i in range(6)]
        rows.append([p] + [pct(x, r) for x in reached] + [pct(a["victories"], r)])
    w(table(["model"] + [f"R{i+1} {REGIONS[i]}" for i in range(6)] + ["won"], rows))
    w("\nDeaths by region (share of that model's deaths):\n")
    rows = []
    for p, a in policies.items():
        per = defaultdict(float)
        for key, n in a["cause_by_region"].items():
            per[int(key.split("|")[0])] += n
        d = max(1, a["deaths"])
        rows.append([p] + [pct(per[i], d) for i in range(6)])
    w(table(["model"] + [f"R{i+1}" for i in range(6)], rows))
    w("")

    # 3. Arrival vitals
    w("## 3. Condition on arrival at each region (means)\n")
    for p in [x for x in ("novice", "informed", "cautious") if x in policies]:
        a = policies[p]
        w(f"**{p}**\n")
        rows = []
        for i in range(6):
            b = a["arrivals"].get(str(i))
            if not b:
                continue
            c = b["count"]
            rows.append([f"R{i+1}", int(c), pct(b["hp_pct"], c), mean(b["hp"], c, 0), mean(b["hp_max"], c, 0), mean(b["satiety"], c), mean(b["fatigue"], c, 0),
                         mean(b["radiation"], c, 0), mean(b["level"], c), mean(b["food"], c), mean(b["healing"], c), mean(b["ammo"], c), mean(b["scrap"], c), pct(b["unarmed"], c), mean(b["conditions"], c, 2)])
        w(table(["region", "arrivals", "HP %", "HP", "max HP", "satiety", "fatigue", "radiation", "level", "food items", "healing items", "ammo", "scrap", "unarmed", "conditions"], rows))
        w("")

    # 4. Death causes
    w("## 4. Causes of death\n")
    rows = []
    for p, a in policies.items():
        kinds = defaultdict(float)
        for key, n in a["causes"].items():
            kinds[key.split(":")[0]] += n
        d = max(1, a["deaths"])
        rows.append([p, a["deaths"]] + [pct(kinds[k], d) for k in ("combat", "event", "starvation", "travel", "item_use")])
    w(table(["model", "deaths", "combat", "event choice", "starvation", "travel", "item use"], rows))
    w("\nTop specific causes (informed / novice / aggressive):\n")
    for p in [x for x in ("informed", "novice", "aggressive") if x in policies]:
        a = policies[p]
        top = sorted(a["causes"].items(), key=lambda kv: -kv[1])[:12]
        w(f"**{p}**: " + ", ".join(f"{k} ({int(v)})" for k, v in top))
        w("")
    w("")

    # 5. Enemies
    w("## 5. Enemies in real runs\n")
    w("HP lost includes fights that ended in death. 'XP/100 HP' is XP reward per 100 HP actually lost in wins and losses alike.\n")
    for p in [x for x in ("informed", "aggressive", "novice") if x in policies]:
        a = policies[p]
        w(f"**{p}**\n")
        rows = []
        for enemy, b in sorted(a["enemies"].items(), key=lambda kv: -kv[1]["died"] / max(1, kv[1]["fights"])):
            f = b["fights"]
            adv = adversaries.get(enemy, {})
            threat = adv.get("threat", 0)
            xp = adv.get("xp_reward", 0)
            regions = ",".join(f"R{int(k)+1}" for k, _ in sorted(b["regions"].items(), key=lambda kv: -kv[1])[:3])
            hp_lost = b["hp_lost"] / f if f else 0
            rows.append([enemy, f"{threat} {threat_label(threat)}", xp, f, pct(b["won"], f), pct(b["fled"], f), pct(b["died"], f), f"{hp_lost:.0f}",
                         mean(b["rounds"], f), pct(b["hp_start_pct"], f), mean(b["level"], f), f"{100 * xp / hp_lost:.0f}" if hp_lost > 0 else "–", regions])
        w(table(["enemy", "threat", "XP", "fights", "won", "fled", "died", "HP lost", "rounds", "start HP %", "level", "XP/100 HP", "regions"], rows))
        w("")

    # 6. Lethal choices
    w("## 6. Event choices that kill on the spot\n")
    w("Non-combat choices whose outcome alone killed the survivor (all models pooled).\n")
    pooled = defaultdict(lambda: {"picked": 0, "died": 0, "label": "", "kind": ""})
    for p, a in policies.items():
        for ev, e in a["events"].items():
            for idx, c in e["choices"].items():
                if c["kind"] == "combat":
                    continue
                k = (ev, idx)
                pooled[k]["picked"] += c["picked"]
                pooled[k]["died"] += c["died_here"]
                pooled[k]["label"] = c["label"]
                pooled[k]["kind"] = c["kind"]
    rows = []
    for (ev, idx), c in sorted(pooled.items(), key=lambda kv: -kv[1]["died"]):
        if c["died"] == 0:
            continue
        rows.append([ev, idx, c["label"], c["kind"], c["picked"], c["died"], pct(c["died"], c["picked"])])
    w(table(["event", "#", "choice", "kind", "picked", "deaths", "death rate"], rows[:25]))
    w("")

    # 7. Choice comparison under random
    if "random" in policies or "novice" in policies:
        src = "novice" if "novice" in policies else "random"
        a = policies[src]
        w(f"## 7. Choices compared (from **{src}**, which picks event choices at random)\n")
        w("Because the choice is random, 'reached next region' differences between choices of the same event are close to a controlled comparison. Listed: events where the best and worst choice differ by ≥15 points, with ≥40 picks each.\n")
        rows = []
        for ev, e in a["events"].items():
            stats = []
            for idx, c in e["choices"].items():
                if c["picked"] >= 40:
                    stats.append((c["next_region"] / c["picked"], idx, c))
            if len(stats) < 2:
                continue
            stats.sort(key=lambda x: -x[0])
            spread = stats[0][0] - stats[-1][0]
            if spread >= 0.15:
                best, worst = stats[0], stats[-1]
                rows.append((spread, [ev, f"#{best[1]} {best[2]['label']} ({best[0]*100:.0f}%)", f"#{worst[1]} {worst[2]['label']} ({worst[0]*100:.0f}%)",
                                      f"{spread*100:.0f} pts", f"{best[2]['hp_delta']/max(1,best[2]['hp_samples']):.0f} / {worst[2]['hp_delta']/max(1,worst[2]['hp_samples']):.0f}"]))
        rows.sort(key=lambda r: -r[0])
        w(table(["event", "best choice (reached next region)", "worst choice", "gap", "mean HP Δ best / worst"], [r[1] for r in rows[:30]]))
        w("")

    # 8. Dominant choices for the informed player
    if "informed" in policies:
        a = policies["informed"]
        w("## 8. Choices an informed player almost always takes\n")
        w("Events seen ≥50 times where one choice took ≥90% of picks. Either that choice is the clear best (other options may be traps or filler), or the stakes text makes it look best.\n")
        rows = []
        for ev, e in sorted(a["events"].items(), key=lambda kv: -kv[1]["seen"]):
            if e["seen"] < 50:
                continue
            top = max(e["choices"].items(), key=lambda kv: kv[1]["picked"])
            share = top[1]["picked"] / e["seen"]
            if share >= 0.9 and len(events.get(ev, {}).get("choices", [])) > 1:
                rows.append([ev, events.get(ev, {}).get("title", ""), e["seen"], f"#{top[0]} {top[1]['label']}", pct(top[1]["picked"], e["seen"]), top[1]["kind"]])
        w(table(["event", "title", "seen", "dominant choice", "share", "kind"], rows[:40]))
        w(f"\n{len(rows)} events have a ≥90% dominant choice for the informed model.\n")

    # 9. Locked choices
    w("## 9. Choices that are almost never available\n")
    w("Shown ≥50 times (all models pooled) but available <10% of the time.\n")
    pooled_offer = defaultdict(lambda: [0, 0])
    for p, a in policies.items():
        for ev, e in a["events"].items():
            for idx, o in e["offered"].items():
                pooled_offer[(ev, idx)][0] += o["shown"]
                pooled_offer[(ev, idx)][1] += o["available"]
    rows = []
    for (ev, idx), (shown, avail) in sorted(pooled_offer.items(), key=lambda kv: kv[1][1] / max(1, kv[1][0])):
        if shown >= 50 and avail / shown < 0.10:
            choices = events.get(ev, {}).get("choices", [])
            label = choices[int(idx)].get("label", "") if int(idx) < len(choices) else ""
            req = (choices[int(idx)].get("requires") or {"costs": choices[int(idx)].get("costs", {})}) if int(idx) < len(choices) else ""
            rows.append([ev, idx, label, shown, pct(avail, shown), json.dumps(req)[:70]])
    w(table(["event", "#", "choice", "shown", "available", "requirement"], rows[:30]))
    w("")

    # 10. Coverage
    w("## 10. Content coverage\n")
    seen = defaultdict(int)
    for a in policies.values():
        for ev, e in a["events"].items():
            seen[ev] += e["seen"]
    never = sorted(ev for ev in events if seen.get(ev, 0) == 0)
    total_runs = sum(a["runs"] for a in policies.values())
    rare = sorted(((seen[ev], ev) for ev in events if 0 < seen.get(ev, 0) < total_runs * 0.01))
    w(f"{len(events)} events in data, {len(events) - len(never)} seen at least once across {total_runs} runs, {len(never)} never seen.\n")
    by_file = defaultdict(list)
    for ev in never:
        by_file[events[ev]["file"]].append(ev)
    for f, evs in sorted(by_file.items()):
        w(f"- **{f}** ({len(evs)}): " + ", ".join(evs))
    w(f"\nSeen in fewer than 1% of runs ({len(rare)}): " + ", ".join(f"{ev} ({n})" for n, ev in rare[:60]))
    w("")
    unused_enemies = [a for a in adversaries if all(a not in p["enemies"] for p in policies.values())]
    w(f"\nEnemies never fought by any model: {', '.join(unused_enemies) or 'none'}.\n")

    # 11. Items
    w("## 11. Items\n")
    for p in [x for x in ("informed", "novice") if x in policies]:
        a = policies[p]
        r = a["runs"]
        gained = defaultdict(float)
        sources = defaultdict(lambda: defaultdict(float))
        for key, n in a["items_gained"].items():
            item, source = key.split("|")
            gained[item] += n
            sources[item][source] += n
        used = a["items_used"]
        held = a["held_at_end"]
        rows = []
        for item, n in sorted(gained.items(), key=lambda kv: -kv[1])[:30]:
            src = ", ".join(f"{s or 'start'} {v/n*100:.0f}%" for s, v in sorted(sources[item].items(), key=lambda kv: -kv[1]))
            rows.append([item, f"{n/r:.2f}", f"{used.get(item, 0)/r:.2f}", f"{held.get(item, 0)/r:.2f}", src])
        w(f"**{p}** (per run)\n")
        w(table(["item", "gained", "used", "held at end", "gained from"], rows))
        never_items = sorted(i for i in items if gained.get(i, 0) == 0 and held.get(i, 0) == 0)
        w(f"\nNever obtained by {p}: {', '.join(never_items)}\n")
        dw = a["died_with"]
        d = max(1, dw["deaths_counted"])
        w(f"{p} deaths with healing still in the pack: {pct(dw['healing'], d)}; with food: {pct(dw['food'], d)}.\n")

    # 12. Checkpoints
    w("## 12. Checkpoints\n")
    rows = []
    for p, a in policies.items():
        acts = defaultdict(float)
        trades = defaultdict(float)
        for key, n in a["checkpoints"].items():
            parts = key.split("|")
            if parts[0] == "trade":
                trades[parts[1].split(":")[0]] += n
            else:
                acts[parts[1]] += n
        t = max(1, sum(acts.values()))
        rows.append([p, int(t), pct(acts["rest"], t), pct(acts["trade"], t), pct(acts["press_on"], t),
                     ", ".join(f"{k} {int(v)}" for k, v in sorted(trades.items(), key=lambda kv: -kv[1]))])
    w(table(["model", "checkpoints", "rest", "trade", "press on", "trades by kind"], rows))
    w("")

    # 13. Talents
    w("## 13. Talents (outcome of runs that took each talent)\n")
    for p in [x for x in ("informed", "aggressive") if x in policies]:
        a = policies[p]
        rows = []
        for t, b in sorted(a["talent_outcomes"].items(), key=lambda kv: -kv[1]["runs"]):
            rows.append([t, b["runs"], mean(b["regions"], b["runs"], 2), pct(b["victories"], b["runs"])])
        w(f"**{p}**\n")
        w(table(["talent", "runs", "mean regions", "victory"], rows))
        w("")

    # 14. Archetypes
    w("## 14. Starting archetype (highest starting stat → starting kit)\n")
    rows = []
    for arch in ["strength", "agility", "wits", "grit", "presence"]:
        row = [arch]
        for p in policies:
            b = policies[p]["archetypes"].get(arch)
            row.append(f"{pct(b['victories'], b['runs'])} / {mean(b['regions'], b['runs'], 2)}" if b else "–")
        rows.append(row)
    w(table(["archetype"] + [f"{p} (win / regions)" for p in policies], rows))
    w("")
    for p in [x for x in ("informed",) if x in policies]:
        a = policies[p]
        rows = []
        for wpn, b in sorted(a["final_weapons"].items(), key=lambda kv: -kv[1]["runs"]):
            rows.append([wpn or "(unarmed)", b["runs"], mean(b["regions"], b["runs"], 2), pct(b["victories"], b["runs"])])
        w(f"Weapon held at the end of the run (**{p}**):\n")
        w(table(["weapon", "runs", "mean regions", "victory"], rows))
        w("")

    # 15. Combat actions & conditions
    w("## 15. Combat actions (roll met the needed number)\n")
    rows = []
    for p, a in policies.items():
        ca = a["combat_actions"]
        rows.append([p] + [f"{pct(ca[k]['success'], ca[k]['used'])} of {int(ca[k]['used'])}" if k in ca else "–" for k in ("attack", "block", "dodge", "opportunity", "flee")] + [int(ca.get("use_item", {}).get("used", 0))])
    w(table(["model", "attack", "block", "dodge", "opportunity", "flee", "items used"], rows))
    w("\n## 16. Conditions applied (per run)\n")
    rows = []
    allc = defaultdict(lambda: defaultdict(float))
    for p, a in policies.items():
        for key, n in a["conditions_applied"].items():
            allc[key.split("|")[0]][p] += n / a["runs"]
    for cond, per in sorted(allc.items(), key=lambda kv: -sum(kv[1].values())):
        rows.append([cond] + [f"{per.get(p, 0):.2f}" for p in policies])
    w(table(["condition"] + list(policies), rows))
    w("")

    with open(output, "w", encoding="utf-8") as handle:
        handle.write("\n".join(lines))
    print(f"Wrote {output}")


if __name__ == "__main__":
    main()
