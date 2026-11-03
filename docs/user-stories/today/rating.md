# Today — Rate today

Epic E2 · Milestone M3 · Source: [`../README.md`](../README.md)
Ramp and anchors are literal spec — see also [`journal/day-record.md`](../journal/day-record.md).

### US-203 · Rate today in four seconds
As a **Writer**, I want to rate today on an eleven-stop track in one tap, with the value named as I choose it, so that closing even a day I have no words for is worth it. [§5.3, §6.6]

- Track: eleven half-step stops, hairline 1 px in `border`, selected stop 20 px filled with the ramp colour at that value, ringed in `paper`; labels "bottom" and "good day" at ends; current value named (`4.0 · good`). [§5.3, §6.6]
- One tap sets the rating; **a second tap on the same value clears it** (rating returns to unrated/NULL). [§5.3]
- Anchors shown on first use, on long-press, and in the accessibility label. **[invariant]** [§4.5]
- Light haptic on tap. [§6.4]
- Rating persists and re-renders in < 30 ms after tap. **[screen bracket]** [§5.3]
- Available from Today at any hour, not gated behind the session. **[invariant]** [§2.2]
- Hit target per stop is at least the full 1/11 segment; degrades to a 44 pt slider under 320 dp. [§6.6]
