## Huddle — Pickup Sports, Locally

A local pickup sports app for casual weekend players. The first version focuses on **discovering a game near you happening today** and **tapping "I'm in" in under 10 seconds** — not league registration.

### Core Driver
Belongingness + curiosity ("who's playing at the park right now?"), with light esteem via "regular at this spot" status as users attend more games.

### Target User
Casual players in their 20s-40s, multi-sport (basketball-heavy, plus pickleball, soccer, volleyball, run clubs). Friendly and energetic tone, not a corporate league app.

### Core Action & North Star
- **Core action:** Tap a nearby game → RSVP "I'm in" in seconds.
- **North star:** Games joined per active user per week.

### Virality
- Share a game card via iMessage / Instagram ("3v3 at McCarren Park, 6pm — come thru").
- Attendee avatars + "X regulars going" on each card for social proof.

## Research Snapshot

- **Volo Sports** (2.6★) — Too league-heavy, registration-driven, "not social enough." Confirms the gap.
- **Meetup** (4.7★) — Great event-RSVP pattern but generic and bloated. Mirror the event-card model, skip the group infrastructure.
- **Strava / AllTrails** (adjacent) — Nail the map + list toggle and "regulars at this place" framing. Borrow both.

### UX patterns to mirror
- **Discover:** Strava/AllTrails-style map with a draggable bottom sheet of today's games.
- **Game detail:** Meetup-style event page — hero photo, time/location, host, attendee grid, sticky "I'm in" CTA, share.
- **Host a game:** Apple Calendar-style quick create — 4 fields, one screen.
- **My Games:** Things 3-style grouped list (Today / This week / Past).
- **Spot profile:** AllTrails-style "regulars" leaderboard + recurring game patterns.
- **Tone:** Partiful-style playful event cards — emoji-friendly, bold accent on RSVP, casual copy.

## v1 Scope

### Screens (5)
1. **Discover** — Map + list toggle, filter by sport / distance / time.
2. **Game detail** — RSVP, attendees, location, share.
3. **Host** — Sport / spot / time / max players / skill (one screen).
4. **My Games** — Upcoming + past RSVPs.
5. **Profile** — Sports, default skill level, games attended, regular spots.

### In scope
- Browse and RSVP to nearby pickup games (seeded mock data, NYC anchor city).
- Host a game with sport, spot, time, max players, skill level.
- Map view with pins + draggable bottom sheet list.
- Filter by sport, distance, time window.
- iOS share sheet on game cards.
- Attendee list with avatars and "regulars" badge.

### Non-goals (v1)
- League / season management.
- In-app chat / DMs.
- Skill matching algorithms beyond a manual tag.
- Payments / paid games.
- Real-time GPS check-in.
- Friend graph beyond viewing attendee profiles.

### Data model (sketch)
- `Game`: id, sport, spotId, startTime, durationMin, maxPlayers, skillLevel, hostId, notes, attendeeIds[]
- `Spot`: id, name, coordinate, sports[], photoURL, regularUserIds[]
- `User`: id, name, avatar, sports[], skillLevel, attendedGameIds[]

### Onboarding
- **Permission priming** before the OS location prompt — one custom screen explaining why Huddle needs location ("show games near you today"). Strava/AllTrails pattern.
- No account required in v1. Local profile only.

## Pre-Build Confirmation

### Selected design system
- **Reference:** Partiful — playful, social, bold accent, emoji-friendly, casual.
- **Palette:** Electric Blue
  - primary `#0B1220`
  - accent `#2563EB`
  - background `#FFFFFF`
  - surface `#F4F7FB`
  - text `#0B1220`
- **Catalog seed:** Social Native (`social-native`).
- **Trade-off:** Partiful's social/event energy fits the pickup vibe better than a clinical sports-utility look. The Electric Blue palette keeps it sporty and confident without leaning into the green/orange "fitness app" cliché. Accent is reserved for primary CTAs (RSVP, Host) and active state pins on the map — neutral surfaces carry everything else so the content (game cards, attendee photos, spot imagery) leads.

### Onboarding
- **Permission priming** (location) → straight into Discover. No carousel, no signup wall in v1.

### Data stance
- Mock-first. Realistic seeded games, spots, and users across one anchor city (NYC). No backend, no auth, no payments in v1.

### First screens to build (in order)
1. Discover (map + bottom-sheet list)
2. Game detail (RSVP + attendees + share)
3. Host a Game (one-screen quick create)
4. My Games
5. Profile + Spot profile

### Explicit exclusions for v1
League management, chat, real-time check-in, payments, recommendation algorithms, auth, push notifications.