{% macro jaccard_index(column_one, column_two) %}
    {{ return(adapter.dispatch('jaccard_index', 'dbt_set_similarity')(column_one, column_two)) }}
{% endmacro %}

{% macro default__jaccard_index(column_one, column_two)  %}

    -- numerator query
    {% set numerator_query %}
        (
            SELECT 
                COUNT(DISTINCT value) AS intersection_count
            FROM (
                SELECT UNNEST({{ column_one }}) AS value
                INTERSECT
                SELECT UNNEST({{ column_two }}) AS value
            ) AS intersection
        )::float 
    {% endset %}

    -- denominator query
    {% set denominator_query %}
        (
            SELECT 
                COUNT(DISTINCT value) AS union_count
            FROM (
                SELECT UNNEST({{ column_one }}) AS value
                UNION
                SELECT UNNEST({{ column_two }}) AS value
            ) AS union_set
        )::float
    {% endset %}

    -- safe divide the two
    {{ dbt_utils.safe_divide(numerator_query, denominator_query) }}

{% endmacro %}

{% macro snowflake__jaccard_index(column_one, column_two) %}

    -- numerator query
    {% set numerator_query %}
        (
            SELECT 
                COUNT(DISTINCT value) AS intersection_count
            FROM (
                SELECT value FROM TABLE(FLATTEN(INPUT => {{ column_one }})) AS col_one
                INTERSECT
                SELECT value FROM TABLE(FLATTEN(INPUT => {{ column_two }})) AS col_two
            ) AS intersection
        )::float 
    {% endset %}

    -- denominator query
    {% set denominator_query %}
        (
            SELECT 
                COUNT(DISTINCT value) AS union_count
            FROM (
                SELECT value FROM TABLE(FLATTEN(INPUT => {{ column_one }})) AS col_one
                UNION
                SELECT value FROM TABLE(FLATTEN(INPUT => {{ column_two }})) AS col_two
            ) AS union_set
        )::float
    {% endset %}

    -- safe divide the two
    {{ dbt_utils.safe_divide(numerator_query, denominator_query) }}

{% endmacro %}
