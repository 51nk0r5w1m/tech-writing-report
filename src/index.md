---
title: Human-Centric Document Retrieval
toc: true
---

<style>
.report-hero {
  margin: 3rem 0 2rem;
  text-wrap: balance;
}
.report-hero h1 {
  font-size: clamp(1.6rem, 4vw, 2.4rem);
  line-height: 1.2;
  max-width: 38rem;
  font-weight: 700;
}
.report-hero .subtitle {
  font-size: 1rem;
  color: var(--theme-foreground-muted);
  margin-top: 0.5rem;
  font-style: italic;
}
.byline {
  margin: 1.5rem 0 0;
  font-size: 0.875rem;
  color: var(--theme-foreground-muted);
  line-height: 1.8;
  border-top: 1px solid var(--theme-foreground-faintest);
  padding-top: 1rem;
}
.byline strong { color: var(--theme-foreground); }
.section-label {
  font-size: 0.7rem;
  font-weight: 700;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--theme-foreground-muted);
  margin: 2.5rem 0 0.4rem;
}
figure {
  margin: 1.5rem 0;
}
figure img {
  width: 100%;
  border-radius: 8px;
  border: 1px solid var(--theme-foreground-faintest);
}
figcaption {
  margin-top: 0.5rem;
  font-size: 0.8rem;
  color: var(--theme-foreground-muted);
  font-style: italic;
  text-align: center;
}
.ref-list { padding: 0; list-style: none; }
.ref-list li {
  font-size: 0.875rem;
  color: var(--theme-foreground-muted);
  padding: 0.5rem 0 0.5rem 2rem;
  text-indent: -2rem;
  border-bottom: 1px solid var(--theme-foreground-faintest);
  line-height: 1.6;
}
.ref-list li:last-child { border-bottom: none; }
@media print {
  .section-label { margin-top: 1.5rem; }
  .ref-list li { font-size: 0.8rem; }
}
</style>

<div class="report-hero">
  <h1>Human-Centric Document Retrieval: Evaluating PageIndex for Long Technical Manuals</h1>
  <div class="byline">
    <strong>Carley Fant</strong><br>
    Technical and Scientific Writing, Section V01<br>
    Columbus State University · Spring Semester 2026 · April 6, 2026
  </div>
</div>

---

<div class="grid grid-cols-4">
  <div class="card">
    <div class="label">Document type</div>
    <div class="big">Manual</div>
    <div class="muted">Industrial maintenance</div>
  </div>
  <div class="card">
    <div class="label">Primary comparison</div>
    <div class="big">RAG</div>
    <div class="muted">vs. PageIndex retrieval</div>
  </div>
  <div class="card">
    <div class="label">Key criterion</div>
    <div class="big">Structure</div>
    <div class="muted">Layout carries meaning</div>
  </div>
  <div class="card">
    <div class="label">Sources cited</div>
    <div class="big">8</div>
    <div class="muted">Peer-reviewed + docs</div>
  </div>
</div>

---

## Abstract

Organizations in engineering, maintenance, manufacturing, and compliance rely on long technical documents that mix paragraphs, tables, diagrams, warnings, and cross-references. Those documents are difficult for artificial intelligence systems to search accurately because many retrieval pipelines flatten pages into plain text before answering questions. Retrieval-augmented generation, or **RAG**, improved document question answering by retrieving relevant passages before generation, but standard RAG systems still depend on chunking, embeddings, and similarity search. In long manuals, that design can split related steps, detach warnings from procedures, or ignore page layout that helps a human reader make sense of the document.

This report examines whether a more human-centered approach, represented here by the **PageIndex** framework, is a better fit for long-document retrieval. PageIndex indexes documents as structured pages rather than only as text chunks and uses reasoning over that structure instead of vector search alone. This report reviews the development of keyword retrieval, dense retrieval, and layout-aware document intelligence, then compares PageIndex with conventional RAG for one concrete use case: industrial maintenance manuals. The argument is narrower than "PageIndex replaces RAG." Instead, PageIndex appears most useful when document structure carries part of the meaning.

---

## Introduction

Large language models have made it easier to ask natural-language questions about large document collections. In practice, however, many professional documents do not behave like simple blocks of text. A maintenance manual, for example, may spread one procedure across multiple pages and place a warning, figure, or exception note in a separate column or appendix. If that material is flattened into plain text and broken into chunks, the system may retrieve only part of the answer.

This problem matters in real workplaces. A technician using a 500-page equipment manual does not only need a sentence that sounds relevant. The technician may need the correct step order, a nearby warning label, a torque table, and a diagram that appears on the next page. A retrieval error in that setting is not just inconvenient — it can produce an incomplete or misleading answer.

<div class="caution">

**Why this matters:** In a long manual, the answer is often not one sentence. It is a small cluster of nearby information: a step, a warning, a figure, and a threshold value. Losing that cluster is the retrieval problem this report focuses on.

</div>

Retrieval-augmented generation, usually shortened to **RAG**, was developed to reduce hallucinations by retrieving external documents before a language model generates a response (Lewis et al., 2020). Standard RAG systems typically split documents into small segments, convert those segments into numerical representations called **embeddings**, and retrieve the segments whose embeddings are most similar to the query. This approach works well for many text-heavy tasks, but it also introduces a new set of problems: chunk boundaries can break context, embeddings may blur local detail, and page layout is often treated as secondary information rather than part of the meaning of the document itself.

This report investigates a more human-centric alternative: the **PageIndex** framework. According to the official developer documentation, PageIndex is a vectorless, reasoning-based retrieval framework that builds a tree-structured index of a document and lets a model navigate that structure in a traceable way (PageIndex Developer Docs, 2026). Instead of asking a system to match a question to isolated text chunks, PageIndex asks it to move through a document more like a human reader who uses headings, sections, and page-level context to find the answer.

The central question of this report is whether that approach is meaningfully better for long technical manuals. To answer it, the report first reviews earlier retrieval approaches, then examines limitations in conventional RAG, and finally evaluates where PageIndex offers real advantages and where its evidence base is still emerging.

---

## Literature Review

### From Keyword Search to Dense Retrieval

Early document retrieval systems relied on keyword matching and inverted indexes. Manning, Raghavan, and Schütze (2008) explain that these systems are efficient when users know the right terms, but less effective when the wording of the query differs from the wording of the source. That weakness matters for technical writing because users often ask questions in everyday language even when the document uses specialized vocabulary.

Dense retrieval emerged as a response to that limitation. Instead of matching exact terms, dense retrieval represents queries and documents as embeddings in a shared vector space. Karpukhin et al. (2020) showed that dense passage retrieval could outperform strong BM25 baselines on open-domain question-answering benchmarks, improving top-20 passage retrieval accuracy by substantial margins. In plain terms, dense retrieval made it easier for systems to match by meaning rather than exact wording.

Lewis et al. (2020) formalized retrieval-augmented generation as a method that combines a generative language model with non-parametric memory — knowledge stored outside the model in retrieved documents. Their work is foundational because it frames retrieval not as a separate search step, but as part of the answer-generation process itself. RAG improved factual grounding and helped models produce answers tied to evidence rather than relying only on internal parameters.

<figure>
  <img src="./assets/evolution-dark.svg" alt="Figure 1 — Evolution of document retrieval approaches">
  <figcaption>Figure 1. Evolution of document retrieval approaches from keyword search to page-structured reasoning. The shift is not only toward more powerful models, but toward richer document representations.</figcaption>
</figure>

### Strengths and Limits of Conventional RAG

RAG remains attractive because it is practical. It allows organizations to update a knowledge base without retraining a model, and it gives users answers that can be tied back to retrieved sources. Borgeaud et al. (2022) demonstrated that retrieval could improve language-model performance while reducing the need for extremely large parameter counts.

Even so, retrieval quality remains the decisive factor. If the system retrieves the wrong passage, the final answer can still be wrong. Barnett et al. (2024) identify seven failure points in real RAG systems, including problems with chunking, ranking, query formulation, context assembly, and evaluation. Their findings show that RAG pipelines often fail not because retrieval is useless, but because retrieval engineering is fragile.

One recurring weakness is **chunking** — the practice of splitting documents into smaller units so they can be embedded and retrieved efficiently. Chunking is necessary for many pipelines, but it can also disrupt context. In a maintenance manual, a chunk may contain an instruction without the caution note that appears immediately beside it in the original page layout. A model may then retrieve a technically relevant passage while missing the information that makes it safe or complete.

Another weakness is that standard RAG pipelines often treat layout as noise. Many systems begin with optical character recognition (**OCR**), which converts a page image into machine-readable text. OCR is useful, but plain OCR output does not preserve every spatial relationship that matters in diagrams, forms, sidebars, or visually structured technical pages. When document meaning depends partly on where information appears, text-only retrieval can become lossy.

### Layout-Aware Document Understanding

Research in document intelligence has increasingly recognized that layout carries meaning. Xu et al. (2020), in their work on LayoutLM, argue that text-level modeling alone neglects spatial and visual information vital for document image understanding. Their results show that combining text with layout features improves performance on real-world document tasks such as form understanding and receipt understanding. If layout matters for forms and receipts, it is reasonable to expect that layout also matters for long technical manuals containing tables, callouts, diagrams, and section hierarchies.

Not every retrieval failure comes from bad wording or weak embeddings. Some failures start earlier, with the document representation itself. Once a manual has been reduced to extracted text alone, much of the original page logic is already gone.

### PageIndex and Human-Centric Retrieval

PageIndex is a recent framework built around that concern. The official documentation describes it as a vectorless, reasoning-based retrieval system that transforms documents into a tree-structured index and allows large language models to perform agentic reasoning over that structure (PageIndex Developer Docs, 2026). The public product site also reports high accuracy on FinanceBench and emphasizes page-level citations, hierarchical indexing, and the absence of vector databases or chunking (PageIndex, 2026).

The more important difference is in retrieval logic. In conventional RAG, the system is asking which chunk is closest to the query. In PageIndex, the system is deciding where to go next in the document structure — closer to how a person actually works through a manual by using the table of contents, section headings, appendices, and nearby figures.

<div class="note">

The evidence for PageIndex still needs careful handling. Official benchmarks and product documentation are useful for understanding the system's design, but they are not the same as broad, independent academic validation. In this report, PageIndex is treated as an emerging retrieval architecture supported by early evidence and related layout-aware research — not as a settled replacement for every existing method.

</div>

---

## Discussion

The strongest test is to compare PageIndex with conventional RAG in a setting where layout and continuity matter. Industrial maintenance manuals provide that setting because they combine long procedures, page-level references, warnings, tables, and visual elements.

<figure>
  <img src="./assets/workflow-dark.svg" alt="Figure 2 — Retrieval workflow comparison">
  <figcaption>Figure 2. Comparison of retrieval workflows for long technical manuals. Conventional OCR-plus-RAG pipelines flatten pages into extracted text, then rely on chunking and vector similarity. PageIndex-style retrieval preserves page hierarchy and reasons over document structure directly.</figcaption>
</figure>

The deepest difference between the two approaches is not speed or model size — it is the assumed shape of the document. In a conventional pipeline, retrieval begins after the page has already been transformed into text chunks. In a PageIndex-style pipeline, retrieval begins from page and section structure. That distinction matters when warnings, diagrams, or side notes are essential to the meaning of the procedure.

**Table 1. Comparison of retrieval approaches for long technical documents**

| Approach | Core representation | Main strengths | Main weaknesses | Best use case |
|---|---|---|---|---|
| Keyword / BM25 | Indexed terms | Fast, transparent, easy to maintain | Requires near-exact wording; weak on paraphrase | Known-item lookup |
| Dense-retrieval RAG | Text chunks + embeddings | Better semantic matching; scalable QA | Chunking splits context; layout often flattened | Text-heavy knowledge bases |
| Layout-aware models | Text + spatial / visual features | Better understanding where layout matters | Often focused on extraction, not retrieval workflows | Forms, receipts, structured pages |
| PageIndex-style | Page hierarchy + document-structure reasoning | Preserves section context, page relationships, traceability | Newer; less independent validation; orchestration complexity | Long, highly structured manuals and reports |

The practical advantage of PageIndex becomes clearer when the use case is narrowed further. Imagine a field technician searching a compressor maintenance manual for the startup procedure after a seal replacement. In a chunk-based system, one chunk may contain the sequence of steps, another may contain the pressure threshold, and a third may contain a warning box about overheating. If the system retrieves only the first chunk because it is the closest semantic match, the answer may sound complete while leaving out material that changes the correct action. A page-structured approach has a better chance of preserving those local relationships.

<figure>
  <img src="./assets/failure-modes-dark.svg" alt="Figure 3 — Failure modes in long technical manual retrieval">
  <figcaption>Figure 3. Where retrieval breaks in long technical manuals. The figure maps each OCR+RAG failure point to the corresponding PageIndex design response.</figcaption>
</figure>

Standard RAG remains a strong choice for many tasks, especially when documents are mostly linear prose and the target is a short factual passage. In those cases, dense retrieval offers a practical balance of speed, flexibility, and performance. Long technical manuals are different — they are visual documents, and some of their meaning sits in the layout itself.

**Table 2. Evaluation criteria applied to industrial maintenance manuals**

| Criterion | Why it matters | Conventional RAG | PageIndex-style retrieval |
|---|---|---|---|
| Retrieval completeness | Procedures often depend on adjacent warnings, tables, or later steps | Moderate; depends heavily on chunking strategy | Stronger potential because page and section context stay intact |
| Layout preservation | Visual grouping can signal meaning and safety relevance | Usually weak unless layout features are added separately | Built around page structure and hierarchy |
| Traceability | Users need to verify where an answer came from | Good when citations are attached to chunks | Strong when navigation path and page references are explicit |
| Update flexibility | Manuals and procedures change over time | Strong; indexes can be refreshed without full retraining | Also strong, though implementation details vary by system |
| Usability for non-experts | Users need answers that reflect whole procedures, not fragments | Can be good, but incomplete retrieval can mislead | Potentially stronger for structured document navigation |

<figure>
  <img src="./assets/comparison-dark.svg" alt="Figure 4 — Comparative fit bar chart">
  <figcaption>Figure 4. Comparative fit of keyword search, conventional RAG, and PageIndex-style retrieval for long industrial manuals across the five criteria in Table 2. Scores are on a 0–5 scale.</figcaption>
</figure>

The main value of PageIndex is not that it rejects retrieval — it changes the unit of retrieval from arbitrary text slices to navigable document structure. That design choice directly addresses several failure modes identified by Barnett et al. (2024), especially those involving chunk boundaries, ranking errors, and noisy context assembly.

There is a practical trust advantage as well. Human readers are more likely to trust a system when they can see how it reached an answer. A page-based retrieval path is easier to explain than a hidden nearest-neighbor search over high-dimensional embeddings. In regulated or safety-sensitive environments, that matters.

The limitations are real. PageIndex-specific claims are still supported heavily by official documentation and public product material. Vector search also remains highly effective in many document settings and is backed by a much deeper research base. A PageIndex-style system still requires careful orchestration, model selection, and evaluation to work reliably in production.

The best near-term claim is not "PageIndex replaces RAG." The stronger claim is narrower: PageIndex addresses a class of retrieval failures that become more serious as documents grow longer, more structured, and more visual. That makes it a meaningful development for professional environments where missing context is costly.

---

## Conclusion

The research literature shows a clear progression from keyword search to dense retrieval and then to retrieval-augmented generation. Each stage improved how systems locate and use information. However, the literature also shows that long-document retrieval remains difficult when documents are broken into isolated text chunks and stripped of their original structure.

For long technical manuals, that limitation is significant. These documents depend on page layout, section hierarchy, diagrams, warnings, and cross-references. In such settings, conventional RAG can retrieve relevant language while still missing essential context. PageIndex is promising because it approaches retrieval more like a human reader would: by navigating the document as a structured artifact instead of only as an embedding space.

The conclusion remains cautious, but the direction is clear. PageIndex should not be treated as a universal replacement for RAG, and its public evidence base is still developing. It does point toward a real improvement in document intelligence because it addresses a weakness in text-only retrieval workflows. For industrial maintenance manuals and similar long technical documents, a human-centric retrieval model can offer better completeness, better traceability, and a safer basis for question answering than chunk-based systems alone.

Future work should test these systems with independent evaluations on real-world document collections, not only on public benchmarks or vendor claims. If those evaluations confirm early results, PageIndex-style retrieval may become a valuable standard for document-heavy professional environments.

---

## References

<ul class="ref-list">
  <li>Barnett, S., Kurniawan, S., Thudumu, S., Brannelly, Z., &amp; Abdelrazek, M. (2024). <em>Seven failure points when engineering a retrieval augmented generation system.</em> Proceedings of the First International Conference on AI Engineering: Software Engineering for AI. <a href="https://arxiv.org/abs/2401.05856">https://arxiv.org/abs/2401.05856</a></li>
  <li>Borgeaud, S., Mensch, A., Hoffmann, J., Cai, T., Rutherford, E., Millican, K., … Sifre, L. (2022). <em>Improving language models by retrieving from trillions of tokens.</em> Proceedings of the 39th International Conference on Machine Learning, 2206–2240. <a href="https://proceedings.mlr.press/v162/borgeaud22a.html">https://proceedings.mlr.press/v162/borgeaud22a.html</a></li>
  <li>Karpukhin, V., Oguz, B., Min, S., Lewis, P., Wu, L., Edunov, S., Chen, D., &amp; Yih, W.-t. (2020). <em>Dense passage retrieval for open-domain question answering.</em> Proceedings of the 2020 Conference on Empirical Methods in Natural Language Processing, 6769–6781. <a href="https://aclanthology.org/2020.emnlp-main.550/">https://aclanthology.org/2020.emnlp-main.550/</a></li>
  <li>Lewis, P., Perez, E., Piktus, A., Petroni, F., Karpukhin, V., Goyal, N., … Kiela, D. (2020). <em>Retrieval-augmented generation for knowledge-intensive NLP tasks.</em> Advances in Neural Information Processing Systems, 33. <a href="https://papers.nips.cc/paper/2020/hash/6b493230205f780e1bc26945df7481e5-Abstract.html">https://papers.nips.cc/paper/2020/hash/6b493230205f780e1bc26945df7481e5-Abstract.html</a></li>
  <li>Manning, C. D., Raghavan, P., &amp; Schütze, H. (2008). <em>Introduction to information retrieval.</em> Cambridge University Press. <a href="https://nlp.stanford.edu/IR-book/">https://nlp.stanford.edu/IR-book/</a></li>
  <li>PageIndex. (2026). <em>Vectorless, reasoning-based document intelligence.</em> <a href="https://www.pageindex.dev/">https://www.pageindex.dev/</a></li>
  <li>PageIndex Developer Docs. (2026). <em>What is PageIndex?</em> <a href="https://docs.pageindex.ai/">https://docs.pageindex.ai/</a></li>
  <li>Xu, Y., Li, M., Cui, L., Huang, S., Wei, F., &amp; Zhou, M. (2020). <em>LayoutLM: Pre-training of text and layout for document image understanding.</em> Proceedings of the 26th ACM SIGKDD Conference on Knowledge Discovery and Data Mining, 1192–1200. <a href="https://www.microsoft.com/en-us/research/publication/layoutlm-pre-training-of-text-and-layout-for-document-image-understanding/">https://www.microsoft.com/en-us/research/publication/layoutlm-pre-training-of-text-and-layout-for-document-image-understanding/</a></li>
</ul>

---

## Appendix A — Acknowledgment of Generative AI Use

<div class="tip">

OpenAI's ChatGPT was used as a planning and editorial support tool to help organize the report structure, refine wording, and format draft material for submission. All cited sources were selected and verified by the author, and the final analysis was reviewed and revised by the author before submission.

</div>
