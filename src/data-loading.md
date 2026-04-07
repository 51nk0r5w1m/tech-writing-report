---
title: Observable Data Loading Lab
toc: true
---

<style>
.lab-hero {
  margin: 3rem 0 2rem;
}
.lab-hero h1 {
  font-size: clamp(1.6rem, 4vw, 2.4rem);
  font-weight: 700;
  line-height: 1.2;
}
.lab-hero .subtitle {
  font-size: 1rem;
  color: var(--theme-foreground-muted);
  margin-top: 0.5rem;
  font-style: italic;
}
.method-badge {
  display: inline-block;
  font-size: 0.7rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  background: var(--theme-foreground-focus);
  color: var(--theme-background);
  border-radius: 4px;
  padding: 0.15em 0.55em;
  margin-bottom: 0.5rem;
}
.tip-box {
  background: color-mix(in srgb, var(--theme-foreground-focus) 10%, transparent);
  border-left: 3px solid var(--theme-foreground-focus);
  border-radius: 0 6px 6px 0;
  padding: 0.75rem 1rem;
  margin: 1rem 0;
  font-size: 0.9rem;
}
.tip-box strong { color: var(--theme-foreground); }
.cheatsheet {
  font-size: 0.82rem;
  border-collapse: collapse;
  width: 100%;
}
.cheatsheet th {
  text-align: left;
  color: var(--theme-foreground-muted);
  border-bottom: 1px solid var(--theme-foreground-faintest);
  padding: 0.4rem 0.75rem;
  font-weight: 600;
}
.cheatsheet td {
  padding: 0.4rem 0.75rem;
  border-bottom: 1px solid var(--theme-foreground-faintest);
  vertical-align: top;
}
.cheatsheet tr:last-child td { border-bottom: none; }
code { font-size: 0.82em; }
</style>

<div class="lab-hero">
  <h1>🧪 Observable Framework — Data Loading Lab</h1>
  <div class="subtitle">Four ways to get data into your dashboard, with live experiments</div>
</div>

Observable Framework can load data in four distinct ways. Each has a sweet spot. This page walks through all of them with runnable examples built on top of the retrieval-systems data from the [main report](./).

---

## Quick-reference cheatsheet

<table class="cheatsheet">
  <thead>
    <tr>
      <th>#</th><th>Method</th><th>Where it runs</th><th>Best for</th><th>Build output?</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>1</td><td>Inline JS data</td><td>Browser</td><td>Small, hard-coded datasets</td><td>No</td></tr>
    <tr><td>2</td><td><code>FileAttachment</code> (static file)</td><td>Browser (reads built asset)</td><td>CSV / JSON files you already have</td><td>Copied as-is</td></tr>
    <tr><td>3</td><td>Data loader (<code>.js</code>, <code>.py</code>…)</td><td>Node / Python at build time</td><td>Computed, fetched, or transformed data</td><td>Emitted JSON / CSV</td></tr>
    <tr><td>4</td><td><code>fetch()</code> at runtime</td><td>Browser</td><td>Live APIs, real-time feeds</td><td>No</td></tr>
  </tbody>
</table>

---

## Method 1 — Inline data in a JavaScript block

<div class="method-badge">Method 1 · Inline</div>

The simplest way: just write your data as a JavaScript array or object directly inside a fenced `js` code block. Observable Framework treats every ` ```js ` block as a reactive cell, so any variable you define is automatically available to later cells on the same page.

```js
// Define data right here — no file, no fetch needed.
const inlineData = [
  { approach: "Keyword / BM25",  score: 2 },
  { approach: "Dense RAG",       score: 3 },
  { approach: "Layout-aware",    score: 3 },
  { approach: "PageIndex-style", score: 4 },
];
```

```js
// Observable Plot is included automatically — no import needed.
Plot.plot({
  title: "Inline data — overall retrieval score (0–5)",
  marginLeft: 160,
  x: { domain: [0, 5], label: "Score →" },
  marks: [
    Plot.barX(inlineData, { x: "score", y: "approach", fill: "approach", sort: { y: "-x" } }),
    Plot.ruleX([0]),
  ]
})
```

<div class="tip-box">
<strong>✅ When to use it:</strong> Prototyping, tiny reference tables, or data that literally never changes. For anything larger than ~20 rows, switch to a file or loader.
</div>

---

## Method 2 — FileAttachment (static file)

<div class="method-badge">Method 2 · FileAttachment</div>

`FileAttachment` is the Observable way to load a file that lives alongside your source. The framework copies the file into the build and generates a typed, cached promise. No manual `fetch` URL needed.

The file `src/data/retrieval-scores.json` is already in this project. Load it like this:

```js
// FileAttachment resolves to the correct built URL automatically.
const scores = FileAttachment("data/retrieval-scores.json").json();
```

```js
// `scores` is a plain JS array once the promise resolves.
// Observable Framework awaits it for you in subsequent cells.
Inputs.table(scores, {
  columns: ["approach", "completeness", "layout", "traceability", "flexibility", "usability"],
  header: {
    approach: "Approach",
    completeness: "Completeness",
    layout: "Layout",
    traceability: "Traceability",
    flexibility: "Flexibility",
    usability: "Usability",
  },
})
```

```js
// Now chart it. Pick which criterion to highlight with a dropdown.
const criterion = view(Inputs.select(
  ["completeness", "layout", "traceability", "flexibility", "usability"],
  { label: "Criterion to display", value: "layout" }
));
```

```js
Plot.plot({
  title: `Scores by approach — "${criterion}"`,
  marginLeft: 160,
  x: { domain: [0, 5], label: "Score (0 = weakest, 5 = strongest) →" },
  color: {
    domain: ["Keyword / BM25", "Dense RAG", "Layout-aware", "PageIndex-style"],
    scheme: "tableau10",
  },
  marks: [
    Plot.barX(scores, {
      x: criterion,
      y: "approach",
      fill: "approach",
      sort: { y: "-x" },
      tip: true,
    }),
    Plot.ruleX([0]),
  ]
})
```

<div class="tip-box">
<strong>✅ When to use it:</strong> You already have a CSV or JSON on disk. <code>FileAttachment</code> supports <code>.json()</code>, <code>.csv()</code>, <code>.tsv()</code>, <code>.text()</code>, <code>.image()</code>, and more. The framework validates paths at build time — typos fail loudly, not silently.
</div>

---

## Method 3 — Data loaders (server-side scripts)

<div class="method-badge">Method 3 · Data Loader</div>

A data loader is a script in `src/data/` whose **output becomes a static file** at build time. You write it once; the framework runs it during `observable build` and serves the result. Loaders can be Node.js (`.js`), Python (`.py`), shell (`.sh`), or any executable.

The file `src/data/benchmark.js` in this project is a data loader. It emits a **tidy (long-format)** benchmark dataset, with one row per `(system, criterion)` pair — perfect for multi-series charts.

```js
// The loader output is consumed exactly like a FileAttachment.
// Observable strips the script extension: benchmark.js → benchmark.json
const benchmark = FileAttachment("data/benchmark.json").json();
```

```js
// Show the raw tidy table so you can see the shape.
Inputs.table(benchmark, {
  columns: ["system", "criterion", "score", "confidence"],
  header: {
    system: "System",
    criterion: "Criterion",
    score: "Score (0–5)",
    confidence: "Confidence",
  },
  rows: 10,
})
```

```js
// Interactive heatmap — filter by system with a checkbox group.
const systemOptions = Array.from(new Set(benchmark.map(d => d.system)));
const preferredSystems = ["Dense RAG", "PageIndex-style"];
const defaultSystems = preferredSystems.filter(system => systemOptions.includes(system));

const selectedSystems = view(Inputs.checkbox(
  systemOptions,
  {
    label: "Systems to compare",
    value: defaultSystems.length ? defaultSystems : systemOptions.slice(0, Math.min(2, systemOptions.length)),
  }
));
```

```js
const filtered = benchmark.filter(d => selectedSystems.includes(d.system));

Plot.plot({
  title: "Heatmap — score by system and criterion",
  marginLeft: 140,
  marginBottom: 60,
  x: { label: "Criterion", tickRotate: -30 },
  y: { label: "System" },
  color: {
    scheme: "YlOrRd",
    domain: [0, 5],
    legend: true,
    label: "Score",
  },
  marks: [
    Plot.cell(filtered, {
      x: "criterion",
      y: "system",
      fill: "score",
      tip: true,
      inset: 1,
      rx: 4,
    }),
    Plot.text(filtered, {
      x: "criterion",
      y: "system",
      text: d => d.score,
      fill: d => (d.score >= 4 ? "white" : "black"),
      fontSize: 14,
      fontWeight: 600,
    }),
  ]
})
```

<div class="tip-box">
<strong>✅ When to use it:</strong> Any data that needs transformation, secrets (API keys stay on the server), or heavy computation. The browser only ever sees the finished JSON — never the loader code.
</div>

---

## Method 4 — fetch() at runtime

<div class="method-badge">Method 4 · fetch</div>

Sometimes you want **live data** that changes after the site is built — a real-time API, a database endpoint, or any feed that updates frequently. Use a plain `fetch()` call inside a `js` block and Observable will await the promise for you.

```js
// Fetch Observable Framework's own GitHub repository metadata — live.
const frameworkRepo = fetch("https://api.github.com/repos/observablehq/framework")
  .then(r => {
    if (!r.ok) throw new Error(`GitHub API request failed: ${r.status} ${r.statusText}`);
    return r.json();
  });
```

```js
// Display a few key fields from the live API response.
html`<div class="grid grid-cols-4">
  <div class="card">
    <div class="label">⭐ Stars</div>
    <div class="big">${frameworkRepo.stargazers_count?.toLocaleString()}</div>
    <div class="muted">github stars</div>
  </div>
  <div class="card">
    <div class="label">🍴 Forks</div>
    <div class="big">${frameworkRepo.forks_count?.toLocaleString()}</div>
    <div class="muted">repository forks</div>
  </div>
  <div class="card">
    <div class="label">🐛 Open issues</div>
    <div class="big">${frameworkRepo.open_issues_count?.toLocaleString()}</div>
    <div class="muted">issues + PRs</div>
  </div>
  <div class="card">
    <div class="label">📅 Last push</div>
    <div class="big">${frameworkRepo.pushed_at ? new Date(frameworkRepo.pushed_at).toLocaleDateString() : "—"}</div>
    <div class="muted">most recent push</div>
  </div>
</div>`
```

<div class="tip-box">
<strong>✅ When to use it:</strong> Live dashboards, status pages, or any data that must reflect the current moment. Keep in mind: if the API is down, the page degrades gracefully — the promise rejects and Observable shows the error inline, not a blank page.
</div>

---

## Bonus — Reactivity and transforms

One of Observable Framework's superpowers is **reactive cells**: when a value changes (like a slider or dropdown), every downstream cell re-runs automatically. No event listeners, no manual re-renders.

```js
// A slider to set a minimum-score filter.
const minScore = view(Inputs.range([0, 5], {
  label: "Minimum score filter",
  step: 1,
  value: 3,
}));
```

```js
// This cell re-runs every time `minScore` or `benchmark` changes.
const qualifying = benchmark.filter(d => d.score >= minScore);

Plot.plot({
  title: `Criteria scoring ≥ ${minScore} across all systems`,
  marginLeft: 140,
  x: { label: "Score →", domain: [0, 5] },
  color: { scheme: "tableau10", legend: true },
  marks: [
    Plot.dot(qualifying, {
      x: "score",
      y: "criterion",
      fill: "system",
      r: 10,
      tip: true,
      fillOpacity: 0.8,
    }),
    Plot.ruleX([0]),
  ]
})
```

```js
// Summary card — how many system+criterion pairs pass the filter?
html`<div class="card" style="max-width: 20rem;">
  <div class="label">Pairs passing the filter</div>
  <div class="big">${qualifying.length} / ${benchmark.length}</div>
  <div class="muted">score ≥ ${minScore} (out of 5)</div>
</div>`
```

---

## What you just saw

You used all four data-loading methods in a single page:

1. **Inline JS** — tiny hard-coded array, no file needed.
2. **FileAttachment** — `retrieval-scores.json` loaded and typed automatically.
3. **Data loader** — `benchmark.js` ran at build time; the browser only saw the JSON output.
4. **fetch()** — live GitHub API call, awaited by Observable's runtime.

All of them drop straight into Markdown files. No bundler config, no imports for Plot or D3 — the framework provides them. The hardest part is choosing which method fits the moment. The cheatsheet at the top of this page is a good starting point.

→ Head back to the [main report](./) for the full PageIndex analysis.
