# WORLD OF AZATHOTH — GAME DESIGN DOCUMENT (GDD)

> *"If someone is happy inside a dream, is waking them up really saving them?"*

---

## 1. EXECUTIVE SUMMARY & CORE CONCEPT

**Title:** World of Azathoth  
**Genre:** Dark Surreal Metroidvania / Cosmic Horror Action-Adventure  
**Engine:** Godot 4.4  
**Target Platforms:** Windows, Linux, macOS, Steam  
**Visual Style:** High-detail 2D Pixel Art Characters + Hand-Painted Expressionist/Surreal Backgrounds (inspired by Vincent van Gogh's *Starry Night* and Zdzisław Beksiński)  
**Music & Sound:** Melancholic Piano, Music Box Lullabies, Dark Orchestral Swells, Distorted Ambient Drones, Distorted Silence  

---

## 2. NARRATIVE & STORYLINE

### The Premise: Eternal Sleep
The protagonist is an elite mercenary. Below the hardened exterior lies a desperate parent: their young daughter, **Maria**, has fallen victim to a mysterious affliction known as **Eternal Sleep**. Her body rests peacefully in the real world, but her soul and consciousness have drifted into **Azathoth Land — The Cradle of Dreams**.

Medical science fails. Spells fail. In desperation, the protagonist performs the **Ritual of the Threshold**, placing their soul in the gray state between **Life and Death** to physically cross into the Cradle of Dreams.

### The Price of Dreams
Every death inside Azathoth Land severs another tether to reality. The protagonist's physical memory fades. Should all tethers snap, they will cease to be human and dissolve into another nameless nightmare of the realm.

### The Witch's Revelation
Upon arrival in an impossible forest, the protagonist encounters **The Witch of the Crooked House**. She speaks the unsettling truth:
> *"Your daughter is not sleeping. She is dreaming. But her dream has anchored to Azathoth — the primordial mind that dreamt existence into being before time had a name. Seven Dream Lords seal the path to her core."*

### The Dark Twist: The Seven Dream Lords
The protagonist embarks on a crusade to slay the Seven Dream Lords (Pride, Greed, Lust, Envy, Gluttony, Wrath, Sloth). Only near the end does the horrific truth dawn:
**The Seven Dream Lords are not monsters holding Maria captive — they are fractured pieces of Maria's own broken psyche.**
- **Pride:** Her overwhelming ego shielding her fragile self.
- **Greed:** Her desperate desire to keep her father forever.
- **Lust:** Her idealization of loved ones corrupted into grotesque figures.
- **Envy:** Her jealousy of healthy children in the waking world.
- **Gluttony:** Her inner abyss that consumes everything around her.
- **Wrath:** Her rage at a world that forced her into sickness.
- **Sloth:** Her wish to stop time and never face reality.

By slaying each Dream Lord, the father is literally destroying parts of his daughter's soul to reach her.

---

## 3. THE SEVEN DREAM LORDS & BIOMES

| Dream Lord | Biome | Gameplay Mechanic | Boss Concept |
| :--- | :--- | :--- | :--- |
| **I. Pride** | *The Golden Palace* (Floating cloud citadel) | **Adaptive Mirroring:** Copies player combos & abilities. Gets stronger as player performs better. | Gigantic symmetrical king whose statues shift from the player into Maria. |
| **II. Greed** | *The Endless Vault* (City buried in gold) | **Weight of Riches:** Gold drops buff stats temporarily but increase weight, slow speed, and alter platform layout. | Colossus encased in molten gold; player trades mobility for temporary raw power. |
| **III. Lust** | *The Crimson Garden* (Surreal blooming nightmare) | **Deceptive Reality:** Friendly illusions mask environmental hazards & traps. | Floral abomination using nostalgic illusions of the protagonist's past. |
| **IV. Envy** | *The Mirror City* (Infinite reflections) | **Ability Theft:** Temporarily steals player unlocked skills and distributes them to minions. | Shapeshifting clone array constantly swapping forms and stealing dash/double-jump. |
| **V. Gluttony** | *The Living Abyss* (Organic consuming world) | **Perishing Realm:** Floor and platforms dissolve continuously; requires relentless upward momentum. | Living bio-mechanical mouth engulfing the arena segment by segment. |
| **VI. Wrath** | *The Burning Battlefield* (Endless red-sky warzone) | **Rage Counter:** Reckless aggressive play fills boss's rage meter, boosting attack speed & AoE. | Armored warlord made of ghost weaponry that punishes button-mashing. |
| **VII. Sloth** | *The Frozen Dream* (Time-stalled tundra) | **Time Fracture:** Inputs trigger delayed execution; player can freeze/rewind specific elements. | Ice titan operating in delayed time bursts; bullet-hell in frozen motion. |

---

## 4. FINAL BOSS & ENDINGS

### Final Area: The Heart of Dreams
A surreal walk through floating fragments of memory: Maria's childhood, the family dinner table, the first night of the fever, and impossible false memories.

### Final Boss: Maria — Vessel of Azathoth
- **Phase 1 (The Vessel):** Cosmic nightmare entity — stars, eyes, shifting gravity, swirling Van Gogh night skies.
- **Phase 2 (The Daughter):** Humanoid child sitting in a void. She begs her father to let her stay in the dream, terrified of waking back into pain.

### The Three Endings
1. **True Ending (Sacrifice of Memory):** The father refuses to kill Maria's final human core. He takes Azathoth's curse upon himself, remaining in the dream forever as the new Cradle while sending Maria back to the waking world.
2. **Bad Ending (Desecration):** The father slays Maria to "save" her. Azathoth consumes the father. He awakens as the next Dream Lord, restarting the cycle.
3. **Secret Ending (The Awakening Choice):** Requires collecting all 14 Memory Fragment items without killing innocent Dreamlings. The father realizes Maria chose to dream. He leaves the choice to her — she steps out of the dream voluntarily.

---

## 5. TECHNICAL SPECIFICATIONS

- **Engine:** Godot 4.4 (GDScript + C# options)
- **Resolution:** Base viewport 1920x1080 (Integer scaling supported)
- **Physics Layering:**
  - Layer 1: Player
  - Layer 2: Enemy
  - Layer 3: Environment / Soli
  - Layer 4: Projectile
  - Layer 5: Interactable / Triggers
