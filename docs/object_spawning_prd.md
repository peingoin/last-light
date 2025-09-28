# **Procedural Object Spawning PRD**

## **Overview**
We want to enrich the Perlin-noise–based procedural world with interactive objects, destructible props, pickups, and rare buildings. All spawning must be **driven by the Perlin noise map** to ensure consistent, organic placement across the world. Spawning logic should support both **environmental storytelling** (garbage, bins, benches, etc.) and **player progression** (loot, crafting materials, survival supplies).

---

# **Section 1 – Spawning (Perlin Noise–Driven)**

### **Spawning System**
- The **object_noise Perlin field** is the sole driver of spawn distribution.
- Sampling the noise map at grid intervals (e.g. every 2–4 tiles) determines:
  - Whether a building, prop, or pickup is eligible to spawn.
  - Spawn **density** (values close to 1 = more objects, close to -1 = sparse).
- Additional rules layered on top of the noise field:
  - **Buildings** spawn rarely (low threshold), but act as attractors: many props spawn near them.
  - **Garbage piles** use a special tileset (small clusters), seeded via noise thresholds.
  - **Pickups** and **props** spawn based on noise values and biome context.
  - **Trees** spawn frequently, with biome-based color variations tied to noise regions.
- **Implementation**
  - Normalize Perlin noise values to [0,1].
  - Apply category thresholds:
    - Buildings: 0.95+
    - Garbage piles: 0.6+
    - Trees: 0.4+
    - Props & pickups: 0.5+ with contextual rules
  - Use an **occupancy grid** to prevent overlap and enforce spacing.

---

### **Spawnable Categories**

#### 1. **Buildings**
- **Frequency**: Very rare (< 5% of candidate positions).
- **Placement**: Spawned only if object_noise exceeds the rare threshold.
- **Representation**: TileMap-based structure.
- **Rule**: Surrounding noise area is boosted for prop density.

#### 2. **Garbage piles (from Garbage Tileset)**
- **Visuals**: Small pile variations.
- **Placement**: Spawn when noise exceeds medium threshold.
- **Rule**: Higher chance near buildings (noise + proximity weighting).

#### 3. **Pickup Items (as spawned objects)**
- **Items**: Ammo crates, metal plates, bandages, bullet boxes, canned food.
- **Spawn**: Triggered by object_noise, either standalone or embedded in garbage piles/bins/barrels.

#### 4. **Destructible Props (as static world objects)**
- **Props**: Barrels (rusty/clean), wooden pallets, garbage bins, benches.
- **Trees**:
  - Multiple visual types (spruce, pine, birch, oak, trunk, etc.).
  - Color variants: Green, Yellow, Orange, Red, Dark-Green, Bleak-Yellow.
  - **Spawn rule**: Noise threshold for natural clusters (trees fill high-density noise regions).

---

### **Visual Layering**
- Terrain = base TileMap
- Buildings = separate TileMapLayer
- Props = Node2D container (`YSort` enabled)
- Pickups = children under object container

---

# **Section 2 – Interactivity**

### **Interaction Types**
- **Pickup**: Collect item directly (ammo, bandage).
- **Rummage**: Search prop (garbage pile, bin) → randomized loot.
- **Destructible**: Break prop (barrel, pallet, bench, tree) → drops resources.

---

### **Object Behaviors**

#### **Buildings**
- Static decoration.
- Spawned via noise thresholds (rare).
- Future: possible interiors, quest anchors.

#### **Garbage Piles**
- Spawned by noise thresholds in cluttered regions.
- Rummage → random loot from pickup pool.

#### **Pickup Items**
- Spawned by noise thresholds directly or inside props.
- Collectible via Area2D trigger.

#### **Destructible Props**
- **Barrels** → Drop metal + chance of pickups.
- **Wooden pallets** → Drop wood.
- **Garbage bins** → Rummage for parts + pickups.
- **Benches** → Drop metal + wood.
- **Trees** → Drop wood (different yields depending on type).

---

### **Resource Drops**
- Metal, wood, consumables → used in crafting and survival progression.

---

# **Next Steps**

### For Spawning
1. Define Tileset patterns for garbage piles and building footprints.  
2. Implement spawn manager that:
   - Samples the **Perlin noise map** at intervals.
   - Places buildings sparsely (rare thresholds).
   - Populates props in noise hotspots and around buildings.
   - Inserts pickups in garbage piles, bins, and barrels.  
3. Balance **noise thresholds** for density.

### For Interactivity
1. Add interaction scripts:
   - Pickup collection (Area2D).
   - Rummage containers with loot tables.
   - Destructible props with resource drops.
2. Debug/test collisions and interaction ranges.
3. Balance drop rates for survival gameplay.

---

✅ **Summary:**  
- **Section 1 (Spawning):** Everything must spawn **via the Perlin noise map**, using thresholds and rules per object type.  
- **Section 2 (Interaction):** Each category has defined interactions (collectible, rummage, destructible).  
