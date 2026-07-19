# Ember Keeper


## Setting 
You're the lone keeper of a remote signal/warming station — think a lighthouse keeper's hut, but for a beacon fire instead of a light. It's the dead of winter, one long night, and your job is to keep the fire alive until dawn so travelers/ships/whatever your fiction is can navigate by it. Isolated, quiet, a little eerie. No dialogue needed — it's mood-driven, which suits solo dev + free asset packs well (moody pixel art, ambient winter SFX, one looping score).
How the chair fits (mechanically, not just set-dressing):
The chair is your second interaction mode, not just furniture. You alternate between two states:

At the fire (standing): you can see clearly — manage the flame, sort fuel, patch drafts — but you're deaf to the outside world. Visual gameplay.
In the chair: you sit back from the fire, eyes closed or half-lit, and this is when you listen. Audio cues tell you what's approaching outside (wind shifting, footsteps, ice cracking, something worse). You can't see anything or act on the fire while seated — but sitting is also how you rest, which slowly restores a stamina/focus resource you need to keep functioning.

So the chair is the "slow burn" tension engine: every time you sit down, you're trading vision for information and rest — and you don't know if you're sitting through a quiet moment or missing a critical window to act at the fire. That single toggle (fire vs. chair) is your unique mechanic, and it's simple enough to build solo in 5 days.

## Resources

- Fuel — finite stock, split into types (green wood burns long/dim, dry kindling burns bright/short). Choosing what to feed the fire is a small tactical layer.
- Flame level — cycles between dim and bright on a slow, semi-irregular timer. Bright = short window where you can see the room and act freely. Dim = you're mostly blind, best used as your cue to go sit.
- Focus/stamina — depletes while active at the fire, only regenerates while seated. Too low and your actions get sloppy (fumbled fuel, missed prompts).
- Threat/dread meter — rises based on what you hear while seated and how you respond (or fail to respond). Doesn't reset; it's the run's rising tension.

## Player actions

- Feed the fire (choose fuel type)
- Patch a draft / shutter a window (small maintenance tasks that appear over time)
- Sit in the chair (start listening phase)
- Get up (end listening phase, return to fire)
- React to what you heard — a prompt appears after sitting, asking you to make a call (bar the door, ignore it, call out) based on ambiguous audio cues

## Core game loop

- Manage the fire while it's active (feed it, do upkeep tasks) — costs focus
- Flame dims → decide to sit or push through
- If seated: listen to escalating ambient/directional audio cues, then respond to a prompt
- Consequences ripple: dread rises or falls, focus regenerates, maybe a new task appears at the fire
- Repeat, with fuel scarcity and dread both climbing, until fire dies, dawn breaks, or dread maxes out (bad ending)
