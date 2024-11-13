{% macro jaccard_coef(column_one, column_two) %}
    {{ return(adapter.dispatch('jaccard_coef', 'dbt_set_similarity')(column_one, column_two)) }}
{% endmacro %}

{% macro default__jaccard_coef(column_one, column_two)  %}

    {{ dbt_set_similarity.tversky_coef(column_one, column_two, alpha=1, beta=1) }}

{% endmacro %}
