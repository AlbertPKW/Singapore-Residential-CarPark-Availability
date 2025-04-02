{#
    This macro returns the description of the lot_type 
#}

{% macro get_lot_type_description(lot_type) -%}

    case {{ dbt.safe_cast("lot_type", api.Column.translate_type("string")) }}  
        when 'C' then 'Car'
        when 'M' then 'Motorcycle'
        when 'H' then 'Heavy Vehicle'
        when 'Y' then 'Motorcycle'
        when 'L' then 'Heavy Vehicle'
        when 'S' then 'Car'
        else 'EMPTY'
    end

{%- endmacro %}