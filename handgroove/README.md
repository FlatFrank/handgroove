# Handgroove

Your hands steer a live house set in Sonic Pi through the laptop camera.
Sonic Pi keeps time; the camera only steers, so every change lands on the beat.

## Files

- `handgroove.rb`: the music (Sonic Pi). Edit it live.
- `bridge.py`: connects the browser and Sonic Pi. Standard Python, nothing to install.
- `index.html`: the camera page (hand tracking with Google MediaPipe, all on your laptop).

## First run (about 10 minutes)

1. **Install Sonic Pi** from https://sonic-pi.net (free) and open it.
2. In Sonic Pi, open **Preferences → IO** and turn on **incoming OSC**
   (the checkbox name varies by version: "Enable OSC server", "Allow incoming OSC"…).
   Note the incoming OSC port shown there; it should be **4560**.
3. Open `handgroove.rb` in any text editor, copy everything, paste it into an empty
   Sonic Pi buffer and press **Run**. You should hear a groove straight away.
4. Open **Terminal** and run:
   ```
   cd ~/Desktop/LAB/Proceed/builds/handgroove
   python3 bridge.py
   ```
   If macOS offers to install the "command line developer tools", accept; it's free and needed once.
5. Open **http://localhost:8000** in Chrome, click **Start camera**, allow the camera.
   The first load needs internet (it downloads the hand model); after that Chrome caches it.

The three dots at the top right should all turn green: bridge, Sonic Pi, camera.

## Playing

| Gesture | Music |
|---|---|
| Right hand up / down | Filter sweep on bass and chords |
| Right hand fist → open | Energy: hats, stab pattern, percussion, rolling bass |
| Left hand, 1–5 fingers | Scene: intro · groove · breakdown · peak · outro |
| Left fist, hold | Build: kick out, snare roll, noise riser |
| Open the fist | Drop into the scene your fingers show, on the next bar |
| Hands apart / together | Reverb and delay |
| Move your body | Swing and percussion |

"Left" and "right" mean the halves of the screen. Your hands can rest out of frame:
values stay where you left them. If you drop your left hand during a build, it drops automatically after about a second.

**Keyboard backup:** 1–5 scenes · hold Space to build · ↑↓ filter · ←→ energy · [ ] space.

## Changing the music

Everything musical is in `handgroove.rb`. Edit in Sonic Pi and press Run again; the groove keeps going.

- Tempo: `use_bpm 124`
- Key and chords: `root_at` and `chord_at`
- Which parts play in which scene: the table inside `has`
- Sounds: `sample :bd_haus`, `use_synth :supersaw`, etc. Sonic Pi's Help panel lists them all.

## Troubleshooting

- **Bridge dot red:** `bridge.py` isn't running, or you opened the file directly; use http://localhost:8000.
- **Sonic Pi dot red but bridge green:** incoming OSC is off in Sonic Pi's preferences, or the code isn't running.
- **Music reacts late:** lower `set_sched_ahead_time!` (e.g. 0.1). If audio crackles, raise it (0.3).
- **Scenes jump around:** keep your left hand flat facing the camera; fingers are counted from the palm side.
- **"Address already in use":** another bridge is running; close that Terminal window or press Ctrl+C there.
