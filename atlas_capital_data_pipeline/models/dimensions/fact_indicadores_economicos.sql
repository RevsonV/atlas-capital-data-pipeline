-- models/facts/fact_indicadores_economicos.sql
-- Materializada como tabela (table)
{{ config(
    materialized='table',
    schema='marts_atlas_capital'
) }}

WITH pivoted_data AS (
    SELECT
        country_code,
        country_name,
        indicator_year,
        
        -- PIVOT: Transforma Linhas de Indicadores em Colunas de Métricas
        MAX(CASE WHEN indicator_code = 'NY.GDP.MKTP.CD' THEN indicator_value END) AS gdp_current_usd,           -- PIB
        MAX(CASE WHEN indicator_code = 'FP.CPI.TOTL.ZG' THEN indicator_value END) AS inflation_cpi,             -- Inflação
        MAX(CASE WHEN indicator_code = 'SP.POP.TOTL' THEN indicator_value END) AS total_population,             -- População
        MAX(CASE WHEN indicator_code = 'GC.DOD.TOTL.GD.ZS' THEN indicator_value END) AS gross_debt_pct_gdp,    -- Dívida % PIB
        MAX(CASE WHEN indicator_code = 'SL.UEM.TOTL.ZS' THEN indicator_value END) AS unemployment_rate         -- Desemprego
        
    FROM 
        {{ ref('stg_indicadores_brutos') }} -- Referencia o modelo de staging
    
    GROUP BY 1, 2
)

SELECT
    -- Chaves Estrangeiras (Foreign Keys)
    t.time_key,
    d.country_key,
    
    -- Atributos Descritivos (para facilitar a análise)
    p.country_code,
    p.country_name,
    p.indicator_year,
    
    -- Métricas (Measures)
    p.gdp_current_usd,
    p.inflation_cpi,
    p.total_population,
    p.gross_debt_pct_gdp,
    p.unemployment_rate

FROM pivoted_data p
-- JOIN com a Dimensão de Tempo
INNER JOIN {{ ref('dim_tempo') }} t
    ON p.indicator_year = t.year_number
-- JOIN com a Dimensão de País
INNER JOIN {{ ref('dim_pais') }} d
    ON p.country_code = d.country_code