{% macro dice_coef(column_one, column_two) %}
    {{ return(adapter.dispatch('dice_coef', 'dbt_set_similarity')(column_one, column_two)) }}
{% endmacro %}

{% macro default__dice_coef(column_one, column_two)  %}

    -- numerator query: 2 * intersection count
    {% set numerator_query %}
        (
            2 * (
                SELECT 
                    COUNT(DISTINCT value) AS intersection_count
                FROM (
                    SELECT UNNEST({{ column_one }}) AS value
                    INTERSECT
                    SELECT UNNEST({{ column_two }}) AS value
                ) AS intersection
            )
        )::float
    {% endset %}

    -- denominator query: cardinality of column_one + cardinality of column_two
    {% set denominator_query %}
        (
            SELECT 
                COUNT(value) AS total_count
            FROM (
                SELECT UNNEST({{ column_one }}) AS value
                UNION ALL
                SELECT UNNEST({{ column_two }}) AS value
            ) AS union_all_set
        )::float
    {% endset %}

    -- safe divide the two
    {{ dbt_utils.safe_divide(numerator_query, denominator_query) }}

{% endmacro %}

{% macro default__dice_coef(column_one, column_two) %}

    -- numerator query: 2 * intersection count
    {% set numerator_query %}
        (
            2 * (
                SELECT 
                    COUNT(DISTINCT value) AS intersection_count
                FROM (
                    SELECT VALUE AS value
                    FROM TABLE(FLATTEN(INPUT => {{ column_one }}))
                    INTERSECT
                    SELECT VALUE AS value
                    FROM TABLE(FLATTEN(INPUT => {{ column_two }}))
                ) AS intersection
            )
        )::FLOAT
    {% endset %}

    -- denominator query: cardinality of column_one + cardinality of column_two
    {% set denominator_query %}
        (
            SELECT 
                COUNT(value) AS total_count
            FROM (
                SELECT VALUE AS value
                FROM TABLE(FLATTEN(INPUT => {{ column_one }}))
                UNION ALL
                SELECT VALUE AS value
                FROM TABLE(FLATTEN(INPUT => {{ column_two }}))
            ) AS union_all_set
        )::FLOAT
    {% endset %}

    -- safe divide the two
    {{ dbt_utils.safe_divide(numerator_query, denominator_query) }}

{% endmacro %}
