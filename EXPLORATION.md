# Handgroove: how we got here

Notes from the conversation that led to this build (October 2026).

## Starting point
- Interest: the interconnection of image, sound and code; the early Processing feeling of art and code being "two clicks apart".
- Highest-rated references: Patatap, Chrome Music Lab, Sandspiel, A Way to Go (see Documentation/references.md).
- A Raspberry Pi 3 B+ is available as a sandbox for at least one project.

## Three directions we considered
1. **The signal is the drawing.** Image and sound as the same data: oscilloscope music (Jerobeam Fenderson), painted spectrograms (ANS synthesizer, MetaSynth).
2. **A sketchbook before a piece.** Our own "two clicks apart" editor: code + canvas + sound primitives, instant re-run.
3. **An object that lives somewhere.** The Pi as a long-running generative piece, a sound engine for browser sketches, or a physical instrument (GPIO knobs, sensors). Bonus: Pi audio out into an old oscilloscope.

## Sonic Pi
- Sonic Pi is itself a GUI app: editor with ten buffers, Run button, oscilloscope, log, built-in tutorial.
- It has no knobs/sliders of its own (the author says built-in widgets are part of his newer, experimental Elixir-based work). People control it over OSC or MIDI:
  - TouchOSC (phone/tablet, paid), Open Stage Control (free, browser), USB MIDI controllers, or our own browser page.
- Raspberry Pi 3: Sonic Pi 4.3 reported to run on a Pi 3B; 4.4 runs but poorly. Use a USB sound card (the 3.5 mm jack is noisy).
  Sources: https://in-thread.sonic-pi.net/t/where-is-the-doc-on-which-pi-models-support-sonic-pi/8026 ,
  https://in-thread.sonic-pi.net/t/graphical-widgets-in-sonic-pi/7305
- Browser cousins: Strudel (https://strudel.cc, live-coded patterns) and Hydra (https://hydra.ojack.xyz, live-coded video).

## The brief
"A very expressive, cam-based way of controlling Sonic Pi to generate house/techno sessions live, on the go, very easily." Laptop only.

## Key design rule
The camera steers; Sonic Pi keeps time. Camera latency (50–100 ms) would wreck a groove if gestures triggered notes,
so gestures set macro parameters and every change snaps to the next bar.

## Where the Pi could come in later
- Host the bridge and serve the page to a phone (phone as camera).
- A standalone "groove box" with a USB sound card playing sessions designed on the laptop.
- The Pi 3 B+ is too slow to run hand tracking and Sonic Pi at the same time.

## Cost
Everything is free: Sonic Pi (open source), MediaPipe (open source, runs locally), Python, Chrome. Optional extras only: TouchOSC, a USB sound card for the Pi.
