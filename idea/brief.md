## Huddle — Pickup Sports, Locally

A local pickup sports app for casual weekend players. v1 is about **discovering a game near you happening today** and **tapping "I'm in" in under 10 seconds** — not league registration.

### Core Driver
Belongingness + curiosity ("who's playing at the park right now?"), with light esteem via "regular at this spot" status.

### Target User
Casual players in their 20s-40s, multi-sport (basketball-heavy, plus pickleball, soccer, volleyball, run clubs). Friendly, energetic, not corporate.

### Core Action & North Star
- **Core action:** Tap a nearby game → RSVP "I'm in" in seconds.
- **North star:** Games joined per active user per week.

### Virality
- Share a game card via iMessage / Instagram.
- Attendee avatars + "X regulars going" on every card.

## v1 Scope

### Screens (5)
1. **Discover** — Map + list toggle, filter by sport / distance / time.
2. **Game detail** — RSVP, attendees, location, share.
3. **Host** — Sport / spot / time / max players / skill (one screen).
4. **My Games** — Today / This week / Later / Past.
5. **Profile** — Sports, skill, games attended, regular spots.

### Onboarding
High-converting multi-step quiz: welcome → sports multi-select → skill → frequency → neighborhood → social proof → notifications priming → location priming → analyzing → personalized reveal → name capture. Quiz answers wire into the store (selected sports become the default Discover filter).

### In scope
- Browse + RSVP to nearby pickup games (NYC mock data).
- Host a game (sport, spot, time, max players, skill).
- Map view with pins + draggable bottom-sheet list.
- Filters by sport, distance, time window.
- iOS share sheet on game cards.
- Attendee list with avatars + regulars badge.

### Non-goals (v1)
League/season management, in-app chat, skill matching algorithms, payments, real-time GPS check-in, friend graph, auth, push notifications.

### Data stance
Mock-first. Realistic seeded games, spots, and users across NYC. No backend, no auth.

## Selected Design System

- **Reference:** Partiful — playful, social, bold accent, emoji-friendly, casual.
- **Catalog seed:** Social Native (`social-native`).
- **Palette:** Court Orange
  - primary `#111827`
  - accent `#F26B1F`
  - background `#FAFAF7`
  - surface `#FFFFFF`
  - text `#111827`
- **Trade-off:** Partiful's social/event energy fits the pickup vibe. Court Orange keeps it warm and athletic without leaning into the green "fitness app" cliché. Accent is reserved for primary CTAs (RSVP, Host) + active pins; neutrals carry the rest so content leads.

## Pre-Build Confirmation

Ready to build v1 as a mock-first iOS app:
- 5 main screens (Discover, Game detail, Host, My Games, Profile) + 11-step high-converting onboarding flow.
- NYC seed data: McCarren, West 4th, Pier 6, Prospect, Central Park Reservoir, Astoria.
- Court Orange palette + Partiful-inspired Social Native styling.
- No backend, no auth, no payments. All RSVP/host/filter state via `HuddleStore` (`@Observable`).