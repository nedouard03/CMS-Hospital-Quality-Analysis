# Data

This folder contains the source CMS datasets used in this analysis.

## Files

**hospital_general_information.csv**
Raw CMS Hospital General Information dataset. Contains facility-level data including hospital ratings, ownership type, location, emergency services availability, and underlying quality measure counts across mortality, safety, and readmission domains.

**hcahps_hospital.xlsx**
An exported and filtered version of the CMS HCAHPS (Hospital Consumer Assessment of Healthcare Providers and Systems) dataset. The original raw file exceeded GitHub's file size limits, so this export was filtered to relevant columns and rows prior to upload. The full raw dataset is publicly available at the source link below.

## Source

CMS Hospital General Information, accessed via [data.cms.gov](https://data.cms.gov/provider-data/dataset/xubh-q36u#data-table)

CMS HCAHPS datasets, accessed via [data.cms.gov](https://data.cms.gov/provider-data/dataset/dgck-syfz)

## Notes

Both datasets share a common `facility_id` field used to join hospital-level rating data with patient experience survey data throughout the SQL analysis in this project. See [`/sql`](../sql) for cleaning and join logic.
