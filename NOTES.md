# Handgroove: notes

Version 1, October 2026.

## Idea
Camera-steered live house/techno. Image, sound and code as one loop: the body moves the code,
the code plays the sound, the sound pulses the image.

## Design decisions
- The camera never triggers notes (50–100 ms of jitter would break the groove). It sets macro
  parameters; Sonic Pi reads them at each bar, so drops and scene changes land on the downbeat.
- The fist build into an open-hand drop doubles as scene selection: open to N fingers = drop into scene N.
- Hands are assigned by screen half, not MediaPipe handedness, so the rule is easy to perform.
- The bridge uses HTTP POST + Server-Sent Events rather than WebSockets, so it runs on Python's standard library.

## References (from Documentation/references.md)
- Tone Matrix (★4): a system that can't sound wrong; everything quantized.
- Patatap / Chrome Music Lab (★5): immediate audiovisual response to a gesture.
- Blob Opera (★4): expressive control of a musical system through simple physical gestures.

## Stack and licences
- Sonic Pi (MIT): music engine.
- MediaPipe Tasks Vision 0.10.14 + hand_landmarker model (Apache 2.0): hand tracking in the browser.
- All code here was written for this project.

## Ideas for v2
- Record each session's control stream and replay it, or render it as an image (a "score" of the set).
- A second "instrument" hand pose: pinch to play a lead melody quantized to the scale.
- Move the visuals to WebGL: posterized body silhouette that pulses with the kick.
- Pi 3 B+: run the bridge + a USB sound card as a portable box (needs testing with Sonic Pi 4.3).

## Handfield credits
- Left-hand pose icons: paths from Tabler Icons (MIT licence, https://tabler.io/icons): hand-finger,
  hand-two-fingers, hand-three-fingers, hand-stop. The fist is composed from the same parts.
