use DWISE;
GO

CREATE TABLE gold.dim_equipment (
    equipment_id INT PRIMARY KEY,
    equipment_name VARCHAR(100),
    equipment_type VARCHAR(50),
    rated_capacity DECIMAL(10,2),
    manufacture VARCHAR(100),
    installation_date DATE,
    operational_status VARCHAR(50)
);

CREATE TABLE gold.dim_site (
    site_id INT PRIMARY KEY,
    site_name VARCHAR(100),
    region VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE gold.dim_time (
    time_id INT PRIMARY KEY,
    date DATE,
    year INT,
    month INT,
    day INT
);


CREATE TABLE gold.dim_fuel (
    energy_type_id INT PRIMARY KEY,
    fuel_name VARCHAR(100),
    energy_content DECIMAL(10,2),
    emission_factor DECIMAL(10,2)
);

CREATE TABLE gold.dim_weather (
    weather_id INT PRIMARY KEY,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    wind_speed DECIMAL(5,2)
);


CREATE TABLE gold.fact_energy_equipment_summary (
    fact_id INT IDENTITY PRIMARY KEY,
    equipment_id INT,
    site_id INT,
    time_id INT,
    energy_type_id INT,
    weather_id INT,
    total_energy_production DECIMAL(18,2),
    total_rated_capacity DECIMAL(18,2),
    FOREIGN KEY (equipment_id) REFERENCES gold.dim_equipment(equipment_id),
    FOREIGN KEY (site_id) REFERENCES gold.dim_site(site_id),
    FOREIGN KEY (time_id) REFERENCES gold.dim_time(time_id),
    FOREIGN KEY (energy_type_id) REFERENCES gold.dim_fuel(energy_type_id),
    FOREIGN KEY (weather_id) REFERENCES gold.dim_weather(weather_id)
);

INSERT INTO gold.fact_energy_equipment_summary (
    equipment_id, site_id, time_id, energy_type_id, weather_id,
    total_energy_production, total_rated_capacity
)
SELECT
    ep.equipment_id,
    ep.site_id,
    t.time_id,
    ep.energy_type_id,    
    en.weather_id,
    SUM(en.electricity_Production_kWh),
    SUM(en.Equipment_Rated_Capacity)
FROM silver.stg_equipment_performance ep
JOIN silver.stg_energy_production en
  ON ep.equipment_id = en.equipment_id
  AND ep.site_id = en.site_id
  AND ep.standardized_date = CONVERT(DATE, en.Time_Date)
JOIN gold.dim_time t
  ON t.date = ep.standardized_date
GROUP BY
    ep.equipment_id,
    ep.site_id,
    t.time_id,
    ep.energy_type_id,
    en.weather_id;


select * from gold.fact_energy_equipment_summary;