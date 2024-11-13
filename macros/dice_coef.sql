{% macro dice_coef(column_one, column_two) %}
    {{ return(adapter.dispatch('dice_coef', 'dbt_set_similarity')(column_one, column_two)) }}
{% endmacro %}

{% macro default__dice_coef(column_one, column_two)  %}

    {{ dbt_set_similarity.tversky_coef(column_one, column_two, alpha=0.5, beta=0.5) }}

{% endmacro %}
