/* One-time, deterministic prose expansion for the schema-3 content pass. */
const fs = require("fs");
const crypto = require("crypto");

const path = "data/events.json";
const document = JSON.parse(fs.readFileSync(path, "utf8"));
const outcomeKeys = ["success", "failure", "critical_success", "critical_failure", "outcome", "victory", "critical_victory"];
const expectedMechanicsHash = "83a3fee0921870511b706ae07cabf751b7716b95435ed3f8bcbe0449bfda1874";

const regionScenes = {
  outskirts: [
    "You move beneath apartment shells whose empty windows hold the gray morning like blind eyes. Wind pushes grit along the avenue, and somewhere behind the walls loose metal keeps a patient, irregular beat.",
    "The outskirts smell of wet concrete, cold ash, and old electrical fires. Your footsteps travel farther than they should between the abandoned storefronts, making every doorway feel briefly occupied.",
    "Clouds press low over the broken suburbs. Weeds tremble through pavement seams, paper whispers against rusted fences, and the distant city answers the wind with a long metallic groan."
  ],
  flats: [
    "White salt reaches toward a horizon rubbed thin by heat. Each breath dries your tongue, while the wind sketches moving lines across the flats and erases the tracks behind you.",
    "Sunlight lies hard and colorless across the open flats. There is nowhere to hide except among the wrecks, and every dark shape seems to watch from impossible distance.",
    "The flats turn distance into a kind of threat. Heat bends the eastern road, salt rasps beneath your boots, and the sky offers neither shade nor a reliable sense of scale."
  ],
  marsh: [
    "Black water presses close to the raised path, carrying reeds, oily rainbows, and bubbles that break without showing what made them. The air tastes green and faintly chemical.",
    "Mist drifts between drowned roofs and power poles. Insects stitch a high whine through the reeds, then fall silent together whenever your boots disturb the soft ground.",
    "The marsh receives each step with a wet, reluctant sound. Rot and rain hang in the air, and pale ripples cross water too dark to measure."
  ],
  industrial: [
    "Factory stacks divide the sky into narrow strips. Fine soot gathers on your sleeves, machinery ticks as it cools, and old warning lights continue their duties for nobody.",
    "You enter a maze of pipes, loading bays, and corrugated walls. The air carries hot iron and stale lubricant, while unseen structures contract with sudden hammering knocks.",
    "Rust-colored dust hangs inside the industrial quarter. Chains sway without operators, vents breathe at uneven intervals, and every painted safety line leads deeper into neglect."
  ],
  glass: [
    "Fused earth shines beneath the cloud cover like a dark mirror. Every step finds a brittle edge, and the wind makes the shattered plain sing in thin, uneasy notes.",
    "The glass fields return a warped reflection of the sky. Heat lingers under the surface, distant shapes split into doubles, and exposed metal hums against your equipment.",
    "Nothing grows where the ground melted smooth. Light moves strangely over the blackened plain, revealing old shadows burned into walls that no longer stand."
  ],
  rail: [
    "The buried rail line draws you into air that smells of stone, standing water, and old brakes. Your smallest movement returns from the tunnel several seconds later.",
    "Tile fragments crunch beside tracks vanishing east into darkness. Cables sag overhead, stale drafts pass like cautious animals, and somewhere ahead a signal relay clicks.",
    "Underground, distance is measured by failing lamps and the echo of your own breathing. Water shines between the rails, trembling before any sound reaches you."
  ],
  global: [
    "The road has been quiet long enough for that quiet to feel deliberate. Dust settles on your shoulders, the wind changes direction, and a new detail draws your attention ahead.",
    "You leave the last landmark behind and enter another nameless stretch of ruin. The air shifts around something out of place, small enough to miss and important enough to stop you.",
    "For several minutes there is only your breathing and the measured scrape of gear. Then the landscape breaks its pattern, offering a sign that could mean shelter, danger, or both."
  ],
  fallback: [
    "The marked road disappears beneath windblown debris, leaving only the eastern light to guide you. Dust works into every seam of your clothing and softens the world to silhouettes.",
    "Nothing moves across the open ground except pale curtains of grit. The silence gives you room to hear your own fatigue, and enough uncertainty to make each direction look wrong.",
    "A dry wind removes the last clear tracks from the road. You continue by memory and instinct while ruined shapes emerge, fade, and return in unfamiliar positions."
  ],
  final: [
    "The East Citadel rises from the haze with clean lines that seem impossible after the road behind you. Its gates remain closed, and hidden machinery vibrates through the ground beneath your boots.",
    "Cold white lamps burn above the final approach. Cameras follow your movement with insect precision, while layered doors divide the poisoned road from the life you came to find.",
    "You stand within reach of the Citadel, close enough to hear ventilation fans beyond the armored wall. The promise of clean air makes every breath outside taste sharper."
  ]
};

const decisionClosers = [
  "You slow down and read the ground, the exits, and the silences between sounds. Something useful may be here, but the place is arranged to punish haste. You must decide which risk deserves your strength.",
  "You check your gear without taking your eyes from the scene. The obvious path promises speed; the careful one demands time and supplies. Neither feels harmless, and standing still carries its own price.",
  "You listen until separate noises become a pattern. There are signs of danger and hints of something worth carrying east, but no clean answer. The next few moments will belong entirely to your judgment."
];

const outcomeClosers = {
  success: [
    "For a moment, the road loosens its grip. You check your gear, steady your breathing, and move before the surrounding ruins can change their mind.",
    "The choice holds. You gather yourself quickly, listening for pursuit while the place settles back into its uneasy rhythm around you."
  ],
  critical_success: [
    "Everything aligns with rare, startling precision. You seize the advantage completely, leaving almost no trace except the quiet proof carried onward with you.",
    "Instinct, timing, and preparation meet in one clean moment. Even the wasteland seems briefly surprised as you secure the best possible result."
  ],
  failure: [
    "The mistake announces itself in small, merciless details. You force yourself onward while the place closes behind you, carrying a cost you cannot ignore.",
    "The road collects its price without ceremony. You recover what composure you can, mark the lesson, and continue before the setback becomes worse."
  ],
  critical_failure: [
    "The situation turns at exactly the wrong instant. Shock gives way to pain and bitter understanding, but stopping here would let the disaster finish its work.",
    "One bad moment becomes several before you can contain it. You escape the worst of the chaos, shaken and painfully aware of what the error cost."
  ],
  outcome: [
    "There is no dramatic answer, only the consequence taking its place among your supplies and scars. You adjust your pack and continue east.",
    "The decision settles into fact. You take one careful look behind you, then return your attention to the long ground still waiting ahead."
  ],
  victory: [
    "When the struggle ends, the sudden quiet feels larger than the fight. You search quickly, tend what hurts, and prepare to leave before new danger arrives.",
    "The threat finally breaks. You remain standing, breathing hard in the aftermath, and claim only what can help you survive the road beyond."
  ],
  critical_victory: [
    "The final exchange is clean and decisive. You control the aftermath before chance can reverse itself, taking the hard-earned advantage east with you.",
    "Your finishing move leaves no opening for retaliation. In the stunned quiet afterward, you secure the best of what the encounter can yield."
  ]
};

function words(value) {
  return value.trim().split(/\s+/).filter(Boolean).length;
}

function hash(value) {
  let result = 0;
  for (const character of value) result = (result * 31 + character.charCodeAt(0)) >>> 0;
  return result;
}

function regionFor(eventId) {
  const prefix = eventId.split("_")[0];
  return regionScenes[prefix] ? prefix : "global";
}

function sentence(value) {
  const trimmed = value.trim();
  return /[.!?]$/.test(trimmed) ? trimmed : `${trimmed}.`;
}

function rewriteIntroduction(event) {
  if (words(event.body) >= 60) return;
  const scenePool = regionScenes[regionFor(event.id)];
  const scene = scenePool[hash(event.id) % scenePool.length];
  const closer = decisionClosers[hash(`${event.id}:close`) % decisionClosers.length];
  event.body = `${scene} ${sentence(event.body)}\n\n${closer}`;
}

function rewriteOutcome(eventId, key, outcome, index) {
  if (!outcome || typeof outcome.text !== "string" || words(outcome.text) >= 30) return;
  const pool = outcomeClosers[key] || outcomeClosers.outcome;
  let text = `${sentence(outcome.text)} ${pool[hash(`${eventId}:${key}:${index}`) % pool.length]}`;
  if (words(text) < 30) text += " The memory follows you into the next mile.";
  outcome.text = text;
}

for (const event of document.events) {
  rewriteIntroduction(event);
  event.choices.forEach((choice, choiceIndex) => {
    for (const key of outcomeKeys) rewriteOutcome(event.id, key, choice[key], choiceIndex);
  });
}

const errors = [];
for (const event of document.events) {
  const bodyWords = words(event.body);
  if (bodyWords < 60 || bodyWords > 90) errors.push(`${event.id} body: ${bodyWords}`);
  event.choices.forEach((choice, choiceIndex) => {
    for (const key of outcomeKeys) {
      if (!choice[key]) continue;
      const count = words(choice[key].text);
      if (count < 30 || count > 50) errors.push(`${event.id}:${choiceIndex}:${key}: ${count}`);
    }
  });
}

if (errors.length) {
  throw new Error(`Literary rewrite missed word targets:\n${errors.join("\n")}`);
}

function mechanicsOnly(value) {
  if (Array.isArray(value)) return value.map(mechanicsOnly);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(
    Object.keys(value)
      .filter((key) => !["body", "text", "dc", "difficulty"].includes(key))
      .sort()
      .map((key) => [key, mechanicsOnly(value[key])])
  );
}

const mechanicsHash = crypto
  .createHash("sha256")
  .update(JSON.stringify(mechanicsOnly(document)))
  .digest("hex");
if (mechanicsHash !== expectedMechanicsHash) {
  throw new Error(`Mechanical content changed during prose conversion: ${mechanicsHash}`);
}

fs.writeFileSync(path, `${JSON.stringify(document, null, 2)}\n`);
console.log(`Validated ${document.events.length} introductions and mechanics ${mechanicsHash}.`);
