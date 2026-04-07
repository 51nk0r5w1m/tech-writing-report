import {readFileSync} from "node:fs";

// Observable Framework data loader
// Runs at build time with Node.js — output is served as data/benchmark.json
//
// This loader reads retrieval-scores.json at build time, converts it into a
// long-form (tidy) dataset with one row per (system, criterion) pair, and adds
// a derived "confidence" field so we can show a slightly richer dataset than
// the raw JSON alone.

const raw = JSON.parse(readFileSync(new URL("./retrieval-scores.json", import.meta.url), "utf8"));

if (!Array.isArray(raw) || raw.length === 0) {
  throw new Error("retrieval-scores.json must be a non-empty array");
}

// Derive criteria from the union of all entries' keys (exclude non-score fields)
// Using the union rather than just raw[0] ensures we don't silently miss
// criteria that appear in later entries but not the first.
const NON_CRITERIA = new Set(["approach", "description"]);
const criteriaSet = new Set();
for (const entry of raw) {
  for (const key of Object.keys(entry)) {
    if (!NON_CRITERIA.has(key)) criteriaSet.add(key);
  }
}
const criteria = Array.from(criteriaSet);

if (criteria.length === 0) {
  throw new Error("retrieval-scores.json entries must include at least one numeric criterion field");
}

const rows = [];
for (const entry of raw) {
  if (!entry.approach) {
    throw new Error("Each entry in retrieval-scores.json must have an 'approach' field");
  }
  for (const criterion of criteria) {
    const score = entry[criterion];
    if (typeof score !== "number") {
      throw new Error(`Invalid score for ${entry.approach}/${criterion}: expected a number, got ${typeof score}`);
    }
    rows.push({
      system: entry.approach,
      criterion: criterion.charAt(0).toUpperCase() + criterion.slice(1),
      score,
      confidence: score >= 4 ? "high" : score >= 3 ? "medium" : "low",
    });
  }
}

process.stdout.write(JSON.stringify(rows));
