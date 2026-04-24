# ml-latino-vote-2024

Inferential Feature Analysis of Latino Trump support using the 2024 Collaborative Multiracial Post-Election Survey (CMPS).

**DV:** Binary indicator of Latino vote for Donald Trump.

**Method:** Random Forest (`ranger`) + SHAP values (`treeshap` / `shapviz`), four-tier progressive exclusion framework, 100-iteration bootstrap for rank stability.

## Key files

- `CMPS_2024_IFA_analysis.qmd` — end-to-end analysis pipeline. Runs data cleaning, imputation, RF models (Tiers 1–4), SHAP decomposition, and bootstrap. Saves the fitted objects to `ifa_results.rds` at the project root and renders `CMPS_2024_IFA_analysis.pdf`.
- `CMPS_2024_IFA_analysis.pdf` — rendered output with manuscript-ready figures and tables.
- `ml-latino-vote-2024.Rproj` — RStudio project file.
- `docs/` — CMPS 2024 codebook, instrument, and codebook review summary.

## Folder structure

```
CMPS_2024_IFA_analysis.qmd   # analysis + reporting pipeline
CMPS_2024_IFA_analysis.pdf   # rendered output
docs/                        # codebook, questionnaire, feature notes
data/                        # raw + processed CMPS data (gitignored)
scratch/                     # working drafts, audits, superseded files (gitignored)
ifa_results.rds              # cached model objects (gitignored, regenerated on render)
```

## Reproducing

1. Obtain the 2024 CMPS raw data and place it under `data/raw/`.
2. Open `ml-latino-vote-2024.Rproj` in RStudio.
3. Render `CMPS_2024_IFA_analysis.qmd`. First render fits all models and caches them to `ifa_results.rds`; later renders reuse the cache.

## Main result

Tier 3 (post-partisan exclusion) and Tier 4 (gender-split) models identify which substantive attitudes and experiences predict Latino Trump support beyond partisanship and ideology.

## What is gitignored

- `data/` — license-restricted raw data and derived files
- `scratch/` — working drafts and audits (not needed for reproduction)
- `*.rds` — model caches (regenerated on render)
- Quarto render artifacts (`*_files/`, `.quarto/`, `*.tex`, `*.html`, etc.)

## Related repositories

- [`ml-latino-vote-2016`](https://github.com/jagrijalva/ml-latino-vote-2016) — parallel analysis on the 2016 CMPS.
- [`ml-latino-vote-2020`](https://github.com/jagrijalva/ml-latino-vote-2020) — parallel analysis on the 2020 CMPS.

## License

MIT — see [`LICENSE`](LICENSE).
