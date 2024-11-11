with data_jaccard_coef as (
    select
        input_one::int[] AS input_one,
        input_two::int[] AS input_two,
        output
    from {{ ref('data_jaccard_coef') }}
)

select
    input_one,
    input_two,
    output as expected,
    {{ dbt_set_similarity.jaccard_coef('input_one', 'input_two') }} as actual
from data_jaccard_coef
