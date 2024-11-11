with data_jaccard_index as (
    select
        input_one::int[] AS input_one,
        input_two::int[] AS input_two,
        output
    from {{ ref('data_jaccard_index') }}
)

select
    input_one,
    input_two,
    output as expected,
    {{ dbt_set_similarity.jaccard_index('input_one', 'input_two') }} as actual
from data_jaccard_index
