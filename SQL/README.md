# SQL

BigQuery SQL queries used to clean, transform, and analyze the CMS hospital datasets.

## Files

**cleaned_queries.sql**
Foundational cleaning queries for both the Hospital General Information and HCAHPS datasets. Includes CTEs that filter out records with missing or invalid rating data, cast text-stored numeric fields to proper data types, classify hospitals into four U.S. regions, and calculate composite clinical performance scores from mortality, safety, and readmission measures. These cleaned CTEs (`clean_hospitals` and `clean_surveys`) serve as the foundation referenced throughout the analysis queries below.

**regional_analysis_query_final.sql**
Analyzes hospital overall ratings and patient survey ratings by U.S. region, including five-star and one/two-star concentration counts and percentage breakdowns.

**ownership_type_analysis_final.sql**
Analyzes hospital overall ratings and patient survey performance by ownership type (government, proprietary, voluntary non-profit, Veteran Health Administration, etc.), including composite clinical performance metrics by ownership category.

**state_coverage_analysis_final.sql**
Builds a state-level scorecard combining overall rating quality, HCAHPS survey coverage percentage, and a composite risk classification (Standard, Elevated Risk, High Risk) based on low-star concentration and clinical performance relative to national benchmarks.

## Tools

All queries were written and executed in **Google BigQuery**. Column names and CAST syntax (e.g., `FLOAT64`, `SAFE_CAST`) reflect BigQuery-specific SQL.

## Notes

Because the BigQuery Sandbox environment used for this project does not support persistent temporary tables, cleaning logic is reproduced via CTE at the top of each analysis file rather than referenced from a separate cleaned table.
