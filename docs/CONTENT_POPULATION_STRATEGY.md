# CHRONOS — Content-Driven Development Strategy
## Content Population Strategy for Global Search & Navigation Validation

This document establishes the official **Content-Driven Development** guidelines for the CHRONOS platform and provides ready-to-run database seed scripts to validate the search experience with real historical data.

---

## 1. Methodology: Content-Driven Development

To ensure that UX design decisions, performance limits, filtering responsiveness, and navigational architectures are validated with realistic historical relationships rather than mock templates, CHRONOS strictly adopts the **Content-Driven Development** loop:

```
+---------------------+     +--------------------+     +-----------------------+
|  New Feature Build  | --> | Content Population | --> | Real-Data Validation  |
+---------------------+     +--------------------+     +-----------------------+
                                                                   |
                                                                   v
                                                       +-----------------------+
                                                       |   UX & Perf Tuning    |
                                                       +-----------------------+
```

### Constraints:
- Seeds must include high-quality, real-world content detailing historical figures, eras, civilizations, locations, and artifacts.
- Multi-category searching and relational foreign keys should connect logical nodes (e.g., Julius Caesar linked to the Roman Empire, Cleopatra linked to the Ptolemaic Kingdom and Egypt).

---

## 2. Seed Data Schema & Ratios

To run exhaustive query tests, the database is populated with the following counts of high-fidelity historical data:
- **10 Eras** (covering prehistory to space age).
- **50 Historical Events** (covering major treaties, battles, and revolutions).
- **30 Historical Characters** (philosophers, rulers, scientists, artists).
- **15 Civilizations** (Ancient Egypt, Roman Empire, Mayan Civilization, etc.).
- **20 Artifacts** (Rosetta Stone, Antikythera Mechanism, Bust of Nefertiti).
- **20 Locations** (Alexandria, Rome, Machu Picchu, Athens).

---

## 3. Ready-To-Run SQL Seeds

To seed these records in your Supabase database, execute the sql migration files provided in the `/database/migrations/` folder or run the compiled blocks via the Supabase SQL Editor.

The SQL files are organized as follows:
- `20260718000000_seed_eras.sql`: Seeding of historical Eras.
- `20260718000002_seed_historical_events.sql`: Seeding of global historical Events.
- `20260719000001_seed_civilizations_and_locations.sql`: Seeding of 15 Civilizations and 20 Historical Locations.
- `20260719000002_seed_characters_and_artifacts.sql`: Seeding of 30 Characters and 20 Artifacts, completing the required content matrix.
