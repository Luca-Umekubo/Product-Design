# Technical Specification: Sound Design for Chaos DodgeBall

## 1. Overview

This document outlines the technical specifications for the sound design of *Chaos DodgeBall*, a fast-paced, first-person multiplayer dodgeball game developed in Godot 4. The goal is to create an immersive, futuristic, and action-filled audio experience that provides clear and impactful feedback for gameplay events, enhancing player engagement and situational awareness.

## 2. Scope

The sound design encompasses:
- User Interface (UI) sound effects.
- Player action sound effects (movement, abilities, interactions).
- Dodgeball sound effects (throws, impacts, catches, etc.).
- Character ability sound effects.
- Powerup activation and effect sounds.
- Environmental and ambient sounds.
- Background music (BGM) for menus and gameplay.
- Technical implementation details using Godot Engine 4.x audio features.

## 3. Sound Style & Mood

- **Futuristic:** The core style will be futuristic, incorporating electronic and synthesized sounds. Elements of neon/cyberpunk aesthetics should be considered to match the game's visual theme.
- **Action-Filled:** Audio will be high-energy and impactful, emphasizing the fast-paced nature of the gameplay. Throws, impacts, eliminations, and ability usage should feel powerful.
- **Gameplay Cues:** Clarity is paramount. Sounds associated with critical gameplay actions (dodging, catching attempts, ability cooldowns, powerup spawns, low health, warnings) must be distinct and immediately recognizable to aid player reaction and strategy.

## 4. Sound Asset List

A comprehensive list of required sound assets, categorized for clarity. Specific variations (e.g., `_01`, `_02`) should be created for frequently heard sounds to reduce repetition, potentially using `AudioStreamRandomizer`.

### 4.1 UI Sounds
- `UI_Menu_Navigate_Hover`: Sound for hovering over menu items.
- `UI_Menu_Navigate_Click`: Sound for selecting a menu item.
- `UI_Menu_Navigate_Back`: Sound for going back in menus.
- `UI_Game_Countdown_Tick`: Ticking sound for pre-round countdown.
- `UI_Game_Start_Signal`: Sound indicating the round start.
- `UI_Round_Win_Stinger`: Short musical cue for winning a round.
- `UI_Round_Lose_Stinger`: Short musical cue for losing a round.
- `UI_Match_Win_Stinger`: More significant cue for winning the match.
- `UI_Match_Lose_Stinger`: More significant cue for losing the match.
- `UI_Timer_Tick_Low`: Ticking sound when round timer is low.
- `UI_Overtime_Start_Signal`: Sound indicating overtime has begun.
- `UI_Modifier_Announce`: Sound accompanying modifier announcement.
- `UI_Modifier_Activate`: Sound when a modifier becomes active.
- `UI_Powerup_Spawn_Notify`: Sound indicating a powerup has spawned.
- `UI_Ability_Ultimate_Charged`: Notification sound when ultimate is ready.
- `UI_Character_Select`: Sound on selecting a character.
- `UI_Score_Update`: Sound when score changes.
- `UI_Replay_Transition`: Sound for entering/exiting replays.

### 4.2 Player Sounds
- `Player_Movement_Footstep`: Footstep sounds on the platform (futuristic slide/hum).
- `Player_Jump`: Sound for player jumping.
- `Player_Land`: Sound for player landing.
- `Player_Dodge`: Distinct whoosh/phase sound for dodging (left/right/duck variations possible).
- `Player_Dodge_Cooldown_Ready`: Sound indicating dodge ability is ready.
- `Player_Damage_Taken`: Impact sound when hit by a ball (shield break/energy discharge).
- `Player_Life_Lost`: More significant sound for losing a life (heart break?).
- `Player_Eliminated`: Dramatic sound for final elimination.
- `Player_Fall_Void`: Whoosh sound followed by elimination sound.
- `Player_Respawn`: Sound effect for respawning after spectator catch.
- `Player_Spectator_Enter`: Sound for entering spectator mode.
- `Player_Spectator_Exit`: Sound for exiting spectator mode.
- `Player_Spectator_Movement`: Subtle ethereal whoosh/fly sound for spectator movement.

### 4.3 Ball Sounds
- `Ball_Pickup`: Sound for picking up a ball.
- `Ball_Hold_Loop`: (Optional) Subtle hum/energy loop while holding a ball.
- `Ball_Aim_Enter`: Sound cue for entering aiming state.
- `Ball_Aim_Exit`: Sound cue for exiting aiming state.
- `Ball_Pump_Fake`: Sound for faking a throw.
- `Ball_Throw_Quick`: Standard throw sound.
- `Ball_Throw_Charged`: Build-up sound during aim, powerful release sound.
- `Ball_Travel_Loop`: Whoosh sound for ball in flight (pitch/volume based on speed).
- `Ball_Impact_Player_Hit`: Sound for ball hitting a player.
- `Ball_Impact_Player_Catch`: Success sound for catching a ball.
- `Ball_Impact_Player_Knock`: Deflect/block sound for knocking a ball.
- `Ball_Impact_Wall`: Bounce sound off arena walls/obstacles.
- `Ball_Impact_Floor`: Bounce sound off the platform.
- `Ball_Respawn`: Sound when a ball respawns.
- `Ball_Knockback_Effect`: Sound accompanying the knockback push.
- `Ball_CatchKnock_Target_Appear`: UI sound when catch/knock target appears.
- `Ball_CatchKnock_Target_Disappear`: UI sound when target disappears.
- `Ball_Catch_Success`: Clear success sound cue for a catch.
- `Ball_Knock_Success`: Clear success sound cue for a knock.
- `Ball_Catch_Fail`: Sound cue for missing a catch/knock.
- `Ball_Hoarding_Warning`: Warning sound if team holds balls too long.
- `Ball_Hoarding_Transfer`: Sound when hoarded balls are transferred.

### 4.4 Character Ability Sounds
- `Ability_Ultimate_Charge_Loop`: Sound indicating ultimate charge progress.
- `Ability_Ultimate_Charge_Full`: Sound when ultimate is fully charged (distinct from UI notification).
- `Ability_Ultimate_Activate`: Sound on activating ultimate throw.
- `Ability_Ultimate_Throw`: Extra powerful throw sound.
- `Ability_Ultimate_Impact`: Intense impact/knockback sound for ultimate hit.
- `Ability_Architect_Wall_Summon`: Sound for wall appearing.
- `Ability_Architect_Wall_Loop`: Ambient hum while wall is active.
- `Ability_Architect_Wall_End`: Sound for wall disappearing.
- `Ability_Trickster_Invis_Start`: Sound for entering invisibility.
- `Ability_Trickster_Invis_End`: Sound for reappearing.
- `Ability_Trickster_Decoy_Spawn`: Sound for decoy appearing.
- `Ability_Aggressor_Fireball_Activate`: Sound for activating fire ball ability.
- `Ability_Aggressor_Fireball_Throw`: Throw sound with fire element.
- `Ability_Aggressor_FireTrail_Spawn`: Sound of fire trail appearing.
- `Ability_Aggressor_FireTrail_Loop`: Burning sound loop for the trail.
- `Ability_Aggressor_FireTrail_End`: Sound of fire trail extinguishing.
- `Ability_Aggressor_Explosion`: Sound for fire ball impact/explosion.
- `Ability_Speedster_TimeSlow_Activate`: Sound for activating time slow.
- `Ability_Speedster_TimeSlow_Loop`: Ambient soundscape shift during time slow.
- `Ability_Speedster_TimeSlow_Deactivate`: Sound for time returning to normal.
- `Ability_Speedster_Spin_UI`: Sound for interacting with spin UI.

### 4.5 Powerup Sounds
- `Powerup_Spawn_Appear`: Sound when a powerup physically appears.
- `Powerup_Pickup_TimeSlow`: Distinct pickup sound.
- `Powerup_Pickup_Hunt`: Distinct pickup sound.
- `Powerup_Pickup_GoldenBall`: Distinct pickup sound.
- `Powerup_Pickup_Ballstorm`: Distinct pickup sound.
- `Powerup_Pickup_Firechain`: Distinct pickup sound.
- `Powerup_Pickup_Glock`: Distinct pickup sound (potentially comedic).
- `Powerup_Pickup_Hugh`: Distinct pickup sound (comedic).
- `Powerup_Pickup_PushOut`: Distinct pickup sound.
- `Powerup_TimeSlow_Effect_Loop`: Global sound effect loop while active.
- `Powerup_Hunt_Activate`: Sound on activation.
- `Powerup_Hunt_Target_Acquired`: UI sound for target assignment.
- `Powerup_Hunt_Target_Hit`: Success sound on hitting target.
- `Powerup_Hunt_End`: Sound when Hunt effect ends.
- `Powerup_GoldenBall_Effect_Loop`: Sound loop/modifier on ball sounds while active.
- `Powerup_Ballstorm_Rain_Loop`: Sound of balls raining down.
- `Powerup_Ballstorm_Ball_Land`: Sound of spawned balls landing.
- `Powerup_Firechain_Explosion`: Sound for chain reaction explosion.
- `Powerup_PushOut_Effect`: Sound of the center line moving.

### 4.6 Environmental Sounds
- `Env_Ambience_Loop`: Background ambient sound for the arena (futuristic hum, energy). Specific loops per theme (space, aquatic).
- `Env_Obstacle_BouncePad`: Sound for using a bounce pad.
- `Env_Obstacle_Tree_Move`: Sound for moving tree obstacle (if applicable).
- `Env_Event_LowG_Activate`: Sound cue for low gravity start.
- `Env_Event_LowG_Loop`: Ambient shift during low gravity.
- `Env_Event_LowG_Deactivate`: Sound cue for low gravity end.
- `Env_Event_Trampoline_Activate`: Sound cue for trampoline floor start.
- `Env_Event_Trampoline_Loop`: Ambient shift/bouncy sounds during event.
- `Env_Event_Trampoline_Deactivate`: Sound cue for trampoline floor end.
- `Env_Event_WatchStep_Warn`: Warning sound cue for disappearing floor sections.
- `Env_Event_WatchStep_Disappear`: Sound of floor section disappearing.
- `Env_Event_WatchStep_Reappear`: Sound of floor section reappearing.
- `Env_Overtime_Deteriorate_Loop`: Sounds of stage breaking apart during overtime.

### 4.7 Music (BGM)
- `BGM_Menu_Loop`: Looping track for main menu (futuristic, medium energy).
- `BGM_Ingame_Loop`: Looping track for gameplay (futuristic, high energy, action-oriented). Consider layers for intensity.
- `BGM_Stinger_RoundWin`: Short musical cue.
- `BGM_Stinger_RoundLose`: Short musical cue.
- `BGM_Stinger_MatchWin`: Short musical cue.
- `BGM_Stinger_MatchLose`: Short musical cue.

## 5. Technical Implementation (Godot 4.x)

- **Audio Manager Singleton:** An Autoload script (`AudioManager.gd`) will manage sound playback, bus volumes, and potentially pool AudioStreamPlayer nodes.
    - Functions like `play_sfx(sound_name, position=null)`, `play_ui_sfx(sound_name)`, `play_music(track_name)`, `set_bus_volume(bus_name, db_value)`. 
- **Audio Buses:** A structured bus layout will be used for mixing control:
    - `Master`: Final output.
    - `Music`: BGM playback, routed to Master.
    - `SFX`: Main bus for all sound effects, routed to Master.
        - `UI`: Sub-bus for UI sounds, routed to SFX.
        - `Player`: Sub-bus for player-related SFX, routed to SFX.
        - `Ball`: Sub-bus for ball-related SFX, routed to SFX.
        - `Ability`: Sub-bus for ability SFX, routed to SFX.
        - `Env`: Sub-bus for environmental/powerup SFX, routed to SFX.
- **AudioStreamPlayers:**
    - `AudioStreamPlayer` (non-positional): Used for UI SFX and Music, managed by `AudioManager`.
    - `AudioStreamPlayer3D` (positional): Used for Player, Ball, Ability, and Environmental sounds originating from specific world locations. These nodes should be attached to the relevant game objects (Player character scene, Ball scene, specific obstacles, etc.) or instantiated dynamically by `AudioManager` at specific positions.
    - **Pooling:** Consider implementing a node pooling system within `AudioManager` for frequently played, short-duration 3D sounds to optimize performance by reusing `AudioStreamPlayer3D` nodes instead of constantly creating/destroying them.
- **Audio Streams:**
    - `AudioStreamOGGVorbis`: Preferred format for most assets due to good compression and quality.
    - `AudioStreamWAV`: Use only if necessary for extremely short, high-frequency UI sounds where latency is critical.
    - `AudioStreamRandomizer`: Utilize for adding variation to common sounds like footsteps, impacts, etc., by assigning multiple sound variations within the editor.
- **Effects:** Apply audio effects (Reverb, EQ, Compression, Limiter) via the Audio Bus panel in the Godot editor. A light reverb on the `Env` bus and a Limiter/Compressor on the `Master` bus are recommended starting points.
- **Volume Control:** Game settings should allow players to adjust Master, Music, and SFX bus volumes independently. These settings will call functions in `AudioManager` to update `AudioServer.set_bus_volume_db()`.
- **Spatialization:** Configure `Attenuation`, `Unit Size`, and other relevant properties on `AudioStreamPlayer3D` nodes to achieve desired 3D sound falloff and positioning.

## 6. Music Specifications

- **Menu BGM:** Looping, approximately 1-2 minutes long. Futuristic theme, medium energy, should not be overly distracting.
- **In-Game BGM:** Looping, approximately 2-3 minutes long. Futuristic, high-energy, driving rhythm suitable for fast-paced action. Consider designing with multiple layers (e.g., percussion, bass, melody, intensity layer) that can be faded in/out by `AudioManager` based on game state (e.g., few players left, overtime) for adaptive intensity.
- **Stingers:** Short (2-5 seconds) musical cues for round/match end states, consistent with the overall futuristic style.
- **Format:** Ogg Vorbis (.ogg).

## 7. Asset Specifications

- **Format:** Ogg Vorbis (.ogg) is the primary format for all SFX and Music.
- **Quality:**
    - Sample Rate: 44.1kHz or 48kHz.
    - Bit Depth: 16-bit.
    - Channels: Mono for most SFX unless a specific stereo effect is intended (e.g., wide UI sounds, some ambiences). Stereo for Music and main Ambience loops.
- **Naming Convention:** Use a clear and consistent naming convention: `Category_AssetName_VariationNumber.ogg` (e.g., `SFX_Player_Footstep_01.ogg`, `BGM_Ingame_Loop_Layer1.ogg`, `UI_Button_Click.ogg`).
- **Loudness:** Normalize audio assets to a consistent perceived loudness level before importing into Godot (e.g., target -14 to -18 LUFS for SFX, -16 to -20 LUFS for Music). This allows for more predictable mixing using bus volumes.
- **Looping:** Ensure BGM and ambient loops are seamless.

## 8. Testing Plan

- **Individual Asset Review:** Listen to all exported assets in isolation to check for quality issues (clicks, pops, noise) and ensure loops are seamless.
- **In-Engine Test Scene:** Create a test scene to trigger and listen to sounds via `AudioManager`.
- **Gameplay Testing:** Play the game extensively, focusing on:
    - **Clarity:** Are gameplay cues easily distinguishable during chaotic moments?
    - **Impact:** Do actions feel appropriately powerful?
    - **Spatialization:** Do 3D sounds originate from the correct locations?
    - **Mixing:** Is the balance between Music, SFX, and UI appropriate? Check for excessive loudness or sounds being drowned out.
    - **Clipping:** Monitor the Master bus VU meter during intense gameplay to ensure no clipping occurs.
    - **Performance:** Check for any performance drops related to audio playback.
    - **Repetition:** Identify sounds that become annoying due to repetition and consider adding more variations or using `AudioStreamRandomizer`.

## 9. Future Considerations

- Implementation of more complex environmental reverb using `Area3D` nodes and dedicated reverb buses.
- Development of a more sophisticated adaptive music system reacting to more granular gameplay events.
- Integration of voice chat functionality.

