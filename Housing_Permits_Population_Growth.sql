WITH CTE_HousPopGrowth AS
(
SELECT 
    HousPermSocialChars.*,

    -- Split county/state from year
    LEFT(HousPermSocialChars.County_State, LENGTH(HousPermSocialChars.County_State) - 6) AS County_State_Name,
    CAST(RIGHT(HousPermSocialChars.County_State, 4) AS UNSIGNED) AS `Year`,

    HousChar.Median_House_Value, 
    HousChar.`Total_Paying_30_to_34.9_Pct`,
    HousChar.Total_Paying_Over_35_Pct, 
    HousChar.Median_Rent, 
    HousChar.Occupied_Housing_Units, 
    HousChar.Owner_Occupied, 
    Inc.Median_Household_Income, 
    MedianAge65Emp.Median_Age_Years, 
    MedianAge65Emp.Pct_Age_65_or_above, 
    MedianAge65Emp.Working_Age_Population,
    MedianAge65Emp.Total_Number_Employed, 
    RaceEthPoverty.Number_In_Poverty, 
    RaceEthPoverty.White_Population,
    RaceEthPoverty.Black_Population, 
    RaceEthPoverty.Asian_Population, 
    RaceEthPoverty.Hispanic_Population,
    LandArea.Land_Area_Sq_Miles,

    -- Foreign-born population percentage
    HousPermSocialChars.Foreign_Born_Population * 100.0 /
    HousPermSocialChars.Total_Population AS Foreign_Born_Pct,

    -- Total permits per 1,000 population
    HousPermSocialChars.Total_Permits * 1000.0 /
    HousPermSocialChars.Total_Population AS Total_Permits_per_1000,

    -- Single-family permits per 1,000 population
    HousPermSocialChars.Single_Family_Permits * 1000.0 /
    HousPermSocialChars.Total_Population AS Single_Family_Permits_per_1000,

    -- Total multifamily permits per 1,000 population
    HousPermSocialChars.Tot_Multifamily_Permits * 1000.0 /
    HousPermSocialChars.Total_Population AS Total_Multifamily_Permits_per_1000,

    -- 2-unit permits per 1,000 population
    HousPermSocialChars.`2_Unit_Permits` * 1000.0 /
    HousPermSocialChars.Total_Population AS 2_Unit_Permits_per_1000,

    -- 3–4 unit permits per 1,000 population
    HousPermSocialChars.`3_or_4_Unit_Permits` * 1000.0 /
    HousPermSocialChars.Total_Population AS 3_or_4_Unit_Permits_per_1000,

    -- 5+ unit permits per 1,000 population
    HousPermSocialChars.`5_or_More_Unit_Permits` * 1000.0 /
    HousPermSocialChars.Total_Population AS 5_or_More_Unit_Permits_per_1000,

    -- Permits for buildings with at least 3 units, per 1,000 population
    (HousPermSocialChars.`3_or_4_Unit_Permits` +
     HousPermSocialChars.`5_or_More_Unit_Permits`) * 1000.0 /
    HousPermSocialChars.Total_Population AS 3_or_More_Unit_Permits_per_1000,

    -- Homeownership rate
    HousChar.Owner_Occupied * 100.0 /
    HousChar.Occupied_Housing_Units AS Homeownership_Rate,

    -- Employment-to-working-age-population ratio
    MedianAge65Emp.Total_Number_Employed * 100.0 /
    MedianAge65Emp.Working_Age_Population AS Employment_Population_Ratio,

    -- Poverty rate
    RaceEthPoverty.Number_In_Poverty * 100.0 /
    HousPermSocialChars.Total_Population AS Poverty_Rate,

    -- White population percentage
    RaceEthPoverty.White_Population * 100.0 /
    HousPermSocialChars.Total_Population AS White_Pct,

    -- Black population percentage
    RaceEthPoverty.Black_Population * 100.0 /
    HousPermSocialChars.Total_Population AS Black_Pct,

    -- Asian population percentage
    RaceEthPoverty.Asian_Population * 100.0 /
    HousPermSocialChars.Total_Population AS Asian_Pct,

    -- Hispanic population percentage
    RaceEthPoverty.Hispanic_Population * 100.0 /
    HousPermSocialChars.Total_Population AS Hispanic_Pct,

    -- Rent burden over 30%
    (HousChar.`Total_Paying_30_to_34.9_Pct` +
     HousChar.Total_Paying_Over_35_Pct) * 100.0 /
    (HousChar.Occupied_Housing_Units - HousChar.Owner_Occupied)
    AS Rent_Burden_Over_30_Pct,
    
    -- Population density
    HousPermSocialChars.Total_Population /
    LandArea.Land_Area_Sq_Miles AS Population_Density

FROM `finalized socialchars and houspermits (2010-2023) - 2010-2023` AS HousPermSocialChars

INNER JOIN `final housing characteristics 2010-2022 - 2010-2022 data` AS HousChar 
    ON HousPermSocialChars.County_State = HousChar.County_State

INNER JOIN `final income 2010-2022 - 2010-2022 data` AS Inc 
    ON HousPermSocialChars.County_State = Inc.County_State

INNER JOIN `final medianage age65 workagepop emp 2010-2022 - 2010-2022` AS MedianAge65Emp 
    ON HousPermSocialChars.County_State = MedianAge65Emp.County_State

INNER JOIN `final race_ethnicity and poverty rate 2010-2022 - 2010-2022 data` AS RaceEthPoverty 
    ON HousPermSocialChars.County_State = RaceEthPoverty.County_State

INNER JOIN `final sqmiles land by county - 2010-2022 data` AS LandArea 
    ON HousPermSocialChars.County_State = LandArea.County_State
),

CTE_PopGrowth AS
(
    SELECT
        CTE_HousPopGrowth.*,

        -- Previous year's population within the same county/state
        LAG(Total_Population) OVER (
            PARTITION BY County_State_Name
            ORDER BY `Year`
        ) AS Previous_Population

    FROM CTE_HousPopGrowth
    ),



CTE_Final AS
(
    SELECT
        CTE_PopGrowth.*,

        -- Annual population growth rate
        (Total_Population - Previous_Population) * 100.0 /
        Previous_Population AS Population_Growth_Rate

    FROM CTE_PopGrowth
),



CTE_Lags AS
(
    SELECT
        CTE_Final.*,

        -- Previous-year total permits per 1,000
        LAG(Total_Permits_per_1000) OVER (
            PARTITION BY County_State_Name
            ORDER BY `Year`
        ) AS Lag_Total_Permits_per_1000,

        -- Previous-year single-family permits per 1,000
        LAG(Single_Family_Permits_per_1000) OVER (
            PARTITION BY County_State_Name
            ORDER BY `Year`
        ) AS Lag_Single_Family_Permits_per_1000,

        -- Previous-year 3+ unit permits per 1,000
        LAG(3_or_More_Unit_Permits_per_1000) OVER (
            PARTITION BY County_State_Name
            ORDER BY `Year`
        ) AS Lag_3_or_More_Unit_Permits_per_1000,

        -- Previous-year multifamily permits per 1,000
        LAG(Total_Multifamily_Permits_per_1000) OVER (
            PARTITION BY County_State_Name
            ORDER BY `Year`
        ) AS Lag_Total_Multifamily_Permits_per_1000,

        -- Previous-year median house value
        LAG(Median_House_Value) OVER (
            PARTITION BY County_State_Name
            ORDER BY `Year`
        ) AS Lag_Median_House_Value,

        -- Previous-year median rent
        LAG(Median_Rent) OVER (
            PARTITION BY County_State_Name
            ORDER BY `Year`
        ) AS Lag_Median_Rent,

        -- Previous-year median household income
        LAG(Median_Household_Income) OVER (
            PARTITION BY County_State_Name
            ORDER BY `Year`
        ) AS Lag_Median_Household_Income

    FROM CTE_Final
),

CTE_Growth AS
(
    SELECT
        CTE_Lags.*,

        -- Growth in total permits per 1,000
        (Total_Permits_per_1000 - Lag_Total_Permits_per_1000) * 100.0 /
        NULLIF(Lag_Total_Permits_per_1000, 0)
        AS Total_Permits_Growth_Rate,

        -- Growth in single-family permits per 1,000
        (Single_Family_Permits_per_1000 - Lag_Single_Family_Permits_per_1000) * 100.0 /
        NULLIF(Lag_Single_Family_Permits_per_1000, 0)
        AS Single_Family_Permits_Growth_Rate,

        -- Growth in 3+ unit permits per 1,000
        (3_or_More_Unit_Permits_per_1000 - Lag_3_or_More_Unit_Permits_per_1000) * 100.0 /
        NULLIF(Lag_3_or_More_Unit_Permits_per_1000, 0)
        AS 3_or_More_Unit_Permits_Growth_Rate,

        -- Growth in multifamily permits per 1,000
        (Total_Multifamily_Permits_per_1000 - Lag_Total_Multifamily_Permits_per_1000) * 100.0 /
        NULLIF(Lag_Total_Multifamily_Permits_per_1000, 0)
        AS Multifamily_Permits_Growth_Rate,

        -- Growth in median house value
        (Median_House_Value - Lag_Median_House_Value) * 100.0 /
        NULLIF(Lag_Median_House_Value, 0)
        AS Median_House_Value_Growth_Rate,

        -- Growth in median rent
        (Median_Rent - Lag_Median_Rent) * 100.0 /
        NULLIF(Lag_Median_Rent, 0)
        AS Median_Rent_Growth_Rate,

        -- Growth in median household income
        (Median_Household_Income - Lag_Median_Household_Income) * 100.0 /
        NULLIF(Lag_Median_Household_Income, 0)
        AS Median_Household_Income_Growth_Rate

    FROM CTE_Lags
)

SELECT *
FROM CTE_Growth;
