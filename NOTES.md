# Handgroove: notes

Music played with the hands in front of a laptop camera, entirely in the browser (October 2026).
An early version steered a set in Sonic Pi; it was replaced by browser synthesis so the project can live on a website.

## Pieces
- **Handgroove** (`field.html`): the main piece, an ambient/minimal music field.
- **Sound check** (`soundcheck.html`): the synthesized kit, bass and stabs on their own.

## Design decisions
- **The camera steers, the clock plays.** Hand tracking has 50–100 ms of jitter, so gestures never trigger notes.
  They set parameters; a sample-accurate look-ahead scheduler keeps everything on the grid.
- **One grammar for every sound.** Each panel is an X-Y map, and each sound has a position on every map.
  The left hand chooses (fist, 1–4 fingers; open hand = nothing), the right fist grabs, opening drops,
  past the edge silences or resets. Push/pull and wrist twist add a third and fourth dimension while holding.
- **Four panels (keys 1–4).** Sound (time × tone, depth, echo) · Texture (grain × dust, mix) ·
  Style (loose↔locked × organic↔mechanical, volume) · Harmony (tempo × mode, key, chords).
- **Procedural patterns.** Density comes from the Sound panel. The groove axis decides how patterns are made:
  locked = Euclidean rhythms that repeat; loose = chance weighted by the beat. Bells walk randomly when loose and
  lock into a slowly mutating motif when locked. Every note is constrained to the current mode, so chance never
  sounds wrong. Layers run on different cycle lengths, so the whole rarely repeats.
- **Robust hands.** Roles survive one hand leaving the frame; grabbing needs a deliberate, steady fist and a visible
  left-hand pose; a hand leaving while holding puts the sound back where it was; one-frame tracking glitches are ignored.
- **Sound.** Pure Web Audio: five voices, each with an organic and a mechanical version blended by the Style panel,
  per-voice echo, shared reverb, texture stage (grain gate, bit-crush, crackle), sidechain from the kick.

## References (from Documentation/references.md)
- Tone Matrix (★4): a system that can't sound wrong; everything quantized.
- Patatap / Chrome Music Lab (★5): immediate audiovisual response to a gesture.
- Sandspiel (★5): simple rules, emergent results.
- html.moldandyeast (★5): one self-contained HTML file per piece.

## Stack and licences
- MediaPipe Tasks Vision 0.10.14 + hand_landmarker model (Apache 2.0): hand tracking in the browser.
- Hand pose icons: paths from Tabler Icons (MIT, https://tabler.io/icons): hand-finger, hand-two-fingers,
  hand-three-fingers, hand-stop. The fist is composed from the same parts.
- All other code and every sound were written for this project.

## Ideas
- Scenes: save layouts and morph between them (a Scenes panel).
- Motion loops: record a few bars of moving a sound and let it repeat.
- Stronger visuals: body silhouette coloured by the music, a shader background, a waveform ring per sound.
- Seeded randomness, so a performance can be replayed or shared.
- Record the session as an audio file; export a graphic score of the movements.
- Raspberry Pi: a standalone screen running a slowly drifting field as an installation.
