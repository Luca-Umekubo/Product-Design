# UI Technical Specification for HyperBallz

## Overview
This document outlines the technical specification for the UI for HyperBallz

---

## UI Components (Core Only)

### 1. **Homescreen**
- **Buttons**:
  - `Start Game`
  - `Test World`
  - `Exit Program`
- **Variables**:
  - `start_button: Button`
  - `test_button: Button`
  - `exit_button: Button`
- **Methods**:
  - `_on_start_button_pressed()`
  - `_on_test_button_pressed()`
  - `_on_exit_button_pressed()`
- **Scene Transition**:
  - `Start Game` → Multiplayer Lobby
  - `Test World` → Test Game Screen
  - `Exit Program` → Closes application

---

### 2. **Multiplayer Lobby**
- **Important UI Elements**:
  - `Player Count`, `Player List`, `Host`, `Map`, `Teams`, `Lobby Code`
- **Less-Important Elements**;
  - `Lobby Code`, `Game Mode`, `Skin Indicator`, `Voice Chat Indicator`, `Ready Status`
- **Variables**:
  - `player_list: ItemList`
  - `team_assignments: Dictionary`
  - `lobby_code: String`
- **Methods**:
  - `_refresh_player_list()`
  - `_assign_team(player_id)`
  - `_start_game()`
- **Dependencies**:
  - MultiplayerManager.gd (networking layer)

---

### 3. **Multiplayer Game Screen**
- **Buttons**:
  - `Settings`
- **Variables**:
  - `settings_button: Button`
- **Methods**:
  - `_on_settings_button_pressed()`
- **Transition**:
  - Goes to Escape Menu

---

### 4. **Escape Menu**
- **Buttons**:
  - `Resume`, `Quit`, `Keybinds`, `Game Settings`
- **Variables**:
  - `resume_button: Button`
  - `quit_button: Button`
  - `keybinds_button: Button`
  - `game_settings_button: Button`
- **Methods**:
  - `_on_resume_button_pressed()`
  - `_on_quit_button_pressed()`
  - `_on_keybinds_button_pressed()`
  - `_on_game_settings_button_pressed()`
- **Transitions**:
  - `Resume` → Multiplayer Game Screen
  - `Quit` → Homescreen
  - `Keybinds` → Keybinds Menu
  - `Game Settings` → Game Settings Menu

---

### 5. **End Screen**
- **Buttons**:
  - `Leave Game`, `Play Again`
- **Variables**:
  - `leave_button: Button`
  - `play_again_button: Button`
- **Methods**:
  - `_on_leave_button_pressed()`
  - `_on_play_again_button_pressed()`
- **Transitions**:
  - `Leave` → Homescreen
  - `Play Again` → Multiplayer Lobby

---

### 6. **Test Game Screen**
- **Buttons**:
  - `Settings`, `Game Parameters`
- **Variables**:
  - `settings_button: Button`
  - `parameters_button: Button`
- **Methods**:
  - `_on_settings_button_pressed()`
  - `_on_parameters_button_pressed()`
- **Transition**:
  - `Settings` → Escape Menu
  - `Game Parameters` → Parameters Menu

---

### 7. **Parameters Menu**
- **Controls**:
  - `Map`, `Throw Speed`, `Player Limit`, `Jump Height`, `Time Limit`, `Player Speed`, `Accuracy`, `Charge Speed`, `Return`
- **Variables**:
  - Various sliders for each parameter (Slider class)
- **Methods**:
  - `_on_parameter_changed(parameter_name, value)`
  - `_on_return_button_pressed()`
- **Transition**:
  - `Return` → Test Game Screen

---

## UI Scene Structure in Godot
```
Main.tscn
├── Homescreen.tscn
    ├── MultiplayerLobby.tscn
    ├── MultiplayerGameScreen.tscn
        ├── EscapeMenu.tscn
           ├── KeybindsMenu.tscn
           └── GameSettings.tscn
├── EndScreen.tscn
├── TestGameScreen.tscn
   └── ParametersMenu.tscn
```

---

## Shared Variables and Classes
- `UIManager.gd`
  - Singleton for UI state control and transitions
  - Stores references to current and previous UI states
- `GameState.gd`
  - Stores game-specific variables such as current players, scores, and timers
- `InputManager.gd`
  - Manages rebinding keybinds from KeybindsMenu

---

## Notes for Implementation
- Focus on clean transitions using Godot’s `SceneTree.change_scene_to()`
- Use signals to wire button presses to appropriate methods
- Ensure keyboard/gamepad accessibility for all UI controls
- Use control node anchors/margins for resolution-independent scaling

---