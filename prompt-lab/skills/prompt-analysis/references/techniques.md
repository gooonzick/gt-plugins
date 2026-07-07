# Technique Catalog

Curated from the Prompt Engineering Guide (promptingguide.ai). Cite the link whenever a finding or a creation decision applies a technique.

## Zero-shot prompting
**Essence:** direct instruction, no examples; relies on the model's instruction tuning.
**Apply when:** common task, well-specified instructions, capable model.
**Skip when:** unusual output format or fine-grained style — add examples instead.
**Guide:** https://www.promptingguide.ai/techniques/zeroshot

## Few-shot prompting
**Essence:** 2–5 input→output demonstrations; the model infers format, style, and labeling rules.
**Apply when:** format easier to show than describe; nonstandard labels; consistency across many runs matters.
**Skip when:** examples would exceed the value (simple tasks) or anchor the model too hard on surface patterns.
**Guide:** https://www.promptingguide.ai/techniques/fewshot

## Chain-of-thought (CoT)
**Essence:** ask for intermediate reasoning before the answer ("reason step by step, then answer").
**Apply when:** multi-step logic, math, planning — and the model is NOT a reasoning model.
**Skip when:** reasoning models (they deliberate natively; explicit CoT can degrade them); trivial lookups; latency-critical paths.
**Guide:** https://www.promptingguide.ai/techniques/cot

## Self-consistency
**Essence:** sample several CoT paths, take the majority answer.
**Apply when:** high-stakes single answers where sampling N× is affordable.
**Skip when:** open-ended generation (no vote possible).
**Guide:** https://www.promptingguide.ai/techniques/consistency

## Generated knowledge
**Essence:** have the model first produce relevant facts, then answer using them.
**Apply when:** answers improve with explicit recalled context; commonsense-heavy tasks.
**Guide:** https://www.promptingguide.ai/techniques/knowledge

## Prompt chaining
**Essence:** split one big prompt into sequential focused prompts, each consuming the previous output.
**Apply when:** one prompt does extraction AND transformation AND formatting — and fails at one of them; debugging opaque monoliths.
**Guide:** https://www.promptingguide.ai/techniques/prompt_chaining

## Tree of thoughts (ToT)
**Essence:** explore multiple reasoning branches with evaluation and backtracking.
**Apply when:** search/planning problems where greedy single-path reasoning dead-ends.
**Skip when:** anything simpler works — this is expensive.
**Guide:** https://www.promptingguide.ai/techniques/tot

## Retrieval-augmented generation (RAG)
**Essence:** retrieve relevant documents and ground the answer in them.
**Apply when:** answers depend on private, fresh, or voluminous knowledge; hallucination on facts is the failure mode.
**Guide:** https://www.promptingguide.ai/techniques/rag

## ReAct
**Essence:** interleave reasoning with tool actions (thought → action → observation loops).
**Apply when:** the task needs external information or side effects mid-reasoning (agents).
**Guide:** https://www.promptingguide.ai/techniques/react

## Reflexion
**Essence:** the model critiques its own output and retries with the critique as feedback.
**Apply when:** verifiable outputs (tests, schemas) so critique has teeth.
**Guide:** https://www.promptingguide.ai/techniques/reflexion

## Meta-prompting
**Essence:** structure-first prompting — describe the shape and process of the solution rather than content examples.
**Apply when:** token-efficient alternative to few-shot for structured reasoning tasks.
**Guide:** https://www.promptingguide.ai/techniques/meta-prompting

## Automatic prompt engineering (APE)
**Essence:** use a model to generate and select prompt candidates by score.
**Apply when:** you have an eval to score candidates against (pairs naturally with prompt-testing).
**Guide:** https://www.promptingguide.ai/techniques/ape
