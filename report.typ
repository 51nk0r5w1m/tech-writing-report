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
    #text(20pt, weight: "bold", fill: white)[Retrieval-Augmented Generation vs. Human-Curated Knowledge Systems]
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

Organizations across all sectors depend on reliable access to knowledge to make informed decisions, serve customers, and meet compliance requirements. Two distinct approaches have emerged for managing and retrieving that knowledge at scale: Retrieval-Augmented Generation (RAG), which combines artificial intelligence with automated document search, and human-curated knowledge systems, which rely on expert-organized repositories built for consistency and accountability. This report compares these approaches across three critical dimensions: accuracy, scalability, and operational tradeoffs. Drawing on research in information retrieval, knowledge management, and artificial intelligence, the report synthesizes current findings and evaluates the practical implications of each method. The literature indicates that RAG systems offer meaningful advantages in scalability, adaptability, and semantic search capability, while human-curated systems provide reliability and accountability that are difficult to replicate automatically. Emerging hybrid models suggest that the future of organizational knowledge management lies in combining both approaches. The report also identifies key gaps in current research, including the absence of standardized evaluation frameworks and limited real-world deployment studies.

= Introduction

The way organizations manage knowledge has always shaped their ability to operate efficiently, serve their users, and respond to change. For decades, the standard answer was human curation: subject-matter experts wrote, reviewed, and maintained structured repositories of organizational knowledge — internal wikis, policy manuals, training databases, and help desk libraries. These systems are still widely used and, in many professional domains, remain the accepted baseline for reliable information.

That baseline is now being challenged. The rapid development of large language models has produced AI-driven systems capable of retrieving and synthesizing information with far less human oversight than traditional approaches require. The most prominent of these is Retrieval-Augmented Generation, or #emph[RAG] — a method that retrieves relevant documents at the moment a question is asked and uses that retrieved evidence to generate a response. Where a human-curated system requires someone to write every answer in advance, RAG generates answers on demand, grounded in whatever documents the system can find.

The comparison between these two approaches carries real consequences for how organizations invest in knowledge infrastructure. Understanding when automated retrieval adds genuine value, when human curation is still necessary, and how the two can complement each other requires more than enthusiasm for new technology — it requires a clear look at what the research evidence actually shows.

This report examines that evidence. It synthesizes current research on accuracy, scalability, and operational tradeoffs for both RAG and human-curated systems, identifies emerging trends, and highlights the gaps that most need to be addressed before organizations can confidently build on either approach.

= Literature Review

== Evolution of Knowledge Retrieval

Knowledge retrieval has gone through several distinct phases, each driven by the limitations of the approach before it. Early systems were built on keyword indexing — a user typed search terms, and the system returned documents that contained those exact words. Manning et al. (2008) describe this approach in detail: it is efficient and predictable, but it breaks down whenever a user's phrasing differs from the document's wording. A practical example makes this concrete: an employee searching for "refund policy for damaged goods" may find nothing if the relevant document uses the phrase "returns for defective merchandise." To a keyword system, these are entirely different queries.

Dense retrieval emerged as a response to that fragility. Instead of matching words directly, dense retrieval converts both queries and documents into numerical vectors — essentially coordinates in a mathematical space where similar meanings cluster near one another. Karpukhin et al. (2020) demonstrated that this approach significantly outperforms keyword matching on real question-answering benchmarks, improving top-20 retrieval accuracy by substantial margins. In practical terms, dense retrieval means a system can recognize that "refund for damaged goods" and "returns for defective merchandise" are semantically equivalent, even without sharing a single word.

These advances set the stage for Retrieval-Augmented Generation. Lewis et al. (2020) introduced RAG as a framework that combines document retrieval with generative language models: instead of asking a model to answer from memory alone, RAG first retrieves relevant documents and generates a response grounded in that evidence. This design reduces a well-documented problem in language models called #emph[hallucination] — the tendency to generate confident but incorrect answers — by anchoring responses to real source material rather than relying on what the model was trained to remember.

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
    node((1, 0), text(fill: white, size: 8.5pt)[Dense Retrieval]),
    edge("-|>"),
    node((2, 0), text(fill: white, size: 8.5pt)[RAG]),
    edge("-|>"),
    node((3, 0), text(fill: white, size: 8.5pt)[Human-Curated]),
    edge("-|>"),
    node((4, 0), text(fill: white, size: 8.5pt)[Hybrid Models]),
  ))),
  caption: [Figure 1. Evolution of knowledge retrieval approaches. Each stage addressed a key weakness of the one before it, progressing from exact word matching toward systems that combine automated retrieval with human oversight.]
)

Figure 1 places these developments in sequence. The field did not move from simple search to AI-generated answers in one leap. Each transition addressed a specific failure, and today's most promising approaches — hybrid models — reflect the accumulated lessons of every stage before them.

== Accuracy and Reliability

Accuracy is one of the most studied dimensions of RAG performance, and the research findings are largely consistent: RAG systems produce more factually grounded responses than standalone generative models. Lewis et al. (2020) showed this directly on open-domain question-answering tasks. The reason is intuitive — a model that consults a source document before answering is less likely to fabricate information than one generating an answer purely from memory.

Borgeaud et al. (2022) extended this finding in a practically important direction: retrieval-enhanced models can match the accuracy of much larger standalone models. In other words, a smaller AI system that can search external documents often outperforms a far larger AI system that cannot. Both OpenAI (2023) and Microsoft (2023) reflect this consensus in their technical guidance, recommending retrieval grounding as a key strategy for improving reliability and enabling users to verify AI responses against their sources.

The important caveat is that RAG accuracy depends entirely on the quality of what is retrieved. Karpukhin et al. (2020) are direct about this dependency: even a capable language model cannot compensate for retrieving the wrong document. If the retrieval step fails — because the query is ambiguous, the relevant document is poorly indexed, or the right source simply is not in the collection — the generated response may be fluent and confident while being factually wrong. Retrieval grounding reduces hallucination; it does not eliminate error.

Human-curated systems approach accuracy from a fundamentally different direction. Rather than relying on automated retrieval, they depend on domain experts who verify and organize every piece of information before it enters the knowledge base. Alavi and Leidner (2001) explain that this expert oversight is precisely what gives curated systems their reliability, particularly in high-stakes domains like healthcare, law, and government where a single incorrect answer can have serious consequences. The cost of that reliability is scope: a curated system can only answer questions about what has already been documented and reviewed, and it cannot dynamically synthesize new answers from multiple sources the way RAG can.

== Scalability and Maintenance

The two approaches diverge sharply on scalability, and the research is clear. RAG systems are designed to grow without requiring proportional increases in human labor. Once the retrieval infrastructure is in place, adding new documents to the index is relatively straightforward, and the system can handle larger query volumes without additional headcount. Borgeaud et al. (2022) identify this as one of retrieval-based architecture's most significant practical advantages for organizations operating at scale.

Human-curated systems scale at the pace of human effort. Every document must be written by someone with relevant expertise, reviewed for accuracy, and organized within a structure that supports findability. Davenport and Prusak (1998) describe the organizational reality plainly: maintaining a large knowledge repository requires continuous investment — not only in people, but in the ongoing processes that keep content current and consistent. As the repository grows, so does the cost of keeping it accurate.

Adaptability presents a related contrast. When information changes — new regulations take effect, products are revised, policies are updated — RAG systems can incorporate those changes by updating the document index, without any model retraining (Lewis et al., 2020). Human-curated systems require a review cycle: new content must be written, checked, and approved before it reaches users. During periods of rapid change, this lag can leave users working from outdated material without knowing it.

== Tradeoffs and Emerging Hybrid Models

RAG's scalability and adaptability advantages come with genuine costs. Building a RAG system requires specialized technical infrastructure: vector databases, embedding pipelines, language model APIs or deployments, and ongoing monitoring. These demands place RAG out of reach for many smaller organizations without dedicated technical staff. There is also a transparency problem — it can be difficult to explain precisely why a particular document was retrieved and used in a specific response, a real concern in any context where decisions need to be audited or justified to stakeholders.

Human-curated systems offer a different kind of value: accountability. Every entry was reviewed by a person, errors can be traced and corrected, and the basis for any given answer is clear. In regulated industries, this is not merely a preference — it is a compliance requirement. The limitation is that human-curated systems are less equipped to handle the volume, variety, and pace of change that many modern organizations face.

Researchers and practitioners are increasingly exploring hybrid designs that aim to capture both strengths. In the most common approach, human experts maintain an authoritative knowledge base that serves as the retrieval corpus, while a RAG system provides flexible, natural-language access to that corpus. Users get the reliability of human-reviewed content with the conversational ease of AI-powered querying. This model is gaining traction precisely because it treats human curation and automated retrieval as complementary rather than competing.

== Gaps and Areas for Future Research

Despite meaningful progress, several important questions remain unresolved. First, most RAG evaluations use controlled benchmark datasets rather than data from real production deployments, making it difficult to assess how these systems actually perform over time with real-world queries and edge cases. Second, questions of bias and explainability persist: the mechanisms that determine which documents are retrieved — and therefore which information shapes a response — are not yet fully understood, and systematic bias in those mechanisms is a genuine risk that has not been fully characterized.

Third, no standardized framework currently exists for comparing RAG and human-curated systems across practically important dimensions such as maintenance cost, long-term usability, and user trust. Without common metrics, organizations cannot benchmark their choices with confidence. Fourth, hybrid models, though promising, remain relatively understudied in the research literature. Practical guidance on how to design, govern, and evaluate these systems in enterprise settings is limited. Addressing these four gaps is the field's most pressing unfinished work.

= Discussion

The research literature supports a nuanced conclusion: neither RAG nor human-curated systems is superior in every context. The more useful question is which approach fits a given organization's specific needs — a judgment that depends on the nature of the information, the stakes of errors, the pace of change in that domain, and the technical resources available.

#figure(
  fig-table(
    columns: (auto, 1fr, 1fr),
    table.header(
      [Dimension],
      [RAG Systems],
      [Human-Curated Systems],
    ),
    [Retrieval method], [Automated via vector similarity search], [Manual browse, keyword, or structured navigation],
    [Accuracy dependency], [Depends on retrieval quality and index coverage], [Depends on expert review and content completeness],
    [Scalability], [High; scales with infrastructure, not headcount], [Limited; scales only as fast as human capacity],
    [Update speed], [Fast; index updates require no model retraining], [Slower; new content requires a full review cycle],
    [Transparency], [Limited; retrieval logic is often opaque], [High; every entry is human-reviewed and traceable],
    [Infrastructure cost], [Significant specialized technical stack required], [Lower technical barrier; higher ongoing labor cost],
    [Best suited for], [Large, dynamic knowledge bases with varied queries], [High-stakes, regulated domains requiring verified answers],
  ),
  caption: [Table 1. Comparative overview of RAG and human-curated knowledge systems across key dimensions. Based on synthesis of Lewis et al. (2020), Borgeaud et al. (2022), Karpukhin et al. (2020), Alavi and Leidner (2001), and Davenport and Prusak (1998).]
)

Table 1 shows that the differences between these approaches are not simply a matter of new versus old, or AI versus human. They reflect fundamentally different assumptions about where reliability comes from. RAG systems assume that a well-indexed document corpus and a capable retrieval pipeline will surface the right information when needed. Human-curated systems assume that expert review at the point of content creation is the most reliable form of quality control. Both assumptions are defensible — in their respective contexts.

A concrete example illustrates the tradeoffs. Consider a large healthcare organization managing employee questions about benefits, compliance, and clinical procedures. A human-curated system guarantees that every answer has been verified by a compliance expert — but it may take weeks to incorporate a new regulatory change, and employees who phrase questions differently from the system's keyword structure may not find what they need. A RAG system can handle natural-language queries and update quickly when regulations change — but in a clinical context, a retrieval error that causes an employee to act on incomplete information about a medication policy has real consequences. A hybrid model — where compliance experts maintain the authoritative source documents and a RAG system provides natural-language access to them — addresses both concerns at once.

#figure(
  panel-block(align(center, {
    set text(fill: ink, size: 8.5pt)
    let criteria = ("Accuracy", "Scalability", "Adaptability", "Transparency", "Usability")
    let xs = (0, 1, 2, 3, 4)
    let rag = (4, 5, 5, 2, 4)
    let hc = (5, 2, 2, 5, 3)
    let hybrid = (4, 4, 4, 4, 5)
    let w = 0.25
    lq.diagram(
      width: 11cm,
      height: 6cm,
      ylim: (0, 5.5),
      xaxis: (ticks: xs.zip(criteria), subticks: none),
      lq.bar(
        xs.map(x => x - w),
        rag,
        width: w,
        color: accent-amber,
        label: [RAG],
      ),
      lq.bar(
        xs,
        hc,
        width: w,
        color: accent-blue,
        label: [Human-Curated],
      ),
      lq.bar(
        xs.map(x => x + w),
        hybrid,
        width: w,
        color: accent-green,
        label: [Hybrid],
      ),
    )
  })),
  caption: [Figure 2. Comparative performance scores for RAG, human-curated, and hybrid knowledge systems across five organizational dimensions. Scores reflect qualitative synthesis of research literature on a 0–5 scale; they are not derived from a single empirical study.]
)

Figure 2 makes the complementary nature of these approaches visually clear. RAG systems lead on scalability and adaptability. Human-curated systems lead on accuracy and transparency. Hybrid models score competitively across all five dimensions and achieve the highest usability rating — because they combine the natural-language accessibility of RAG with the reliability of curated content. The consistent picture in the literature is that organizations choosing between these approaches should focus less on which is better in the abstract and more on which characteristics matter most for their specific situation.

The trust dimension deserves particular attention. In regulated or public-facing environments, users and auditors need to trace how an answer was generated and verify that it reflects authoritative, reviewed information. Human-curated systems make this straightforward. RAG systems make it harder, even when source citations are attached to outputs, because the retrieval process itself — the decision about which documents to surface and how to weight them — often remains opaque. Hybrid models, by grounding RAG retrieval in human-curated corpora, can significantly narrow this transparency gap while preserving the scalability advantages that make RAG valuable.

#figure(
  fig-table(
    columns: (auto, 1fr, 1fr, 1fr),
    table.header(
      [Criterion],
      [RAG],
      [Human-Curated],
      [Hybrid],
    ),
    [Handles natural-language queries], [Strong], [Weak], [Strong],
    [Adapts to new information quickly], [Strong], [Limited], [Strong],
    [Provides auditable, traceable answers], [Moderate], [Strong], [Strong],
    [Operates at high query volume], [Strong], [Limited], [Strong],
    [Meets regulatory accountability requirements], [Marginal], [Strong], [Strong],
    [Suitable for small organizations], [Moderate], [Strong], [Moderate],
  ),
  caption: [Table 2. Application-level evaluation of knowledge system approaches across six organizational criteria. Based on synthesis across Lewis et al. (2020), Alavi and Leidner (2001), Borgeaud et al. (2022), and Davenport and Prusak (1998).]
)

Table 2 translates the abstract comparison into specific organizational scenarios. The pattern that emerges is consistent: RAG handles volume and variety well; human-curated systems handle accountability and auditability well; hybrid systems handle both. The practical implication is that organizations in regulated industries or with significant compliance obligations should plan for hybrid architectures rather than treating RAG as a full replacement for human curation.

= Conclusion

The research literature tells a consistent story. The evolution from keyword search to dense retrieval to Retrieval-Augmented Generation represents genuine progress in how information systems handle the complexity of human language. RAG offers scalability, adaptability, and semantic understanding that human-curated systems cannot match at scale. Human-curated systems offer reliability, accountability, and auditability that RAG currently struggles to replicate. Neither approach is adequate alone for the full range of organizational needs.

The most actionable finding from the literature is that hybrid models — where human expertise defines and maintains the knowledge foundation, and AI-powered retrieval provides flexible access — represent the most promising direction for enterprise knowledge management. This is not a compromise between competing approaches. It is a recognition that their strengths are genuinely complementary, and that combining them produces systems that outperform either alternative on the dimensions that matter most in practice: accuracy, usability, transparency, and scalability together.

What the literature does not yet provide is the practical guidance organizations need to design, implement, and evaluate these systems with confidence. The gaps identified in this report — limited real-world deployment evidence, unresolved bias and explainability challenges, the absence of standardized comparison frameworks, and the underdevelopment of hybrid system governance — are not minor theoretical footnotes. They represent the gap between recognizing that hybrid models are promising and knowing how to build them well. Closing those gaps is the field's most important near-term task, and it requires research conducted in real production environments, not only on academic benchmarks.

= Reference Page

[Alavi, M., & Leidner, D. E. (2001). #emph[Knowledge management and knowledge management systems: Conceptual foundations and research issues]. MIS Quarterly, 25(1), 107–136. https://www.jstor.org/stable/3250961]

[Borgeaud, S., Mensch, A., Hoffmann, J., Cai, T., Rutherford, E., Millican, K., van den Driessche, G., Lespiau, J.-B., Damoc, B., Clark, A., de Las Casas, D., Guy, A., Menick, J., Ring, R., Hennigan, T., Huang, S., Maggiore, L., Jones, C., Cassirer, A., ... Sifre, L. (2022). #emph[Improving language models by retrieving from trillions of tokens]. DeepMind. https://www.deepmind.com/publications/improving-language-models-by-retrieving-from-trillions-of-tokens]

[Davenport, T. H., & Prusak, L. (1998). #emph[Working knowledge: How organizations manage what they know]. Harvard Business School Press. https://hbr.org/product/working-knowledge-how-organizations-manage-what-they-know/10566]

[Karpukhin, V., Oguz, B., Min, S., Lewis, P., Wu, L., Edunov, S., Chen, D., & Yih, W.-t. (2020). #emph[Dense passage retrieval for open-domain question answering]. Proceedings of the 2020 Conference on Empirical Methods in Natural Language Processing, 6769–6781. https://arxiv.org/abs/2004.04906]

[Lewis, P., Perez, E., Piktus, A., Petroni, F., Karpukhin, V., Goyal, N., Kuttler, H., Lewis, M., Yih, W.-t., Rocktaschel, T., Riedel, S., & Kiela, D. (2020). #emph[Retrieval-augmented generation for knowledge-intensive NLP tasks]. Advances in Neural Information Processing Systems, 33. https://arxiv.org/abs/2005.11401]

[Manning, C. D., Raghavan, P., & Schütze, H. (2008). #emph[Introduction to information retrieval]. Cambridge University Press. https://nlp.stanford.edu/IR-book/]

[Microsoft. (2023). #emph[Retrieval-augmented generation (RAG) and LLMs]. Microsoft Azure Architecture Center. https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/rag]

[OpenAI. (2023). #emph[Improving factual accuracy with retrieval]. OpenAI Platform Documentation. https://platform.openai.com/docs/guides/retrieval]

= Appendix

== Appendix A. Acknowledgment of Generative AI Use

OpenAI's ChatGPT was used as a planning and editorial support tool to help organize the report structure, refine wording, and format draft material for submission. All cited sources were selected and verified by the author, and the final analysis was reviewed and revised by the author before submission.
