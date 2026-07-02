# CMS Hospital Quality Analysis

A regional and clinical risk analysis of U.S. hospital quality using publicly available CMS Medicare data, covering nearly 3,000 hospitals across all 50 states.

## Overview

This project analyzes CMS Hospital General Information and HCAHPS (Hospital Consumer Assessment of Healthcare Providers and Systems) data to identify regional disparities in hospital quality ratings, ownership-type performance patterns, patient experience survey coverage gaps, and a composite clinical risk classification by state.

The analysis combines hospital overall star ratings with underlying mortality, safety, and readmission performance measures to build a more complete picture of hospital quality than star ratings alone provide.

## Key Findings

- The Midwest leads the nation in both overall quality rating (3.28) and patient experience scores (3.30), while the South lags at 2.97
- Veteran Health Administration hospitals significantly outperform all other ownership types across both overall rating and patient survey scores
- Patient survey data coverage is strong nationally — only Mississippi falls below 80% coverage among rated hospitals
- 10 states are flagged High Risk based on a composite model combining low-star concentration with below-average mortality and safety performance: Mississippi, New York, Alabama, Kentucky, Georgia, Illinois, Arkansas, New Mexico, West Virginia, and Nevada

Full findings summary available in [`/findings`](./findings).

## Repository Structure

| Folder | Contents |
|---|---|
| [`/data`](./data) | Source CMS datasets used in this analysis |
| [`/sql`](./sql) | BigQuery SQL queries for cleaning and analysis |
| [`/findings`](./findings) | One-page findings summary and data cleaning log |
| [`/tableau`](./tableau) | Interactive Tableau dashboard and workbook file |

## Tools Used

- **BigQuery** — data cleaning and SQL analysis
- **Microsoft Excel** — initial data exploration and cleaning
- **Tableau Public** — dashboard visualization
- **Google Sheets** — supplementary cleaning documentation

## Live Dashboard

View the interactive dashboard on Tableau Public: [https://public.tableau.com/views/Copy_17826017627110/Dashboard2?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link]

## Data Source

CMS Hospital General Information, accessed via [data.cms.gov](https://data.cms.gov/provider-data/dataset/xubh-q36u#data-table)

CMS HCAHPS datasets, accessed via [data.cms.gov](https://data.cms.gov/provider-data/dataset/dgck-syfz)


## About

Built by Nikhil Edouard as an independent healthcare analytics project. Connect with me on [LinkedIn](https://www.linkedin.com/in/nikhil-edouard).
