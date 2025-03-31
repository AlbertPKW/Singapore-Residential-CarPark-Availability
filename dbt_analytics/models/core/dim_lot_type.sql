WITH lot_types AS (
    SELECT 'C' AS lot_type_code, 'Car' AS lot_type_description
    UNION ALL
    SELECT 'H' AS lot_type_code, 'Heavy Vehicle' AS lot_type_description
    UNION ALL
    SELECT 'Y' AS lot_type_code, 'Motorcycle' AS lot_type_description
    UNION ALL
    SELECT 'S' AS lot_type_code, 'Car' AS lot_type_description
    UNION ALL
    SELECT 'L' AS lot_type_code, 'Heavy Vehicle' AS lot_type_description
    UNION ALL
    SELECT 'M' AS lot_type_code, 'Motorcycle' AS lot_type_description
)

SELECT
    --lot_type_code AS lot_type_key,
    lot_type_code,
    lot_type_description
FROM lot_types