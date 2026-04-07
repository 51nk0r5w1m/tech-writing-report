// Dark slate theme (ngrok blog style)
#let bg = rgb("#0d1117")
#let ink = rgb("#d1d7e0")
#let ink-soft = rgb("#b6c2d1")
#let muted = rgb("#7d8590")
#let panel = rgb("#161b22")
#let panel-soft = rgb("#1c232c")
#let line = rgb("#30363d")
#let track = rgb("#303030")
#let accent-blue = rgb("#79c0ff")
#let accent-amber = rgb("#e3b341")
#let accent-green = rgb("#56d364")
#let accent-red = rgb("#ff7b72")

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@preview/lilaq:0.2.0" as lq
#import "@preview/gentle-clues:1.3.1": warning

#set page(
  paper: "us-letter",
  margin: (x: 1in, y: 0.9in),
  fill: bg,
)

#set par(justify: true, leading: 0.72em)
#set text(font: "DejaVu Sans", size: 10.5pt, fill: ink)
#show heading.where(level: 1): set text(fill: white)
#show heading.where(level: 1): set block(above: 1.2em, below: 0.5em)
#show heading.where(level: 2): set text(fill: rgb("#f0f6fc"))
#show heading.where(level: 2): set block(above: 0.9em, below: 0.4em)
#show emph: set text(fill: accent-blue)
#show strong: set text(fill: white)
#show link: set text(fill: accent-blue)
#show raw: set text(font: "DejaVu Sans Mono", fill: accent-green)

#let chip(body, fill-color: panel-soft, text-color: rgb("#e6e6e6")) = box(
  fill: fill-color,
  inset: (x: 7pt, y: 4pt),
  radius: 6pt,
  stroke: 0.6pt + fill-color.lighten(20%),
  [
    #set text(font: "DejaVu Sans Mono", size: 9pt, fill: text-color)
    #body
  ],
)

#let panel-block(body) = block(
  fill: panel,
  stroke: 0.7pt + line,
  radius: 10pt,
  inset: 12pt,
  body,
)

#let arrow-down = align(center)[#text(fill: accent-amber, weight: "bold")[↓]]

#let fig-table(..args) = table(
  fill: (x, y) => if y == 0 { panel-soft } else if calc.odd(y) { panel } else { bg },
  stroke: 0.5pt + line,
  inset: 8pt,
  align: (x, y) => if x == 0 { left + horizon } else { center + horizon },
  ..args,
)

#show table.cell.where(y: 0): set text(fill: white, weight: "bold")
#show figure.caption: set text(fill: muted)

#align(center)[
  #v(2.2em)
  #block(width: 85%, [
    #set par(justify: false, leading: 0.5em)
    #text(20pt, weight: "bold", fill: white)[Human-Centric Document Retrieval: Evaluating PageIndex for Long Technical Manuals]
  ])
  #v(1.5em)
  Carley Fant\
  Technical and Scientific Writing, Section V01\
  Spring Semester 2026\
  Columbus State University\
  April 6, 2026
]

#pagebreak()

= Table of Contents

#outline()

#pagebreak()

= Abstract

Organizations in engineering, maintenance, manufacturing, and compliance rely on long technical documents that mix paragraphs, tables, diagrams, warnings, and cross-references. Those documents are difficult for artificial intelligence systems to search accurately because many retrieval pipelines flatten pages into plain text before answering questions. Retrieval-augmented generation, or RAG, improved document question answering by retrieving relevant passages before generation, but standard RAG systems still depend on chunking, embeddings, and similarity search. In long manuals, that design can split related steps, detach warnings from procedures, or ignore page layout that helps a human reader make sense of the document. This report examines whether a more human-centered approach, represented here by the PageIndex framework, is a better fit for long-document retrieval. PageIndex indexes documents as structured pages rather than only as text chunks and uses reasoning over that structure instead of vector search alone. This report reviews the development of keyword retrieval, dense retrieval, and layout-aware document intelligence, then compares PageIndex with conventional RAG for one concrete use case: industrial maintenance manuals. The argument is narrower than “PageIndex replaces RAG.” Instead, PageIndex appears most useful when document structure carries part of the meaning.

= Introduction

Large language models have made it easier to ask natural-language questions about large document collections. In practice, however, many professional documents do not behave like simple blocks of text. A maintenance manual, for example, may spread one procedure across multiple pages and place a warning, figure, or exception note in a separate column or appendix. If that material is flattened into plain text and broken into chunks, the system may retrieve only part of the answer.

A 500-page equipment manual changes the stakes. A technician does not only need a sentence that sounds relevant. The technician may need the correct step order, a nearby warning label, a torque table, and a diagram that appears on the next page. In that setting, a retrieval error is more than inconvenient. It can produce an incomplete or misleading answer.

#warning(title: "Why This Matters")[
  In a long manual, the answer is often not one sentence. It is a small cluster of nearby information: a step, a warning, a figure, and a threshold value. Losing that cluster is the retrieval problem this report focuses on.
]

Retrieval-augmented generation, usually shortened to #emph[RAG], was developed to reduce hallucinations by retrieving external documents before a language model generates a response (Lewis et al., 2020). Standard RAG systems typically split documents into small segments, convert those segments into numerical representations called #emph[embeddings], and retrieve the segments whose embeddings are most similar to the query. This approach works well for many text-heavy tasks, but it also introduces a new set of problems: chunk boundaries can break context, embeddings may blur local detail, and page layout is often treated as secondary information rather than part of the meaning of the document itself.

The alternative examined here is the #emph[PageIndex] framework. According to the official developer documentation, PageIndex is a vectorless, reasoning-based retrieval framework that builds a tree-structured index of a document and lets a model navigate that structure in a traceable way (PageIndex Developer Docs, 2026). Instead of matching a question to isolated chunks, it moves through the document more like a reader using headings, sections, and page-level context to find the answer.

The central question is whether that approach works better for long technical manuals. To answer it, the report first reviews earlier retrieval approaches, then examines limits in conventional RAG, and finally evaluates where PageIndex offers real advantages and where the evidence is still developing.

= Literature Review

== From Keyword Search to Dense Retrieval

Early document retrieval systems relied on keyword matching and inverted indexes. Manning, Raghavan, and Schutze (2008) explain that these systems are efficient when users know the right terms, but they are less effective when the wording of the query differs from the wording of the source. That weakness is important for technical writing because users often ask questions in everyday language even when the document itself uses specialized vocabulary.

Dense retrieval emerged as a response to that limitation. Instead of matching exact terms, dense retrieval represents queries and documents as embeddings in a shared vector space. Karpukhin et al. (2020) showed that dense passage retrieval could outperform strong BM25 baselines on open-domain question-answering benchmarks, improving top-20 passage retrieval accuracy by substantial margins. In plain terms, dense retrieval made it easier for systems to match by meaning rather than exact wording.

Lewis et al. (2020) turned that retrieval trend into the modern RAG framework. They described a system that combines a generative language model with non-parametric memory, meaning knowledge stored outside the model in retrieved documents. That move mattered because retrieval stopped being just a search step and became part of answer generation itself. RAG improved factual grounding and helped models produce answers tied to evidence rather than relying only on internal parameters.

== Strengths and Limits of Conventional RAG

RAG remains attractive because it is practical. It allows organizations to update a knowledge base without retraining a model, and it gives users answers that can be tied back to retrieved sources. Borgeaud et al. (2022) further demonstrated the power of retrieval-augmented systems at scale by showing that retrieval could improve language-model performance while reducing the need for extremely large parameter counts.

Even so, retrieval quality remains the decisive factor. If the system retrieves the wrong passage, the final answer can still be wrong. Barnett et al. (2024) identify seven failure points in real RAG systems, including problems with chunking, ranking, query formulation, context assembly, and evaluation. Their findings are especially useful for this report because they move beyond ideal benchmark conditions and focus on operational systems. The paper shows that RAG pipelines often fail not because retrieval is useless, but because retrieval engineering is fragile.

One recurring weakness is #emph[chunking], the practice of splitting documents into smaller units so they can be embedded and retrieved efficiently. Chunking is necessary for many pipelines, but it can also disrupt context. In a maintenance manual, a chunk may contain an instruction without the caution note that appears immediately beside it in the original page layout. A model may then retrieve a technically relevant passage while missing the information that makes it safe or complete.

Another weakness is that standard RAG pipelines often treat layout as noise. Many systems begin with optical character recognition, or #emph[OCR], which converts a page image into machine-readable text. OCR is useful, but plain OCR output does not preserve every spatial relationship that matters in diagrams, forms, sidebars, or visually structured technical pages. When document meaning depends partly on where information appears, text-only retrieval can become lossy.

#figure(
  panel-block(align(center, diagram(
    node-stroke: 0.7pt + line,
    node-fill: panel-soft,
    node-inset: 8pt,
    node-corner-radius: 6pt,
    edge-stroke: 1pt + accent-amber,
    spacing: (8pt, 6pt),
    node((0, 0), text(fill: white, size: 8.5pt)[Keyword IR]),
    edge("-|>"),
    node((1, 0), text(fill: white, size: 8.5pt)[Dense retrieval]),
    edge("-|>"),
    node((2, 0), text(fill: white, size: 8.5pt)[RAG]),
    edge("-|>"),
    node((3, 0), text(fill: white, size: 8.5pt)[Layout-aware]),
    edge("-|>"),
    node((4, 0), text(fill: white, size: 8.5pt)[PageIndex]),
  ))),
  caption: [Evolution of document retrieval approaches from keyword search to page-structured reasoning. The figure emphasizes the shift in document representation rather than only a shift in model scale.]
)

Figure 1 places PageIndex in context. The field did not jump directly from keyword search to page-based reasoning. Retrieval systems moved from literal term matching to semantic similarity, then to retrieval-plus-generation, and finally toward layout-aware representations. PageIndex makes more sense when seen as part of that longer shift toward richer document representations.

#figure(
  panel-block([
      #grid(
        columns: (1fr, 1fr),
        column-gutter: 14pt,
        [
          #set text(fill: ink)
          #text(weight: "bold", fill: white)[Manual page as a reader sees it]
          #v(8pt)
          #chip([Step 3: Verify pressure > 42 psi], fill-color: accent-blue.darken(65%))
          #h(6pt) #chip([Warning: Do not engage motor above threshold], fill-color: accent-red.darken(70%))
          #v(8pt)
          #chip([Torque table nearby], fill-color: accent-green.darken(70%))
          #h(6pt) #chip([Figure A next to steps], fill-color: accent-amber.darken(70%), text-color: black)
          #v(12pt)
          #text(size: 9pt, fill: ink-soft)[
            A human reader treats these elements as one local unit of meaning.
          ]
        ],
        [
          #set text(fill: ink)
          #text(weight: "bold", fill: white)[Same page after flattening]
          #v(8pt)
          #block(
            fill: panel-soft,
            inset: 10pt,
            radius: 8pt,
            [
              #set text(font: "DejaVu Sans Mono", size: 9.5pt, fill: accent-blue)
              Section 4.2 Startup after seal replacement ... Verify pressure holds above 42 psi ... Warning do not engage motor above 42 psi ... Figure A ... torque table set B ...
            ],
          )
          #v(12pt)
          #text(size: 9pt, fill: ink-soft)[
            The words remain, but grouping and visual emphasis are weaker.
          ]
        ],
      )
    ],
  ),
  caption: [Manual-page anatomy rendered in a native Typst visual style. The figure shows why a page can carry meaning through grouping and placement, not only through raw text.]
)

Figure 2 makes the OCR-loss problem concrete. A maintenance page is not just a paragraph. It is a cluster of related signals. When those signals are flattened into text and split into chunks, retrieval quality can drop before generation even begins.

== Layout-Aware Document Understanding

Research in document intelligence has increasingly recognized that layout carries meaning. Xu et al. (2020), in their work on LayoutLM, argue that text-level modeling alone neglects spatial and visual information that is vital for document image understanding. Their results show that combining text with layout features improves performance on real-world document tasks such as form understanding and receipt understanding. The significance of that finding for this report is direct: if layout matters for forms and receipts, it is reasonable to expect that layout also matters for long technical manuals containing tables, callouts, diagrams, and section hierarchies.

A broader point follows from that research. Not every retrieval failure comes from bad wording or weak embeddings. Some failures start earlier, with the document representation itself. Once a manual has been reduced to extracted text alone, much of the original page logic is already gone.

== PageIndex and Human-Centric Retrieval

PageIndex is a recent framework built around that concern. The official documentation describes it as a vectorless, reasoning-based retrieval system that transforms documents into a tree-structured index and allows large language models to perform agentic reasoning over that structure (PageIndex Developer Docs, 2026). The public product site also reports high accuracy on FinanceBench and emphasizes page-level citations, hierarchical indexing, and the absence of vector databases or chunking (PageIndex, 2026).

The more important difference is in retrieval logic. In conventional RAG, the system is usually asking which chunk is closest to the query. In PageIndex, the system is deciding where to go next in the document structure. That is closer to how a person actually works through a manual by using the table of contents, section headings, appendices, and nearby figures.

The evidence for PageIndex still needs careful handling. Official benchmarks and product documentation are useful for understanding the system's design, but they are not the same as broad, independent academic validation. In this report, PageIndex is treated as an emerging retrieval architecture supported by early evidence and by related layout-aware document research, not as a settled replacement for every existing method.

= Discussion

Novelty by itself is not enough here. The stronger test is to compare PageIndex with conventional RAG in a setting where layout and continuity matter. Industrial maintenance manuals provide that setting because they combine long procedures, page-level references, warnings, tables, and visual elements.

#figure(
  panel-block(align(center, diagram(
    node-stroke: 0.7pt + line,
    node-fill: panel-soft,
    node-inset: 8pt,
    node-corner-radius: 6pt,
    edge-stroke: 1pt + accent-amber,
    spacing: (18pt, 10pt),
    node((0, 0), text(fill: accent-red, weight: "bold", size: 9pt)[OCR + RAG]),
    node((1, 0), text(fill: accent-blue, weight: "bold", size: 9pt)[PageIndex]),
    node((0, 1), text(fill: white, size: 8.5pt)[1. Extract text]),
    node((1, 1), text(fill: white, size: 8.5pt)[1. Keep structure]),
    node((0, 2), text(fill: white, size: 8.5pt)[2. Chunk passages]),
    node((1, 2), text(fill: white, size: 8.5pt)[2. Follow hierarchy]),
    node((0, 3), text(fill: white, size: 8.5pt)[3. Rank by similarity]),
    node((1, 3), text(fill: white, size: 8.5pt)[3. Reason through manual]),
    edge((0, 1), (0, 2), "-|>"),
    edge((0, 2), (0, 3), "-|>"),
    edge((1, 1), (1, 2), "-|>"),
    edge((1, 2), (1, 3), "-|>"),
  ))),
  caption: [Comparison of retrieval workflows for long technical manuals. Conventional OCR-plus-RAG pipelines flatten pages into extracted text, then rely on chunking and vector similarity. PageIndex-style retrieval preserves page hierarchy and reasons over the document structure directly.]
)

Figure 3 shows that the deepest difference between the two approaches is not speed or model size. It is the assumed shape of the document. In a conventional pipeline, retrieval begins after the page has already been transformed into text chunks. In a PageIndex-style pipeline, retrieval begins from page and section structure. That distinction matters when warnings, diagrams, or side notes are essential to the meaning of the procedure.

Imagine a field technician searching a compressor maintenance manual for the startup procedure after a seal replacement. In a chunk-based system, one chunk may contain the sequence of steps, another may contain the pressure threshold, and a third may contain a warning box about overheating. If the system retrieves only the first chunk because it is the closest semantic match, the answer may sound complete while leaving out material that changes the correct action. A page-structured approach has a better chance of preserving those local relationships.

#figure(
  fig-table(
    columns: (1fr, 1fr),
    table.header(
      [Where OCR + RAG breaks],
      [What page-structured retrieval preserves],
    ),
    [Warning box separates from the procedure step],
    [Page-level grouping of steps, notes, and warnings],
    [Table values drift away from nearby explanation],
    [Local relationship between values and instructions],
    [Cross-reference falls into a different chunk],
    [Direct navigation through references and appendices],
    [Similar wording can outrank the correct page],
    [Document position and hierarchy as retrieval signals],
    [Final citation may miss surrounding context],
    [Traceable grounding that is easier to verify],
  ),
  caption: [Failure-point comparison for OCR-plus-RAG and PageIndex-style retrieval. The figure shows where flattening a manual into disconnected text units creates preventable loss.]
)

Figure 4 turns the comparison into specific breakdown points. This is where the PageIndex argument is strongest. The issue is not simply that RAG uses vectors. The bigger problem is that a visually structured manual is often converted into disconnected text units before retrieval even begins.

#figure(
  panel-block(align(center, {
    set text(fill: ink, size: 8.5pt)
    let criteria = ("Complete", "Layout", "Trace", "Update", "Usability")
    let xs = (0, 1, 2, 3, 4)
    let kw = (2, 1, 3, 5, 2)
    let rag = (3, 1, 3, 5, 3)
    let pi = (5, 5, 5, 4, 5)
    let w = 0.25
    lq.diagram(
      width: 11cm,
      height: 6cm,
      ylim: (0, 5.5),
      xaxis: (ticks: xs.zip(criteria), subticks: none),
      lq.bar(
        xs.map(x => x - w),
        kw,
        width: w,
        color: accent-red,
        label: [Keyword],
      ),
      lq.bar(
        xs,
        rag,
        width: w,
        color: accent-amber,
        label: [RAG],
      ),
      lq.bar(
        xs.map(x => x + w),
        pi,
        width: w,
        color: accent-blue,
        label: [PageIndex],
      ),
    )
  })),
  caption: [Comparative fit of keyword search, conventional RAG, and PageIndex-style retrieval for long industrial manuals. Scores are on a 0-5 scale.]
)

Figure 5 applies that comparison directly to industrial manuals. The main value of PageIndex is not that it rejects retrieval. It changes the unit of retrieval from arbitrary text slices to navigable document structure. That design choice directly addresses several failure modes identified by Barnett et al. (2024), especially those involving chunk boundaries, ranking errors, and noisy context assembly.

This does not make conventional RAG ineffective. Standard RAG remains a strong choice for many tasks, especially when documents are mostly linear prose and the target is a short factual passage. In those cases, dense retrieval offers a practical balance of speed, flexibility, and performance. Long technical manuals are different. They are visual documents, and some of their meaning sits in the layout itself.

There is a practical trust advantage as well. Human readers are more likely to trust a system when they can see how it reached an answer. A page-based retrieval path is easier to explain than a hidden nearest-neighbor search over high-dimensional embeddings. In regulated or safety-sensitive environments, that matters.

The limitations are real. PageIndex-specific claims are still supported heavily by official documentation and public product material. Vector search also remains highly effective in many document settings and is backed by a much deeper research base. A PageIndex-style system still requires careful orchestration, model selection, and evaluation to work reliably in production. A more human-like retrieval strategy does not remove the need for engineering discipline.

So the best near-term claim is not “PageIndex replaces RAG.” The stronger claim is narrower. PageIndex addresses a class of retrieval failures that become more serious as documents grow longer, more structured, and more visual. That makes it a meaningful development for professional environments where missing context is costly.

= Conclusion

The research literature shows a clear progression from keyword search to dense retrieval and then to retrieval-augmented generation. Each stage improved how systems locate and use information. However, the literature also shows that long-document retrieval remains difficult when documents are broken into isolated text chunks and stripped of their original structure.

For long technical manuals, that limitation is significant. These documents depend on page layout, section hierarchy, diagrams, warnings, and cross-references. In such settings, conventional RAG can retrieve relevant language while still missing essential context. PageIndex is promising because it approaches retrieval more like a human reader would: by navigating the document as a structured artifact instead of only as an embedding space.

The conclusion remains cautious, but the direction is still clear. PageIndex should not be treated as a universal replacement for RAG, and its public evidence base is still developing. It does point toward a real improvement in document intelligence because it addresses a weakness in text-only retrieval workflows. For industrial maintenance manuals and similar long technical documents, a human-centric retrieval model can offer better completeness, better traceability, and a safer basis for question answering than chunk-based systems alone.

Future work should test these systems with independent evaluations on real-world document collections, not only on public benchmarks or vendor claims. If those evaluations confirm early results, PageIndex-style retrieval may become a valuable standard for document-heavy professional environments.

= Reference Page

[Barnett, S., Kurniawan, S., Thudumu, S., Brannelly, Z., & Abdelrazek, M. (2024). #emph[Seven failure points when engineering a retrieval augmented generation system]. Proceedings of the First International Conference on AI Engineering: Software Engineering for AI. https://arxiv.org/abs/2401.05856]

[Borgeaud, S., Mensch, A., Hoffmann, J., Cai, T., Rutherford, E., Millican, K., van den Driessche, G., Lespiau, J.-B., Damoc, B., Clark, A., de Las Casas, D., Guy, A., Menick, J., Ring, R., Hennigan, T., Huang, S., Maggiore, L., Jones, C., Cassirer, A., ... Sifre, L. (2022). #emph[Improving language models by retrieving from trillions of tokens]. Proceedings of the 39th International Conference on Machine Learning, 2206-2240. https://proceedings.mlr.press/v162/borgeaud22a.html]

[Karpukhin, V., Oguz, B., Min, S., Lewis, P., Wu, L., Edunov, S., Chen, D., & Yih, W.-t. (2020). #emph[Dense passage retrieval for open-domain question answering]. Proceedings of the 2020 Conference on Empirical Methods in Natural Language Processing, 6769-6781. https://aclanthology.org/2020.emnlp-main.550/]

[Lewis, P., Perez, E., Piktus, A., Petroni, F., Karpukhin, V., Goyal, N., Kuttler, H., Lewis, M., Yih, W.-t., Rocktaschel, T., Riedel, S., & Kiela, D. (2020). #emph[Retrieval-augmented generation for knowledge-intensive NLP tasks]. Advances in Neural Information Processing Systems, 33. https://papers.nips.cc/paper/2020/hash/6b493230205f780e1bc26945df7481e5-Abstract.html]

[Manning, C. D., Raghavan, P., & Schutze, H. (2008). #emph[Introduction to information retrieval]. Cambridge University Press. https://nlp.stanford.edu/IR-book/]

[PageIndex. (2026). #emph[Vectorless, reasoning-based document intelligence]. https://www.pageindex.dev/]

[PageIndex Developer Docs. (2026). #emph[What is PageIndex?]. https://docs.pageindex.ai/]

[Xu, Y., Li, M., Cui, L., Huang, S., Wei, F., & Zhou, M. (2020). #emph[LayoutLM: Pre-training of text and layout for document image understanding]. Proceedings of the 26th ACM SIGKDD Conference on Knowledge Discovery and Data Mining, 1192-1200. https://www.microsoft.com/en-us/research/publication/layoutlm-pre-training-of-text-and-layout-for-document-image-understanding/]

= Appendix

== Appendix A. Acknowledgment of Generative AI Use

OpenAI's ChatGPT was used as a planning and editorial support tool to help organize the report structure, refine wording, and format draft material for submission. All cited sources were selected and verified by the author, and the final analysis was reviewed and revised by the author before submission.
