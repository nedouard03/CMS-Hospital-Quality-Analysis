
/*Created BY: Nikhil Edouard
Date: 6/9/2026
Description: Cleaning Queries*/

--5,426 rows before analysis
--Can't Create tables/temp tables in Sandbox, so I will have to use CTEs to reference clean tables
--Cleaned CMS Hospital General Information Table Query: Returns 2,866 rows 
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
  SAFE_CAST(Count_of_MORT_Measures_Better AS INT64) + SAFE_CAST(Count_of_Safety_Measures_Better AS INT64) + SAFE_CAST(Count_of_READM_Measures_Better AS INT64) AS Composite_Better_Count
FROM
  cms-data-1.CMS_Data.Hospital_General_Information
WHERE
  hospital_overall_rating <> 'Not Available'),

--Cleaned HCAHPS Table Query: Returns 3,183 rows
  
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

--Joined Clean Tables: Returns 2,741 Rows (all distinct)
SELECT
  *
FROM
  clean_hospitals as ch
INNER JOIN
  clean_surveys as cs
  ON ch.facility_id=cs.facility_id;





