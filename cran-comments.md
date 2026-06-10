## Submission

We recognize this resubmission comes sooner than the usual one-month waiting
period following our previous release (0.1.1). We are submitting early because
the bug fixed in this version is user-visible and significant enough that it
has a high probability of discouraging adoption of the package.

The issue stems from an inherent unpredictability in local LLMs: when the
context summary injected into the translation prompt is much longer than the
field being translated, some local models paraphrase the context rather than
translate the input. For short fields (10 words or fewer) this happened
consistently, producing output that was clearly wrong and immediately apparent
to users. There was no workaround available to users short of disabling context
summaries entirely, a feature that was the main addition in 0.1.1.

We apologize for the rapid turnaround and appreciate CRAN's consideration.

- When the input is 10 words or fewer, the context summary is now omitted from
  the translation prompt. Local LLMs can get confused by a context summary that
  is much longer than the field being translated, causing them to paraphrase
  the context instead of translating the input.

## R CMD checks on GitHub

- Windows Server x64 (build 26100) (x86_64, mingw32), R version 4.2.3 (2023-03-15 ucrt)
- Ubuntu 24.04.4 LTS (x86_64, linux-gnu), R Under development (unstable) (2026-06-06 r90114)
- Windows Server 2022 x64 (build 26100) (x86_64, mingw32), R version 4.6.0 (2026-04-24 ucrt)
- Ubuntu 24.04.4 LTS (x86_64, linux-gnu), R version 4.5.3 (2026-03-11)
- macOS Sequoia 15.7.7 (aarch64, darwin23), R version 4.6.0 (2026-04-24)
- Ubuntu 24.04.4 LTS (x86_64, linux-gnu), R version 4.6.0 (2026-04-24)

## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
