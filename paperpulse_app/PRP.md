# PaperPulse — Product Requirements Document

**Version:** 1.0 | **Platform:** Flutter (iOS & Android) | **Stage:** MVP Sprint

> _"Read the research. Feed the curiosity."_

---

## Table of Contents

1. [Product Vision](#1-product-vision)
2. [Target Audience](#2-target-audience)
3. [Design Language & Visual Identity](#3-design-language--visual-identity)
4. [Information Architecture](#4-information-architecture)
5. [Screen-by-Screen Requirements](#5-screen-by-screen-requirements)
6. [The Curiosity Card — Core Component](#6-the-curiosity-card--core-component)
7. [Shareable Paper Card — Signature Feature](#7-shareable-paper-card--signature-feature)
8. [Engagement & Habit Features](#8-engagement--habit-features)
9. [Freemium Feature Matrix](#9-freemium-feature-matrix)
10. [Curation & AI Pipeline](#10-curation--ai-pipeline)
11. [Technical Architecture](#11-technical-architecture)
12. [MVP Roadmap](#12-mvp-roadmap)
13. [Success Metrics](#13-success-metrics)

---

## 1. Product Vision

PaperPulse is a Flutter mobile application that turns academic paper discovery into a daily reading habit. It delivers beautifully curated, curiosity-first summaries of the latest research papers — matched to each user's interest profile — and entices them to read the full paper.

**The core promise:** Every summary feels like the opening page of a great book, not an abstract. Users should finish each card _wanting more_.

### What PaperPulse is NOT

- Not a paper repository or search engine (that's Google Scholar)
- Not an academic tool with dense UI (that's ResearchGate)
- Not a generic RSS reader — every piece of content is intentionally curated and editorially voiced

---

## 2. Target Audience

| Persona                          | Description                                      | Primary Need                                 |
| -------------------------------- | ------------------------------------------------ | -------------------------------------------- |
| 🎓 **The Grad Student**          | Staying current without drowning in literature   | Efficient discovery, relevant to their field |
| 🔬 **The Researcher**            | Peripheral reading outside their core literature | Cross-discipline inspiration                 |
| 🏢 **The Industry Professional** | Tracking emerging ideas for applied use          | Accessible summaries, no jargon              |
| 🌍 **The Curious Explorer**      | Intellectually restless non-expert               | Warmth, accessibility, wonder                |

---

## 3. Design Language & Visual Identity

> **Aesthetic Direction:** _Editorial warmth meets academic credibility._ Think The Atlantic's digital experience crossed with Readwise Reader — but warmer, more approachable, and with a clear typographic personality. Data-dense where needed, but never cluttered.

The design references provided show three key qualities to capture:

- **From the design system (Image 1):** Soft, pastel accent palette; clean typographic hierarchy with Instrument Sans as primary; generous whitespace; minimal linear iconography
- **From the book app (Image 2):** Bold, large editorial typography on dark cards; layered depth; strong color-blocked visual identity; title as hero element
- **From the community app (Image 3):** Warm off-white background; hand-drawn/organic accents; clean list UI with illustrated icons; approachable and conversational in tone

### 3.1 Color Palette

```
Primary Base
  Paper White:   #F7F4EE   — App background. Warm, not sterile.
  Ink Black:     #1A1A1A   — Primary text, dark cards, nav bar

Accent (Soft Pastels — inspired by Image 1)
  Sage Green:    #B2C9AD   — Primary brand accent. Tags, highlights, CTAs.
  Sage Light:    #E4EDE2   — Chip backgrounds, card tints
  Sage Dark:     #4A7C59   — Text on sage backgrounds, active states
  Morning Haze:  #FFF8E8   — Secondary warm background (onboarding, callouts)
  Cherry Blossom:#F5D6D6   — Error states, alerts, destructive actions
  Quiet Sky:     #C8DFF0   — Info states, link previews

Secondary
  Dark Gray:     #3A3A3A   — Body text
  Mid Gray:      #7A7A7A   — Subtext, labels, metadata
  Light Gray:    #D4D0C8   — Dividers, borders, inactive states
```

**Palette rules:**

- Ink Black + Paper White is the primary pairing for all reading surfaces
- Sage Green is the _only_ color used for CTAs and primary actions
- Pastels are accents only — never dominant, always supporting
- Dark cards (Ink Black background) are reserved for the Curiosity Card and Share Cards to make them feel premium and distinct

### 3.2 Typography

**Primary Typeface: Instrument Serif**
Used for all display text, card titles, section headers, and the app wordmark. The serif signals editorial credibility and warmth simultaneously.

```
Display / App Name:   Instrument Serif · 48–72px · Italic variant for emphasis
Heading 1 (Screen):  Instrument Serif · 32px · Regular
Heading 2 (Card):    Instrument Serif · 24px · Regular
Card Title:          Instrument Serif · 20–22px · Regular
Pull Quote / Hook:   Instrument Serif · 16–18px · Italic
```

**Secondary Typeface: Geist**
Used for all UI chrome, labels, body copy, metadata, and navigation. Its geometric neutrality balances the personality of Instrument Serif.

```
Body Text:       Geist · 15px · Regular · Line height 1.7
UI Labels:       Geist · 13px · Medium
Buttons:         Geist · 14px · SemiBold
Metadata:        Geist · 12px · Regular · color: Mid Gray
```

**Monospace: Geist Mono**
Used sparingly for tags, version labels, API identifiers, and streak numbers. Adds a subtle technical credential to the reading-app feel.

```
Tags / Chips:    Geist Mono · 10–11px · All caps · Letter spacing 0.1em
Streak Counter:  Geist Mono · 14px · Medium
```

### 3.3 Spacing & Shape

- **Border radius:** Cards use `16px`, chips use `100px` (fully rounded), modals use `24px`
- **Card shadow:** `0 8px 32px rgba(0,0,0,0.08)` — soft, not dramatic
- **Spacing scale:** 8px base unit. Common values: 8, 16, 24, 32, 48, 64
- **Content margins:** 20px horizontal on all screens

### 3.4 Iconography

Use **linear (outline) icons** throughout the UI — consistent with the minimal, editorial aesthetic from Image 1. Icons should be 20×20px at 1.5px stroke weight. Only use filled/bold icons for active navigation states.

### 3.5 Motion Principles

- **Card transitions:** Smooth spring physics (300ms, slight overshoot) — never instant, never sluggish
- **Page transitions:** Slide up for modals, slide right for back navigation, fade for tab switches
- **Micro-interactions:** Bookmark icon does a small bounce on tap; streak number ticks up with a subtle count animation
- **Skeleton loaders:** Always show before content loads — never a spinner alone
- **Swipe gestures:** Swipe right to bookmark (with haptic feedback + sage green flash), swipe left to skip (subtle gray flash)

---

## 4. Information Architecture

```
PaperPulse
├── Onboarding (first launch only)
│   ├── Splash / Tagline
│   ├── Interest Picker
│   ├── Digest Schedule Preference
│   ├── Sample Cards Preview  ← value before registration
│   └── Account Creation
│
└── Main App (Bottom Nav — 4 tabs)
    ├── 📬 Digest      — Weekly curated digest, hero experience
    ├── 🔍 Browse      — Infinite scroll feed with topic filters
    ├── 🔖 Library     — Bookmarks, reading queue, highlights
    └── 👤 Profile     — Streak, stats, interests, settings
```

---

## 5. Screen-by-Screen Requirements

### 5.1 Onboarding Flow

**Principle: Show value before asking for commitment.**
The user sees actual paper cards before they create an account.

#### Screen O1 — Splash

- Full-screen Paper White background
- App wordmark centered: `Paper` in Ink Black + `Pulse` in Sage Green, Instrument Serif, 64px
- Tagline below: _"Read the research. Feed the curiosity."_ — Geist, 16px, Mid Gray, italic
- Auto-advances after 2 seconds or on tap
- Subtle fade-in animation (400ms)

#### Screen O2 — Interest Picker

- Header: "What moves you?" — Instrument Serif, 32px
- Subheader: "Pick at least 3 topics. We'll curate your first digest." — Geist, 15px, Mid Gray
- **Topic tiles grid:** 2-column grid of rounded cards. Each tile has:
  - A small linear icon representing the field
  - Topic name in Geist SemiBold, 14px
  - Unselected: white background, Light Gray border
  - Selected: Sage Light background, Sage Dark border, sage checkmark in corner
  - Selection triggers a subtle scale animation (1.0 → 1.03 → 1.0)
- Suggested topics: Machine Learning, Neuroscience, Climate Science, Physics, Economics, Biology, Computer Vision, Linguistics, Materials Science, Psychology, Robotics, Astronomy
- Sticky CTA at bottom: "Build My Digest →" — disabled until 3+ selections
- **Do NOT use a list.** Tiles only. The visual format matters.

#### Screen O3 — Digest Schedule

- Header: "When do you read?" — Instrument Serif, 32px
- Two toggle groups:
  - **Day:** Mon / Wed / Fri (segmented control, Sage Green active state)
  - **Time:** Morning (8am) / Evening (7pm)
- Friendly confirmation text updates live: _"Your digest lands every Monday morning."_ — Geist Mono, 12px, Sage Dark
- Secondary: "You can always change this in settings"

#### Screen O4 — Sample Cards Preview

- Header: "Here's a taste" — Instrument Serif, 32px
- Show 2 fully rendered Curiosity Cards (non-interactive, real content)
- Cards are slightly stacked/fanned behind each other to show depth
- Soft label above: "Real papers. Real curiosity." — Geist, 13px, Mid Gray
- CTA: "This is my kind of reading →"
- This screen should make the user feel the product before creating an account

#### Screen O5 — Account Creation

- Minimal: Email field + password, or "Continue with Google"
- Header: "Last step." — Instrument Serif, 32px
- Subheader: "Create your account to save your digest." — Geist, 15px
- No dark patterns. No lengthy T&C in the flow.

---

### 5.2 Digest Screen (Tab 1) — Hero Experience

The Digest is the flagship screen. It should feel like opening a beautifully curated weekly magazine.

#### Layout

- **Top bar:**
  - Left: App wordmark — `Paper`_`Pulse`_ in Instrument Serif, 22px
  - Right: Streak badge — `🔥 12-day streak` in Geist Mono, 11px, Sage Dark on Sage Light background, rounded pill
- **Digest header section:**
  - Date stamp: `MONDAY DIGEST · FEB 17` — Geist Mono, 10px, Mid Gray, all caps
  - Title: `This Week in Research` — Instrument Serif, 28px, Ink Black
  - Sub: `6 papers curated for your interests` — Geist, 13px, Mid Gray
- **Paper cards:** Vertical stack, one card per paper (see §6 for card spec)
- **Empty state (mid-week):** Show a warm illustration + "Your next digest lands Monday morning. Browse in the meantime →"

#### Swipe Behavior

- **Swipe right:** Bookmark (sage green flash + haptic)
- **Swipe left:** Skip/dismiss
- **Tap:** Expand to full card detail view
- Cards stack behind each other with subtle parallax depth — the next card peeks 24px below the current one

---

### 5.3 Browse Screen (Tab 2)

Infinite scroll discovery feed, always available.

#### Layout

- **Header:** `Browse` — Instrument Serif, 32px
- **Search bar:** Rounded, Geist, placeholder: _"Search topics, authors, keywords..."_
- **Filter chips (horizontal scroll):** Topic filters as rounded pills
  - All · Machine Learning · Neuroscience · Climate · Physics · + more
  - Active chip: Ink Black background, Paper White text
  - Inactive: Sage Light background, Sage Dark text, Sage border
- **Feed:** List of Browse Cards (compact version of Curiosity Card — see §6.2)
- **Free tier gate:** After 10 papers/month, show a soft paywall banner at the bottom of the list (not a full-screen block)

#### Sort Options

- Latest · Most Cited · Trending · Recommended (default)

---

### 5.4 Library Screen (Tab 3)

Personal knowledge base. Where saved papers live.

#### Layout

- **Header:** `Library` — Instrument Serif, 32px
- **Tabs (segmented):** Unread · In Progress · Finished
- **Paper list items:**
  - Each item shows: Topic tag chip, paper title (Instrument Serif, 16px), author + source, estimated read time for full paper
  - Swipe left on item to remove bookmark
  - Tap to open full Curiosity Card
- **Highlights sub-section (Pro):** Below the reading list, a "Your Highlights" section shows pulled quotes from papers the user annotated, in a card format with the paper title

---

### 5.5 Profile Screen (Tab 4)

Personal stats and settings. Should feel rewarding to visit, not bureaucratic.

#### Layout

- **Profile header:** Dark background (Ink Black) with:
  - Avatar circle (initials if no photo)
  - Name + join date
  - Streak display: large streak number in Instrument Serif + `DAY STREAK` label in Geist Mono
- **Stats row (3 columns):**
  - Papers Read · Topics Explored · Highlights Made
  - Numbers in Instrument Serif, 28px; labels in Geist Mono, 9px
- **Interest radar / topic breakdown (Pro):**
  - Simple horizontal bar chart showing top 5 topics by papers read
  - Bars in Sage Green gradient
- **Settings sections:**
  - Digest Schedule · Interest Topics · Notifications · Account · Pro Subscription
  - Clean list rows, no clutter

---

### 5.6 Paper Detail View (Modal)

Opens when user taps any Curiosity Card.

#### Layout

- Slides up as a bottom sheet modal (not a new page)
- **Drag handle** at top center
- **Full Curiosity Card** at top (dark card style)
- Below the card:
  - "About this paper" section: journal, publication date, citation count (from Semantic Scholar)
  - "Authors" section: author names + institutions as chips
  - **"Read Full Paper →"** button: Full-width, Sage Green, prominent — this is the primary conversion action
  - **Related papers** section (horizontal scroll of compact cards): "You might also like"
- **Highlight tool (Pro):** When in this view, user can tap-and-hold on text in the synopsis to highlight

---

## 6. The Curiosity Card — Core Component

> The Curiosity Card is the atomic unit of the entire product. Every design, interaction, and copy decision should serve this component.

### 6.1 Full Curiosity Card (Digest View)

**Philosophy:** This is a book blurb, not an abstract. It opens a loop; it does not close one. The copy must end with a question — implicit or explicit — that only the full paper can answer.

**Visual structure (top to bottom):**

```
┌─────────────────────────────────────────┐
│  [TOPIC TAG]              [SOURCE BADGE] │  ← Row: tag chip left, arxiv/IEEE badge right
│                                         │
│  Paper Title Goes Here in              │  ← Instrument Serif · 20px · 2 lines max
│  Large Editorial Type                  │
│                                         │
│  Author Name · Institution             │  ← Geist · 12px · Mid Gray
│                                         │
│  The curiosity hook goes here. This is  │  ← Geist · 14px · line-height 1.7
│  150-200 words of warm, editorial copy  │     Ends on an open question or revelation
│  that reads like the first page of a   │     that makes you need to read more.
│  great piece of science journalism...   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │   Read Full Paper  →            │   │  ← Sage Green CTA button · Geist SemiBold
│  └─────────────────────────────────┘   │
│                                         │
│  [🔖 Save]  [✏️ Highlight]  [↗ Share]  │  ← Action row · Geist · 13px · Mid Gray
└─────────────────────────────────────────┘
```

**Card styling:**

- Background: **Ink Black** (`#1A1A1A`)
- Card text: Paper White (`#F7F4EE`)
- Topic tag: Sage Light background, Sage Green text, Sage border — Geist Mono, 10px, all caps
- Source badge (arXiv / IEEE / etc.): subtle outline pill, Mid Gray
- CTA button: Sage Green background, Ink Black text, 12px border-radius
- Card border-radius: `16px`
- Padding: `24px`

### 6.2 Compact Browse Card (Browse & Library Views)

Smaller version for list contexts:

```
┌─────────────────────────────────────────┐
│  [TOPIC TAG]                      [→]   │
│  Paper Title in Instrument Serif        │
│  Author · arXiv · 3 min read           │
└─────────────────────────────────────────┘
```

- White background, Light Gray border, 12px radius
- No synopsis shown — tap to expand to full card

### 6.3 Copy Guidelines for Curiosity Hook

The AI pipeline must generate summaries following these rules:

- **Tone:** Science journalist, not academic. Warm, curious, accessible.
- **Length:** 150–200 words. No more.
- **Structure:** What did they find → Why it's surprising → What it means → Open question
- **Ending:** Must close on an open loop — a question, a tension, an implication not yet resolved
- **Forbidden words:** "novel", "robust", "utilize", "leverage", "herein", "aforementioned"
- **Voice:** Third person, present tense for findings, past tense for methodology
- **Example closing line:** _"But the data raises an uncomfortable question: if the model learned this without being told to, what else has it learned that we haven't thought to check for?"_

---

## 7. Shareable Paper Card — Signature Feature

> This is PaperPulse's most viral mechanic and primary organic growth engine. Treat it with the same design care as the core product.

### 7.1 Purpose

Users can export any paper as a beautiful, standalone image card optimized for:

- Instagram Stories (9:16)
- Twitter/X posts (4:5 or square)
- WhatsApp image shares

### 7.2 Card Design Spec

**Dimensions:** 1080×1920px for Stories; 1080×1350px for feed

**Visual elements (top to bottom):**

```
┌─────────────────────────────────────┐
│  [arXiv]              PaperPulse   │  ← Source badge left · wordmark right (subtle)
│                                     │
│  ┌─────────────────┐               │
│  │  MACHINE        │               │  ← Topic tag — Geist Mono, large, all caps
│  │  LEARNING       │               │     Color-blocked left panel or pill chip
│  └─────────────────┘               │
│                                     │
│  The Paper Title                    │  ← Instrument Serif · 36–48px · 3 lines max
│  In Large Editorial                 │
│  Type Here                          │
│                                     │
│  ─────────────────────────────     │  ← Thin Sage divider line
│                                     │
│  "The one-sentence hook that        │  ← Instrument Serif Italic · 18px
│   makes you stop scrolling."       │     Left border in Sage Green (4px)
│                                     │
│  ─────────────────────────────     │
│                                     │
│  Author Name et al.  · 2025        │  ← Geist Mono · 12px · Mid Gray
│                                     │
│                    [QR CODE]        │  ← Links directly to full paper
└─────────────────────────────────────┘
```

**Background options (user can choose):**

1. **Dark (Default):** Ink Black background — premium, editorial
2. **Light:** Paper White background with subtle grain texture
3. **Sage:** Sage Light background with Ink Black text

**Free tier:** Includes `paperpulse.app` watermark in bottom corner, small but visible
**Pro tier:** Clean card, no watermark

### 7.3 Share Flow UX

1. User taps Share icon on any Curiosity Card
2. Bottom sheet slides up showing card preview + 3 color options
3. "Download" saves to camera roll; "Share" opens native share sheet
4. Copy to clipboard option for the paper URL

### 7.4 Implementation Note (Flutter)

Use `RepaintBoundary` widget wrapped around the card widget. Capture via `RenderRepaintBoundary.toImage()` at 3x pixel ratio for high-DPI quality. Export as PNG.

---

## 8. Engagement & Habit Features

### 8.1 Reading Streak

**Goal:** Build the daily opening habit. Make not opening the app feel like a small loss.

- Visible streak counter on Profile screen and subtly in Digest header
- Streak increments when user opens and reads at least one card per day
- **Streak Shield:** One free miss per week — users get a "shield" that auto-applies when they break their streak. Prevents the "I missed one day so why bother" dropout
- Week 1, 4, 8, 12 milestones: unlock a cosmetic badge shown subtly on profile
- Streak counter uses Geist Mono typeface, large, with a small flame icon (linear, not emoji)
- On streak milestone days, a small congratulatory animation plays when opening the app (confetti or a gentle expanding ring — subtle, not Duolingo-loud)

### 8.2 Reading Stats (Pro)

- Papers read this week / month
- Topics distribution (horizontal bar chart, Sage Green)
- Reading streak history (calendar view, similar to GitHub contribution graph)
- Most read topic, most saved author
- "Your reading equivalent" fun stat: e.g., "You've read the equivalent of 3 research papers this month"

### 8.3 Bookmarks & Reading Queue

- Unread / In Progress / Finished tabs in Library
- One-tap bookmark from any card (swipe right or tap bookmark icon)
- Estimated full paper read time shown on each saved item (calculated from PDF page count via Semantic Scholar metadata)
- Bookmarks sync across devices via Supabase

### 8.4 Highlights & Annotations (Pro)

- In the Paper Detail view, users can tap-hold on synopsis text to highlight
- Highlighted text is stored with the paper reference in Supabase
- All highlights are collectable in the Library → Highlights tab
- Exportable as a plain text summary (copy to clipboard)
- Highlight color: Sage Green, 40% opacity background

---

## 9. Freemium Feature Matrix

| Feature                     | Free                  | Pro ($4.99/mo or $39.99/yr) |
| --------------------------- | --------------------- | --------------------------- |
| Weekly Digest (6–8 papers)  | ✅ Full               | ✅ Full                     |
| Daily Drop (1–2 papers/day) | ❌                    | ✅                          |
| Browse Feed                 | ✅ 10 papers/month    | ✅ Unlimited                |
| Interest Profile            | ✅ Up to 3 topics     | ✅ Unlimited topics         |
| Bookmarks                   | ✅ Up to 20           | ✅ Unlimited                |
| Highlight & Annotate        | ❌                    | ✅                          |
| Shareable Paper Cards       | ✅ With watermark     | ✅ Clean (no watermark)     |
| Community Submission        | ✅ 1/week             | ✅ Unlimited                |
| Reading Streak              | ✅ Basic              | ✅ Full with shields        |
| Stats Dashboard             | ✅ Basic (count only) | ✅ Full charts + history    |
| Full Paper Link             | ✅ Always             | ✅ Always                   |

### Paywall Placement Rules

Paywalls must feel **earned**, not forced. Trigger only at natural friction points:

1. **Browse gate:** When free user hits paper #11 in a month → soft banner at bottom of feed (not a full-screen block)
2. **Highlight gate:** First time user tries to highlight → modal showing the feature with 7-day free trial CTA
3. **Share card gate:** After generating first (watermarked) card → show the clean version with "Upgrade to remove watermark"
4. **Daily drop gate:** Show Daily Drop section header in Digest but blur cards behind it with "Pro" chip

---

## 10. Curation & AI Pipeline

### 10.1 Paper Sources

| Source                    | API                             | Content Type                                |
| ------------------------- | ------------------------------- | ------------------------------------------- |
| **arXiv**                 | arXiv API (free)                | Preprints: CS, Physics, Math, Biology, Econ |
| **Semantic Scholar**      | S2 API (free)                   | Citation data, influence scores, embeddings |
| **IEEE / ACM**            | Open-access subset only for MVP | Engineering, CS journals                    |
| **Community Submissions** | In-app URL submission           | User-submitted papers (reviewed)            |

### 10.2 Automated Pipeline (Weekly Cron Job)

```
1. FETCH
   └── Pull papers from arXiv, Semantic Scholar
       Filters: Published in last 7 days, citation velocity > threshold

2. SCORE
   └── Rank by relevance to topic clusters
       Use Semantic Scholar embeddings or cosine similarity against user interest vectors

3. SUMMARIZE
   └── Pass top candidates to Claude API (claude-haiku-4-5 for cost)
       Prompt: Curiosity Hook format (see §6.3 copy guidelines)
       Temperature: 0.7 — warm but controlled

4. EDITORIAL REVIEW
   └── Admin dashboard queue (lightweight web UI)
       Manual approve / reject / edit before publish
       This step is non-negotiable for v1 quality control

5. PUBLISH
   └── Push approved papers to digest queue
       Match to user interest profiles for personalized delivery
       Trigger push notification / email
```

### 10.3 Community Submission Flow

1. User taps "Submit a Paper" in Profile → Browse section
2. Paste URL or DOI
3. System auto-fetches: title, authors, abstract, journal from URL/DOI resolver
4. User adds a short note: "Why should this be featured?"
5. Submission enters editorial queue
6. If approved → paper goes through standard summarization pipeline
7. Published card shows submitter credit: _"Suggested by @username"_ in Geist Mono, 10px

---

## 11. Technical Architecture

### 11.1 Frontend — Flutter

| Decision              | Choice                      | Rationale                          |
| --------------------- | --------------------------- | ---------------------------------- |
| State Management      | Riverpod                    | Predictable, testable, scales solo |
| Navigation            | go_router                   | Declarative, deep-link ready       |
| Local Storage         | Isar                        | Fast, typed, offline-first         |
| HTTP Client           | Dio                         | Interceptors, caching, retry logic |
| Share Card Generation | RepaintBoundary → toImage() | Native Flutter, no dependencies    |
| Push Notifications    | firebase_messaging          | FCM for iOS and Android            |
| Analytics             | PostHog (open source)       | Privacy-friendly, self-hostable    |

### 11.2 Backend — Supabase

| Service                   | Usage                                                      |
| ------------------------- | ---------------------------------------------------------- |
| **Postgres**              | Users, papers, digests, bookmarks, highlights, submissions |
| **Supabase Auth**         | Email/password + Google OAuth                              |
| **Edge Functions (Deno)** | Curation pipeline jobs, submission handler                 |
| **Realtime**              | (Post-MVP) Live community features                         |
| **Storage**               | Generated share card images, user avatars                  |
| **Cron (pg_cron)**        | Weekly/daily pipeline triggers                             |

### 11.3 External APIs

- `api.arxiv.org` — Paper fetching
- `api.semanticscholar.org` — Metadata, embeddings, citation data
- `api.anthropic.com` — claude-haiku-4-5 for summarization
- `fcm.googleapis.com` — Push notifications
- `accounts.google.com` — OAuth

### 11.4 Key Data Models

```
User
  id, email, name, created_at, is_pro
  interest_topics: string[]
  digest_day: enum(mon, wed, fri)
  digest_time: enum(morning, evening)
  streak_count: int
  streak_shield_used: bool

Paper
  id, title, authors: string[], institution
  source: enum(arxiv, semantic_scholar, ieee, community)
  source_url, doi, published_at
  topic_tags: string[]
  curiosity_hook: text          ← AI generated
  citation_count: int
  submitted_by: user_id?        ← null if editorial, user_id if community

Digest
  id, user_id, week_of
  paper_ids: uuid[]
  delivered_at, opened_at

Bookmark
  id, user_id, paper_id, created_at, status: enum(unread, in_progress, finished)

Highlight
  id, user_id, paper_id, text_content, color, created_at
```

---

## 12. MVP Roadmap

### MVP Scope

**MVP includes:**

- Onboarding with interest picker
- Weekly digest (manual editorial curation is acceptable for v1)
- Curiosity Card UI with swipe gestures
- Bookmarking
- Shareable Paper Card generation
- Basic streak counter
- arXiv API integration + Claude summarization
- Supabase auth (email + Google)

**MVP excludes (post-MVP):**

- Highlights & annotations
- Daily drops
- Browse feed
- Community submissions
- Full stats dashboard
- IEEE/ACM integration
- Push notifications (email only for v1)

### 6-Week Build Plan

| Week | Phase               | Focus                                                                 | Key Deliverable       |
| ---- | ------------------- | --------------------------------------------------------------------- | --------------------- |
| 1    | Foundation          | Flutter project setup, Supabase auth, navigation shell, design tokens | Running app with auth |
| 2    | Core UI             | Curiosity Card component, swipe gestures, paper data model            | Interactive card      |
| 3    | Pipeline            | arXiv fetch + Claude summarization + admin review queue               | End-to-end paper flow |
| 4    | Digest + Sharing    | Weekly Digest screen + Share Card generation (RepaintBoundary)        | First shareable card  |
| 5    | Onboarding + Polish | Interest picker, streak counter, bookmarks, edge cases                | Testable onboarding   |
| 6    | Beta                | TestFlight + Play Store internal test, 10–20 beta users               | First real users      |

---

## 13. Success Metrics

For the first 90 days post-launch, track these leading indicators:

| Metric                      | Target | Why It Matters                           |
| --------------------------- | ------ | ---------------------------------------- |
| D7 Retention                | ≥ 30%  | Are users coming back after a week?      |
| Digest Open Rate            | ≥ 50%  | Are notifications driving opens?         |
| "Read Full Paper" CTR       | ≥ 15%  | Are summaries generating real curiosity? |
| Share Card Exports per DAU  | ≥ 0.1  | Is the viral loop working?               |
| Week-4 Streak Retention     | ≥ 20%  | Is the habit forming?                    |
| Free → Pro Conversion (60d) | ≥ 3%   | Is the freemium model working?           |

---

## Appendix A — App Name & Brand

Working title: **PaperPulse**

- `Paper` = content, academia, the physical act of reading
- `Pulse` = rhythm, habit, the heartbeat of curiosity — also implies a feed/signal

**Visual wordmark treatment:**

- `Paper` — Instrument Serif, Ink Black, regular
- `Pulse` — Instrument Serif, Sage Green, italic

Alternative names to explore: _The Stack, Curio, Meridian, Pressprint, Folios_

Ensure availability: App Store, Play Store, `.app` or `.com` domain

---

## Appendix B — Design Inspirations

The three UI screenshots shared inform the visual direction as follows:

**Image 1 (Design System):** Adopt the pastel accent palette directly (sage, blush, sky, cream). Use Instrument Sans equivalents (Instrument Serif for display). Follow the linear icon system. Use the typography scale hierarchy as a guide.

**Image 2 (Book App):** The dark card on a high-contrast background is the direct inspiration for the Curiosity Card. The large, editorial serif title treatment — where the paper title _is_ the hero — must be replicated. The layered depth and color-blocked energy informs the Share Card design.

**Image 3 (Community App):** The warm off-white background, generous whitespace, and conversational headers ("Let's discuss this book?") inform the overall app tone. The clean list-with-illustration treatment is the reference for the Library and Browse screens.

**What to avoid:** Dense tables, academic grey palettes, small body text, modal-heavy flows, and anything that feels like a database interface. If a screen would fit in at a hospital or a government website, it's wrong.

---

_PaperPulse PRD v1.0 — Built for the intellectually restless._
