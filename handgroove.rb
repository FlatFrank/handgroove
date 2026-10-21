# HANDGROOVE: Sonic Pi side
# 1. Paste this whole file into an empty Sonic Pi buffer and press Run.
# 2. Start bridge.py, then open http://localhost:8000 in Chrome.
#
# The camera page sends /proceed/ctrl with six numbers, about 20 times a second:
#   0 cut     0..1  filter on bass, stabs and pads   (right hand height)
#   1 energy  0..1  hats, stab pattern, percussion   (right hand open/closed)
#   2 scene   0..4  intro, groove, breakdown, peak, outro   (left hand: 1-5 fingers)
#   3 kick    0/1   0 while the left fist is held = build; opening it = drop
#   4 space   0..1  reverb + delay                    (distance between hands)
#   5 move    0..1  swing + percussion density        (how much you move)
#
# Every musical part reads the controls at the start of each bar,
# so scene changes and drops always land on the downbeat.
# Edit anything below and press Run again: the groove keeps playing.

use_bpm 124
set_sched_ahead_time! 0.15   # lower = camera feels tighter; raise to 0.3 if audio crackles

set :cut, 0.55
set :energy, 0.45
set :scene, 1
set :kick, 1
set :space, 0.15
set :move, 0.2
set :build, 0

# ---------- helpers ----------

define :bridge do |path, *args|
  osc_send "localhost", 4561, path, *args
end

# Which parts play in which scene: 0 intro, 1 groove, 2 breakdown, 3 peak, 4 outro
define :has do |part|
  parts = {
    kick:  [0, 1, 3, 4],
    clap:  [1, 3],
    bass:  [1, 3],
    stabs: [1, 3],
    pad:   [0, 2, 4],
    perc:  [3]
  }
  parts[part].include?(get[:scene])
end

# Map the filter control onto a cutoff range (Sonic Pi cutoff is in MIDI notes, 0-130)
define :cutoff do |lo, hi|
  lo + get[:cut] * (hi - lo)
end

# A minor house progression, two bars per chord
define :root_at do |bar|
  (ring :a1, :f1, :d1, :e1)[bar / 2]
end

define :chord_at do |bar|
  (ring chord(:a3, :m7), chord(:f3, :major7), chord(:d3, :m7), chord(:e3, :m7))[bar / 2]
end

# ---------- control input ----------

live_loop :listen do
  use_real_time
  v = sync "/osc*/proceed/ctrl"
  set :cut, v[0]
  set :energy, v[1]
  set :scene, v[2].to_i.clamp(0, 4)
  set :kick, v[3].to_i
  set :space, v[4]
  set :move, v[5]
end

# ---------- clock (also tells the page where the beat is) ----------

live_loop :beat do
  i = tick
  bridge "/proceed/beat", i % 4, i / 4, get[:scene]
  sleep 1
end

# ---------- drums ----------

live_loop :kick, sync: :beat do
  if get[:kick] == 0
    # BUILD: a snare roll that tightens and rises for as long as the fist is held
    n = get[:build]
    set :build, n + 1
    synth :bnoise, attack: 3.6, release: 0.4, amp: [0.08 + n * 0.05, 0.35].min,
      cutoff: [75 + n * 10, 125].min
    steps = n < 2 ? 8 : 16
    steps.times do |i|
      sample :drum_snare_soft, amp: [0.25 + (n + i.to_f / steps) * 0.2, 1.2].min,
        rate: 1 + n * 0.04
      sleep 4.0 / steps
    end
  elsif has(:kick)
    set :build, 0
    4.times do |i|
      sample :bd_haus, amp: 1.5, cutoff: 115
      bridge "/proceed/kick", i
      sleep 1
    end
  else
    set :build, 0
    sleep 4
  end
end

live_loop :clap, sync: :beat do
  if has(:clap) && get[:kick] == 1
    2.times do
      sleep 1
      sample :perc_snap, amp: 0.9
      sample :drum_snare_hard, amp: 0.25, finish: 0.3
      sleep 1
    end
  else
    sleep 4
  end
end

live_loop :hats, sync: :beat do
  16.times do |i|
    e = get[:energy]
    sw = get[:move] * 0.06
    if i % 4 == 2 && e > 0.08
      sample :drum_cymbal_open, amp: 0.3, finish: 0.12, rate: 1.4
    end
    if i.odd? && rand < (e - 0.35) * 2
      sample :drum_cymbal_closed, amp: 0.18 + rand(0.12), rate: 1.2
    end
    sleep(i.even? ? 0.25 + sw : 0.25 - sw)
  end
end

live_loop :perc, sync: :beat do
  if has(:perc) || get[:energy] > 0.72
    pat = spread(get[:move] > 0.4 ? 7 : 5, 16).rotate(tick % 4)
    16.times do |i|
      if pat[i]
        sample [:elec_tick, :elec_pop, :elec_blip].choose, amp: 0.28,
          pan: rrand(-0.6, 0.6), rate: [1, 1.5, 2].choose
      end
      sleep 0.25
    end
  else
    sleep 4
  end
end

# ---------- bass ----------

live_loop :bass, sync: :beat do
  r = root_at(tick)
  if has(:bass) && get[:kick] == 1
    use_synth :tb303
    rolling = get[:scene] == 3 || get[:energy] > 0.8
    16.times do |i|
      on = rolling ? (i % 4 != 0) : (i % 4 == 2)
      n = (rolling && i % 8 == 7) ? r + 12 : r
      play n, release: 0.18, cutoff: cutoff(55, 110), res: 0.8, wave: 0, amp: 0.6 if on
      sleep 0.25
    end
  else
    sleep 4
  end
end

# ---------- chords: stabs and pads, through reverb + delay ----------

with_fx :reverb, room: 0.85, mix: 0.2 do |rv|
  with_fx :echo, phase: 0.75, decay: 6, mix: 0 do |ec|
    live_loop :chords, sync: :beat do
      ch = chord_at(tick)
      sp = get[:space]
      control rv, mix: 0.1 + sp * 0.6
      control ec, mix: sp * 0.5
      if has(:pad)
        use_synth :prophet
        play ch, attack: 1.2, sustain: 1.6, release: 1.4, cutoff: cutoff(60, 100), amp: 0.35
        sleep 4
      elsif has(:stabs)
        use_synth :supersaw
        pattern = get[:energy] > 0.55 ? [3, 6, 11, 14] : [2, 10]
        16.times do |i|
          play ch, release: 0.22, cutoff: cutoff(65, 122), amp: 0.22 if pattern.include?(i)
          sleep 0.25
        end
      else
        sleep 4
      end
    end
  end
end
