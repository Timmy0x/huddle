# Huddle — Conversation

### You

Local pickup sports app

---

### 10x

Research is in — Volo and Meetup expose a clear gap: Volo is too league/registration-heavy and Meetup is too generic for sports. Casual players want a fast "what's happening at a court near me in the next few hours" view, not a season registration flow. Let me save the brief and surface the design picker.

---

### 10x

Plan saved. Huddle v1 is a 5-screen, mock-first pickup sports app: Discover (map + list), Game detail with RSVP, one-screen Host, My Games, and Profile — wrapped in a Partiful-style social tone with the Electric Blue palette and a single permission-priming step for location.

---

### You

The plan looks great. Start building the app now.

---

### 10x

Starting with the foundation: theme, models, and entry point.

---

### 10x

Now reusable components: avatar, sport pill, game card, and the discover-specific pieces.

---

### 10x

Now ContentView (tab shell + onboarding gate), then the 5 main screens.

---

### 10x

Huddle v1 is built. 14 files covering all 5 screens plus the location-priming opener.

**Signature moves:**
- **Discover** opens on a list with a horizontally-scrolling Time window strip + sport pills. The card uses a bold gradient sport tile on the left with time stamped over it — not a generic full-width card. Toggle to a map view with custom emoji pins and a snap-scrolling card carousel as the bottom sheet.
- **Game detail** has a gradient hero with an oversized translucent sport emoji, an attendee grid that shows open dotted-circle seats, and a sticky frosted RSVP bar that swaps to green "You're in" once joined.
- **Host** is a single scroll: 6 sections (sport / where / when / crew size / vibe / notes) with a sport-emoji chip grid as the lead control.
- **My Games** uses Today / This week / Later / Past sections with a top stat-tile row.
- **Profile** shows regular spots with the sport emojis the spot supports.
- **Onboarding** is a single permission-priming screen with floating emoji "pins" on a blue gradient — Strava-style.

All RSVP toggles, hosting, and filters are wired through `HuddleStore` (`@Observable`) with realistic NYC seed data (McCarren, West 4th, Pier 6, Prospect, Central Park Reservoir, Astoria). Palette is strictly the Electric Blue tokens — neutrals and tints only, with a single green reserved for the confirmed-RSVP state.

Open the simulator to try it — tap "Turn on location" to get into the app.

---

### You

redo the ui, massively improve it
