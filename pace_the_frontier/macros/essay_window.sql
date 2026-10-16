{#- Classify a signed day offset from the essay date into the study windows
    (METHODOLOGY section 3): before = -30..-1, after = +1..+30, the essay day
    itself belongs to neither window, everything else is outside. -#}
{% macro essay_window(days_expression) -%}
    case
        when {{ days_expression }} between -{{ var('window_days') }} and -1 then 'before'
        when {{ days_expression }} between 1 and {{ var('window_days') }} then 'after'
        when {{ days_expression }} = 0 then 'essay_day'
        else 'outside'
    end
{%- endmacro %}
