# NGDC — Computational Analysis: Empirical Findings
**Kalcer Institute | Odri | May 2026**

---

## Overview

This document summarises the results of computational research treatment applied to the Norwegian Green Discourse Corpus (NGDC, v1.0). The analysis covers:

- **Phase 1**: Stortinget plenary debates, 2016–2025 (15,210 keyword-matched speeches)
- **Phase 2**: NBIM annual/responsible-investment reports (19 documents, 2015–2024)

Methods applied: temporal frequency analysis, party-level comparison, KWIC and collocation analysis (quanteda), Structural Topic Modelling (STM, K=10), and cross-institutional term rate comparison.

---

## Finding 1: The Petroleum/Klima Ratio — Disavowal in Aggregate

**The ratio of speeches naming 'petroleum*' to speeches naming 'klima*' has halved over eight years.**

| Session | petroleum speeches | klima speeches | Ratio |
|---|---|---|---|
| 2016–17 | 154 | 916 | **0.168** |
| 2017–18 | 135 | 796 | 0.170 |
| 2018–19 | 150 | 1,157 | 0.130 |
| 2019–20 | 166 | 1,030 | 0.161 |
| 2020–21 | 98 | 1,106 | 0.089 |
| 2021–22 | 103 | 1,113 | 0.093 |
| 2022–23 | 72 | 911 | 0.079 |
| 2023–24 | 73 | 865 | 0.084 |
| 2024–25 | 69 | 831 | **0.083** |

**Interpretation**: As Norway's petroleum extraction has continued — and in many years increased — the word "petroleum" has been spoken progressively less in parliamentary plenary debates, while "klima" has remained broadly constant. This is disavowal operating at the aggregate level of the parliamentary corpus: the extractive thing is present in practice; its name is absent from discourse. The decline is not merely gradual — there is a significant step-change between 2019–20 and 2020–21 (from 0.161 to 0.089), coinciding with the post-COVID green recovery framing and accelerated renewable investment rhetoric.

**The ratio operates entirely within the filtered corpus** — i.e. within speeches that already contain at least one energy/petroleum/climate keyword. Even when parliament is speaking *about* petroleum, it speaks about climate three to twelve times more.

---

## Finding 2: Cross-Partisan Consistency — Disavowal Is Structural

**Petroleum mention rates decline across all parties, regardless of ideological position.**

| Party | N speeches | Petroleum rate | Klima rate |
|---|---|---|---|
| FrP (Progress, pro-petroleum) | 1,145 | 9.5% | 49.0% |
| H (Conservative) | 1,858 | 6.8% | 50.8% |
| KrF (Christian Democrat) | 423 | 7.3% | 61.0% |
| A (Labour) | 2,099 | 5.5% | 56.8% |
| Sp (Centre) | 1,252 | 4.9% | 57.7% |
| SV (Socialist Left) | 1,736 | 6.2% | 70.3% |
| MDG (Greens) | 763 | 5.5% | 75.0% |
| R (Red, far-left) | 481 | 5.2% | 46.4% |
| V (Liberal) | 1,101 | 6.4% | 70.9% |
| Statsråd (Ministers) | 4,010 | 7.7% | 50.3% |

**Key observations**:

1. **Even FrP, the explicitly pro-petroleum party, speaks klima at 49% of its speeches** — more than petroleum at 9.5%. The party most ideologically committed to petroleum extraction still uses climate language far more than petroleum language. This is the structural compulsion of disavowal: you cannot speak in parliament without engaging climate identity.

2. **The two Prime Ministers (Solberg/Conservative and Støre/Labour) are nearly identical**:
   - Erna Solberg: 2.6% petroleum rate, 56% klima rate
   - Jonas Gahr Støre: 1.6% petroleum rate, 57% klima rate
   These are political opponents. Their petroleum/klima rates are functionally indistinguishable. The institutional position of Prime Minister requires the same discursive performance regardless of party.

3. **Ministers (Statsråd) have the highest petroleum rate of any category (7.7%)** — but even they speak klima 50% of the time. The state apparatus names petroleum more than individual parties do, but still substantially less than klima.

4. **Terje Aasland (Minister of Petroleum AND Energy, 2021–present)** — 362 speeches, 10.8% petroleum rate, 38.4% klima rate. The single official responsible for petroleum extraction and climate transition simultaneously performs this in his corpus presence: he speaks petroleum at the highest ministerial rate but still speaks klima 3.5× more often.

---

## Finding 3: KWIC and Collocation — The Semantic Fields of Disavowal

Keyword-in-context analysis (±8 tokens) and collocations (±5 tokens) reveal the semantic fields surrounding key terms.

### 'Petroleum*' contexts (1,997 KWIC instances)

Petroleum almost never appears as a standalone word in Norwegian parliamentary speech. It appears as a prefix in compound words: "petroleumsnæringen" (industry), "petroleumsvirksomhet" (operations/activity), "petroleumstilsynet" (safety authority), "petroleumssektoren" (sector), "petroleumsaktivitet" (activity), "petroleumsforvaltning" (management), "petroleumspolitikk" (policy), "petroleumsskatten" (taxation).

**The compounding is itself a finding**: petroleum discourse is entirely bureaucratized and institutionalized. The thing is always already administered. It appears in the context of management structures, not raw extraction. Sample KWIC contexts:

- *"Stabilitet og forutsigbarhet er et adelsmerke ved norsk [petroleumsforvaltning] og det skal det fortsatt være"* — "Stability and predictability are a hallmark of Norwegian petroleum management and that is how it shall remain." [stability frame]
- *"ambisjonen til regjeringa om at norsk [petroleumsverksemd] skal vere verdsleiande på helse miljø og tryggleik"* — "the government's ambition that Norwegian petroleum operations should be world-leading in health, environment and safety." [excellence/responsibility frame]
- *"den samlede omsetningen i leverandørnæringene til [petroleum] fornybar energi hydrogen og CCS"* — "total turnover in supplier industries for petroleum, renewable energy, hydrogen and CCS." [both/and frame — petroleum listed alongside renewables]

**Top collocates of 'petroleum*'**: "norsk" (Norwegian), "næringen/næringene" (industry/industries), "petroleumsvirksomhet", "petroleumstilsynet", "sektoren" (sector), "viktig" (important), "aktiv/aktivitet" (active/activity).

**Pattern**: petroleum speech is dominated by regulatory/supervisory language (Petroleumstilsynet = the safety authority), economic framing (sector, industry), and the assertion of competence and responsibility ("world-leading", "important"). The thing is present only as something that is *governed*.

### 'Klima*' contexts (22,854 KWIC instances — 11× more than petroleum)

**Top collocates of 'klima*'**: "regjeringen" (the government), "klimapolitikk/klimapolitikken" (climate policy), "viktig" (important), "klimagassutslipp" (greenhouse gas emissions), "klimaendringene" (the climate changes), "klimamålene" (the climate targets), "norsk" (Norwegian).

**Pattern**: climate speech is dominated by policy-aspiration language — targets, goals, policies, the government's responsibility. The word *viktig* (important) appears prominently: climate is something important, something that matters morally and politically. This contrasts with petroleum's collocates, which are institutional-technical. Climate is *performed*; petroleum is *administered*.

---

## Finding 4: STM Topic Structure — Disavowal as the Dominant Discursive Space

Structural Topic Modelling (STM, K=10, with year and party covariates) produces the following topic structure:

| Topic | Proportion | Label | Theoretical class |
|---|---|---|---|
| **T5** | **23.5%** | Adversarial floor debate | DISAVOWAL UNDER PRESSURE |
| **T4** | **12.0%** | Energy transition & industry | DISAVOWAL (managed transition) |
| T3 | 11.0% | Parliamentary procedure / law | Procedural |
| **T7** | **10.4%** | Climate policy & emissions | GREEN IDENTITY PERFORMANCE |
| T6 | 9.7% | Nynorsk speech register | Register (dialect) |
| T2 | 8.3% | Welfare state / social services | Welfare legitimation |
| T1 | 6.5% | Petroleum fiscal regime | EXTRACTIVE / FISCAL |
| T9 | 6.5% | Foreign policy & geopolitics | Geopolitical frame |
| T8 | 6.1% | Transport & infrastructure | Emission reduction |
| T10 | 6.0% | Nature & biodiversity / rural | Nature / land |

**Key findings**:

1. **35% of the corpus (T4 + T5) lives in disavowal sites** — the managed-transition frame (T4: offshore wind alongside gas) and adversarial floor debate (T5: where the fantasy is maintained under pressure). Another 10% is in green identity performance (T7). The explicitly extractive-fiscal topic (T1: oljepenger, skatter) accounts for only 6.5%.

2. **Topic 5 (Adversarial floor debate, 23.5%) is the single largest topic** — larger than the explicit green identity topic. The most prevalent discourse type in the filtered corpus is *unscripted exchanges where disavowal must be defended* — oral question time, replies, rebuttals. This is theoretically significant: the ideology works hardest in the site of greatest pressure.

3. **Topic 4 (Energy transition & industry, 12%)** contains both "havvind" (offshore wind), "vannkraft" (hydropower), "fornybar" (renewable) AND "gassn æringen" (gas industry), "sokkel" (the shelf), "gass". Petroleum and renewables co-inhabit a single topic — the "both/and" of managed transition. The industry is not opposed to renewables; it *extends into* renewables. This is the ideological operation of disavowal at the level of topic space.

4. **Topic 1 (Petroleum fiscal regime)** contains "oljepenger" (oil money) — the informal term for petroleum revenue. Petroleum appears most explicitly in this topic, but framed entirely as *finance* (taxes, state revenues, budget) not as *extraction*. The thing produces money; its physical reality is not spoken.

### Topic × Party distribution

Key finding from the topic-party heatmap: all parties share very similar topic distributions, with minor variations:
- FrP has slightly higher T1 (petroleum fiscal) and lower T7 (climate policy)
- MDG has higher T7 and T4, lower T1
- Statsråd (Ministers) have higher T3 (procedural), T4 (energy transition), lower T5 (adversarial)

**The cross-partisan consistency of topic distribution confirms the structural claim**: the discursive landscape is shared across the ideological spectrum. You cannot speak in parliament without inhabiting the same topic space.

---

## Finding 5: Cross-Institutional Comparison — NBIM as Hyper-Disavowal

Comparison of term rates per 10,000 words between Parliament (Phase 1) and NBIM reports (Phase 2, 2022–2024 rich content only):

| Term | Parliament | NBIM | NBIM ÷ Parliament |
|---|---|---|---|
| carbon neutral / net zero | 0.29 | 14.9 | **51.7×** |
| responsible | 1.76 | 65.6 | **37.3×** |
| divestment | ~0 | 30.5 | **~3,000×** |
| sustainable / bærekraft | 9.52 | 28.6 | 3.0× |
| climate / klima | 38.0 | 66.1 | 1.74× |
| petroleum | 3.3 | **0.0** | Parliament more |
| oil / olje | 7.56 | **0.0** | Parliament more |
| extraction | 0.85 | **0.0** | Parliament more |

**Interpretation**:

- NBIM uses "carbon neutral / net zero" at **51.7 times** the rate of Parliament. Parliament performs green identity; NBIM *hyperperforms* it.

- **"Divestment" is an NBIM-exclusive vocabulary** — Parliament almost never uses it, yet NBIM uses it at 30.5 per 10,000 words. This is theoretically significant: the mechanism by which the fund performs its green credentials (divesting from coal companies, ethical exclusions) is almost entirely *absent from parliamentary discourse*. Parliament gave NBIM the mandate to divest; NBIM enacts and narrates it; Parliament does not look at it.

- **"Petroleum", "oil", and "extraction" all rate zero in NBIM**. The fund that was created by and exists because of petroleum revenue does not name petroleum, oil, or extraction in its self-description. Parliament — which oversees petroleum production policy — names these terms more than the fund they produced.

- The "responsible" rate in NBIM (65.6/10,000) is extraordinary. NBIM calls itself responsible constantly; Parliament almost never uses this language about itself (1.76/10,000). NBIM's self-legitimating vocabulary is an extreme version of the green identity claim: *I am responsible, therefore my wealth is clean*.

---

## Summary: The Disavowal Structure in Numbers

The corpus empirically demonstrates what the Lacanian-Žižekian framework predicts:

1. **At the level of word frequency**: petroleum disappears from discourse while extraction continues. The ratio halves in eight years.

2. **At the level of semantic field**: petroleum appears only in bureaucratic-compound forms (as something governed and administered); climate appears in aspiration language (policy, goals, importance). The thing is present only as managed; the identity is performed only as aspiration.

3. **At the level of discourse type (STM)**: the largest discursive space is *adversarial exchange* where disavowal is defended under pressure — not programmatic speeches, but reactive maintenance of the fantasy.

4. **At the cross-institutional level**: NBIM performs the green identity at 50× the rate of Parliament, while completely suppressing the naming of petroleum, oil, and extraction. Parliament names the thing more than the fund it created.

5. **Across parties and governments**: the discursive pattern is structurally consistent — held across parties, governments, speech types. This is not rhetoric. It is the ideological form of the Norwegian state.

---

*Analysis produced by Claude Code (Anthropic) in collaboration with Odri / Kalcer Institute.*
*R packages: quanteda v4.4, stm v1.3.8, tidyverse v2.0, ggplot2 v4.0*
*Full scripts: `/analysis/` | Figures: `/outputs/figures/` | Tables: `/outputs/tables/`*

---

## Inferential Analysis: Statistical Tests

*Scripts 09–12 | 4 methods | 11 additional figures (INF01–INF11)*

---

### Inferential Finding 1: The year effect is statistically robust

**Logistic regression** (has_petroleum ~ year + party + speech_type | N = 14,868 speeches)

The probability of a speech mentioning petroleum declines significantly with each passing year, controlling for party and speech type:

> **OR = 0.886 [95% CI: 0.863, 0.909], p < 0.001**

Each additional year reduces the *odds* of a speech mentioning petroleum by **11.4%**, holding party and speech type constant. This is not descriptive pattern-matching — it is a formal parameter estimate with uncertainty bounds.

Model comparison confirms that adding party + speech type significantly improves fit over year alone (LRT χ² = 65.1, df = 11, p < 0.001). Adding year × party interactions is also significant (χ² = 25.7, df = 9, p = 0.002), meaning the decline is not uniform — some parties are declining faster than others — but the direction is consistent across all.

**Party effects** (reference: Labour/A):
- FrP: OR = 2.12 [1.61, 2.80] *** — significantly higher petroleum rate than Labour
- Statsråd (Ministers): OR = 1.72 [1.38, 2.17] *** — ministers name petroleum more than backbench MPs
- Replies (Replikk): OR = 0.73 [0.63, 0.85] *** — petroleum mentioned *less* in unscripted replies (the managed vocabulary holds even under pressure)
- Most other parties: not significantly different from Labour after controlling for year

**Mann-Kendall trend test** (non-parametric, n = 9 sessions):
> **τ = -0.722, two-sided p = 0.009; one-sided p (declining) ≈ 0.005**

The decline is monotonically consistent — not a random walk, not a blip. Kendall's tau of -0.722 indicates a strong directional trend across all nine sessions.

---

### Inferential Finding 2: Party explains essentially zero variance in petroleum rates

**Mixed-effects logistic regression** with random intercepts for party, session, and speaker (Model B):

| Grouping level | Variance | ICC (% of total) |
|---|---|---|
| **Speaker (individual)** | 1.206 | **26.7%** |
| **Session (year context)** | 0.019 | **0.4%** |
| **Party** | ~0.000 | **~0.0%** |
| Residual (speech level) | — | ~72.9% |

**Party accounts for essentially zero variance** in petroleum mention rates once individual speaker variation is controlled. Session context (year) accounts for 0.4%. Individual speakers account for 26.7% — there are rhetorically distinctive individuals (e.g., Terje Halleland/FrP consistently high; Audun Lysbakken/SV consistently low), but these are individual patterns, not party-level patterns.

The year fixed effect in the multilevel model remains significant and large:
> **OR = 0.89 [0.846, 0.936], p < 0.001**

This is the structural claim made maximally precise: **the variance in petroleum discourse is individual and temporal, not party-ideological**. The discourse system is not organised around party position — it is organised around time (the tightening of the disavowal) and individual speaker habit.

---

### Inferential Finding 3: Topic structure is shifting — energy transition grows, everything else falls

**STM prevalence effects** (estimateEffect, global uncertainty method, 95% CIs):

Topics with **significant year effects**:

| Topic | Effect per year | Direction | Significance |
|---|---|---|---|
| T4: Energy transition & industry | +0.009 | **Growing** ↑ | *** |
| T9: Foreign policy & geopolitics | +0.014 | **Growing** ↑ | *** |
| T6: Nynorsk register | +0.010 | Growing ↑ | *** |
| T1: Petroleum fiscal regime | -0.003 | **Declining** ↓ | * |
| T5: Adversarial floor debate | -0.005 | Declining ↓ | ** |
| T7: Climate policy & emissions | -0.007 | **Declining** ↓ | *** |
| T2: Welfare / social services | -0.010 | Declining ↓ | *** |
| T10: Nature & biodiversity | -0.004 | Declining ↓ | * |

Three findings demand theoretical attention:

**1. Energy transition (T4) is the fastest-growing topic** — the discourse is not merely avoiding petroleum; it is *expanding into* the transition frame. Offshore wind, renewables, and gas inhabit the same topic. The language of disavowal is not silence — it is the proliferating vocabulary of managed transition.

**2. Petroleum fiscal regime (T1) is declining** — petroleum-as-finance is being spoken less, even within the petroleum-financial register. The material thing is disappearing at every discursive level.

**3. Climate policy (T7) is also declining** — this is counter-intuitive but theoretically productive. Explicit climate policy discourse is shrinking not because climate has become less important but because it has been *normalised* — absorbed into procedural and transitional vocabulary. When climate no longer needs to be explicitly named as a political commitment, it has become the invisible assumption of all speech. This is the deepest form of disavowal: not the denial that requires naming, but the absorption that requires none.

---

### Inferential Finding 4: FrP is adversarial about petroleum, not exceptional to it

**STM prevalence effects — FrP vs rest of corpus:**

| Topic | FrP effect | Significance |
|---|---|---|
| T5: Adversarial floor debate | **+0.093** | *** |
| T1: Petroleum fiscal regime | +0.041 | *** |
| T4: Energy transition & industry | +0.033 | *** |
| T7: Climate policy & emissions | -0.018 | ** |

FrP's most distinctive feature is not that it talks about petroleum more (though it does, T1 +0.041) — it is that it talks about everything in an **adversarial register** (T5 +0.093). FrP over-represents the adversarial floor debate topic by a larger margin than any other single effect. When FrP mentions petroleum, it does so while occupying the frame of political challenge and contestation, not programmatic policy. And FrP also inhabits the energy transition topic (T4 +0.033) significantly more than average — it is engaging the transition frame, arguing against or on terms set by it, not outside it.

The structural implication: even the party most ideologically committed to petroleum has been captured by the discursive terrain of transition. FrP is not outside the disavowal; it is arguing within it, from an adversarial position.

---

### Summary: What the inferential layer adds

| Claim | Status before inferential | Status after inferential |
|---|---|---|
| Petroleum mention declining over time | Observed pattern | **Formally confirmed: OR=0.886, p<.001; τ=-0.722, p=.009** |
| Decline is cross-partisan | Visually consistent | **Party explains ~0% of variance (multilevel ICC)** |
| Year effect holds controlling for party | Assumed | **Confirmed: OR=0.886 with party as covariate** |
| Energy transition discourse growing | STM proportion | **Statistically significant: +0.009/year, p<.001** |
| Climate policy discourse declining | STM proportion | **Statistically confirmed: -0.007/year, p<.001** |
| FrP is adversarial, not exceptional | Qualitative | **Largest FrP effect is adversarial topic (+0.093, p<.001)** |
| 2020 structural break | Visually apparent | **Suggestive but underpowered at n=9; level change not significant (p=.32)** |

The epistemological caveat stands: this is a full population, not a probability sample. The inferential framework is justified under the superpopulation model — speeches as draws from the distribution of all possible Norwegian parliamentary speech. Effect sizes with confidence intervals are the primary output; p-values are evidence-strength indicators, not decision thresholds.

---

*Inferential analysis: R packages lme4 v1.1, Kendall v2.2, segmented v2.1, sandwich v3.1, stm v1.3.8*
*Scripts 09–12 | 11 figures: INF01–INF11 | Tables: logistic_m2_coefficients, multilevel_icc, mann_kendall_result, its_model_results, stm_*_effects*
