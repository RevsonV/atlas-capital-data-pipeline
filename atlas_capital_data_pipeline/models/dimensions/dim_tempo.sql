-- models/dimensions/dim_tempo.sql
-- Materializada como tabela (table) para performance e reuso (melhor que view)
{{ config(
    materialized='table'
    , schema='marts_atlas_capital'
) }}

SELECT DISTINCT
    indicator_year AS time_key, -- Chave Primária (PK)
    indicator_year AS year_number,
    -- Adicionar colunas de ano fiscal, trimestre, etc., se a fonte permitisse, mas aqui nos limitamos ao ano.
    CAST(indicator_year AS STRING) AS year_label

FROM 
    {{ ref('stg_indicadores_brutos') }} -- Referencia o modelo de staging que acabamos de construir

ORDER BY 1