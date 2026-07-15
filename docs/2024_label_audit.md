# CMPS 2024 — Label & Direction Audit

**Purpose.** Post-hoc reporting-layer audit per the Computational framework:
feature importance is computed on absolute SHAP (direction-invariant), so
directional recoding happens AFTER the stable feature list is locked.
This document is the lookup that the reporting QMD consumes.

**Convention.** `high = conservative / pro-Trump`.
When `reverse = TRUE`, the raw column is rescored as `(max + min) - x`
before generating the beeswarm so that dark points (high raw) push right
(positive SHAP).

**Source.** `docs/cmps2024_codebook.txt` + `docs/cmps2024_instrument.txt`
in this repo.

---

## Structural bugs found during audit (flagged separately — do NOT silently patch the locked model)

1. **Q3 feeling-thermometer label keying mismatch.**
   The `feature_labels` map in `CMPS_2024_IFA_analysis_final_patched.qmd`
   (line ~121) keys thermometers as `q3a`, `q3b`, … `q3s`. The CSV
   columns are `q3r1` … `q3r19`. None of the Q3 thermometer labels
   currently render — they fall through to the raw code in the PDF.

2. **`exclude_tautological` entry `q3q` matches nothing.**
   Line ~487 lists `q3q` in the tautological exclusion set. The CSV has
   no column named `q3q`; the intended item (Jan 6 insurrectionists
   thermometer) is `q3r17`. Net effect: **q3r17 is not currently being
   excluded** even though the list appears to do so. Any downstream claim
   that the model is "Tier 3 non-partisan with Jan 6 removed" is not
   true as written.

3. **Q28 parallel-structure break vs 2020.**
   2020 excludes `Q28R1–R19` as partisan-contact items. 2024 omits all
   `q28r*` from `exclude_partisan`. `q28r2` (contacted by Republican
   Party GOTV) is currently the #1 stable feature in Tier 3. This is
   the same class of variable 2020 treats as partisan by construction.

4. **Q175 is a direct Trump-performance item.**
   Q175 ("approve / disapprove of Trump defying court orders") directly
   evaluates Trump's own behavior. Under the framework's tautology
   criterion #1 (items that directly evaluate Trump) it belongs in
   `exclude_tautological`, not as a retained feature.

These four items are **model-spec questions**, not label questions —
fixing the label map alone will not make the model Tier 3 non-partisan
as claimed. See Recommendations at end.

---

## Response-scale reference (2024)

Unless noted, Likert items are coded **1 = Strongly agree / support /
favor / approve … 5 = Strongly disagree / oppose / disapprove**, with
6 = Don't know / Refused where present. Feeling thermometers are 0–100
(higher = warmer).

Two important exceptions detected during codebook review:

- **Q182, Q183** reverse the Likert direction (1 = Strongly disagree …
  5 = Strongly agree). These are already flagged `(rev)` in the label
  map.
- **Q28r1–r5** are binary 0/1 contact flags, not Likerts.

---

## Per-feature audit (top stable features, Tier 3)

| Feature | Codebook item | Response scale | Proposed label | Natural direction (raw ↑) | Reverse to get high=conservative |
|---|---|---|---|---|---|
| `q28r2` | Q28_r2 — contacted by Republican Party to get out the vote | 0 = No, 1 = Yes | Contacted by GOP GOTV | ↑ = GOP outreach contact (not itself ideological) | **Exclude** (partisan-contact, parallels 2020 rule) |
| `q28r1` | Q28_r1 — contacted by Democratic Party GOTV | 0/1 | Contacted by Dem GOTV | ↑ = Dem outreach | **Exclude** (partisan) |
| `q3r17` | Q3_r17 — feeling thermometer, Jan 6 insurrectionists | 0–100 | Warmth toward Jan 6 insurrectionists | ↑ = warmer toward insurrectionists = pro-Trump | **Exclude** (tautological — direct Trump event) |
| `q3r15` | Q3_r15 — feeling thermometer, transgender people | 0–100 | Warmth toward transgender people | ↑ = warmer = liberal | Reverse: `100 - x` |
| `q3r16` | Q3_r16 — feeling thermometer, undocumented immigrants | 0–100 | Warmth toward undocumented immigrants | ↑ = warmer = liberal | Reverse: `100 - x` |
| `q3r18` | Q3_r18 — feeling thermometer, Black Lives Matter | 0–100 | Warmth toward BLM | ↑ = warmer = liberal | Reverse: `100 - x` |
| `q310` | Q310 — "Fund renewable-energy job training in communities of color" | 1 Strongly support … 5 Strongly oppose | Support for green-jobs program for communities of color | ↑ = oppose = conservative | **No reverse** (already high = conservative) |
| `q10r1` | Q10_r1 — priority: economy/jobs | binary 0/1 (endorsed as priority) | Names economy as top priority | ↑ = prioritizes economy | Keep; direction is priority salience, not left-right |
| `q11` | Q11 — how important that SCOTUS look like America | 1 Not at all … 5 Extremely | SCOTUS demographic representation important | ↑ = more important = liberal | Reverse: `6 - x` |
| `q251` | Q251 — ban trans youth from school sports | 1 Strongly favor … 5 Strongly oppose | Ban trans youth from sports | ↑ = oppose ban = liberal | Reverse: `6 - x` |
| `q174` | Q174 — approve Alien Enemies Act use | 1 Strongly disapprove … 5 Strongly approve | Approve Alien Enemies Act | ↑ = approve = conservative | Keep |
| `q175` | Q175 — approve Trump defying court orders | 1 Strongly disapprove … 5 Strongly approve | Approve Trump defying courts | ↑ = approve Trump = pro-Trump | **Exclude** (tautological — direct Trump-performance) |
| `q176` | Q176 — racial resentment (std direction) | 1 Strongly agree … 5 Strongly disagree | Racial resentment item 1 | ↑ = disagree = liberal | Reverse: `6 - x` |
| `q177` | Q177 — racial resentment (std direction) | 1 Str agree … 5 Str disagree | Racial resentment item 2 | ↑ = liberal | Reverse: `6 - x` |
| `q178` | Q178 — racial resentment (std direction) | 1 Str agree … 5 Str disagree | Racial resentment item 3 | ↑ = liberal | Reverse: `6 - x` |
| `q179` | Q179 — racial resentment (std direction) | 1 Str agree … 5 Str disagree | Racial resentment item 4 | ↑ = liberal | Reverse: `6 - x` |
| `q180` | Q180 — racial resentment (std direction) | 1 Str agree … 5 Str disagree | Racial resentment item 5 | ↑ = liberal | Reverse: `6 - x` |
| `q181` | Q181 — racial resentment (std direction) | 1 Str agree … 5 Str disagree | Racial resentment item 6 | ↑ = liberal | Reverse: `6 - x` |
| `q182` | Q182 — racial resentment (REVERSED wording) | 1 Str disagree … 5 Str agree | Racial resentment item 7 (rev) | ↑ = agree with conservative framing | Keep |
| `q183` | Q183 — racial resentment (REVERSED wording) | 1 Str disagree … 5 Str agree | Racial resentment item 8 (rev) | ↑ = conservative | Keep |
| `q190` | Q190 — remove books from schools | 1 Strongly favor … 5 Strongly oppose | Favor book bans in schools | ↑ = oppose bans = liberal | Reverse: `6 - x` |
| `q45` | Q45 — how hard reps work on Black issues | 1 Very hard … 4 Not hard at all | Reps not working on Black issues | ↑ = not working = cynical/conservative-on-race | Keep (directionality interpretive; flag in reporting) |
| `q30` | Q30 — family economic outlook | 1 Optimistic, 2 Pessimistic, 3 DK | Economic outlook (pessimistic) | Non-monotonic (3=DK) | **Recode** as ordinal 1=Optimistic, 2=Pessimistic; drop/impute DK before reversal decision |
| `q2`  | Q2 — executive branch has too much / right amount / not enough power | 1 Too much, 2 Right amount, 3 Not enough, 4 DK | Executive power view | Non-monotonic | **Recode** to 2-level (Too much vs Not enough) or one-hot; do not reverse as-is |

---

## Recommendations (post-hoc, within the framework)

**A. Labels only — ship now (no model re-fit).**
The `feature_labels` map and a parallel `reverse_code` logical vector
belong in the reporting QMD. The 2020 and 2024 reporting QMDs should
consume the same `label_direction_lookup.R` file so they stay in sync.
This resolves the "raw codes in PDF" complaint immediately.

**B. Model-spec fixes — require a controlled re-run, flag to user.**
1. Fix `exclude_tautological`: replace `q3q` with `q3r17`.
2. Add `paste0("q28r", 1:5)` to `exclude_partisan` to mirror 2020.
3. Add `q175` to `exclude_tautological` (Trump-performance criterion).
4. Re-run Tier 3. Document in the QMD that the original Tier 3 list
   included a coding bug for q3r17 and a partisan-contact inclusion
   that 2020 excluded; the corrected Tier 3 is the defensible one.

**C. Directional recoding applies only to Likert + thermometer
retained features.** Binary priority flags (`q10r*`) and partisan
contact flags (`q28r*`, if retained anywhere) should not be reversed;
their direction in the beeswarm reads as "more of the thing", not
"more conservative".
