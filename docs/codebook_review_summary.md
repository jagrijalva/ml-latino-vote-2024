# CMPS 2024 Codebook Review Summary
## For RF+SHAP Latino Vote Choice Pipeline
### Prepared for Dr. Grijalva — March 19, 2026

---

## 1. DATA SNAPSHOT (from glimpse diagnostic)

| Metric | Value |
|---|---|
| Raw data | 19,634 rows × 1,301 columns |
| Latino voters (latino==1, q12 ∈ {3,4}) | **3,257 rows** × 1,301 columns |
| DV: q17==1 (Trump) | 1,286 (39.5%) |
| DV: q17==2 (Harris) | 1,765 (54.2%) |
| DV: q17==3 (Someone else) | 147 (4.5%) |
| DV: q17==4 (No one) | 59 (1.8%) |
| Gender: s14==1 (Man) | 1,568 |
| Gender: s14==2 (Woman) | 1,669 |
| Gender: s14==3 (Non-binary) | 20 |

**Critical structural difference from 2016/2020**: All values are numeric (`dbl`), NOT factor-coded strings. The special-value sweep must target numeric codes (97, 98, 99, 999) instead of string patterns like "(-99)".

**Column naming**: All lowercase in the CSV (e.g., `q17`, `s14`, `pid7`), while the codebook uses uppercase.

**Special-value codes confirmed (from diagnostic_special_values.R)**:
- **97** = Don't know
- **98** = Refused / Skipped
- **99** = Not applicable
- **999** = Not asked / split-form skip
- No negative special-value codes (-99, -98, -97, -1) found anywhere in the data

---

## 2. CORE PIPELINE VARIABLES

| Role | Variable | Values | Notes |
|---|---|---|---|
| Latino filter | `latino` | 0/1 | Binary, derived from s3r2 |
| Voter filter | `q12` | 3=probably voted, 4=definitely voted | **REVERSED from 2020** where 1-2 = voted |
| **DV** | `q17` | 1=Trump, 2=Harris, 3=Other, 4=No one | Binary: q17==1 → Trump=1, q17==2 → Trump=0. **Drop q17 ∈ {3,4}** |
| Gender | `s14` | 1=Man, 2=Woman, 3=Non-binary | For Tier 4 split. 20 non-binary → keep in Tiers 1-3, exclude from Tier 4 only |
| State | `s21` | 1-51 | Nominal, for region lookup |
| Region | `region` | 1-4 | Pre-built in data (unlike 2016/2020 where we had to construct it) |
| Block assignment | `blockassignment` | 1-4 | Determines split-form routing |

---

## 3. EXCLUSION LISTS

### LIST A — Administrative/Metadata (Exclude from ALL tiers)

**IDs, timestamps, screening:**
`uuid`, `date`, `start_date`, `status`, `ipaddress`, `qtime`, `adult`, `primaryadult`, `s1` (US citizenship screening), `s2b` (age verification), `s18` (100% NA), `s19` (100% NA)

**Survey administration:**
`blockassignment`, `surveylanguagevar`

**ALL pipe/routing variables** (regex pattern: columns containing "pipe"):
`q17pipenone`, `q17piper1`, `q17piper2`, `q18pipenone`, `q18piper2`, `q18piper3`, `q26pipenone`, `q26piper1`, `q26piper2`, `q29pipea*`, `q29pipeb*`, `q96pipe*`, `q106pipe*`, `q114pipea*`, `q114pipeb*`, `q122pipe*`, `q137pipe*`, `q138pipe*`, `q151pipea*`, `q151pipeb*`, `q173pipe*`, `q215pipe*`, `q219pipe*`, `q377pipe*`, `q378pipe*`, `q379pipe1*`, `q379pipe2*`, `s20pipe*`, `s25apipea*`, `s25apipeb*`, `s28pipe*`, `s30pipe*`, `qgrouppipe*`, `raceidpipe*`

**ALL open-ended text variables** (regex pattern: columns ending in "oe", plus Q274, Q315, Q343r1, Q343r2, Q398):
`q70r6oe`, `q88r7oe`, `q89r11oe`, `q121r10oe`, `q233ar11oe`, `q233br11oe`, `q233cr11oe`, `q233dr11oe`, `q270r3oe`, `q356r7oe`, `q392r6oe`, `s7r16oe`, `s8r9oe`, `s8r15oe`, `s8r18oe`, `s8r19oe`, `s9r22oe`, `s11r14oe`, `s12r37oe`, `s13r16oe`, `s15r6oe`, `vbrowserr15oe`, `vosr15oe`
Plus text-response items: `q274`, `q315`, `q343r1`, `q343r2`, `q398`

**ALL county codes** (two-letter state abbreviation + "c"):
`akc`, `alc`, `arc`, `azc`, `cac`, `coc`, `ctc`, `dec`, `flc`, `gac`, `hic`, `iac`, `idc`, `ilc`, `inc`, `ksc`, `kyc`, `lac`, `mac`, `mdc`, `mec`, `mic`, `mnc`, `moc`, `msc`, `mtc`, `ncc`, `ndc`, `nec`, `nhc`, `njc`, `nmc`, `nvc`, `nyc`, `ohc`, `okc`, `orc`, `pac`, `ric`, `scc`, `sdc`, `tnc`, `txc`, `utc`, `vac`, `vtc`, `wac`, `wic`, `wvc`, `wyc`

**Weight variables:**
`wt_adult_ca`, `wt_adult_lgbt`, `wt_adult_os`, `wt_adult_ps`

**Device/browser metadata:**
`vbrowser`, `vdropout`, `vmobiledevice`, `vmobileos`, `vos`

**Oversample flags:**
`os_afrolat`, `os_blkimm`, `os_jewish`, `os_lgbtq`, `os_mena`, `os_muslim`, `os_native`, `california`

**Randomization assignments:**
`lgbtrandassignment`, `lgbtrandassignment2`, `menarandassignment`

**No-answer flags:**
`noanswerq147_r7`, `noanswerq185_r5`

---

### LIST B — Sample-Definition Variables (Exclude from ALL tiers as predictors)

These variables define the analytic sample but are not predictors:
- `latino` — the filter variable itself
- `q12` — voter certainty (used as filter, not predictor)
- `s14` — gender (used for Tier 4 split, not included as predictor in gender-split models)
- `s3r1`–`s3r7` — ethnicity checkboxes (feeding `latino`, `white`, `black`, etc.)
- `s22` — ZIP code (too granular, PII-adjacent)

---

### LIST D — Tautological (Exclude from Tiers 2, 3, 4)

These are mechanically/logically linked to the vote choice DV:

**Direct vote choice:**
- `q17` — the DV itself

**Candidate thermometers (direct evaluations of candidates on the ballot):**
- `q4r1` — Donald Trump feeling thermometer
- `q4r2` — Joe Biden feeling thermometer (linked to Harris candidacy)
- `q4r3` — Kamala Harris feeling thermometer
- `q4r4` — J.D. Vance feeling thermometer

**Downstream vote choice items:**
- `q18` — Congressional vote choice (who did you vote for in House race)

**Candidate-specific reasoning/conflict:**
- `q25r1`–`q25r9` — Has your family experienced conflict because of Trump (9 items)
- `q25b`, `q25c` — Additional Trump family conflict items
- `q29r1`–`q29r7` — Reasons for supporting your chosen candidate (7 items)

**Campaign behavior directly tied to candidate:**
- `q64r2` — Donated to presidential candidate

**BORDERLINE TAUTOLOGICAL — for your review:**
- `q257` — "How optimistic are you that President Donald Trump will protect LGBTQ+ rights?" (names Trump evaluatively)
- `q174` — Approve/disapprove of the US President using the 1798 Alien Enemies Act (evaluates specific presidential action)
- `q175` — Approve/disapprove of the US President defying Federal Court orders (evaluates specific presidential action)

> **Decision point**: These three items name/evaluate Trump directly in policy contexts. In 2020, analogous items about Trump's COVID response were excluded as tautological. Recommend excluding from Tier 2+ but flagging for sensitivity analysis.

---

### LIST E — Partisan (Exclude from Tiers 3, 4 only)

**Party identification (direct):**
- `s28` — Party registration
- `s29` — Party leaning
- `s30` — Strength of party identification
- `pid3` — 3-point party ID (Dem/Rep/Ind)
- `pid7` — 7-point party ID scale

**Party evaluation:**
- `q5` — Approve/disapprove of how Democratic leaders in Congress are handling their job
- `q6` — Approve/disapprove of how Republican leaders in Congress are handling their job
- `q3r1` — Democratic Party feeling thermometer
- `q3r2` — Republican Party feeling thermometer
- `q3r3` — Independent feeling thermometer
- `q206r1` — Republican Party favorability (1-7)
- `q206r2` — Democratic Party favorability (1-7)

**Ideology:**
- `q7` — Ideology self-placement
- `q8` — Ideology (second item, possibly strength)

**Party representation items:**
- `q26` — Which party better represents [your group]
- `q96` — Which party better represents [your group] (different pipe condition)
- `q270` — Which political party works hardest for Black people

---

## 4. KEY THEMATIC BATTERIES (Substantive predictors by domain)

### Immigration & Enforcement (NEW 2024-specific content)
- `q34`–`q41` — Immigration policy attitudes (path to citizenship, border wall, DACA, deportation priorities, etc.)
- `q42r1`–`q42r11` — Most important issue facing community (select all)
- `q149r1`–`q149r5` — Immigrant integration (Ukraine, Haiti, Afghanistan, Venezuela, Palestine)
- `q159`–`q163` — Attitudes toward Central/South American migrants
- `q174` — Alien Enemies Act approval (borderline tautological, see above)
- `q233a`/`q233b`/`q233c`/`q233d` — **SPLIT-FORM EXPERIMENT**: Immigration vignette (4 conditions by blockassignment — MUST COLLAPSE)
- `q234r1`–`q234r3` — Feeling thermometers: People from Mexico, Central America, Cuba (0-100)
- `q235`–`q236` — Negative news about immigrants → stereotypes/discrimination
- `q237`–`q239` — Latinos in immigration enforcement

### Economy & Financial Hardship
- `q43`–`q48` — Economic perceptions (national economy, personal finances, inflation)
- `q307r1`–`q307r3` — Resource scarcity beliefs
- `q308`–`q311` — Green energy jobs programs (by group)
- `q312` — Government responsibility to reduce income inequality
- `q357`–`q358` — Government benefits, emergency savings
- `q359r1`–`q359r11` — Types of credit/debt used
- `q360r1`–`q360r4` — Digital financial services
- `q361` — Government spending vs. services
- `q362`–`q366` — Earned wage advances, consumer protections
- `q367` — Financial situation vs. last year
- `q368`–`q375` — Alternative financial services (check cashing, payday, pawnshop, etc.)

### Reproductive Rights (NEW 2024 battery)
- `q279r1`–`q279r12` — Definition of reproductive rights (select all)
- `q280` — Contraception good/bad for society
- `q281` — IVF good/bad for society
- `q282` — Abortion law opinion (4-point policy scale)
- `q283` — Personal view on abortion (3 positions)
- `q284` — Willingness to donate sperm
- `q285` — Abortion laws in my state reflect my values
- `q286` — Parents responsible for teen sexual health
- `q287r1`–`q287r4` — Experienced reproductive health issues
- `q288`–`q290` — Pregnancy/children experience
- `q291` — Children under 18 in household
- `q292`–`q297` — Parenting, prenatal care, birth experience, discrimination

### Gaza / Israel-Palestine / Foreign Policy (NEW 2024)
- `q380r1`–`q380r7` — Feelings about Israel-Hamas war (select all: angry, sad, afraid, hopeful, proud, etc.)
- `q381` — Two-state solution support
- `q382` — Gaza ceasefire support
- `q383` — US funding to Israel for military assistance
- `q384` — Which side committed worse violence
- `aj1` — View of Israeli war on Hamas (justified/too far/wrong)
- `aj2r1`–`aj2r6` — Antisemitism statements (true/false)
- `aj3` — Free speech on campus / protecting Jewish students

### Masculinity & Gender Attitudes (KEY 2024 battery)
- `q140` — Government responsibility to promote gender equality
- `q219` — Women interpret innocent remarks as sexist (piped by race)
- `q220` — Women in politics → men's challenges overlooked
- `q221` — Black/White women experience sexism differently
- `q222` — Must fight racism, sexism, homophobia, transphobia
- `q318` — Women should be cherished and protected by men
- `q319` — Men should sacrifice well-being to provide financially for women
- `q320` — Men are incomplete without women
- `q321` — Women have superior moral sensibility
- `q322` — Many women interpret innocent remarks as sexist (general)
- `q323` — Women fail to appreciate what men do
- `q324` — Women seek to gain power over men
- `q325` — Once committed, women put men on a tight leash
- `q326` — Country needs a strong, determined leader to crush evil (**authoritarianism**)
- `q327` — Honor forefathers, do what authorities say, get rid of "rotten apples" (**authoritarianism**)

### Policing & Criminal Justice
- `q164`–`q166` — Police accountability, comfort calling police, trust in police (1-7 scales)
- `q167` — Cut police funding, reinvest in community
- `q168` — Abolish the police
- `q313` — School Resource Officers necessity
- `q314r1`–`q314r4` — Meritocracy beliefs (work hard → success)

### Discrimination & Racial Attitudes
- `q141` — Feeling about increasing diversity
- `q142`–`q146` — Government effort protecting groups from violence (own group, White, Latino, Black, Asian)
- `q155r1`–`q155r3` — Violence attitudes (political violence, group violence, personal experience)
- `q156` — How much discrimination against [own group]
- `q169`–`q171` — Personal discrimination experience + attributions
- `q176`–`q183` — **Racial resentment scale** (classic 6-item toward Blacks + 2 linked fate items)
- `q240` — Racism as systemic (benefits White people)
- `q241`–`q243` — Comparative racial treatment (jobs, police, customer service)
- `q278r1`–`q278r9` — Everyday discrimination scale (9 items)

### Latino Identity & Linked Fate
- `q128`–`q136` — Pan-ethnic identity, group consciousness, political resources
- `q150`–`q151` — Parental political socialization about racial group
- `q152`–`q154` — Latino assimilation attitudes (Spanish in public, flags, assimilation pressure)
- `q228r1`–`q228r3` — Afro-descendant treatment, skin color preference, mestizaje
- `q229` — Hispanics/Latinos as distinct racial group
- `q230` — Closeness to other Hispanics/Latinos
- `q231` — Hispanics/Latinos disadvantaged
- `q232` — Hispanics/Latinos need to work together
- `q376` — Linked fate (what happens to [group] affects me)

### Religion
- `q341r1`–`q341r6` — Religious orientation (fundamentalist, evangelical, mainline, liberal, pentecostal)
- `q342` — Worship attendance frequency
- `q345` — Importance of religion in life
- `q348` — Poverty as sign of God's displeasure

### Resilience & Well-being
- `q328` — Happiness
- `q329` — Opportunity to get ahead
- `q333`–`q338` — Brief Resilience Scale (6 items)
- `q339`–`q340` — Meritocracy beliefs
- `q403` — Self-rated health
- `q404` — Mental health days (0-30)

### Media & Information
- `q385r1`–`q385r18` — Social media platforms used (18 platforms)
- `q386` — Social media frequency
- `q387` — Talk politics with coworkers
- `q388` — Primary information source

### Demographics (kept as features)
- `s2` — Birth year → convert to age
- `s9` / `latorig` — Latino national origin
- `s10` — Generation status (if foreign-born)
- `s12` — Parental national origin
- `s13r1`–`s13r17` — Language proficiency items
- `s15` — Sexual orientation
- `s16` — Education level
- `s17` — Employment status
- `s18` — Marital status
- `s19` — Household income
- `s20` — Home ownership
- `s21` — State
- `s24` — Nativity (born in US?)
- `s25` — Citizenship status
- `s26` — Skin color (1-10 scale)
- `s27` — Religion/denomination
- `region` — Census region (pre-built)
- `agecat` — Age category (pre-built)
- `educat` — Education category (pre-built)
- `hhinc` — Household income category (pre-built)
- `white`, `black`, `aapi`, `asian`, `nhpi`, `mena` — Multiracial identity flags

---

## 5. SPLIT-FORM ITEMS REQUIRING COLLAPSE

Like 2020's Q48/Q49/Q50 → voter_fraud_belief collapse, we need:

1. **Q233a / Q233b / Q233c / Q233d** — Immigration vignette experiment
   - Q233a: "Central American Immigrant" charged with robbery (block 1)
   - Q233b: Generic "Immigrant" charged with robbery (block 2)
   - Q233c: "South Carolina Man" charged with robbery (block 3)
   - Q233d: "Cuban Immigrant" charged with robbery (block 4)
   - **Action**: Collapse across blocks into single variable; the *response* (country guess) is comparable

2. **Q150 / Q151** — Parental political socialization about racial group
   - Q150: "How often did parents talk about how politics affects [raceidpipe] people?"
   - Q151: "How often did parents talk about how politics affects [Q151pipeb] [Q151pipea] people?"
   - **Action**: Both measure parental politicization; need to identify which respondents get which version

3. **Q376 / Q377 / Q378** — Linked fate items with different group referents
   - Q376: linked fate for own racial group
   - Q377: linked fate for same-gender group
   - Q378: linked fate for same-race group (different pipe)
   - **Action**: Keep as separate variables; they measure distinct linked-fate dimensions

---

## 6. ENCODING NOTES

### Variables needing special handling:
- **Birth year → Age**: `s2` (1923-2025) → compute `2024 - s2` for continuous age
- **Continuous 0-100 thermometers**: `q3r1`-`q3r19`, `q4r1`-`q4r8`, `q210`, `q211`, `q234r1`-`q234r3`, `q344r1`-`q344r5` → keep continuous
- **Continuous 0-10 scales**: `q226r1`-`q226r6`, `q227r1`-`q227r2`, `q261`-`q263` → keep continuous
- **Ordinal scales** (1-5, 1-7): Most substantive Q items → treat as ordinal/numeric
- **Binary check-all-that-apply** (0/1): Q items with r-suffix sub-items (e.g., q42r1-q42r11, q61r1-q61r16) → already 0/1 binary, no OHE needed
- **Nominal** (needs OHE): `s9`/`latorig` (national origin), `s21` (state), `s27` (religion), `q170` (race of discriminator), `q388` (information source), `region`
- **Year variables**: `q400` (year arrived in US), `q401` (year of naturalization) → could convert to "years since"
- **Q365r55**: Control variable (values 1-1 only) → exclude

### Special-value sweep (numeric, not string-based):
Since all values are `dbl`, the sweep converts **97, 98, 99, 999 → NA** across all predictor columns.
- **No negative codes found** in the data (no -99, -98, -97, -1)
- **No iconv() UTF-8 guard needed** (unlike 2020's factor-level approach)
- **Caution on 0–100 thermometers** (q3r1–q3r19, q4r5–q4r8, q234r1–r3, etc.): 97/98/99 are ambiguous (could be valid ratings). Counts are small (< 1.5% per code), consistent with missingness codes. Sweep applies to these too.
- **Additional 999-bearing variables**: q389r1–r5, q390r1–r5 (max = 999 in range scan)
- **Year variables exempt**: s2 (birth year, 1931–2006), q400 (arrival year, 1945–2023), q401 (naturalization year, 1952–2024) — these are real values, not special codes

---

## 7. DECISIONS (CONFIRMED by Dr. Grijalva — March 19, 2026)

1. **Q174, Q175, Q257 (borderline tautological)**: **KEEP in Tiers 1 and 2**. Evaluate empirically via SHAP rankings. If they show massive SHAP values in Tier 2 (behaving tautologically), exclude from Tier 3. Decision deferred to post-model diagnostics.

2. **Q233 vignette experiment**: **KEEP for now**. Let the model show whether it contributes signal or noise. If it behaves erratically across bootstrap iterations (high rank SD), that's empirical grounds for exclusion.

3. **Non-binary respondents (n=20)**: **Keep in Tiers 1–3, exclude from Tier 4 gender-split only**. Insufficient n for separate estimation; non-binary Latino political behavior deserves dedicated study with adequate sample.

4. **Q4r5–q4r8 (other thermometers)**: **KEEP in all tiers**. Diagnostic confirmed these are non-candidate figure thermometers:
   - q4r5: Dem-leaning figure (diff = −25.4, Harris voters rate higher)
   - q4r6: Strong Dem-leaning figure (diff = −71.3, 15.1% 999/not-asked)
   - q4r7: Strong Rep-leaning figure (diff = +63.5, Trump voters rate higher)
   - q4r8: Dem-leaning figure (diff = −47.7, 25.7% 999/not-asked)
   Not tautological — these measure attitudes toward non-candidate political figures.

5. **Q402 (first-time voter)**: **KEEP** as demographic/political socialization predictor in all tiers.

6. **Race flag variables (white, black, aapi, etc.)**: **KEEP in all tiers**. Capture within-Latino heterogeneity (Afro-Latino, Asian-Latino, White-Latino identity).

7. **Special-value sweep**: **CONFIRMED** — 97, 98, 99, 999 → NA. No negative codes. Year variables (s2, q400, q401) exempt. 0–100 thermometer ambiguity resolved (small counts = missingness codes).

---

## 8. FOUR-TIER ARCHITECTURE (2024)

| Tier | Name | What's excluded | Purpose |
|---|---|---|---|
| **Tier 1** | Full | Only List A + List B | Maximum predictive power; identifies ceiling AUC |
| **Tier 2** | Non-Tautological | Lists A + B + D | Removes items mechanically linked to vote choice |
| **Tier 3** | Non-Partisan | Lists A + B + D + E | **Analytically central**: What predicts Trump vote beyond partisanship? Key for T1→T3 AUC drop diagnostic |
| **Tier 4** | Gender-Split | Same as Tier 3, split by s14 | Men vs. Women models; tests gendered predictive structures |

**Cross-election comparison target**: T1→T3 AUC drop was 0.087 in 2016, 0.0151 in 2020. The 2024 value will reveal whether attitudinal consolidation (party ID becoming redundant) continued, plateaued, or reversed.
