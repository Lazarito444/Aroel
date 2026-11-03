# Trust — Privacy

Epic E7 · Milestone M6 · Source: [`../README.md`](../README.md)

### US-702 · Trust the promises on the tin
As a **Writer**, I want a privacy summary that binds the app to what it claims, so that I can verify rather than believe. [§5.14, §8.1]

- No advertising SDKs; third-party analytics limited to crash reports and opt-in funnel events. **[invariant]** [§8.1]
- Staff cannot read entry bodies, ratings or gratitude — support has no such tool. **[invariant, product promise]** [§8.1]
- TLS 1.3 in transit; server-side encryption at rest; strict CORS; per-user row isolation in queries; no secrets in the client. **[invariants, §8.2 + AGENTS.md]**
