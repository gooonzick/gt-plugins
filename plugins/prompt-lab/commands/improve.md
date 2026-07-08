---
description: Improve a prompt — analysis, rewrite with rationale, optional A/B verification by real runs
argument-hint: "[file path or inline prompt text]"
---

Improvement loop for the target below.

1. Invoke the prompt-lab:prompt-analysis skill on it.
2. Rewrite: produce v2 fixing the top findings; annotate every change with its rationale and technique citation from the analysis.
3. Offer verification (user may skip): invoke the prompt-lab:prompt-testing skill comparing original vs v2 (A/B).
4. If v2 loses on any case: iterate on exactly those findings — at most 2 iterations, then report results honestly, even if the original wins.
5. Present the final version and a summary diff. Do not modify the user's file unless asked.

Target:

$ARGUMENTS
