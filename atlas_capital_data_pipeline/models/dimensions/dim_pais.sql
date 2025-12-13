-- models/dimensions/dim_pais.sql
-- Materializada como tabela (table)
{{ config(
    materialized='table',
    schema='marts_atlas_capital'
) }}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['country_code']) }} AS country_key, -- Chave Substituta (PK)
    country_code, -- Código ISO (Ex: BRA)
    country_name, -- Nome completo (Ex: Brasil)
    
    -- No futuro, poderíamos adicionar aqui a Região, Continente, etc.
    -- Por enquanto, usamos apenas os atributos diretos da source.
    
    CURRENT_TIMESTAMP() AS created_at_utc

FROM
    {{ ref('stg_indicadores_brutos') }} -- Referencia o modelo de staging