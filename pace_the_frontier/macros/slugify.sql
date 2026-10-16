{#- Lower-case, collapse every run of non-alphanumerics to "_", trim the ends.
    "Alibaba (Qwen)" -> alibaba_qwen, "Claude Fable 5.1 / Claude Mythos 5.1" -> claude_fable_5_1_claude_mythos_5_1 -#}
{% macro slugify(expression) -%}
    trim(regexp_replace(lower({{ expression }}), '[^a-z0-9]+', '_', 'g'), '_')
{%- endmacro %}
