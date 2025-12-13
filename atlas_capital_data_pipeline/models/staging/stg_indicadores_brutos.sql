-- models/staging/stg_indicadores_brutos.sql

-- Este modelo apenas seleciona, renomeia e converte tipos da tabela bruta.
-- O prefixo 'stg_' indica que é um modelo de staging (limpeza leve).
SELECT
    -- Chaves e Identificadores
    country_code,
    country_name,
    indicator_code,
    indicator_name,

    -- Conversão de Tipos e Limpeza
    -- Certificando que 'date' é um inteiro para uso futuro como chave de tempo
    CAST(date AS INT64) AS indicator_year, 
    
    -- O 'value' é a métrica principal. Converte para FLOAT e trata NULOS (se houver)
    CAST(value AS BIGNUMERIC) AS indicator_value, 

    -- Adiciona um carimbo de data/hora (timestamp) para rastreabilidade (opcional, mas profissional)
    CURRENT_TIMESTAMP() AS loaded_at_utc

FROM 
    -- Referencia a fonte externa definida no sources.yml
    {{ source('world_bank_raw', 'stg_indicadores_brutos') }}

-- Filtra apenas registros com valores, reforçando o que já foi feito no Python
WHERE value IS NOT NULL
