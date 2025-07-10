{% macro tversky_coef(column_one, column_two, alpha=0.5, beta=0.5) %}
    {{ return(adapter.dispatch('tversky_coef', 'dbt_set_similarity')(column_one, column_two, alpha, beta)) }}
{% endmacro %}

{% macro default__tversky_coef(column_one, column_two, alpha, beta) %}

    -- numerator query: intersection of two sets
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

    -- denominator query: weighted Tversky formula
    {% set denominator_query %}
        (
            -- intersection
            SELECT COUNT(DISTINCT value) 
            FROM (
                SELECT UNNEST({{ column_one }}) AS value
                INTERSECT
                SELECT UNNEST({{ column_two }}) AS value
            ) AS intersection
        )::float

        +

        -- elements in column_one only (A - B)
        (SELECT {{ alpha }} * COUNT(DISTINCT value)
         FROM (
             SELECT UNNEST({{ column_one }}) AS value
             EXCEPT
             SELECT UNNEST({{ column_two }}) AS value
         ) AS only_in_a
        )::float

        +

        -- elements in column_two only (B - A)
        (SELECT {{ beta }} * COUNT(DISTINCT value)
         FROM (
             SELECT UNNEST({{ column_two }}) AS value
             EXCEPT
             SELECT UNNEST({{ column_one }}) AS value
         ) AS only_in_b
        )::float
    {% endset %}

    -- safe divide the two
    {{ dbt_utils.safe_divide(numerator_query, denominator_query) }}

{% endmacro %}

{% macro snowflake__tversky_coef(column_one, column_two, alpha, beta) %}

    -- numerator: intersection size
    {% set numerator_query %}
        (
            ARRAY_SIZE(
                ARRAY_INTERSECTION({{ column_one }}, {{ column_two }})
            )::FLOAT
        )
    {% endset %}

    -- intersection size (reused in denominator)
    {% set intersection_query %}
        ARRAY_SIZE(
            ARRAY_INTERSECTION({{ column_one }}, {{ column_two }})
        )
    {% endset %}

    -- elements only in column_one (A - B)
    {% set only_in_a_query %}
        (
            ARRAY_SIZE({{ column_one }})
            - {{ intersection_query }}
        )
    {% endset %}

    -- elements only in column_two (B - A)
    {% set only_in_b_query %}
        (
            ARRAY_SIZE({{ column_two }})
            - {{ intersection_query }}
        )
    {% endset %}

    -- denominator: weighted sum
    {% set denominator_query %}
        (
            {{ intersection_query }}::FLOAT
            + {{ alpha }} * {{ only_in_a_query }}::FLOAT
            + {{ beta }} * {{ only_in_b_query }}::FLOAT
        )
    {% endset %}

    -- final Tversky coefficient
    {{ dbt_utils.safe_divide(numerator_query, denominator_query) }}

{% endmacro %}

{% macro duckdb__tversky_coef(column_one, column_two, alpha, beta) %}

    -- numerator query: intersection of two sets
    {% set numerator_query %}
        (
            SELECT 
                COUNT(DISTINCT value) AS intersection_count
            FROM (
                SELECT UNNEST({{ column_one }}) AS value
                INTERSECT
                SELECT UNNEST({{ column_two }}) AS value
            ) AS intersection
            {# duckdb handles empty sets weirdly #}
            WHERE value IS NOT NULL AND value <> ''
        )::float
    {% endset %}

    -- denominator query: weighted Tversky formula
    {% set denominator_query %}
        (
            -- intersection
            SELECT COUNT(DISTINCT value) 
            FROM (
                SELECT UNNEST({{ column_one }}) AS value
                INTERSECT
                SELECT UNNEST({{ column_two }}) AS value
            ) AS intersection
            WHERE value IS NOT NULL AND value <> ''
        )::float

        +

        -- elements in column_one only (A - B)
        (SELECT {{ alpha }} * COUNT(DISTINCT value)
         FROM (
             SELECT UNNEST({{ column_one }}) AS value
             EXCEPT
             SELECT UNNEST({{ column_two }}) AS value
         ) AS only_in_a
         WHERE value IS NOT NULL AND value <> ''
        )::float

        +

        -- elements in column_two only (B - A)
        (SELECT {{ beta }} * COUNT(DISTINCT value)
         FROM (
             SELECT UNNEST({{ column_two }}) AS value
             EXCEPT
             SELECT UNNEST({{ column_one }}) AS value
         ) AS only_in_b
         WHERE value IS NOT NULL AND value <> ''
        )::float
    {% endset %}

    -- safe divide the two
    {{ dbt_utils.safe_divide(numerator_query, denominator_query) }}

{% endmacro %}
