# Handgroove

Music you play with your hands, in front of a laptop camera. Everything is synthesized live in the
browser: no samples, no installs, and the camera image never leaves your computer.

| File | What it is |
|---|---|
| `index.html` | The landing page. |
| **`field.html`** | **Handgroove** itself, the main piece: an ambient/minimal music field played with hand gestures (or the mouse). One self-contained file. |
| `soundcheck.html` | A sound check for the synthesized 808/909-style kit, 303-style bass and chord stabs, with the macros gestures can drive. |
| `NOTES.md` | Design notes, credits and ideas. |
| `EXPLORATION.md` | How the project started (an early version used Sonic Pi; the project is now fully in the browser). |

---

## Playing Handgroove (`field.html`)

### Run it

The camera only works when the page is served over `http://localhost` or `https://`, not when the file is double-clicked.

- **On your Mac:** in Terminal, run
  ```
  cd ~/Desktop/LAB/Proceed/builds/handgroove
  python3 -m http.server 8000
  ```
  then open **http://localhost:8000/field.html** in Chrome.
- **Online:** it runs on GitHub Pages as it is, no server needed. Turn it on in the repository's
  Settings → Pages → Deploy from a branch → `main` / root. The landing page is then
  `https://flatfrank.github.io/handgroove/` and the piece is `https://flatfrank.github.io/handgroove/field.html`.

Click **Start with camera** (or **Mouse only**). The first load needs internet to fetch the hand-tracking model; the sound itself needs nothing.

### Play it

Every sound is a light on the screen. Where it sits is how it plays.

| Gesture | What it does |
|---|---|
| **Left hand, a shape** | Chooses a sound: fist = Kick · 1 finger = Ticks · 2 = Sub · 3 = Pad · 4 = Bells. Open hand = nothing, so you can rest. |
| **Right hand, close your fist** | Grabs the chosen sound. It follows your hand. |
| **Open the right hand** | Drops it there. It keeps playing that way. |
| **Drop it past the edge** | Silences it (on the Sound panel) or resets it (on the other panels). |
| **While holding: push in / pull back** | Depends on the panel (see below). |
| **While holding: twist your wrist** | Echo trails on the held sound (on the Harmony panel: the key). |

If your hands seem swapped, press **H**. If a hand leaves the camera while holding a sound, the sound goes back to where it was just before; nothing is ever flung or silenced by accident.

### The four panels (keys 1–4, or the tabs at the top right)

| Key | Panel | Left → right | Bottom → top | Push in / pull back |
|---|---|---|---|---|
| **1** | **Sound** | sparse → dense (time) | dark → bright (tone) | close and dry → far and washed out (depth) |
| **2** | **Texture** | smooth → granular (grain) | clean → dusty (crackle, lo-fi) | less → more texture (mix) |
| **3** | **Style** | loose → locked (groove) | organic → mechanical (material) | louder → quieter (volume) |
| **4** | **Harmony** | 90 → 130 bpm (tempo) | phrygian → lydian (mood) | drone → 8 chords; twist = key |

**Style** corners: ambient (loose, organic) · organic minimal (locked, organic) · industrial (loose, mechanical) · techno (locked, mechanical), with acid growing into the far top-right corner.
The groove axis also decides how patterns are made: **loose** = chance (every bar different), **locked** = Euclidean rhythms that repeat; locked bells play a melodic motif that slowly mutates.

**Harmony** is a single light (the key), grabbed with the right fist alone. Changes land on the next bar.

### Mouse and keyboard

Drag a light to move it · scroll on a light: echo · Shift+scroll: depth / mix / volume (depending on the panel) ·
on the Harmony panel, scroll: key, Shift+scroll: chords · **[ ]** master filter · **1–4** panels · **H** swap hands.

### How it works

- **Sound:** pure Web Audio synthesis. Five voices (kick, ticks, sub, pad, bells), each with an organic and a mechanical version blended by the Style panel, a per-voice echo line, a shared reverb, and a texture stage (grain gate, bit-crush, crackle).
- **Patterns:** procedural. Density comes from the Sound panel; Euclidean or weighted-chance rhythms from the Style panel; random walks and motifs for the bells; all notes constrained to the current mode, so chance never sounds wrong.
- **Hands:** Google MediaPipe hand tracking, running locally in the browser.
- **Clock:** a sample-accurate look-ahead scheduler, so gestures steer while the groove stays on the grid.

---

## Sound check (`soundcheck.html`)

Open it in a browser and press **Play**. Switch 808/909, mute parts, trigger single hits, and move the macros (filter, energy, acid, space, pump, swing, kick pitch, hat decay).

---

## Credits

- Hand tracking: MediaPipe Tasks Vision (Apache 2.0).
- Hand pose icons: paths from Tabler Icons (MIT, https://tabler.io/icons).
- Everything else was written for this project.
