/* Created By: Nikhil Edouard
Date:6/13/2026
Description: Ownership Type Analysis*/

--clean hospitals dataset
WITH 
  clean_hospitals AS (
SELECT
  facility_id,
  TRIM(facility_name) AS facility_name,
  address,
  city_town,
  State,
  CASE
		WHEN State IN ('ME','NH','VT','MA','RI','CT','NY','NJ','PA') THEN 'Northeast'
		WHEN State IN ('OH','MI','IN','WI','IL','MN','IA','MO','ND','SD','NE','KS') THEN 'Midwest'
		WHEN State IN ('DE','MD','DC','VA','WV','NC','SC','GA','FL','KY','TN','AL','MS','AR','LA','OK','TX') THEN 'South'
		WHEN State IN ('AK', 'AZ', 'CA', 'CO', 'HI', 'ID', 'MT', 'NV','NM', 'OR', 'UT', 'WA', 'WY') THEN 'West'
    ELSE 'US Territories'
	END AS region,
  zip_code,
  county_parish,
  hospital_type,
  hospital_ownership, 
  Emergency_Services, 
  CAST(hospital_overall_rating AS FLOAT64) AS hospital_overall_rating,
  SAFE_CAST(Count_of_MORT_Measures_Worse AS INT64) AS Count_of_MORT_Measures_Worse, 
  SAFE_CAST(Count_of_Safety_Measures_Worse AS INT64) AS Count_of_Safety_Measures_Worse, 
  SAFE_CAST(Count_of_READM_Measures_Worse AS INT64) AS Count_of_READM_Measures_Worse, 
  SAFE_CAST(Count_of_MORT_Measures_Better AS INT64) AS Count_of_MORT_Measures_Better, 
  SAFE_CAST(Count_of_Safety_Measures_Better AS INT64) AS Count_of_Safety_Measures_Better, 
  SAFE_CAST(Count_of_READM_Measures_Better AS INT64) AS Count_of_READM_Measures_Better,
  SAFE_CAST(Count_of_MORT_Measures_Worse AS INT64) + SAFE_CAST(Count_of_Safety_Measures_Worse AS INT64) + SAFE_CAST(Count_of_READM_Measures_Worse AS INT64) AS Composite_Worse_Count,
  SAFE_CAST(Count_of_MORT_Measures_Better AS INT64) + SAFE_CAST(Count_of_Safety_Measures_Better AS INT64) + SAFE_CAST(Count_of_READM_Measures_Better AS INT64) AS Composite_Better_Count,
  SAFE_CAST(COUNT_of_Facility_Mort_Measures AS INT64) AS COUNT_of_Facility_Mort_Measures,
  SAFE_CAST(MORT_Group_Measure_Count AS INT64) AS MORT_Group_Measure_Count
FROM
  cms-data-1.CMS_Data.Hospital_General_Information
WHERE
  hospital_overall_rating <> 'Not Available'),

--Clean surveys dataset
 clean_surveys AS (
SELECT
  Facility_ID,
  TRIM(Facility_name) as facility_name,
  CAST(Patient_Survey_Star_Rating AS FLOAT64) as patient_survey_star_rating,
  Number_of_completed_surveys,
  survey_response_rate_percent
FROM
  cms-data-1.CMS_Data.HCAHPS_Hospital
WHERE
  HCAHPS_Question = 'Summary star rating'
  AND Patient_Survey_Star_Rating NOT IN ('Not Available','Not Applicable'))

--Ownership Type Clinical Performance
SELECT
  ch.hospital_ownership,
  COUNT(*) AS hospital_count,
  ROUND(AVG(ch.hospital_overall_rating),2) AS avg_hospital_overall_rating,
  ROUND(AVG(cs.patient_survey_star_rating),2) AS avg_survey_rating,
  ROUND(AVG(SAFE_DIVIDE(ch.composite_better_count, ch.composite_worse_count)),2) AS composite_count_ratio,
  ROUND(AVG(ch.composite_worse_count),2) AS avg_composite_worse_count,
  ROUND(AVG(ch.composite_better_count),2) AS avg_composite_better_count,

FROM
  clean_hospitals as ch
LEFT JOIN
  clean_surveys as cs
  ON ch.facility_id=cs.facility_id
GROUP BY
  ch.hospital_ownership
HAVING
  hospital_count >=15
ORDER BY
  avg_hospital_overall_rating DESC;




