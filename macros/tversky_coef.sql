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

    -- numerator query: intersection of two sets
    {% set numerator_query %}
        (
            SELECT 
                COUNT(DISTINCT value) AS intersection_count
            FROM (
                SELECT VALUE
                FROM TABLE(FLATTEN(INPUT => {{ column_one }})) AS a
                INTERSECT
                SELECT VALUE
                FROM TABLE(FLATTEN(INPUT => {{ column_two }})) AS b
            ) AS intersection
        )::float
    {% endset %}

    -- denominator query: weighted Tversky formula
    {% set denominator_query %}
        (
            -- intersection
            SELECT COUNT(DISTINCT value) 
            FROM (
                SELECT VALUE
                FROM TABLE(FLATTEN(INPUT => {{ column_one }})) AS a
                INTERSECT
                SELECT VALUE
                FROM TABLE(FLATTEN(INPUT => {{ column_two }})) AS b
            ) AS intersection
        )::float

        +

        -- elements in column_one only (A - B)
        (SELECT {{ alpha }} * COUNT(DISTINCT value)
         FROM (
             SELECT VALUE
             FROM TABLE(FLATTEN(INPUT => {{ column_one }})) AS a
             MINUS
             SELECT VALUE
             FROM TABLE(FLATTEN(INPUT => {{ column_two }})) AS b
         ) AS only_in_a
        )::float

        +

        -- elements in column_two only (B - A)
        (SELECT {{ beta }} * COUNT(DISTINCT value)
         FROM (
             SELECT VALUE
             FROM TABLE(FLATTEN(INPUT => {{ column_two }})) AS b
             MINUS
             SELECT VALUE
             FROM TABLE(FLATTEN(INPUT => {{ column_one }})) AS a
         ) AS only_in_b
        )::float
    {% endset %}

    -- safe divide the two if they are eligible sets, do not if they are not
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
