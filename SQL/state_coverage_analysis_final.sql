/*Created By: Nikhil Edouard
Date: 6/16/2026
Description: State Coverage Analysis*/

--Cleaned hospitals CTE
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

--Cleaned survey Table
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
  AND Patient_Survey_Star_Rating NOT IN ('Not Available','Not Applicable')),

--state overall rating quality CTE
state_quality AS(
  SELECT 
    State, 
    region,
    count(facility_id) AS hospital_count, 
    ROUND(AVG(hospital_overall_rating),2) AS average_overall_rating, 
    --high overall rating defined as 4 or 5 stars
    SUM(CASE WHEN hospital_overall_rating IN (4,5) THEN 1 ELSE 0 END)  AS high_ovr_rating_count,
    --low overall rating defined as 1 or 2 stars
    SUM(CASE WHEN hospital_overall_rating IN (1,2) THEN 1 ELSE 0 END)  AS low_ovr_rating_count,
    ROUND((SUM(CASE WHEN hospital_overall_rating IN (1,2) THEN 1 ELSE 0 END) *100.0) /COUNT(facility_id),1) AS percentage_low_rated,
    ROUND(AVG(Composite_Worse_Count),2) AS Composite_Worse_Count,
    ROUND(SUM( CASE
		WHEN Count_of_MORT_Measures_Worse > 0 THEN 1.0
		ELSE 0 END) * 100.0/ Count (*),2) AS percent_below_national_avg_mort,
	ROUND(SUM( CASE
		WHEN Count_of_safety_Measures_Worse > 0 THEN 1.0
		ELSE 0 END) * 100.0/ Count (*),2) AS percent_below_national_avg_safety
  FROM clean_hospitals GROUP BY State, region),

--state survey coverage CTE
state_coverage AS(
  SELECT	
    ch.State,
    COUNT(DISTINCT ch.facility_id) AS total_hospitals,
    COUNT(DISTINCT cs.facility_id) AS hospitals_with_survey_data,
    ROUND(AVG(cs.patient_survey_star_rating),2) as patient_survey_star_rating
  FROM
    clean_hospitals as ch
  LEFT JOIN 
    clean_surveys as cs
    ON ch.facility_id=cs.facility_id
  GROUP BY ch.state),
national_benchmark AS (
		SELECT ROUND(AVG(hospital_overall_rating),2) AS national_average_rating
		FROM clean_hospitals)


--State Level quality and coverage scorecard
SELECT
	sq.State,
  sq.region,
	sc.total_hospitals,
  sc.patient_survey_star_rating,
	sq.average_overall_rating,
	nb.national_average_rating,
	CASE
		WHEN sq.average_overall_rating > nb.national_average_rating THEN 'Above'
		WHEN sq.average_overall_rating = nb.national_average_rating THEN 'At'
		ELSE 'Below'
	END AS overall_rating_vs_national,
	sq.high_ovr_rating_count,
	sq.percentage_low_rated,
  ROUND((sc.hospitals_with_survey_data *100.0)/sc.total_hospitals,1) AS survey_coverage_percentage,
	CASE 
		WHEN (sc.hospitals_with_survey_data  *100.0)/sc.total_hospitals > 80 THEN 'Strong'
		WHEN (sc.hospitals_with_survey_data  *100.0)/sc.total_hospitals BETWEEN 50 AND 80 THEN 'Moderate'
		ELSE 'Weak'
	END AS survey_coverage_tier,
  sq.Composite_Worse_Count,
	CASE 
		WHEN sq.percentage_low_rated >25 AND (sc.hospitals_with_survey_data  *100.0)/sc.total_hospitals < 50 THEN 'High Priority'
		WHEN sq.percentage_low_rated >25 OR (sc.hospitals_with_survey_data  *100.0)/sc.total_hospitals < 50 THEN 'Monitor'
		ELSE 'Stable'
	END AS priority_flag,
  sq.percent_below_national_avg_mort,
	sq.percent_below_national_avg_safety,
	CASE
		WHEN sq.percentage_low_rated >= 40 OR (sq.percentage_low_rated >= 25 AND (sq.percent_below_national_avg_safety >=40 OR sq.percent_below_national_avg_mort>=40)) THEN 'High Risk'
		WHEN sq.percentage_low_rated >= 30 OR (sq.percentage_low_rated >= 15 AND (sq.percent_below_national_avg_safety >=30 OR sq.percent_below_national_avg_mort>=30)) THEN 'Elevated Risk'
		ELSE 'Standard'
	END AS composite_risk_flag
FROM 
	state_quality AS sq
JOIN
	state_coverage AS sc 
	ON sq.State=sc.State
CROSS JOIN
	national_benchmark as nb
WHERE
	sc.total_hospitals>=15
ORDER BY
  composite_risk_flag,
  	sq.average_overall_rating;


