-- macros/schema_override.sql

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}

    {# 
       Se o custom_schema_name for definido (como 'stg_atlas_capital'),
       use-o diretamente. Caso contrário, use o schema padrão do target.
    #}
    {%- if custom_schema_name is not none -%}

        {{ custom_schema_name | trim }}

    {%- else -%}

        {{ default_schema | trim }}

    {%- endif -%}

{%- endmacro %}