{% set adapter = target.type %}

with data_overlap_coef as (
    select
        {% if adapter == 'postgres' %}
            input_one::int[] as input_one,
            input_two::int[] as input_two,
        {% elif adapter == 'duckdb' %}
            str_split(trim(both '{}' from input_one), ',') as input_one,
            str_split(trim(both '{}' from input_two), ',') as input_two,
        {% else %}
            -- Default behavior
            input_one,
            input_two,
        {% endif %}
            output
    from {{ ref('data_overlap_coef') }}
)

select
    input_one,
    input_two,
    output as expected,
    {{ dbt_set_similarity.overlap_coef('input_one', 'input_two') }} as actual
from data_overlap_coef
