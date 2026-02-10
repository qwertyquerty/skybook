# Agentic Current Task (Readonly)
We are importing glitches from the compendium CSV files in the root folder into our glitch lists.

### Plan
Modify sparingly as new information is learned. Keep minimal and simple.
The goal is to keep the architecture in mind and not drift into minefields.

- Keep top-level `categories` stable for nav UX: `Glitches`, `Theory`, `Reference` (already wired to `_tabs/*`).
- Use `tags` as the multi-axis system for discoverability and ambiguity handling (cross-post replacement).
- Normalize tags during import so search/tag pages stay clean (case, aliases, acronyms, platform markers).
- Treat compendium section headers as location/topic metadata and not as separate entries.
- Each new page should have a warning "This page was migrated from the compendium by an AI agent, and could use human cleanup!"
- Define and lock the tag schema below before bulk importing more CSV rows.
- Normalize existing post tags to schema (`glitch` vs `glitches`, `RNG` vs `rng`, acronym aliases).
- Build one import pass for `General.csv`:
  - skip blank rows and section header rows,
  - map each entry to one top-level category (`Glitches` default; `Theory` for theoretical/unsolved investigations; `Reference` for pure mechanics docs),
  - attach normalized tags.
- Build one import pass for location CSVs and attach `map-*` tags from section headers.
- Add source-quality tags during import:
  - `needs-source` for blank / `<Need video>` sources,
  - `has-notes` when extra notes column is populated.
- Run spot QA after each batch (10 entries): frontmatter validity, tag consistency, generated tag/category pages.
- Decide whether to expose additional navigation pages (optional) only after at least ~100 imported entries.
- If making a hard decision, or blocked, add to ## Notes for Owner

## Current Tasklist (ordered)
(Remove as completed, add remaining concrete tasks. If the list is empty, audit the codebase to come up with a plan for the next concrete steps.)

Come up with a list of tasks based on the plan. As tasks come up, add/remove them here. If done, audit the compendium csv files and project structures.

## Notes for Owner

- 

## Important Information
Append important discoveries. Compact regularly.

- Repository currently has 20 posts in `_posts` and uses category tabs:
  - `_tabs/glitches.md` -> `/categories/glitches/`
  - `_tabs/theory.md` -> `/categories/theory/`
  - `_tabs/reference.md` -> `/categories/reference/`
- Existing tags are inconsistent today (`glitch` and `glitches`, uppercase `RNG`, mixed acronyms such as `EHC`, `PGS`, `EMS`).
- Compendium CSV audit:
  - 7 CSV files, ~520 entry rows total.
  - ~71 entries have missing or placeholder source (`<Need video>` or empty).
  - Bracket markers are common and should map to tags: `[Wii]`, `[HD]`, `[Theoretical]`, `[TAS]`, etc.
  - Several rows in `General.csv` are malformed and look like notes/URLs; do not import blindly.

### Proposed Tag Schema (v1)
- Keep tags lowercase kebab-case.
- Facet: `type-*` (content nature):
  - `type-glitch`, `type-theory`, `type-reference`.
- Facet: `status-*` (research maturity):
  - `status-partially-solved`, `status-unsolved`, `status-theoretical`. (No solved tag is necessary, as this is assumed unless stated otherwise)
- Facet: `platform-*`:
  - `platform-wii`, `platform-gcn`, `platform-hd`, `platform-pal`.
- Facet: `mechanic-*` (mechanic family):
  - `mechanic-movement`, `mechanic-collision`, `mechanic-combat`, `mechanic-memory`, `mechanic-long-jump-attack`, `mechanic-rng`, `mechanic-cutscene`, `mechanic-actor-corruption`, `mechanic-storage`, `mechanic-warp`, `mechanic-oob`, `mechanic-softlock`, `mechanic-crash`.
- Facet: `map-*` (section/location taxonomy from non-General CSVs):
  - examples: `map-ordon-village`, `map-forest-temple`, `map-kakariko-village`, `map-city-in-the-sky`, `map-hyrule-castle`, `map-lake-hylia`.
- Facet: `meta-*`:
  - `meta-tas`, `meta-needs-source`, `meta-has-notes`.

Note from owner: There is no reason to ever specify "cross-post" like the compendium has (tags implicitly solve this).

### Normalization Rules
- Map legacy aliases:
  - `glitches` -> `glitch`
  - `RNG` -> `rng`
  - existing acronym tags (e.g. `EHC`, `PGS`, `EMS`, `gws`) remain temporarily but should gain explicit canonical tags in parallel (Early Hyrule Castle, Poe Gate Skip, Early Master Sword, Golden Wolf Storage...).
- Parse bracket prefixes in entry names into tags and remove bracket text from display title.
- If an entry appears in multiple CSV sections, keep one post and attach multiple `map-*` tags.
- If category assignment is unclear, default to `Glitches` + `status-unsolved` and add a short review note.

## Agent Scratchpad and Notes
(Append below and compact regularly to relevant recent notes, keep under ~20 trap parts).

- `General.csv` includes true sections (`Movement Tech`, `Combat Tech`, etc.) and noisy rows that are actually notes; import filter must be strict.
- Location CSVs are cleanly sectioned and suitable for `map-*` tag generation.
- Even though these are CSVs, the owner has requested manual import at an agent LLM level, not script based. These need thining to route.

### Concise Session Log
Append logs for each session here. Compact redundancy.

- Audited repo content and compendium CSV layout.
- Confirmed current nav depends on category pages; tags are the right place for multi-classification.
- Added concrete migration plan, tag schema, normalization rules, and ordered tasklist for next import sessions.
