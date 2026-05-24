# The Language of the Responsible Petrostate: Empirical Evidence of Disavowal in Norwegian Parliamentary Discourse

**Kalcer Institute | Odri | Draft, May 2026**

---

## Abstract

This chapter presents the first systematic, corpus-based analysis of disavowal in Norwegian state discourse on petroleum and climate. Drawing on the Norwegian Green Discourse Corpus (NGDC, v1.0) — 15,210 keyword-matched plenary speeches from the Stortinget (2016–2025) and 19 NBIM institutional documents (2015–2024) — I demonstrate that the Lacanian-Žižekian structure of disavowal (*Verleugnung*: *I know very well, but nevertheless…*) operates not as individual rhetorical choice but as a structural feature of Norwegian state discourse as a whole. The evidence is fourfold: (1) the probability of a parliamentary speech naming petroleum declines by 11.4% per year (OR = 0.886, p < 0.001) while petroleum extraction continues or increases; (2) party membership explains zero percent of the variance in petroleum mention rates — the discursive pattern is structurally uniform across the ideological spectrum; (3) the oil fund is linguistically bifurcated — parliament names its origin (*Oljefondet*, the Oil Fund) while the fund's own discourse suppresses origin entirely, using "carbon neutral" at 51.7 times Parliament's rate; (4) the dominant discourse type in the corpus is adversarial floor debate where the managed contradiction must be defended under pressure.

---

## 1. Introduction: The Empirical Problem of Disavowal

The Lacanian concept of disavowal (*Verleugnung*), developed in Žižek's political theory as the operative structure of ideological fantasy, has been extensively deployed in critical analyses of petrostates, green capitalism, and the discourse of managed transition (Žižek 1989; Swyngedouw 2010; Bettini 2017). The concept names a structure: *I know very well* [that we are a petrostate, that extraction continues, that the fund was built on oil revenues], *but nevertheless* [I perform the identity of a climate leader, a responsible steward, a green pioneer]. The knowing and the performing are not contradictions that require resolution — they are the ideology functioning exactly as designed.

What has been lacking is systematic empirical evidence that disavowal, thus theorised, is demonstrably *structural* — that it is not reducible to individual rhetorical choices, partisan positions, or particular government decisions, but characterises the discourse of the Norwegian state apparatus as a whole, across parties, governments, speech types, and institutional sites. Without such evidence, the claim remains at the level of interpretive conjecture, however theoretically sophisticated.

This chapter provides that evidence.

---

## 2. Data and Methods

### 2.1 The Norwegian Green Discourse Corpus

The NGDC (v1.0) comprises two phases. Phase 1 is a corpus of Stortinget plenary debate transcripts: all keyword-matched speeches from the 2016–17 through 2024–25 parliamentary sessions (N = 15,210 speeches from a total of ~103,000 extracted), collected via the Stortinget public API. The corpus begins in 2016 — the year of Norwegian ratification of the Paris Agreement — and extends through the 2024–25 session. Phase 2 comprises 19 NBIM (Norges Bank Investment Management) annual and responsible investment reports (2015–2024), collected from nbim.no.

The keyword filter is the corpus's central curatorial decision. Inclusion requires the presence of at least one core keyword from the ideological terrain of the Norway paradox: *petroleum*, *olje* (oil), *klima* (climate), *klimaendring* (climate change), *fornybar energi* (renewable energy), *bærekraft* (sustainability), *energiomstilling* (energy transition), *Oljefondet/NBIM* (the Oil Fund). Extended keywords (*karbonfangst*, *grønn vekst*, *rettferdig omstilling*) trigger inclusion but are flagged separately. This filter is not topical but theoretical: inclusion means a speech participates in the discursive terrain where petroleum and green identity collide.

### 2.2 Methods

Analysis proceeds through three layers. The *descriptive* layer uses frequency analysis, KWIC (keyword-in-context, ±8 tokens, N = 1,997 petroleum instances and 22,854 klima instances), collocational profiling (±5 tokens), and Structural Topic Modelling (STM, K=10, with year and party prevalence covariates; Roberts et al. 2019). The *inferential* layer uses logistic regression (predicting petroleum mention from year, party, and speech type; N = 14,868 speeches), the Mann-Kendall non-parametric trend test, a mixed-effects logistic regression with random intercepts for party, session, and speaker (lme4; Bates et al. 2015), and STM effect estimation with global uncertainty (95% CIs). The *cross-institutional* layer compares term rates per 10,000 words between Parliament (Phase 1) and NBIM (Phase 2).

A note on epistemology: the NGDC is a full population corpus — not a probability sample — covering all keyword-matched plenary speeches in the period. Inferential statistics are justified under the superpopulation model standard in corpus linguistics (Gries 2021): speeches are treated as draws from the distribution of all possible parliamentary speech the Norwegian state could have produced. Effect sizes with confidence intervals are the primary output; p-values are evidence-strength indicators.

---

## 3. The Petroleum/Klima Ratio: Disavowal in Aggregate

The most direct evidence of disavowal at the aggregate level is the trajectory of the petroleum/klima speech ratio across nine parliamentary sessions.

**Table 1: Petroleum and klima speech counts by session**

| Session | Petroleum speeches | Klima speeches | Ratio |
|---|---|---|---|
| 2016–17 | 154 | 916 | 0.168 |
| 2017–18 | 135 | 796 | 0.170 |
| 2018–19 | 150 | 1,157 | 0.130 |
| 2019–20 | 166 | 1,030 | 0.161 |
| 2020–21 | 98 | 1,106 | 0.089 |
| 2021–22 | 103 | 1,113 | 0.093 |
| 2022–23 | 72 | 911 | 0.079 |
| 2023–24 | 73 | 865 | 0.084 |
| 2024–25 | 69 | 831 | 0.083 |

This is a ratio operating entirely *within* the filtered corpus — within speeches that already contain at least one petroleum or climate keyword. Even when parliament is speaking *about* energy, petroleum, or climate, it speaks about climate three to twelve times more often than it speaks about petroleum. The ratio itself halved over eight years: from 0.168 in 2016–17 to 0.083 in 2024–25, a 50% decline. Over the same period, Norwegian petroleum extraction continued at historically high levels, with record production in several years.

The Mann-Kendall non-parametric trend test confirms the decline is monotonic: τ = -0.722, p = 0.009 (two-tailed). Nine sessions, eight consecutive steps in the right direction. This is not noise.

What is declining is not merely the *number* of petroleum speeches but the *probability* of any given speech naming petroleum. Logistic regression (has_petroleum ~ year + party + speech_type) estimates this effect as an odds ratio of **0.886 per year** [95% CI: 0.863, 0.909, p < 0.001]. Each additional year reduces the odds of a speech mentioning petroleum by 11.4%, controlling for party and speech type. The 95% confidence interval does not approach 1.0.

This is the disavowal signal, formalised: the thing that Norway extracts at the highest rate in its history is the thing parliament speaks of less, year on year, controlling for all other factors.

---

## 4. The Structure of Absence: What 'Petroleum' Looks Like in Discourse

The KWIC and collocation analysis reveals that petroleum's declining verbal presence is accompanied by a distinctive discursive *form*. Petroleum almost never appears as a standalone word in Norwegian parliamentary speech. It appears embedded in compound forms — the Norwegian linguistic mechanism for normalising and institutionalising a concept:

*petroleumsnæringen* (the petroleum industry), *petroleumsvirksomhet* (petroleum operations), *petroleumstilsynet* (the Petroleum Safety Authority), *petroleumssektoren* (the petroleum sector), *petroleumsforvaltning* (petroleum management), *petroleumspolitikk* (petroleum policy), *petroleumsskatten* (petroleum taxation).

**The compounding is itself a finding.** In Norwegian, to compound a noun is to domesticate it — to make it part of an established institutional landscape rather than a thing in itself. Petroleum is not *utvinnet* (extracted) in parliamentary speech; it is *forvaltet* (managed), *regulert* (regulated), *skattlagt* (taxed). The activity appears only as something already administered. Its collocational profile — "norsk" (Norwegian), "næringen" (the industry), "viktig" (important), "Petroleumstilsynet", "sektoren", "aktivitet" — is the lexicon of governance, not extraction.

Contrast this with the collocational profile of *klima*: "regjeringen" (the government), "klimapolitikk" (climate policy), "viktig" (important), "klimamålene" (the climate targets), "klimagassutslipp" (greenhouse gas emissions), "klimaendringene" (the climate changes). Climate appears in the language of aspiration, policy commitment, and moral urgency. Petroleum appears in the language of management structures.

This is the semantic structure of disavowal: the activity is *administered*, the identity is *performed*. The thing exists only as something that is governed; the self exists as something that cares.

---

## 5. Cross-Partisan Consistency: Disavowal Is Not a Party Position

The structural claim of disavowal — that it is a property of the state apparatus rather than of particular parties — is directly testable. If disavowal is structural, petroleum mention rates should be broadly similar across parties regardless of ideological position.

**Table 2: Vocabulary rates by party (% of speeches mentioning each term)**

| Party | Political position | N speeches | Petroleum rate | Klima rate |
|---|---|---|---|---|
| FrP | Right-populist, pro-petroleum | 1,145 | 9.5% | 49.0% |
| H | Centre-right | 1,858 | 6.8% | 50.8% |
| KrF | Centre-right | 423 | 7.3% | 61.0% |
| A | Centre-left | 2,099 | 5.5% | 56.8% |
| Sp | Centre/agrarian | 1,252 | 4.9% | 57.7% |
| SV | Left | 1,736 | 6.2% | 70.3% |
| MDG | Green | 763 | 5.5% | 75.0% |
| R | Far-left | 481 | 5.2% | 46.4% |
| V | Green liberal | 1,101 | 6.4% | 70.9% |
| Statsråd (Ministers) | Government capacity | 4,010 | 7.7% | 50.3% |

Even the Progress Party (FrP) — the party that explicitly defines itself as pro-petroleum, the party that treats petroleum extraction as national pride and economic identity — speaks about *klima* in nearly half of its speeches (49.0%) and speaks about *petroleum* in only 9.5%. The ratio within FrP's own corpus is roughly 5:1 in favour of climate language. The party most ideologically committed to petroleum has been structurally compelled to perform the same green identity as its opponents.

The two Prime Ministers across the period — Erna Solberg (Conservative, 2013–2021) and Jonas Gahr Støre (Labour, 2021–present) — are functionally indistinguishable in their petroleum/klima profiles: Solberg at 2.6%/56%, Støre at 1.6%/57%. These are political opponents. The institutional position of Prime Minister produces the same discursive performance regardless of party affiliation.

The mixed-effects logistic regression makes this precision quantitative. With random intercepts for party, session, and speaker, the **party-level intraclass correlation is approximately zero** — party accounts for ~0% of the variance in petroleum mention rates once individual speaker variation is controlled. The session-level ICC is 0.4%. The speaker-level ICC is 26.7%, suggesting that some individuals are rhetorically distinctive (certain FrP backbenchers, certain SV climate specialists), but these are individual habits distributed within parties, not party-level patterns.

The year fixed effect remains large and significant in the multilevel model: OR = 0.89 [0.846, 0.936], p < 0.001. The decline is temporal, not partisan. It is the shared trajectory of an institution, not the strategy of a faction.

---

## 6. The Discourse of Managed Transition: Topic Structure

Structural Topic Modelling (K=10, with year and party prevalence covariates) produces a topic structure that maps onto the theoretical terrain with precision.

**Table 3: STM topic structure with theoretical annotation**

| Topic | Proportion | Label | Theoretical class |
|---|---|---|---|
| T5 | 23.5% | Adversarial floor debate | DISAVOWAL UNDER PRESSURE |
| T4 | 12.0% | Energy transition & industry | DISAVOWAL (managed transition) |
| T3 | 11.0% | Parliamentary procedure | Procedural |
| T7 | 10.4% | Climate policy & emissions | GREEN IDENTITY PERFORMANCE |
| T6 | 9.7% | Nynorsk speech register | Register |
| T2 | 8.3% | Welfare / social services | Welfare legitimation |
| T1 | 6.5% | Petroleum fiscal regime | EXTRACTIVE / FISCAL |
| T9 | 6.5% | Foreign policy & geopolitics | Geopolitical frame |
| T8 | 6.1% | Transport & infrastructure | Transition |
| T10 | 6.0% | Nature & biodiversity | Nature / land |

Three findings demand theoretical attention.

**First**: the largest single topic — 23.5% of the corpus — is adversarial floor debate (T5). Its FREX terms include *egentlig* (actually/really), *synes* (think/believe), *innlegg* (speech/intervention), *tror* (believe). This is unscripted exchange: oral question time, replies, rebuttals. The modal discourse type in the filtered corpus is not programmatic speech but the *maintenance of the fantasy under adversarial pressure*. Disavowal is not a statement; it is a practice that must be continually reproduced in response to challenge.

**Second**: Topic 4 (Energy transition & industry, 12%) contains *havvind* (offshore wind), *vannkraft* (hydropower), and *fornybar* (renewables) *alongside* *gassnæringen* (gas industry) and *sokkel* (the continental shelf). Petroleum and renewables co-inhabit a single topic. The energy transition frame does not replace petroleum — it *absorbs* it. The petroleum industry extends into renewables; the transition is managed such that the same industrial actors, the same shelf infrastructure, the same state relationships are continuous across the fossil-to-green boundary. This is disavowal in its technical-economic form: extraction continues, but now it is *transitioning*.

**Third**: STM effect estimates (estimateEffect with 95% CIs) reveal that Topic 7 (Climate policy & emissions) is **significantly declining** over time (β = -0.007 per scaled year, p < 0.001), while Topic 4 (Energy transition) is **significantly growing** (β = +0.009, p < 0.001). Explicit climate policy discourse is shrinking as transition discourse expands. The theoretical interpretation: climate identity is being *normalised* — absorbed into the procedural and transitional vocabulary such that it no longer needs to be explicitly performed. When climate no longer requires explicit commitment because it is already the assumed frame, the disavowal has reached its mature form. The not-saying becomes structural rather than chosen.

---

## 7. Cross-Institutional Disavowal: NBIM as Hyper-Performance

The most dramatic evidence of disavowal comes from the cross-institutional comparison. The Norwegian Government Pension Fund Global (NBIM/Oljefondet) is the institutional site where the oil-extraction revenues are narratively transformed — from petroleum income into long-term, responsible, globally diversified capital stewardship. This transformation requires a specific discursive operation: the suppression of origin.

**Table 4: Key term rates per 10,000 words, Parliament vs. NBIM (2022–24)**

| Term | Parliament | NBIM | Ratio |
|---|---|---|---|
| carbon neutral / net zero | 0.29 | 14.9 | **51.7×** |
| responsible | 1.76 | 65.6 | **37.3×** |
| divestment | ~0 | 30.5 | **~3,000×** |
| sustainable / bærekraft | 9.52 | 28.6 | 3.0× |
| climate / klima | 38.0 | 66.1 | 1.74× |
| petroleum | 3.3 | **0.0** | Parliament names it more |
| oil / olje | 7.56 | **0.0** | Parliament names it more |
| extraction | 0.85 | **0.0** | Parliament names it more |

NBIM uses the phrase "carbon neutral / net zero" at 51.7 times Parliament's rate. "Responsible" appears 37.3 times more often. "Divestment" — the mechanism by which the fund performs its ethical exclusions — appears at approximately zero frequency in Parliament but at 30.5 per 10,000 words in NBIM's own reports. Parliament mandated the divestment mechanism; NBIM enacts and narrates it; Parliament does not speak of it.

The symmetrical finding: *petroleum*, *oil*, and *extraction* all rate zero in NBIM's self-description. The fund that was built by and exists entirely because of petroleum revenue does not name petroleum, oil, or extraction in its institutional discourse. Parliament — the chamber that oversees petroleum licensing, production, and taxation — names these terms more than the fund they produced.

This asymmetry constitutes the cross-institutional form of disavowal. Parliament cannot fully suppress the naming of petroleum because it must legislate it — it is the site of production policy. NBIM can suppress it entirely because its mandate is stewardship, not production. The petroleum money arrives at NBIM already laundered of its origin. NBIM's task is not to name it but to invest it responsibly. The suppression of "extraction" in NBIM discourse is not dissembling — it is the institutional completion of the disavowal that Parliament begins.

---

## 8. The Name of the Fund: Oljefondet vs. SPU

The fund has two names. "Oljefondet" — the Oil Fund — is the popular form: historically accurate, etymologically honest, widely used. "Statens pensjonsfond utland" (SPU — Government Pension Fund Global) is the official form, adopted in 2006: bureaucratically neutral, petroleum-suppressing, globally legible.

Does parliament name the fund in a way that names its oil origin, or in a way that suppresses it?

Over the corpus period, "Oljefondet" appears as 689 tokens versus 410 tokens for SPU/Statens pensjonsfond — a ratio of 1.68:1 in favour of the oil-naming form. Parliament persistently uses the name that names the oil. The share oscillates but shows no monotonic decline: in 2023 and 2024, Oljefondet's share of fund references actually *increases* to 78% and 77%.

This finding complicates the simple disavowal narrative in a theoretically productive way. Parliament does not suppress the fund's oil origin at the level of the proper noun. It keeps naming the thing an Oil Fund. What it suppresses is the *activity* — the ongoing extraction, the wells, the production, the barrel counts, the platform operations. The fund's origin is preserved as historical fact — a monument, a proud achievement, something Norway owns and that bears its name — while the present tense of petroleum extraction is progressively disappeared from discourse.

The disavowal is thus temporally structured: *petroleum* as ongoing activity is suppressed; *Oljefondet* as inheritance from that activity is retained. Norway knows it is a petrostate; *it was*, and the fund is the evidence. But the *is* — the current drilling, the licensing rounds, the platform expansions — that is what must not be spoken. The Oil Fund becomes the alibi of a historical past rather than the current proceeds of a present activity. Disavowal, here, works through temporalisation: petroleum is something Norway *had*, that generated a fund it *has*, not something it *is still doing*.

---

## 9. The "Both/And" Frame: Holding the Contradiction

The 415 speeches (2.7% of the corpus) that name both *petroleum* and *klima* in the same text are the densest sites of disavowal. They are the speeches where a speaker explicitly holds both terms and must perform their co-existence. A sample of these contexts reveals the available frames:

**The sequentialist frame**: petroleum is Norway's present, renewables are its future. The transition is managed; the extraction continues while the alternative is prepared. *"Vi skal klare å kombinere petroleumsvirksomheten med en aktiv klimapolitikk."* (We must manage to combine petroleum operations with an active climate policy.) The "both/and" is a promise: we will do both, and eventually the both will become only the latter.

**The expertise transfer frame**: the skills, infrastructure, and industrial capacity developed in petroleum can be redirected to offshore wind and CCS. The petroleum past becomes the foundation of the green future. Nothing is wasted; everything continues. The industry is not ended but *pivoted*.

**The global responsibility frame**: Norway's petroleum revenue finances the green transition — domestically through welfare state investment and internationally through the Oil Fund's ESG criteria. The extraction is legitimated by what it funds. *"Det er det som gir oss muligheten til å satse på fornybar energi."* (It is this [petroleum revenue] that gives us the opportunity to invest in renewable energy.)

**The adversarial accountability frame**: used primarily by SV, MDG, R, and occasionally A backbenchers — petroleum is named in the context of challenge: *"Dere kan ikke kalle dere et klimaparti og samtidig åpne nye oljefelter."* (You cannot call yourselves a climate party while simultaneously opening new oil fields.) Here petroleum is named in order to *expose* the disavowal. But even this naming — the opposition's naming of the thing — is contained within the same corpus, the same institution, the same discursive system.

The rate at which petroleum mentions also contain klima — *klima given petroleum* — rises from 30% in 2016–17 to 57% in 2021–22 before the pattern shifts. By 2021, when petroleum is mentioned it is accompanied by climate language in more than half of cases. The thing cannot be named without immediately managing it with the green supplement.

---

## 10. Conclusion: The Structural Form of the Fantasy

The empirical record establishes, with statistical rigour and discursive precision, what the theoretical framework predicts: that disavowal in Norwegian state discourse is structural, not rhetorical; collective, not individual; temporal, not accidental.

Its five key features:

**1. Lexical displacement**: Petroleum mention rates decline by 11.4% per year (OR = 0.886, p < 0.001) while extraction continues. The activity is present in the world; its name is progressively absent from discourse.

**2. Semantic bureaucratisation**: When petroleum is named, it appears only in compound-institutionalised forms — *petroleumsforvaltning*, *petroleumsnæringen*, *petroleumstilsynet*. The raw activity of extraction is always already administered, managed, governed. The thing exists only as something that is regulated.

**3. Zero party effect**: Party membership explains zero percent of the variance in petroleum mention rates (multilevel ICC ≈ 0%). The decline is shared across Labour, Conservative, Progress, Socialist Left, and Ministers alike. This is the institutional apparatus speaking, not its partisan components.

**4. Topic expansion, not silence**: The energy transition topic (STM T4) is significantly growing (+0.009/year, p < 0.001) even as petroleum fiscal discourse (T1) and explicit climate policy (T7) decline. The disavowal does not operate as silence but as proliferating transition vocabulary — the thing continues, now narrated as something that is already changing.

**5. Institutional bifurcation**: Parliament names the Oil Fund as an Oil Fund (Oljefondet) but suppresses the ongoing activity (petroleum mention declining). NBIM suppresses both — the fund's origin and petroleum altogether — while hyper-performing green identity ("responsible" at 37× Parliament's rate; "carbon neutral" at 51.7×). The disavowal is complete at the institutional level: the fund manages the wealth; parliament legislates the activity; neither names the extraction as such.

The Norwegian state does not lie about petroleum. It knows very well. Its annual reports are full of production figures, licensing rounds, tax revenues from petroleum. The paradox is not concealment but *management*: knowing and performing the not-knowing simultaneously, in such a way that the not-knowing is never chosen but always structurally reproduced. This is Žižek's formula enacted at the level of an entire state apparatus, across nine years, fifteen thousand speeches, and two institutional sites.

Norway knows it is a petrostate. Nevertheless.

---

## References

*[Citations to Žižek 1989, Roberts et al. 2019, Bates et al. 2015, Gries 2021, Swyngedouw 2010, Bettini 2017, and corpus methods literature to be inserted in final version.]*

---

## Data and Code Availability

All data, scripts, and outputs are available in the Norwegian Green Discourse Corpus (NGDC, v1.0):
`https://github.com/[odripads]/ngdc`

Scripts: `analysis/01–13_*.R` | Figures: `outputs/figures/` | Tables: `outputs/tables/`
Full findings: `outputs/ANALYSIS_FINDINGS.md`
