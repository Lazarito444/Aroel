# Auth — Account management

Epic E1 · Milestone M1 (account) / M6 (deletion) · Source: [`../README.md`](../README.md)

### US-105 · Manage my account
As a **Writer**, I want to see my email, change my password, and sign out, so that my account stays mine. [§5.14]

- Settings → Account holds email, password change, sign out, delete account. [§5.14]
- `GET/PATCH /me` backed; display name and timezone editable. [§4.2, §7.2]

### US-106 · Delete everything
As a **Writer**, I want to delete my account in two steps knowing it actually deletes, so that leaving is one flow and not a dark pattern. [§5.14, §8.1]

- Two confirmed steps; local data is wiped immediately; server data wiped within 24 h; the screen states both plainly. **[spec is literal about the wording: "states this plainly"]** [§5.14]
- Deletion must be real: no "deactivated" accounts. **[invariant]** [§8.2]
