with data_tversky_coef as (
    select
        input_one::int[] AS input_one,
        input_two::int[] AS input_two,
        output
    from {{ ref('data_tversky_coef') }}
)

select
    input_one,
    input_two,
    output as expected,
    {{ dbt_set_similarity.tversky_coef('input_one', 'input_two', alpha=1, beta=1) }} as actual
from data_tversky_coef
