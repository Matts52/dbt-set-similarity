{% test assert_equal(model, actual, expected) %}
    select * from {{ model }}
    where
        abs(actual - expected) > 0.0001
{% endtest %}
