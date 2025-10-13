# Last Light (Working Title)

## Overview
**Genre:** Survival Strategy / Roguelike / Resource Management  
**Perspective:** Top-down or Isometric  

**Core Loop:**  
Harvest → Manage → Decide (Move or Stay) → Defend → Sacrifice → Explore → Progress  

**Experience Goal:**  
Survive in a dying world by managing limited life force, scarce resources, and impossible moral choices.

---

## Setting
The world has been swallowed by a poisonous gas that kills any living being that breathes it. Civilization has fallen into ruin — all that remains are scattered remnants, broken machines, and the silence of a dead world.  
You and a small group of survivors travel across this wasteland inside a van equipped with a Life Core, a machine that emits a forcefield to keep the poison out.  
But the Core is powered by Life Force, extracted from living beings. Every mile you travel, every repair you make, every decision you choose — costs life.  
The van is your home, your fortress, and your coffin if the Core ever fails.

---

## The Van (Your Mobile Base)
The van houses the Life Core and acts as your entire world. From the outside, it’s a battered shell — but inside, it’s larger than it seems, fitted with rooms and stations for each survivor:

| Room / Station | Function |
|----------------|---------|
| Life Core Room | Central hub — shows energy levels, map, and move/stay decision. |
| Kitchen | Food management; consume rations daily to sustain health and energy. |
| Blacksmith Station | Crafts and upgrades tools and weapons; unlocks new recipes via blueprints. |
| Weaponsmith Station | Builds and upgrades van defenses; increases durability during attacks. |
| Storage Bay | Stores materials (wood, metal, food, life force). |
| Living Quarters | Shows morale, status, and passive buffs from survivors. |

Each survivor has a specific role and can work in their assigned station during the day phase.

---

## NPC Teammate Roles & Gameplay Mechanics

| Name | Role | Passive Buff / Ability | Sacrifice Impact |
|------|------|---------------------|-----------------|
| Technician | Repairs van and Life Core | Uses 20% less wood, steel, and Life Force when repairing damage from mob attacks | Repairs cost full materials and energy without their bonus |
| Medic | Heals injured NPCs and mitigates starvation | Heals 50% of damage inflicted by mobs on teammates; reduces Life Force loss during starvation by 50% after 2 days without food | Healing and starvation reduction no longer apply |
| Blacksmith | Upgrades tools and weapons | Can upgrade weapons if provided with materials and blueprints (metal, wood) | Weapon upgrades fail or take longer |
| Weaponsmith | Builds/Upgrades van defenses | Can create or upgrade defenses (spikes, turrets, barbed wire, electric fences, rocket launchers, flamethrowers, spike launchers) if given materials and blueprints | Defense upgrades fail or are weaker |
| Scout | Exploration & map guidance | Reveals nearby points of interest (loot, bosses, structures); provides map visibility while alive | You lose map visibility and directional hints |
| Forager | Harvesting & resource gathering | Increases harvesting speed; 30% chance to boost yield by 10% | Harvesting slows and yields decrease |

---

## Van & Life Core Mechanics
- The van protects survivors from poisonous gas but takes damage during night waves of mobs.  
- Life Core damage reduces shield strength; it must be repaired by the Technician.  
- NPCs inside the van take damage when mobs attack. Damage can be partially healed by the Medic.  
- Repairs require wood, steel, and Life Force; efficiency is improved if the Technician is alive.  
- Upgrading weapons and defenses requires resources + blueprints: the Blacksmith handles tools and weapons; the Weaponsmith handles the van’s defensive systems.

---

## Weapons & Tools

### Blacksmith-Crafted Weapons & Tools (Player-Held)
| Item | Type | Function | Upgrade Path / Mechanics |
|------|------|---------|------------------------|
| Survival Axe | Tool / Melee | Harvest wood, fight small mobs | Upgrade increases harvest speed & damage |
| Pistol | Weapon / Ranged | Short-range, fast fire rate | Upgrade increases clip size, accuracy, damage |
| Shotgun | Weapon / Ranged | Close-range, high spread | Upgrade increases range, pellet count, or knockback |
| SMG | Weapon / Ranged | Medium-range, rapid fire | Upgrade increases damage, fire rate, or reload speed |
| LMG | Weapon / Ranged | Long-range suppression | Upgrade increases ammo capacity, damage, or stability |

### Weaponsmith-Crafted Van Defenses
| Item | Type | Function | Upgrade Path / Mechanics |
|------|------|---------|------------------------|
| Spikes | Passive | Damages mobs that touch the van sides | Upgrade increases damage |
| Barbed Wire | Passive | Slows mobs approaching the van | Upgrade increases area coverage & slow effect |
| Electric Fence | Active | Shocks mobs on contact | Upgrade increases damage or adds stun duration |
| Turret (Small Gun) | Active | Shoots mobs automatically | Upgrade increases fire rate, damage, or range |
| Rocket Launcher (Mounted) | Active | High-damage AoE | Upgrade increases blast radius, damage, or reload speed |
| Flamethrower | Active | Short-range area damage | Upgrade increases duration, damage, or range |
| Spike Launcher | Active | Shoots spikes in a line | Upgrade increases projectile speed, damage, or reload speed |

**Mechanics:**  
- All van defenses require metal + wood + blueprints to build or upgrade.  
- All defenses take damage during night attacks and can be repaired.  
- Can be combined strategically to protect the van from mobs.

---

## Daily Cycle
1. **Day Phase – Harvest & Manage**  
   - Harvest food, wood, metal, and blueprints from ruins, structures, and random spawns.  
   - Assign NPCs to foraging, scavenging, exploring, or resting.  
   - Survivors must eat daily; after 2 days without food, Life Force starts to drain.

2. **Management Phase – Upgrades & Crafting**  
   - Blacksmith upgrades weapons/tools.  
   - Weaponsmith upgrades van defenses.  
   - Kitchen cooks food and manages rationing.

3. **Decision Phase – Move or Stay**  
   - Stay: Minimal Life Force used, no attacks.  
   - Move: Extra energy used, shield weakens → night attacks.

4. **Night Phase – Defense**  
   - Mobs attack van and Life Core.  
   - NPCs defend, repair, and heal based on roles.  
   - Life Core and van defenses take damage.

5. **Sacrifice Phase – Desperation**  
   - Sacrifice NPCs to fuel the Life Core.  
   - Permanent removal of buffs and abilities.

---

## Structures & Exploration
**Major Structures**
| Structure | Typical Loot | Notes / Hazards |
|-----------|--------------|----------------|
| Dungeon | Life Force capsules, rare materials, occasionally blueprints | Contains a boss fight; high risk/high reward |
| Gas Station | Scrap metal | Light combat, moderate risk; good for van upgrades |
| Grocery Store | Food, metal | Moderate risk; provides essential rations and some materials |
| Lab | Metal, wood, occasional Life Force capsules | Often guarded by mobs; may contain blueprints for advanced upgrades |
| Industrial Factory | Metal, scrap machinery, occasional blueprints | Dense mobs; high metal yield for van defenses and tools |
| Military Outpost / Bunker | Weapons, ammo, blueprints | Heavy mobs or boss-like enemies; high combat risk, high reward |
| Farm / Barn | Food, wood, rare seeds | Low-to-moderate hazard; good for sustaining the team |
| Airbase | N/A (final goal) | Location of the plane for escaping the planet; heavily defended; endgame objective |

**Random Resource Spawns**
| Spawn Type | Loot | Mechanics |
|------------|------|----------|
| Garbage Bins | Small amounts of metal, wood, or food | Quick rummage; low risk, low reward |
| Scrap Heaps | Steel, wood | Slightly slower; medium reward |
| Trees | Large amounts of wood | Chop with Survival Axe; upgradeable for faster harvesting |
| Fruit Bushes | Food | Chop with Survival Axe; replenishes rations |

**Mystery Box:**  
- Can appear in any nearby structure, but not guaranteed.  
- Maximum one per round.  
- Marked on the Scout’s map with a gold glowing question mark.  
- Rewards include blueprints, Life Force capsules, legendary weapons, metal caches, or large food supplies.  

**Exploration Mechanics:**  
- Scout reveals structures; Mystery Box is visually distinct.  
- Randomized structure placement ensures replayability.  
- Team strategy: NPC roles impact efficiency and safety during exploration (Forager, Scout, Medic).  
- Airbase: Appears late in the map; heavily defended; represents the escape objective.

---

## Objective
- Survive long enough to locate the Airbase and escape via plane.  
- Failing to manage food, energy, or the Core leads to inevitable death.

---

## Resources Overview
| Resource | Source | Use |
|----------|--------|-----|
| Life Force | Enemies, sacrifices, rare caches | Powers the Life Core, repairs |
| Food | Harvesting, ruins, bushes, farms | Prevent starvation & life loss |
| Wood | Harvesting forests, trees, ruins | Tools, upgrades, van repairs |
| Metal / Steel | Ruins, scrap heaps, garbage bins | Tools, upgrades, defenses |
| Blueprints | Rare finds | Unlock advanced upgrades |

---

## Themes & Tone
- **Sacrifice and Survival:** Every choice has a cost.  
- **Hope and Despair:** The Airbase represents salvation; every step is a gamble.  
- **Human Connection:** Decisions impact both gameplay and narrative.

---

## Visual & Audio Style
- **Visuals:** Desaturated palette (grays, browns, glowing blues for Life Force).  
- **Interior:** Warm, functional stations for each NPC.  
- **Sound:** Low ambient drones, heartbeat when energy is low, muffled combat outside.  
- **Music:** Ambient, melancholic; swells during sacrifice, combat, or rare structure exploration.

---

## Endings
- **Escape Ending:** Reach Airbase and survive.  
- **Martyr Ending:** Sacrifice yourself to power the final jump.  
- **Collapse Ending:** Van stops; the last light fades.
