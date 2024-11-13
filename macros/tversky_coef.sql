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
