# 🚀 Asteroid Defense – Space Shooter

*A minimalistic space shooter with turret management, energy economy, and asteroid destruction.*

---

## 📖 About

**Asteroid Defense** is a 2D space shooter where you control a starship that cannot maneuver. Your only defense is a set of **5 turrets** that can fire at asteroids heading toward your ship. Each asteroid has health points (HP) and drops energy when destroyed. You must manage your energy pool wisely – firing costs energy, but destroying asteroids replenishes it. Alternatively, you can use an **energy shield** to reflect asteroids (costs less energy but yields no drop).

The game features **3 difficulty levels**, **color schemes**, **sound/music controls**, and **full localization** (English/Russian). It’s built with **Godot 4.7.1** and written in GDScript with clean, commented code.

---

## ✨ Features

- **Turret system** – 5 turrets that automatically fire at assigned targets. Click an asteroid to assign a turret; each click adds another turret to that target.
- **Energy management** – Energy regenerates over time. Firing and shielding consume energy; destroying asteroids gives energy drops.
- **Asteroid scaling** – Asteroids grow from a spawn point toward the ship. When they reach the screen edge, they collide with the ship, reducing HP.
- **Health system** – Ship has 10 HP. Collision costs 1 HP. Game Over when HP reaches 0.
- **Critical warning** – Asteroids flash when they reach 80% of their maximum size, triggering an alarm sound.
- **Customizable UI** – Choose from multiple color themes (Classic, Nebula, Pastel, Gold, Inferno, Ice, Sunset, White, Black, Forest, Pinky).
- **Audio** – Background music, radar clicks, shot sounds, and a warning alarm. All can be toggled separately.
- **Localization** – Full English and Russian translations, with font switching for Cyrillic support.
- **Dynamic difficulty** – Spawn rate accelerates as your score increases (100 and 300 points thresholds).
- **Radar** – A rotating radar line on the main screen adds atmosphere.
- **Pause & settings** – Press `ESC` to open the settings menu (pauses the game). Adjust difficulty, color scheme, sound, language, restart, or quit.

---

## 🎮 Gameplay

- **Asteroids** appear in random positions and grow toward your ship. Left-click an asteroid to assign one turret to it (up to 5 turrets per asteroid). Right-click to activate the shield and reflect it away (costs energy, no energy drop).
- **Energy** regenerates automatically (rate depends on difficulty). Spend it on turret shots (cost varies by asteroid size) or shield.
- **Score** increases by the total HP of destroyed asteroids. Higher score speeds up asteroid spawns (at 100 and 300 points).
- **Game Over** occurs when your ship HP reaches 0. A "Game Over" message appears, and you can restart from the settings menu.

---

## 🎯 Controls

| Action | Key / Mouse |
|--------|-------------|
| Assign turret to asteroid | Left-click on asteroid |
| Activate shield on asteroid | Right-click on asteroid |
| Open/close settings | `ESC` |
| Pause (settings menu) | `ESC` |
| Restart game | Settings → RESTART |
| Quit game | Settings → QUIT |

*(Debug spawn: press `SPACE` or `CTRL` to spawn an asteroid for testing.)*

---

## 🛠️ Installation

### Requirements
- **Godot Engine 4.7.1** (or later 4.x)
- No external dependencies – all assets are built-in.

### Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/asteroid-defense.git
   ```
2. Open the project in Godot 4.7.1.
3. Run the main scene (`main.tscn` or the root scene).
4. (Optional) Add your own sound files in `res://sounds/` (see below).

### Sound files (optional)
The game expects the following audio files in `res://sounds/`:
- `music.ogg` – background loop
- `radar.ogg` – radar tick
- `shot.ogg` – laser shot
- `alarm.ogg` – critical warning

If missing, the game runs without sound.

### Fonts
Place your TTF fonts in `res://`:
- `RU.ttf` – used for both English and Russian (supports Cyrillic). You can rename your font file accordingly.

---

## ⚙️ Configuration

All settings are saved in `user://settings.cfg` (platform-specific user directory). Settings include:
- Difficulty
- Color scheme
- Music/Sounds on/off
- Language

You can change these from the in-game settings menu (`ESC`).

---

## 🧩 Project Structure

```
res://
├── main.gd                  # Root UI controller, menus, panels
├── game_world.gd            # Game world: asteroids, turrets, shots, radar
├── asteroid.gd              # Asteroid class (growth, damage, flashing)
├── turret.gd                # Turret class (auto-fire, energy cost)
├── game_manager.gd          # Global game state (energy, HP, score, difficulty)
├── settings_manager.gd      # Persistent settings (color, sound, language)
├── audio_manager.gd         # Sound and music player
├── translation_manager.gd   # Localization dictionary
├── font_manager.gd          # Font selection based on language
├── custom_cursor.gd         # Custom crosshair cursor
├── stars.gd                 # Animated starfield and star info panel
├── asteroid_list.gd         # Asteroid list panel (right side)
├── color_rect.gd            # Background color rect
├── ui_controller.gd         # Input controller (ESC handling, always active)
├── RU.ttf                   # Font file (rename as needed)
└── sounds/                  # (optional) Sound files
```

---

## 🧑‍💻 Development Notes

- The code is fully typed and commented in Russian (for educational purposes). English comments can be added upon request.
- The project follows DRY (Don't Repeat Yourself) principles.
- All UI panels are created programmatically – no `.tscn` dependencies for UI.
- Pause handling: the UI layer (`process_mode = ALWAYS`) remains active while the game world pauses.

---

## 📜 License

This project is open-source under the MIT License. Feel free to modify and distribute.

---

## 🙏 Credits

- Developed by [Your Name]
- Built with Godot Engine – https://godotengine.org/

---

**Enjoy the game!** 🚀
