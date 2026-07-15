# ------------------------------------------------------------------
# label_direction_lookup.R  (CMPS 2024)
# ------------------------------------------------------------------
# Purpose
#   Post-hoc reporting layer. Feature importance is locked on |SHAP|
#   (direction-invariant). This file supplies (a) human labels and
#   (b) a reverse-code flag so the beeswarm prints with
#   `high raw = conservative / pro-Trump` on the right.
#
# Usage (in the reporting QMD, AFTER the stable feature list is built):
#   source("R/label_direction_lookup.R")
#   plot_df <- shap_long |>
#     dplyr::mutate(
#       raw_for_plot = dplyr::if_else(
#         feature %in% names(reverse_code)[reverse_code],
#         reverse_raw(feature, raw_value),
#         raw_value
#       ),
#       label = dplyr::recode(feature, !!!feature_labels, .default = feature)
#     )
#
# The `reverse_raw()` helper below handles 0-100 thermometers and
# 1-5 Likerts so you don't have to remember the max per feature.
# ------------------------------------------------------------------

# Human-readable labels --------------------------------------------
# Keys match the raw column names in the 2024 CSV.
feature_labels_2024 <- c(
  # Partisan-contact (flagged for exclusion; labels included in case
  # they are still rendered during the exclusion-list transition)
  q28r1 = "Contacted by Dem GOTV",
  q28r2 = "Contacted by GOP GOTV",
  q28r3 = "Contacted by civic org GOTV",
  q28r4 = "Contacted re: ballot initiative",

  # Tautological / Trump-performance (flagged for exclusion)
  q3r17 = "Warmth toward Jan 6 insurrectionists",
  q175  = "Approve: Trump defying court orders",

  # Retained Likerts / thermometers
  q3r15 = "Warmth toward transgender people",
  q3r16 = "Warmth toward undocumented immigrants",
  q3r18 = "Warmth toward Black Lives Matter",
  q310  = "Support: green-jobs program for communities of color",
  q11   = "SCOTUS should look like America",
  q251  = "Favor ban on trans youth in sports",
  q174  = "Approve: Alien Enemies Act",
  q176  = "Racial resentment item 1",
  q177  = "Racial resentment item 2",
  q178  = "Racial resentment item 3",
  q179  = "Racial resentment item 4",
  q180  = "Racial resentment item 5",
  q181  = "Racial resentment item 6",
  q182  = "Racial resentment item 7 (rev wording)",
  q183  = "Racial resentment item 8 (rev wording)",
  q190  = "Favor removing books from schools",
  q45   = "Elected reps work hard on Black issues",
  q10r1 = "Priority: economy/jobs",
  q30   = "Family economic outlook",
  q2    = "Executive branch has too much/right/not enough power"
)

# Reverse-code flags -----------------------------------------------
# TRUE  -> reverse the raw value before plotting so dark points
#          (high raw on the printed axis) mean the conservative end.
# FALSE -> already coded high = conservative (or direction is
#          inherently non-monotonic / binary salience; see notes).
reverse_code_2024 <- c(
  # Thermometers: higher warmth = liberal -> reverse to flip
  q3r15 = TRUE,   # transgender
  q3r16 = TRUE,   # undocumented
  q3r18 = TRUE,   # BLM
  q3r17 = FALSE,  # Jan 6 — warmth already = conservative (should be excluded)

  # Likerts where 1 = Strongly support/favor/agree (liberal end high-raw-means-conservative)
  q310  = FALSE,  # 1 support green jobs ... 5 oppose -> high = conservative
  q251  = TRUE,   # 1 favor ban ... 5 oppose -> high=oppose-ban=liberal -> reverse
  q190  = TRUE,   # 1 favor bans ... 5 oppose -> reverse
  q11   = TRUE,   # 1 not important ... 5 extremely important (liberal) -> reverse
  q174  = FALSE,  # 1 disapprove ... 5 approve -> high = conservative
  q175  = FALSE,  # same scale as q174 (should be excluded)
  q176  = TRUE,   # standard racial-resentment direction -> reverse
  q177  = TRUE,
  q178  = TRUE,
  q179  = TRUE,
  q180  = TRUE,
  q181  = TRUE,
  q182  = FALSE,  # reversed wording -> already high = conservative
  q183  = FALSE,  # reversed wording

  # Binary / non-monotonic -> do not reverse, interpret at face value
  q28r1 = FALSE,
  q28r2 = FALSE,
  q28r3 = FALSE,
  q28r4 = FALSE,
  q10r1 = FALSE,
  q45   = FALSE,  # interpretive; flag in caption
  q30   = FALSE,  # needs recode to 2-level before reversal decision
  q2    = FALSE   # non-monotonic, one-hot at plot time
)

# Helper: reverse a raw value given its known scale -----------------
# Uses the question's canonical min/max. Anything not listed falls
# through to (max + min) - x computed from observed data.
reverse_raw <- function(feature_name, x) {
  # 0-100 feeling thermometers
  therm <- c("q3r15", "q3r16", "q3r17", "q3r18")
  # 1-5 Likerts
  lik5  <- c("q11", "q190", "q251", "q174", "q175", "q310",
             "q176", "q177", "q178", "q179", "q180", "q181",
             "q182", "q183")
  if (feature_name %in% therm) return(100 - x)
  if (feature_name %in% lik5)  return(6 - x)
  # Fallback: data-driven
  rng <- range(x, na.rm = TRUE)
  (rng[1] + rng[2]) - x
}
