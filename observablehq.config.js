// See https://observablehq.com/framework/config for documentation.
export default {
  title: "Human-Centric Document Retrieval",
  root: "src",
  base: "/tech-writing-report/",
  theme: ["near-midnight"],
  toc: true,
  sidebar: false,
  footer: "Carley Fant · Technical and Scientific Writing, Section V01 · Columbus State University · Spring 2026",
  head: `<style>
    @media print {
      #observablehq-header,
      #observablehq-footer,
      .observablehq-sidebar-toggle { display: none !important; }
      body { background: var(--theme-background) !important; }
      .card { page-break-inside: avoid; }
      figure { page-break-inside: avoid; }
      table { page-break-inside: avoid; }
      h1, h2, h3 { page-break-after: avoid; }
      @page { size: 8.5in 11in; margin: 0.75in 1in; }
    }
  </style>`,
};
