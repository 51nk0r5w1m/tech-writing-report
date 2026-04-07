// Observable Framework data loader
// Runs at build time with Node.js — output is served as data/benchmark.json
//
// This loader generates a long-form (tidy) version of the retrieval-scores data,
// plus a simple "confidence" field calculated from the scores, so we can show
// a slightly richer dataset than the raw JSON.

const systems = ["Keyword / BM25", "Dense RAG", "Layout-aware", "PageIndex-style"];

const criteria = ["Completeness", "Layout", "Traceability", "Flexibility", "Usability"];

// Raw scores (0–5) matching Table 2 in the report
const scoreMatrix = [
  [2, 1, 3, 4, 2], // Keyword / BM25
  [3, 2, 3, 4, 3], // Dense RAG
  [3, 4, 3, 3, 3], // Layout-aware
  [4, 5, 5, 4, 4], // PageIndex-style
];

const rows = [];
for (let i = 0; i < systems.length; i++) {
  for (let j = 0; j < criteria.length; j++) {
    const score = scoreMatrix[i][j];
    rows.push({
      system: systems[i],
      criterion: criteria[j],
      score,
      // simple 0–100 confidence derived from the score
      confidence: Math.round((score / 5) * 100),
    });
  }
}

process.stdout.write(JSON.stringify(rows));
