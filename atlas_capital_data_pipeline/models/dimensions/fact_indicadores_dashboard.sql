-- models/dimensions/fact_indicadores_dashboard.sql
-- Materializada como view (view)
{{ config(
    materialized='view',
    schema='marts_atlas_capital'
) }}

SELECT
    f.*,
    p.country_name,
    t.year_label,
    t.loaded_at_utc
FROM {{ ref('fact_indicadores_economicos') }} f
LEFT JOIN {{ ref('dim_pais') }} p 
    ON f.country_key = p.country_key
LEFT JOIN {{ ref('dim_tempo') }} t 
    ON f.time_key = t.time_key