# Platform — Reminders

Cross-cutting · Milestone M1 · Source: [`../README.md`](../README.md)

### US-803 · Exactly one reminder
As a **Writer**, I want exactly one daily reminder whose base case is a reliable local notification, so that I remember without receiving push spam. [§3, §5.2, §7.4]

- v1: exactly one reminder. **[invariant: §3 scope]** [§3, §4.2]
- Client schedules a local notification at the chosen local time — no server dependency for the base case. [§7.4]
- The server sends a push **only** as fallback: when the device hasn't opened the app for 24 h, from a worker bucketing users by timezone into 15-minute slots. Beyond that single case, no push. **[invariant]** [§7.4]
- Permission prompt lives in onboarding step 3 with a clear "not now"; never nag on later visits. [§5.2, §3.1]
