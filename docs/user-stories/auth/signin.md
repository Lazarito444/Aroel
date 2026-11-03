# Auth — Sign in & sessions

Epic E1 · Milestone M1 · Source: [`../README.md`](../README.md)

### US-101 · Sign up with email
As a **Writer**, I want to create an account with email and password, so that I can sync my journal across devices. [§5.1]

- Password minimum 10 characters, no composition rules. [§5.1]
- Email verification is required **before the first sync but not before writing** — the app is fully usable offline immediately after signup, with zero account interaction. **[invariant]** [§5.1]
- Payload is hashed with Argon2id; no password rules messages beyond the length check. [§7.2, §8.2]

### US-102 · Sign in with Apple or Google
As a **Writer**, I want to sign in with one tap on a provider button, so that I don't manage another password. [§5.1]

- Provider buttons sit above an "or use email" disclosure. [§5.1]
- Acceptance: sign-in completes in ≤ 2 taps for Apple/Google. **[screen bracket]** [§5.1]
- OIDC tokens are validated server-side; identities link to the same user across providers. [§7.2]

### US-103 · Sessions survive devices and theft of tokens
As a **Writer**, I want my signed-in state to be secure and long-lived, so that I don't have to re-authenticate constantly but can't be impersonated. [§7.2]

- Access token lives 15 minutes; refresh token rotates every use and expires at 60 days. **[invariant]** [§7.2]
- Reuse of a rotated refresh token revokes the whole family (reuse detection). [§7.2]
- Auth endpoints rate-limited at 5/min. **[invariant]** [§7.2]
