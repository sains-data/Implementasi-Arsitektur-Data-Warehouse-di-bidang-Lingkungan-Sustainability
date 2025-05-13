
-- 1. Time Dimension 
CREATE TABLE dim_time (
    time_id INT PRIMARY KEY,
    date DATE,
    month INT,
    year INT,
    hours INT,
    minutes INT
);

-- 2. Site Dimension 
CREATE TABLE dim_site (
    site_id INT PRIMARY KEY,
    site_name VARCHAR(100),
    region VARCHAR(100),
    operational_status VARCHAR(50)
);

-- 3. Weather Dimension
CREATE TABLE dim_weather (
    weather_id INT PRIMARY KEY,
    temperature DECIMAL(5,2),       
    humidity_percent DECIMAL(5,2),
    wind_speed_mps DECIMAL(5,2), 
    rainfall_mm DECIMAL(5,2)        
);

-- 4. Fuel Type Dimension
CREATE TABLE dim_fuel_type (
    fuel_type_id INT PRIMARY KEY,
    fuel_name VARCHAR(100),
    quantity DECIMAL(10,2)        
);

-- 5. Equipment Dimension
CREATE TABLE dim_equipment (
    equipment_id INT PRIMARY KEY,
    equipment_name VARCHAR(100),
    equipment_type VARCHAR(100),
    manufacture VARCHAR(100),
    capacity DECIMAL(10,2),       
    installation_date DATE,
    last_maintenance_date DATE
);

-- 6. Project Dimension
CREATE TABLE dim_project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    project_type VARCHAR(50)
);

-- 7. Emission Type Dimension 
CREATE TABLE dim_emission_type (
    emission_type_id INT PRIMARY KEY,
    emission_scope VARCHAR(100),
    source_type VARCHAR(100),
    emission_unit VARCHAR(50)
);

-- 8. Regulation Dimension 
CREATE TABLE dim_regulation (
    regulation_id INT PRIMARY KEY,
    enforcement_agency VARCHAR(100),
    regulation_name VARCHAR(100),
    compliance_level VARCHAR(50),
    penalty_risk_level VARCHAR(50)
);

-- 9. Inspection Result Dimension 
CREATE TABLE dim_inspection_result (
    inspection_result_id INT PRIMARY KEY,
    result_category VARCHAR(100),
    severity_level VARCHAR(50),
    action_required VARCHAR(100)
);

-- 10. Fact Table: Energy Production
CREATE TABLE fact_energy_production (
    production_id INT PRIMARY KEY,
    time_id INT,
    site_id INT,
    equipment_id INT,
    weather_id INT,
    fuel_type_id INT,
    total_production DECIMAL(12,2),
    cost_production DECIMAL(12,2), 

    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (site_id) REFERENCES dim_site(site_id),
    FOREIGN KEY (equipment_id) REFERENCES dim_equipment(equipment_id),
    FOREIGN KEY (weather_id) REFERENCES dim_weather(weather_id),
    FOREIGN KEY (fuel_type_id) REFERENCES dim_fuel_type(fuel_type_id)
);

-- 11. Fact Table: Equipment Performance
CREATE TABLE fact_equipment_performance (
    ep_id INT PRIMARY KEY,
    time_id INT,
    site_id INT,
    equipment_id INT,
    fuel_type_id INT,
    cost_maintenance DECIMAL(12,2),
    fuel_consumption DECIMAL(12,2),
    downtime_hours DECIMAL(10,2),

    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (site_id) REFERENCES dim_site(site_id),
    FOREIGN KEY (equipment_id) REFERENCES dim_equipment(equipment_id),
    FOREIGN KEY (fuel_type_id) REFERENCES dim_fuel_type(fuel_type_id)
);

-- 12. Fact Table: Operational Efficiency
CREATE TABLE fact_operational_efficiency (
    oe_id INT PRIMARY KEY,
    time_id INT,
    site_id INT,
    project_id INT,
    actual_cost DECIMAL(12,2),
    budget DECIMAL(12,2),
    variance_cost DECIMAL(12,2),
    duration INT,

    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (site_id) REFERENCES dim_site(site_id),
    FOREIGN KEY (project_id) REFERENCES dim_project(project_id)
);

-- 13. Fact Table: Environmental
CREATE TABLE fact_environmental (
    env_id INT PRIMARY KEY,
    time_id INT,
    site_id INT,
    emission_type_id INT,
    regulation_id INT,
    carbon_emission DECIMAL(12,2),
    waste_generated DECIMAL(12,2),

    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (site_id) REFERENCES dim_site(site_id),
    FOREIGN KEY (emission_type_id) REFERENCES dim_emission_type(emission_type_id),
    FOREIGN KEY (regulation_id) REFERENCES dim_regulation(regulation_id)
);

-- 14. Fact Table: Regulatory Compliance
CREATE TABLE fact_regulatory_compliance (
    compliance_id INT PRIMARY KEY,
    time_id INT,
    site_id INT,
    regulation_id INT,
    inspection_result_id INT,
    inspection_count INT,
    violation_count INT,
    penalty_estimate DECIMAL(12,2),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (site_id) REFERENCES dim_site(site_id),
    FOREIGN KEY (regulation_id) REFERENCES dim_regulation(regulation_id),
    FOREIGN KEY (inspection_result_id) REFERENCES dim_inspection_result(inspection_result_id)
);

-- Queries
SELECT 
    t.year, t.month,
    s.region,
    e.equipment_type,
    f.total_production,
    f.cost_production
FROM fact_energy_production f
JOIN dim_time t ON f.time_id = t.time_id
JOIN dim_site s ON f.site_id = s.site_id
JOIN dim_equipment e ON f.equipment_id = e.equipment_id;

SELECT 
    t.year, t.month,
    s.site_name,
    o.budget,
    o.actual_cost,
    o.variance_cost
FROM fact_operational_efficiency o
JOIN dim_time t ON o.time_id = t.time_id
JOIN dim_site s ON o.site_id = s.site_id
JOIN dim_project p ON o.project_id = p.project_id;

SELECT 
    t.date,
    e.equipment_name,
    e.capacity,
    ep.fuel_consumption,
    ep.downtime_hours
FROM fact_equipment_performance ep
JOIN dim_time t ON ep.time_id = t.time_id
JOIN dim_equipment e ON ep.equipment_id = e.equipment_id;

SELECT 
    t.date,
    s.region,
    et.source_type AS emission_source,
    f.carbon_emission,
    f.waste_generated
FROM fact_environmental f
JOIN dim_time t ON f.time_id = t.time_id
JOIN dim_site s ON f.site_id = s.site_id
JOIN dim_emission_type et ON f.emission_type_id = et.emission_type_id;

SELECT 
    t.year,
    s.site_name,
    r.regulation_name,
    r.compliance_level,
    rc.inspection_count,
    rc.violation_count
FROM fact_regulatory_compliance rc
JOIN dim_time t ON rc.time_id = t.time_id
JOIN dim_site s ON rc.site_id = s.site_id
JOIN dim_regulation r ON rc.regulation_id = r.regulation_id;
