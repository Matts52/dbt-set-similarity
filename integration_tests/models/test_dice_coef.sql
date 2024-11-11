with data_dice_coef as (
    select
        input_one::int[] AS input_one,
        input_two::int[] AS input_two,
        output
    from {{ ref('data_dice_coef') }}
)

select
    input_one,
    input_two,
    output as expected,
    {{ dbt_set_similarity.dice_coef('input_one', 'input_two') }} as actual
from data_dice_coef
