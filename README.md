# Care Companion v2 — Deployment Guide

## What's New in v2

- **Snack / extra food logging** - "Add Snack / Food" button in each meal segment
- **Food note popup** - When marking a meal Done, a sheet asks what was eaten
- **Skip reason popup** - When skipping, optional reason captured (defaults to "Skipped")
- **Water deduct** - Minus button to remove incorrect water entries, with optional note
- **Custom water amount** - Free-text ml entry with optional note (e.g. coconut water, soup)
- **Custom symptoms** - Free-text field for symptoms not in the predefined list
- **Schedule / Calendar tab** - Add chemo sessions, checkups, and appointments
- **Today's schedule banner** - If an event is scheduled today, a banner shows on the home screen
- **Patient name split** - `Althea` in data/PDFs; `Mama` in on-screen motivational copy

---

## File Structure

```
care-companion/
├── index.html           ← The entire app (single file)
├── sw.js                ← Service Worker (offline PWA)
├── manifest.json        ← PWA manifest
├── supabase-schema.sql  ← Run once in Supabase dashboard
├── icons/
│   ├── icon-192.png     ← PWA icon (create manually)
│   └── icon-512.png     ← PWA icon (create manually)
└── README.md
```

---

## Step 1 — Supabase Setup

1. Go to [supabase.com](https://supabase.com) → New Project
2. Name it: `care-companion`
3. Go to **SQL Editor** → paste `supabase-schema.sql` → Run
4. Go to **Settings → API** → copy:
   - `Project URL` → `supabaseUrl`
   - `anon / public` key → `supabaseKey`
5. Go to **Settings → API → Allowed origins** → add your GitHub Pages URL

---

## Step 2 — Update CONFIG in index.html

```javascript
const CONFIG = {
  patientName:  "Althea",          // used in reports / PDF
  callName:     "Mama",            // used in motivational UI copy
  waterGoalMl:      2000,
  waterGoalGlasses: 8,
  supabaseUrl:  "YOUR_SUPABASE_URL",
  supabaseKey:  "YOUR_SUPABASE_ANON_KEY",
  useSupabase:  true,              // change false → true
};
```

---

## Step 3 — Create Icons

- `icon-192.png` — 192×192 pixels
- `icon-512.png` — 512×512 pixels

Suggested: green leaf or heart on cream background via [favicon.io](https://favicon.io) or Canva.

---

## Step 4 — Deploy to GitHub Pages

```bash
git init
git add .
git commit -m "Care Companion v2"
git branch -M main
git remote add origin https://github.com/YOURUSERNAME/care-companion.git
git push -u origin main
```

GitHub → Settings → Pages → Source: **Deploy from branch: main / root**

---

## Step 5 — Install on iPhone (Safari only)

1. Open in **Safari**
2. Share button → **Add to Home Screen** → Add

---

## Step 6 — iPhone Reminders

| Reminder | Time | Repeat |
|---|---|---|
| Morning Medication | 8:00 AM | Daily |
| Breakfast | 8:30 AM | Daily |
| Afternoon Medication | 1:00 PM | Daily |
| Water check-in | Every 2 hours | Daily |
| Dinner | 6:00 PM | Daily |
| Evening Medication | 8:00 PM | Daily |
| Daily Reflection | 8:30 PM | Daily |

---

## Data Architecture

| What | Where |
|---|---|
| Daily logs (tasks, water, symptoms, notes, reflection) | `localStorage` key: `cc_YYYY-MM-DD` |
| Schedule events | `localStorage` key: `cc_events` (persists across days) |
| Offline sync queue | `localStorage` key: `syncQueue` |
| All of the above | Also synced to Supabase when `useSupabase: true` |

- Daily state auto-resets at midnight (new date = new key)
- Schedule events persist indefinitely until manually deleted
- Sync status dot: Green = saved, Yellow = saving, Red = offline

---

## Supabase Tables (v2)

| Table | Purpose |
|---|---|
| `activity_log` | Meals, medications, snacks, custom tasks |
| `symptom_log` | Predefined and custom symptoms |
| `water_log` | Water entries (positive = add, negative = deduct) |
| `daily_reflection` | Mood + notes |
| `notes` | Free-form journal notes |
| `schedule_events` | Chemo, checkup, and other appointments |
| `treatment_log` | Future use |

---

## Customization

| What | Where |
|---|---|
| Patient name (data) | `CONFIG.patientName` |
| Patient name (UI) | `CONFIG.callName` |
| Water goal | `CONFIG.waterGoalMl` / `CONFIG.waterGoalGlasses` |
| Tasks | `const TASKS = [...]` |
| Symptoms | `const SYMPTOMS = [...]` |
| Affirmations | `const AFFIRMATIONS = [...]` |
| Colors | `:root { --sage: ... }` CSS variables |
