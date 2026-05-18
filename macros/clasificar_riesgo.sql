{% macro clasificar_riesgo(columna_tasa) %}
    case
        when {{ columna_tasa }} >= 10 then 'Crítico'
        when {{ columna_tasa }} >= 7  then 'Alto'
        when {{ columna_tasa }} >= 4  then 'Medio'
        else                               'Bajo'
    end
{% endmacro %}