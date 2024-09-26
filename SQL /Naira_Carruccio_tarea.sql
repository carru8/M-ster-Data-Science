# Ejercicio 2

# 1)

SELECT `country` AS Pais, 
       `status` AS Estado, 
       COUNT(`order_id`) AS TotalOperaciones, 
       ROUND(AVG(`amount`), 2) AS Importe
FROM orders
WHERE created_at>2015-07-01 AND country in ("Espana", "Francia", "Portugal")
AND amount BETWEEN 100 and 1499
GROUP BY `country`, `status`
ORDER BY Importe DESC;

# 2)

SELECT `country` AS Pais, 
       COUNT(`order_id`) AS TotalOperaciones, 
	   MAX(`amount`) AS MáximoImporte,
	   MIN(`amount`) As MinimoImporte
FROM orders
WHERE 
      `status` NOT IN ("Delinquent", "Cancelled")
AND    `amount`>100
GROUP BY `country`
ORDER BY TotalOperaciones DESC
LIMIT 3;

# Ejercicio 3 

# 1
SELECT 
 `country` as Pais, `name` AS Establecimiento , m.`merchant_id` AS ID_Establecimiento , COUNT(o.`order_id`) AS TotalOperaciones,
 ROUND(AVG(o.`amount`), 2) AS PromedioImporte, COUNT(r.`order_id`) as TotalDevoluciones,
 CASE 
    WHEN COUNT(r.`order_id`) = 0 THEN "No"
    WHEN COUNT(r.`order_id`) > 0 THEN "Si"
    END AS acepta_devoluciones
FROM orders as o
INNER JOIN merchants as m
ON o.`merchant_id`=m.`merchant_id`
LEFT JOIN refunds as r
ON o.`order_id`=r.`order_id`
WHERE `country` IN ("Marruecos", "Italia", "Espana", "Portugal")
GROUP BY Pais, Establecimiento , ID_Establecimiento
HAVING TotalOperaciones > 10 
ORDER BY TotalOperaciones ASC;
    
#2
CREATE VIEW orders_view AS
SELECT  m.`merchant_id` AS ID_Establecimiento, `name` AS NombreEstablecimiento,
 o.`order_id` AS ID_Operaciones, `created_at` as Fecha , `status` AS Estado , o.`amount` AS Importe, `country`AS Pais,
 r.`order_id` AS ID_Devoluciones, COUNT(r.`order_id`) as TotalDevoluciones, ROUND(SUM(r.`amount`),2) as ValorDevoluciones
FROM orders AS o 
INNER JOIN merchants as m
ON o.`merchant_id`=m.`merchant_id`
INNER JOIN refunds as r
ON o.`order_id`=r.`order_id`
GROUP BY    m.`merchant_id`,  `name`, o.`order_id`, `created_at`, `status` , o.`amount`,  `country`, r.`order_id`;


# Ejercicio 4 

# Query 1
SELECT  `name` as Establecimiento , COUNT(m.`merchant_id`) as Operaciones, round(SUM(`amount`),2) as ImporteTotal
FROM orders AS o 
LEFT JOIN merchants as m
ON o.`merchant_id`=m.`merchant_id`
WHERE `country`= "Alemania" 
GROUP BY m.`merchant_id`, `name`
ORDER BY Operaciones DESC;

# Query 2
SELECT
    `name` as Establecimiento,
    COUNT(m.`merchant_id`)  as Operaciones,
    ROUND(SUM(`amount`), 2) as ImporteTotal,
	(SELECT  MONTH(`created_at`)
	 FROM orders
     WHERE `country` = "Alemania" AND `merchant_id` = m.`merchant_id`
     # FILTRAMOS QUE EL PAÍS SEA ALEMANIA E IGUALAMOS LA COLUMNA MERCHANT PARA QUE SALGAN LOS RESULTADOS QUE COINCIDAN EN AMBAS TABLAS
     GROUP BY MONTH(`created_at`)
     ORDER BY COUNT(`merchant_id`) DESC
     # ORDENAMOS POR OPERACIONES DE MAYOR A MENOR
     LIMIT 1) AS MesRepetido, 
     RANK() OVER (ORDER BY SUM(`amount`) DESC) AS Rango_Importe,
CASE
WHEN ROUND(SUM(`amount`), 2) < 100 THEN "No Rentable"
WHEN ROUND(SUM(`amount`), 2) > 100 AND ROUND(SUM(`amount`), 2) < 1000 THEN "Rentable"
WHEN ROUND(SUM(`amount`), 2) > 1000 THEN "Muy Rentable"
END AS Rentabilidad
FROM orders AS o
INNER JOIN merchants as m 
ON o.`merchant_id` = m.`merchant_id`
WHERE `country` = "Alemania" AND `status` NOT IN ("Cancelled", "Delinquent")
GROUP BY m.`merchant_id`, `name`
ORDER BY Operaciones DESC;



       
