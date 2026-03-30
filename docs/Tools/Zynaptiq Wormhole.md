# Zynaptiq Wormhole: Advanced DSP Architecture and Sound Design Reference
Updated March 19th, 2026

This document serves as an advanced, quick-reference cheat sheet for digital signal processing (DSP) and technical sound design using Zynaptiq WORMHOLE.

## 1. DSP Routing Dynamics (The Signal Flow)
By default, audio flows through the Delay, into WARP, and then SHIFT. The routing order of the main modules fundamentally alters the math of the signal chain. 

*   **WARP > SHIFT (Solid & Massive):** The dry audio is broken apart and spectrally inverted, then pitched entirely up or down as a solid block. Best for stable creature design, solid bass modulation, and heavy cinematic impacts.
*   **SHIFT > WARP (Reactive & Glitchy):** Audio is pitched first. Because WARP relies on incoming frequencies to calculate its inversions, feeding it an artificially pitched/shifting signal causes unpredictable tearing and bubbling. Best for glitchy sci-fi textures and malfunctioning energy beams.

## 2. Module Quick Reference

### The WARP Module (Spectral Inversion)
*   **Warp Depth (0-100%):** Dictates spectrum bandwidth. Low values (10-30%) grab only top-end transients (glassy/alien tech). High values (70-100%) process everything (atonal drones).
*   **Warp Tilt:** Shifts spectral features up (CW) or down (CCW). Extreme vertical shifts introduce intentional grit.
*   **Poles:** Adds physical, pipe-like resonance. High values are perfect for droids/mechs but will eat CPU and destroy organic flesh sounds. Keep at 0 for natural sources.
*   **LP Filter (Pre/Post):** `Pre` routing forces WARP to generate gritty, broken artifacts. `Post` routing smooths the output and tames piercing highs.
*   **Discontinuity (Toggle):** Bypasses smoothing to deliberately introduce harsh mathematical artifacts. Crucial for lo-fi, broken transmissions, and bad sample rate conversion textures.

### The SHIFT Module (Pitch & Frequency)
*   **Pitch Algorithms (+/- 48 Semitones):**
    *   `Smooth`: Optimized for phase coherence on sustained audio (vocals, drones, pads).
    *   `Tight`: Transient accurate. Low CPU. Best for impacts, drums, and weapon fire.
    *   `Detune A & B`: Stereo micro-pitching (+/- 48 cents). Shifts L/R channels in opposite directions for massive widening without phase-cancellation.
*   **Frequency Shift (+/- 4000 Hz):** Destroys harmonic relationships.
    *   `Lin` Mode: Linear scaling for radical destruction.
    *   `Map` Mode: Micro-tuning (0.1 Hz increments in the first 25% of travel). Use the **Shift key** while dragging for extreme precision phasing.
*   **Decay Time Slider:** A dynamic gate for shifted harmonics. *Pro-Tip:* Turn this down when pitching down heavy cinematic impacts to truncate muddy sub-bass rumble and save mix headroom.

### Delay, Reverb & FX Blend
*   **Bipolar Delay Line (+/- 500ms):** Positive values delay the wet effect. Negative values delay the *dry* signal (excellent for "pre-verb" reverse-sucks and charge-ups). 
*   **L/R INV:** Inverts the delay time exclusively for the right channel. Pushes the audio out of phase for a psychoacoustically "outside the speakers" Haas effect.
*   **Dual Reverbs:** Two randomized hall reverbs that can be placed Pre-Blend, Post-Blend, or both. Shared Size, Damping, and Mix controls.
*   **Structural Morphing (FX BLEND):**
    *   `X-Fade`: Standard linear volume mix.
    *   `Morph A`: Wraps the dry sound into the structural properties of the *wet* effect. Deeply alien and mutated.
    *   `Morph B`: Maps the effect onto the *dry* signal. Retains physical punch and intelligibility (superior for dialogue and creature vocals).

## 3. Strengths, Weaknesses, and Alternatives

As the tool has aged, WORMHOLE remains unparalleled in specific sound design niches, but it can be outperformed by specialized tools in others.

**Where WORMHOLE Excels (Top Tier)**
*   **Psychic, Alien, and Robotic Vocals:** The glassy, spectral artifacts and structural morphing are perfect for otherworldly intelligence and classic droids.
*   **Magic Auras and Spells:** The structural morphing of infinite reverb tails (`Morph B`) is gorgeous and ethereal.
*   **Sci-Fi UI and Micro-Clicks:** High `WARP` depth combined with short inverted delays adds expensive, high-tech microscopic textures to basic synths.
*   **Subtle Tonal Sweetening:** Using `Detune A/B` with `Morph B` adds wide, phase-coherent stereo shimmer to mix busses without destroying the fundamental tone.

**Where to Reach for Alternatives**
*   **Organic Flesh, Gore, and Realistic Beasts:** WORMHOLE's spectral inversion inherently imparts a synthetic, metallic timbre. **Alternative:** Use Krotos Dehumaniser or standard pitching algorithms (like Elastique) for raw, fleshy creature sounds.
*   **Rhythmic Mechanical Movements:** The plugin lacks internal LFOs or step sequencers for rhythmic chattering. **Alternative:** Tools like Infiltrator 2 or Output Portal are better suited for evolving, sequenced mechanical loops.
*   **Continuous Heavy Loops (e.g., Giant Vehicle Engines):** While it creates great dissonant engine whines via Frequency Shifting, WORMHOLE introduces a noticeable CPU overhead. **Alternative:** A synthesizer like Phase Plant might be a safer, less CPU-intensive choice for continuous looping sound generation.

## 4. The Quick-Reference Application Matrix

| Sound Category | Routing | SHIFT Settings | WARP Settings | Spatial & Blend | Rationale |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Psychic Vocals** | WARP > SHIFT | `Smooth`. Pitch: +7 to +12 st. | Depth: 50%. Tilt: +0.20. LP: `Post`. | `Morph A` at 60%. Post-Reverb. | `Morph A` wraps glassy artifacts tightly to the vocal envelope. |
| **Heavy Impacts** | WARP > SHIFT | `Tight`. Pitch: -24 to -36 st. Decay: 15%. | Depth: 0% (Bypassed). | `X-Fade` at 100%. Neg Delay: -15ms. | Low Decay acts as a dynamic gate to kill sub-mud. Negative delay creates a pre-impact vacuum. |
| **Droid Dialogue** | SHIFT > WARP | Freq Shift: `Map` Mode, +10 Hz. | Depth: 80%. Poles: 80%. | `Morph B` at 80%. Delay: 5ms + `L/R INV`. | High `Poles` add pipe resonance. `Morph B` retains human articulation. `L/R INV` creates wide stereo. |
| **Sci-Fi UI Clicks** | WARP > SHIFT | `Tight`. Pitch: +12 to +24 st. | Depth: 15%. Discontinuity: `ON`. LP: `Pre`. | `X-Fade` at 100% Wet. Pre-Reverb. | `Discontinuity` forces the transient into broken, granular high-end textures. |
| **Plasma Beams** | SHIFT > WARP | Freq Shift: `Lin`, automate sweep from +2k to -500 Hz. | Depth: 100%. Tilt: +0.80. | `Morph A` at 100%. Post-Reverb. | Sweeping the frequency *into* a 100% Warp tears the math apart for bubbling thermal overload. |
| **Magic Auras** | WARP > SHIFT | `Detune B`. | Depth: 30%. Tilt: +0.40. | `Morph B` at 60%. Pre + Post Reverb. | Pushing dual reverbs *through* `Morph B` forces the infinite tail to mimic the original spell's envelope. |
| **Modern Tonal Sweeteners** | N/A (Bypass Warp) | `Detune A/B` Mode. | Depth: 0% (Bypassed). | `Morph B` at 20-30%. Delay: Short offset. | `Detune` cleanly decorrelates the stereo field. `Morph B` structurally glues the newly generated width directly to the dry transient. |

## 5. Application Spotlights & Workflow Chains

This section breaks down the exact DSP rationales for each core workflow, common pitfalls to avoid, and where WORMHOLE sits best within your broader plugin chain.

### Spotlight 1: Psychic / Otherworldly Vocals
*   **Goal:** Create highly intelligible but distinctly alien or telepathic dialogue.
*   **Setup:** Use `WARP > SHIFT` routing. Set SHIFT to `Smooth` mode and pitch up +7 to +12 semitones. Apply 50% Warp Depth with a +0.20 Tilt and a `Post` LP Filter. Set the FX BLEND to `Morph A` at 60%, and add a Post-Blend Reverb. 
*   **Why it works:** The `Smooth` pitch algorithm prioritizes the phase coherence necessary for dialogue. Using `Morph A` structurally wraps the wet signal's glassy, alien artifacts tightly into the dry vocal's envelope. The `Post` filter tames the piercing highs that spectral inversion naturally generates.
*   **⚠️ Pitfalls & Artifacts:** Pushing the `Warp Tilt` too far on organic sources completely destroys intelligibility. The generated highs can also result in painful, harsh sibilance.
*   **🔗 Chain Routing:** Place a fast de-esser or dynamic EQ *before* WORMHOLE to aggressively tame harsh "S" and "T" consonants, as the WARP engine will radically exaggerate them. Follow WORMHOLE with standard vocal compression to glue the morphed artifacts firmly to the dynamic envelope of the actor's performance.

### Spotlight 2: Heavy Cinematic Impacts & Explosions
*   **Goal:** Pitch massive impacts down into the sub-sonic domain without muddying the mix or losing transient punch.
*   **Setup:** Use `WARP > SHIFT` routing. Set SHIFT to `Tight` mode and drop the pitch between -24 and -36 semitones. Lower the Decay Time slider to 15%. Bypass WARP entirely. Set Blend to 100% `X-Fade` and introduce a Negative Delay of -15ms.
*   **Why it works:** `Tight` mode preserves the exact transient alignment of percussive material. By lowering the Decay Time, you discard the elongated, ringing low-frequency components that naturally result from heavy downward pitch-shifting, uncluttering the sub-bass. The negative delay shifts the *dry* signal back 15ms, allowing the processed low-end to bloom a fraction of a second before the primary impact hits.
*   **⚠️ Pitfalls & Artifacts:** Forgetting to lower the Decay Time will generate massive amounts of muddy sub-frequency ringing that consumes your mix headroom.
*   **🔗 Chain Routing:** Place WORMHOLE early in the chain. Follow it immediately with a brickwall peak limiter (like smart:limit) to keep the massive newly generated sub-harmonics from clipping your bus, and apply a multi-band compressor (like OTT) to tighten the tail.

### Spotlight 3: Robotic / Droid Dialogue
*   **Goal:** Replicate classic, physical-sounding droid dialogue with a resonant, "chassis" tone.
*   **Setup:** Route `SHIFT > WARP`. Set Frequency Shift to `Map` Mode at +10 Hz. Push Warp Depth to 80% and Poles to 80%. Set FX BLEND to `Morph B` at 80%. Add a 5ms Delay and engage the `L/R INV` toggle.
*   **Why it works:** Pushing the `Poles` parameter high tightens the harmonics around specific pitches to create a heavily resonant, pipe-like sound. `Morph B` maps this metallic effect directly onto the structural base of the *dry* human voice. Finally, the `L/R INV` delay pushes the left and right channels in opposite directions temporally, creating a super-wide robot voice.
*   **⚠️ Pitfalls & Artifacts:** High values on the `Poles` parameter aggressively consume CPU. Furthermore, the resulting comb-filtered resonances can become ear-piercingly sharp and cause listener fatigue.
*   **🔗 Chain Routing:** Run a resonance suppressor (such as Soothe 2) *after* WORMHOLE to aggressively pull down the harsh, whistling comb-filter peaks while retaining the core metallic robot tone.

### Spotlight 4: Sci-Fi UI & Micro-Clicks
*   **Goal:** Add expensive, high-tech microscopic textures to basic synths or organic click recordings.
*   **Setup:** Use `WARP > SHIFT` routing. Pitch up via `Tight` mode (+12 to +24 st). Use a very low Warp Depth (15%), engage the `Discontinuity` toggle, and set the LP Filter to `Pre`. Use 100% `X-Fade` and a small Pre-Blend Reverb.
*   **Why it works:** A low warp depth restricts the processing strictly to the high frequencies. Activating `Discontinuity` deliberately introduces harsh, mathematical grit. Filtering the audio *Pre*-Warp forces the spectral inverter to generate entirely new, broken artifacts out of a limited frequency band.
*   **⚠️ Pitfalls & Artifacts:** The `Discontinuity` mode naturally generates harsh, tinny aliasing that mimics bad sample rate conversion. If left completely dry, this can sound like a broken audio driver rather than intentional sci-fi design.
*   **🔗 Chain Routing:** Use WORMHOLE on a parallel aux bus. Keep it 100% wet, and feed the result into a clean, short spatial reverb to sit the mathematical artifacts into a 3D physical space, taking the synthetic edge off.

### Spotlight 5: Plasma Beams & Energy Weapons
*   **Goal:** Generate aggressively tearing, bubbling, and unpredictable thermal overload textures.
*   **Setup:** Route `SHIFT > WARP`. Set Frequency Shift to `Lin` (Linear) mode. In your DAW, draw an automation curve that sweeps the frequency violently from +2000 Hz down to -500 Hz. Push Warp Depth to 100% and Tilt to +0.80. Set `Morph A` to 100% with a Post-Blend Reverb.
*   **Why it works:** Because the routing forces the pitch shift to happen *before* the Warp module, the spectral inversion algorithm is constantly fed rapidly shifting mathematical values. Linearly sweeping the frequency into a 100% Warp tears the math apart in real-time, generating a hollow, bubbling overload texture.
*   **⚠️ Pitfalls & Artifacts:** Sweeping the frequency through extreme WARP values causes mathematically violent tearing that can result in unpredictable, extreme volume spikes.
*   **🔗 Chain Routing:** *Mandatory* heavy limiting or aggressive multi-band compression (e.g., OTT or Squash) *after* WORMHOLE to clamp down on the chaotic volume spikes.
*   **🧬 The Double Wormhole Stack:** Try running two instances in serial. Let the first WORMHOLE handle the chaotic `Lin` frequency sweep (100% Wet `X-Fade`). Feed that destruction into a *second* WORMHOLE purely utilizing `Morph B` to structurally glue the bubbling laser chaos back into the clean, punchy transient of the original weapon source.

### Spotlight 6: Ethereal Magic Spells & Auras
*   **Goal:** Give a punchy, organic magic burst a gorgeous, mutating aura that reacts dynamically to the blast.
*   **Setup:** Use `WARP > SHIFT` routing. Select `Detune B` mode. Set Warp Depth to 30% and Tilt to +0.40. Push the FX BLEND to `Morph B` at 60%, and engage *both* the Pre-Blend and Post-Blend Reverbs.
*   **Why it works:** `Detune B` shifts the left and right channels in opposite directions for lush thickening. Pushing a huge Pre-Blend reverb tail *through* the `Morph B` circuit forces the infinite, randomized hall tail to structurally mimic the physical amplitude envelope of the dry transient.
*   **⚠️ Pitfalls & Artifacts:** Morphing the dry transient to an infinite reverb tail can cause low-mid frequencies to build up infinitely, resulting in a muddy, washed-out mix.
*   **🔗 Chain Routing:** Place an EQ *before* WORMHOLE to aggressively cut the low-mids of the source material. Follow WORMHOLE with a creative distortion unit (like Output Thermal or Noise Engineering Ruina) to add a sizzling, aggressive top-end crust to the ethereal tail without dirtying the low end.

### Spotlight 7: Modern Tonal Sweeteners
*   **Goal:** Expand a basic synth pluck, bell, or dry guitar into a wide, rich stereo image without destroying its fundamental tonal integrity.
*   **Setup:** Use `Detune A` or `Detune B` mode. Bypass the WARP module completely. Set FX BLEND to `Morph B` at roughly 30%.
*   **Why it works:** The Detune algorithms decorrelate the stereo field cleanly without the sweeping, cyclical wobble inherent to standard chorus LFOs. Using `Morph B` ensures this subtle widening is mathematically tied to the original dry transient's envelope.
*   **⚠️ Pitfalls & Artifacts:** Accidentally engaging the WARP module or shifting the core pitch (even slightly) will introduce inharmonic, metallic artifacts that instantly ruin the "expensive" musical tone.
*   **🔗 Chain Routing:** Place WORMHOLE *first* in your sweetener chain as a "width and shimmer" generator. Because the micro-pitching decorrelates the stereo field so cleanly, running this output into downstream saturation or compression (like Decapitator or an LA-2A) will beautifully glue the massive width together into a single, hyper-real instrument.