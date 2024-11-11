# Harvard Catalyst Workshop 2024 [![Booklet](https://github.com/tlverse/catalyst2024-workshop/actions/workflows/bookdown.yml/badge.svg)](https://github.com/tlverse/catalyst2024-workshop/actions/workflows/bookdown.yml)

## Course description

In fields ranging from public health and medicine to political science and
economics, great care is required to disentangle intricate causal relationships
using real-world data and inform decision-making efforts. Causal inference has
emerged as a methodological framework for translating substantive questions
into well-defined causal estimands, expressing identification assumptions
necessary for these to be learned from data, and estimating the resultant
quantities via standardization (i.e., outcome regression) and inverse
probability weighting. However, such progress has failed to keep pace with
developments in machine learning; thus, the practice of causal inference is
often marred by over-reliance on restrictive modeling practices. The Targeted
Learning (TL) paradigm presents a solution to this problem by unifying aspects
of semi-parametric statistical theory, machine learning, and causal inference.
The result is a methodological toolbox for evaluating causal effects via
state-of-the-art estimators that are both robust (to model misspecification)
and efficient (minimal variance, i.e., narrowest possible confidence
intervals). This short course introduces the TL paradigm, beginning with the
guiding philosophy and underlying scientific motivations and going on to
discuss estimation algorithms and their practical implementation through
open-source software tools (e.g., the TLverse: <https://github.com/tlverse>),
addressing basic theoretical underpinnings along the way. Specific topics to be
covered include targeted maximum likelihood estimation (TMLE) and collaborative
TMLE (C-TMLE) for confounder selection (and, time permitting, adaptive TMLE
(A-TMLE) for hybrid designs that combine experimental and external data); TMLE
algorithms to estimate the causal effects of interventions on binary and
continuous exposures; complications for addressing time-varying confounding
and/or censoring; and incorporating machine learning via the super learner and
highly adaptive lasso algorithms. This short course incorporates a mix of case
studies, discussion, and hands-on programming exercises to allow participants
to build familiarity with techniques and tools that will translate to
improvements in real-world data analytic practice.

<https://catalyst.harvard.edu/calendar/event/biostatistics-short-course-targeted-learning-bridging-machine-learning-with-causal-and-statistical-inference-november-15/>

## Instructors

- Mark van der Laan, University of California, Berkeley (webpage:
  <https://ctml.berkeley.edu/people/mark-van-der-laan-phd>)
- Nima Hejazi, Harvard T.H. Chan School of Public Health (webpage:
  <https://www.hsph.harvard.edu/profile/nima-s-hejazi/>)

## Recommended background

This course is primarily intended for biostatisticians, epidemiologists, and
applied quantitative scientists. Participants are expected to have had prior
training in statistical inference, including such concepts as conditional
expectation, confidence intervals, hypothesis testing, regression modeling, and
confounding. While some prior knowledge of mathematical statistics may be
useful, it is not necessary for success. Prior experience with programming, and
with the R language for statistical computing and graphics, will be essential.

## Materials

This GitHub repository contains the source materials for a full-day workshop on
Targeted Learning, with some applications demonstrated using the `tlverse`
software ecosystem. Some of the teaching materials are adapted from a draft of
the forthcoming book [*Targeted Learning in `R`: Causal Data Science with the
`tlverse` Software Ecosystem*](https://tlverse.org/tlverse-handbook/), by Mark
van der Laan, Jeremy Coyle, Nima Hejazi, Ivana Malenica, Rachael Phillips, and
Alan Hubbard; the unabridged book is [freely
available](https://tlverse.org/tlverse-handbook).
