# Tech Writing Report

Source files for the final technical writing report on PageIndex and long-document retrieval.

## Files

- `report.typ`: main Typst source (themed, with inline figures)
- `report.md`: Markdown version with embedded SVG figures
- `assets/`: standalone SVG figure assets

## Assets

| File | Content |
| --- | --- |
| `assets/workflow-dark.svg` | Retrieval workflow comparison: OCR+RAG vs. PageIndex-style |
| `assets/evolution-dark.svg` | Evolution of document retrieval approaches (keyword → PageIndex) |
| `assets/comparison-dark.svg` | Grouped bar chart comparing retrieval approaches across five criteria |
| `assets/failure-modes-dark.svg` | Two-column breakdown of RAG failure points and PageIndex solutions |

## Build

```bash
typst compile report.typ report.pdf
```

## Web Site (Observable Framework)

The report is also published as an interactive web page using [Observable Framework](https://observablehq.com/framework/).

**Local preview:**

```bash
npm install
npm run dev
```

**Production build:**

```bash
npm install
npm run build   # output goes to dist/
```

## Deploy to GitHub Pages

The repository uses a GitHub Actions workflow (`.github/workflows/deploy.yml`) that automatically builds and deploys the site to GitHub Pages on every push to `main`.

To enable GitHub Pages for the repository:

1. Go to **Settings → Pages** in the repository on GitHub.
2. Under **Build and deployment**, set **Source** to **GitHub Actions**.
3. Push a commit to `main` (or trigger the workflow manually via **Actions → Deploy to GitHub Pages → Run workflow**).

The live site will be available at `https://<username>.github.io/<repo-name>/` once the workflow completes.

## Notes

The repository tracks the source files for the report. The locally rendered PDF can be regenerated from `report.typ`. The SVG assets in `assets/` are used in `report.md` and are also available as standalone figures for presentations or web use.
