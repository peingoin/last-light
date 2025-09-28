# Interaction Limits & Question Syntax Features

## Interaction Limits System

### Overview
NPCs can now be configured with interaction limits to control how many times a player can talk to them.

### Configuration Properties
- `max_interactions: int = -1` - Maximum number of interactions allowed
  - `-1` = Infinite interactions (default)
  - `0` = No interactions allowed
  - `>0` = Limited number of interactions
- `interaction_limit_message: String` - Message shown when limit is reached

### Usage Examples

```gdscript
# In NPC script or scene properties:
max_interactions = 3  # Can only talk 3 times
interaction_limit_message = "I have nothing more to say."

# Utility methods:
npc.reset_interaction_count()           # Reset to 0
npc.set_interaction_limit(5)           # Change limit
npc.get_remaining_interactions()       # Returns remaining count (-1 = infinite)
```

### Test Cases in Game

1. **TestNPC** - Limited to 4 interactions with advanced features
   - **First interaction**: Introduction with 4 choice options
   - **Interactions 2-4**: Dynamic dialogue based on player choices and remaining interactions
   - **After 4**: "I really must get back to my work now. Perhaps we can chat again later!"
   - **Features demonstrated**:
     - Player name memory system
     - Dynamic greeting based on interaction count
     - Nested dialogue trees (exploration, village info)
     - State tracking between conversations

2. **VillageGuard** - Limited to 3 interactions
   - First 3 interactions: Full dialogue options
   - After 3: "I've told you everything I can. Please move along."

3. **ShopkeeperNPC** - Limited to 5 interactions
   - First 5 interactions: Full shop dialogue
   - After 5: "I'm sorry, but I need to help other customers now. Come back later!"

## Enhanced Question Syntax

### Overview
The dialogue system now properly separates question text from options, allowing for clearer dialogue flow.

### Syntax Format
```
Speaker: Statement or context.

Question text here?
[[OPTIONS]]
[key:id] Option text
[key:id] Option text
[[/OPTIONS]]
```

### Examples

#### Simple Question
```
Guard: Halt! Do you have a pass?
[[OPTIONS]]
[y:yes] Yes, here's my pass.
[n:no] No, I don't have one.
[[/OPTIONS]]
```

#### Complex Question with Context
```
Shopkeeper: Welcome to my humble shop! I have the finest goods in the village.

What brings you to my establishment today?
[[OPTIONS]]
[b:buy] I'd like to buy something.
[s:sell] Do you buy items from travelers?
[i:info] Tell me about this village.
[[/OPTIONS]]
```

#### Multi-line Context
```
Guard: I'm sorry, but you'll need a pass to enter. The village has strict security measures.

How would you like to proceed?
[[OPTIONS]]
[o:ok] Okay, I'll go find a pass.
[p:plead] Please, I really need to get in!
[w:where] Where can I get a pass?
[[/OPTIONS]]
```

#### TestNPC Advanced Example
```
Villager: Oh, hello there! I don't think we've met before. I'm just a simple villager, but I love meeting new people.

What brings you to our little village today?
[[OPTIONS]]
[h:hello] Hello! I'm just passing through.
[e:explore] I'm here to explore and learn about the area.
[t:trade] I'm looking for trade opportunities.
[q:quiet] I prefer to keep to myself.
[[/OPTIONS]]
```

#### Dynamic Follow-up Questions
```
Villager: An explorer! How adventurous! There are many interesting places around here for someone with a curious spirit.

What kind of exploration interests you most?
[[OPTIONS]]
[routes:routes] What are the main travel routes?
[ruins:ruins] Are there any ancient ruins nearby?
[dangers:dangers] What dangers should I watch out for?
[[/OPTIONS]]
```

### Implementation Details

1. **Parser Enhancement**
   - `OptionsParser.parse_options()` now returns `question_text` field
   - Automatically extracts text before `[[OPTIONS]]` block
   - Handles multi-line questions and context

2. **Dialogue System Integration**
   - `show_dialogue_with_options()` uses extracted question text
   - Falls back to full content if no options block found
   - Maintains backward compatibility

### Test NPCs Showcase

1. **TestNPC** - Demonstrates:
   - Interaction limits with dynamic messaging
   - Player name memory and personalization
   - Nested dialogue trees with multiple question levels
   - Clear question syntax with context separation
   - State persistence across conversations

2. **VillageGuard** - Demonstrates:
   - Multi-state dialogue branching
   - Clear question separation
   - Context + question format

3. **ShopkeeperNPC** - Demonstrates:
   - Complex nested questions
   - State tracking between interactions
   - Rich dialogue trees with multiple question levels

## Testing the Features

### Interaction Limits Test
1. **TestNPC Testing**:
   - Talk to TestNPC 4 times - each interaction should be unique
   - First time: Introduction with choice options
   - Times 2-4: Different greetings mentioning remaining interactions
   - After 4 interactions: Limit message appears
   - Further attempts: Should be blocked entirely

### Question Syntax Test
1. **TestNPC**: Notice clear question separation and nested dialogue trees
2. **VillageGuard**: See context + question format with multiple dialogue states
3. **Shopkeeper**: Complex nested question flow with state tracking
4. Verify options appear below question text in UI

### Combined Features Test
1. **Complete TestNPC Flow**: Experience all 4 interactions with different choices
2. **Cross-NPC Testing**: Talk to all NPCs to see different limit configurations
3. **State Persistence**: Verify name memory and choice consequences persist
4. **Limit Behavior**: Test that limits work correctly with complex dialogue trees