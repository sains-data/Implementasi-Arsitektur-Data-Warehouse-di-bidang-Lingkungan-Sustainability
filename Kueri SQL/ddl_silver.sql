use DWISE;

GO

-- Menstandarisasi format waktu ke YYYY-MM-DD
SELECT
    equipment_id,
    site_id,
    energy_type_id,
    weather_id,
    CONVERT(DATE, Time_Date, 120) AS standardized_date,
    UPPER(LTRIM(RTRIM(site_name))) AS site_name,
    UPPER(LTRIM(RTRIM(Site_Location))) AS region
INTO silver.stg_equipment_performance
FROM bronze.equipment_performance;


-- Tipe energi unik
SELECT DISTINCT
    energy_type_id,
    Energy_Type_Name
INTO silver.dim_energy_type
FROM bronze.equipment_performance
WHERE Energy_Type_Name IS NOT NULL;

-- Tipe peralatan unik
SELECT DISTINCT
    equipment_id,
    equipment_name,
    equipment_type
INTO silver.dim_equipment_type
FROM bronze.equipment_performance
WHERE equipment_name IS NOT NULL AND equipment_type IS NOT NULL;

--Penanganan Missing Value
SELECT
    *,
    ISNULL(electricity_Production_kWh, 0) AS fuel_consumption_cleaned
INTO silver.stg_energy_production
FROM bronze.energy_production;

select * from silver.stg_equipment_performance;