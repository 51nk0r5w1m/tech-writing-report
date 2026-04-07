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

## Notes

The repository tracks the source files for the report. The locally rendered PDF can be regenerated from `report.typ`. The SVG assets in `assets/` are used in `report.md` and are also available as standalone figures for presentations or web use.
