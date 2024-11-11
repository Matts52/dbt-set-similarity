{% macro overlap_coef(column_one, column_two) %}
    {{ return(adapter.dispatch('overlap_coef', 'dbt_set_similarity')(column_one, column_two)) }}
{% endmacro %}

{% macro default__overlap_coef(column_one, column_two)  %}

    -- numerator query: intersection count |A ∩ B|
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

    -- denominator query: minimum of the sizes of column_one and column_two
    {% set denominator_query %}
        (
            LEAST(
                (SELECT COUNT(DISTINCT value) FROM UNNEST({{ column_one }}) AS value),
                (SELECT COUNT(DISTINCT value) FROM UNNEST({{ column_two }}) AS value)
            )
        )::float
    {% endset %}

    -- safe divide the two
    {{ dbt_utils.safe_divide(numerator_query, denominator_query) }}

{% endmacro %}
