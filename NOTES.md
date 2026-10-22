# Handgroove: notes

Music played with the hands in front of a laptop camera, entirely in the browser (October 2026).
An early version steered a set in Sonic Pi; it was replaced by browser synthesis so the project can live on a website.

## Pieces
- **Handgroove** (`index.html`): the piece itself. It opens straight into the playing field; **0** shows the help.

## Design decisions
- **The camera steers, the clock plays.** Hand tracking has 50–100 ms of jitter, so gestures never trigger notes.
  They set parameters; a sample-accurate look-ahead scheduler keeps everything on the grid.
- **One grammar for every sound.** Each panel is an X-Y map, and each sound has a position on every map.
  The left hand chooses (fist, 1–4 fingers; open hand = nothing), the right fist grabs, opening drops,
  past the edge silences or resets. Push/pull and wrist twist add a third and fourth dimension while holding.
- **Five panels (keys 1–5).** Sound (time × tone, depth, echo) · Texture (grain × dust, mix) ·
  Style (loose↔locked × organic↔industrial, acid zone in the far corner, volume) · Harmony (tempo × mode, key, chords) ·
  Rhythm (syncopation × grouping, mutation, interlock).
- **Procedural patterns.** Density comes from the Sound panel. The groove axis decides how patterns are made:
  locked = Euclidean rhythms that repeat; loose = chance weighted by the beat. Bells walk randomly when loose and
  lock into a slowly mutating motif when locked. Every note is constrained to the current mode, so chance never
  sounds wrong. Layers run on different cycle lengths, so the whole rarely repeats.
- **Rhythm panel, not genres.** An earlier version had a map of named genres (dub, dembow, house…); it was replaced
  because fixed templates went against the generative idea. Now each sound gets a rhythmic character instead, and styles
  emerge from the mix. X = syncopation: step weights blend from on the grid (group starts, then their middles) to off it
  (the middles, the step before each pulse, the step after). Y = grouping of the 16 steps: 4+4+4+4, 3+3+2·3+3+2,
  3+3+3+3+4, 5+3+5+3. The pattern is the k best steps (k = density from the Sound panel), with a fixed random
  tie-breaker per sound as its fingerprint. Mutation re-rolls a few tie-breakers each bar (0 = frozen). Interlock makes a
  part avoid the steps of the parts before it (kick → sub → ticks → bells → pad), so the bass leaves room for the kick,
  hats fill gaps and bells answer. Loose style still drops notes and adds ghost notes. Parked in the gutter = the free
  patterns described above. The ring of 16 dots around each sound shows its bar.
- **Transitions everywhere.** Each panel edits a target (what you see); the sound follows a gliding copy (what you hear),
  with time constants of 0.8–2 s, recalculated by the scheduler so it keeps going in background tabs. Tempo glides; rhythm
  patterns morph toward their target by at most two notes per bar; switching a sound between free and shaped rhythm
  crossfades step by step; key and chord changes land on the next bar and crossfade on the pad; the master filter eases.
- **Robust hands.** Roles survive one hand leaving the frame; grabbing needs a deliberate, steady fist and a visible
  left-hand pose; a hand leaving while holding puts the sound back where it was; one-frame tracking glitches are ignored.
- **Sound.** Pure Web Audio: five voices, each with an organic and an industrial version blended by the Style panel,
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
