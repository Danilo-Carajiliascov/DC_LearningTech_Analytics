/*markdown
#### Escalar
*/

SELECT 100

SELECT MAX("fuel_tank_capacity") FROM "CARS"

/*markdown
#### Vetor
*/

SELECT DISTINCT("fuel_type") FROM "CARS"

SELECT DISTINCT("car_name") FROM "CARS"

SELECT "car_name", "fuel_type", "fuel_tank_capacity" FROM "CARS"

SELECT 
    "car_name", "fuel_type", "fuel_tank_capacity" 
    FROM "CARS"
    WHERE 
        "fuel_tank_capacity" > 60 AND 
        "fuel_type" = 'Petrol'

/*markdown
#### Teste_Tipo_Dados
*/

SELECT 
    '2023-01-01'::date + 1 as "::date",
    DATE('2023-01-01') + 1 as "DATE()",
    '12:30:00'::time as "::time",
    '2023-01-01'::date + '09:30:00'::time as "datetime"

SELECT 
               date('2023-01-01') - '03:00:00'::time   as "date", 
    pg_typeof( date('2023-01-01') - '03:00:00'::time ) as "type"

SELECT 
    CONCAT(date('2023-01-01'), 1), 
    PG_TYPEOF( CONCAT(date('2023-01-01'), 1) )

SELECT TRUE + 1

SELECT '' + 1

SELECT NULL + 1

SELECT NULL + ''

SELECT NULL + date('2023-01-01')

SELECT date('2023-01-01')::int

SELECT date('2023-01-01')::text

SELECT NULL + NULL

SELECT 
    TRUE , 
    pg_typeof( TRUE )

SELECT
    concat( NULL, 1 ) as "concat( NULL, 1 )",
    NULL + 1 as "NULL + 1",
    concat( NULL, date('2023-01-01') ) as "concat( NULL, date('2023-01-01') )"

SELECT datename('2023-01-01')

/*markdown
# Analytics
*/

/*markdown
#### Ctas_Receber_DB
*/

SELECT * FROM "Ctas_Receber_DB"
    LIMIT 8

/*markdown
#### add Prazo_NF, Prazo_Desc, Prazo_Real, 
#### Taxa_Desc, Taxa_Desc * 100, Taxa_Desc formatada
#### Renomear colunas com nomes mais compactos
*/

CREATE VIEW "Ctas_Receber_Proc" 
    AS SELECT * FROM "Ctas_Receber_DB"

WITH 
    "CTAS_RECEBER1" AS (
    SELECT 
        *, 
        EXTRACT (DAY FROM "Data_Vencimento"  - "Data_Emissão")     as "Prazo_NF",
        EXTRACT (DAY FROM "Data_Vencimento"  - "Data_Recebimento") as "Prazo_Desc",
        EXTRACT (DAY FROM "Data_Recebimento" - "Data_Emissão")     as "Prazo_Real"
        FROM "Ctas_Receber_DB"
), "CTAS_RECEBER2" AS (
    SELECT 
        *,
        CASE WHEN "Prazo_Desc" = 0 
            THEN 0 
            ELSE ("Valor_a_Receber" / "Valor_Recebido")^(1 / ("Prazo_Desc" / 30)) -1
            END AS "Taxa_Desc"
        FROM "CTAS_RECEBER1"
)

SELECT
    *,
    "Taxa_Desc" * 100 AS "Taxa_Desc2",
    ROUND("Taxa_Desc" * 100, 2)::text || '%' as "Taxa_Desc3"
    FROM "CTAS_RECEBER2"

SELECT ROUND(0.1234 * 100, 2)::text || '%' as "Taxa_Desc3"

WITH "Totais_por_Cliente" AS (
    SELECT 
        "ID_Cliente", "Descr_Cliente",
        SUM("Valor_a_Receber") AS "Total_a_Receber",
        SUM("Valor_Recebido")  AS "Total_Recebido",
        SUM("Diferenca")       AS "Total_Diferenca"
        FROM "Ctas_Receber_DB"
        WHERE "Descontado_com" IS NOT NULL
        GROUP BY "ID_Cliente", "Descr_Cliente"
        ORDER BY "Total_Recebido"
)

SELECT 
    *, TO_CHAR("Total_Diferenca" / "Total_a_Receber" * 100, 'fm0D00%') as "%_Desconto" 
    FROM "Totais_por_Cliente"

/*markdown
# Brasilian Ecommerce Olist
*/

/*markdown
#### Tabelas
*/

SELECT * FROM "customers" LIMIT 10

SELECT * FROM "geolocation" LIMIT 10

SELECT 
    "product_id", "price"  -- Filtro de colunas
    FROM "order_items"
    WHERE "price" > 5000   -- Filtro de linhas

SELECT * FROM "order_payments" LIMIT 10

SELECT * FROM "order_reviews" LIMIT 10

SELECT * FROM "orders" LIMIT 10

SELECT * FROM "products" LIMIT 10

SELECT * FROM "sellers" LIMIT 10

SELECT * FROM "product_category_name_translation" LIMIT 10

SELECT COUNT( DISTINCT("customer_state") ) FROM "customers"

SELECT COUNT( DISTINCT("customer_city") ) FROM "customers"

SELECT COUNT( DISTINCT("customer_unique_id") ) FROM "customers"

SELECT COUNT( DISTINCT("product_id") ) FROM "order_items"

SELECT 
    MIN("order_delivered_customer_date") as "Data_mais_antiga", 
    MAX("order_delivered_customer_date") as "Data_mais_recente"
    FROM "orders"
    WHERE "order_delivered_customer_date" > '2000-01-01'

SELECT 
    "order_id", "product_id", "seller_id", DATE("shipping_limit_date"), "price", "freight_value",
    COUNT("product_id")                   as "QTD",
    "price" * COUNT("product_id")         as "Total_Products",
    "freight_value" * COUNT("product_id") as "Total_Frete"
    FROM "order_items"
    GROUP BY "order_id", "product_id", "seller_id", "shipping_limit_date", "price", "freight_value"

/*markdown
# 
*/

/*markdown
# 
*/

/*markdown
# Exemplos de personalização do Markdown
*/

/*markdown
<b>Negrito, </b><i>Itálico, </i><u>Sublinhado, </u><s>Tachado</s>
*/

/*markdown
Pular<br>linha
*/

/*markdown
<font size=1>tamanho da fonte (1)</font><br>
<font size=2>tamanho da fonte (2)</font><br>
<font size=3>tamanho da fonte (3)</font><br>
<font size=4>tamanho da fonte (4)</font><br>
<font size=5>tamanho da fonte (5)</font><br>
<font size=6>tamanho da fonte (6)</font><br>
<font size=7>tamanho da fonte (7)</font>
*/

/*markdown
<h6>tamanho da fonte (h6)</h6><br>
<h5>tamanho da fonte (h5)</h5><br>
<h4>tamanho da fonte (h4)</h4><br>
<h3>tamanho da fonte (h3)</h3><br>
<h2>tamanho da fonte (h2)</h2><br>
<h1>tamanho da fonte (h1)</h1>
*/

/*markdown
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. </p><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
*/

/*markdown
<p>Lorem ipsum dolor sit amet, <strong>consectetur adipiscing elit</strong>, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
*/

/*markdown
<p>
    mudar 
    <font style="font-family:impact">fonte</font>
    do 
    <font style="font-family:consolas"><b>texto.</b></font>
</p>
*/

/*markdown
<p>mudar <font color="green"><b>cor</b></font> do <font color="red"><b>texto.</b></font></p>
*/

/*markdown
<p style="background-color:lightgreen; color:green"><b>mudar a cor do parágrafo</b></p>
*/

/*markdown
<font style="background-color:lightgreen; color:green"><b>mudar a cor do texto</b></font>
*/

/*markdown
<a href="https://www.youtube.com/@danilocarajiliascov-learni7566"><b>Link para o Canal</b></a>
*/

/*markdown
<font style='font-family:calibri; color:#D5CEA3; background-color:#553939' size=6>
    &#160;&#160;&#160;&#160;&#160;&#160;&#160;
    Relatório de
    <font style='font-family:consolas'>&#160;</font>&#160;&#160;&#160;&#160;&#160;&#160;
<br></font>
<font style='font-family:impact; color:#3C2A21; background-color:#D5CEA3' size=7>
    &#160;FATURAMENTO&#160;
</font>
*/

/*markdown
# 
*/

/*markdown
# 
*/

/*markdown
# <font style="font-family:impact; color:orange">Relatório de Faturamento</font>
<h4 style="font-family:consolas">por Mês, UF, Cidade, Categoria_Produto - Lat, Long, Receita, Frete, Peso, Volume</h4>
*/

/*markdown

### <h2 style = "font-family: impact; color:lightblue">Estratégia</h2>
<h5><p style = "font-family: consolas">
1. Lat e Long de <b style = "color:lightgreen">"geolocation"</b> para <b style = "color:lightgreen">"sellers"</b> e <b style = "color:lightgreen">"customers"</b><br>
2. UF, Cidade, Lat e Long de <b style = "color:lightgreen">"customers"</b> para <b style = "color:lightgreen">"orders"</b><br>
3. UF, Cidade, Lat, Long e Data_Entrega de <b style = "color:lightgreen">"orders"</b> para <b style = "color:lightgreen">"order_items"</b><br>
4. Categoria de Produto, Peso e Volume_m³ para <b style = "color:lightgreen">"order_items"</b><br>
5. UF, Cidade, Lat e Long dos <b style = "color:lightgreen">"sellers"</b> para <b style = "color:lightgreen">"order_items"</b><br>
6. Quantidade * Preço para obter <b>Valor de Receita*</b><br>
7. Adicionar distância por <b style = "color:pink">Haversine</b><br>
8. Exportar CSV
</h5></p>
*/

/*markdown
#### $d = 2r\ \arcsin( \sqrt{\sin^2(\frac{\phi_2 - \phi_1}{2} ) + \cos(\phi_1)\cos(\phi_2)\sin^2( \frac{\lambda_2 - \lambda_1}{2}} ) )$
$\phi_1,\ \phi_2\ $ <h style="font-family:consolas">são a latitude do ponto 1 e a latitude do ponto 2 (em radianos)</h> \
$\lambda_1,\ \lambda_2\ $ <h style="font-family:consolas">são a longitude do ponto 1 e a longitude do ponto 2 (em radianos)</h>
<br><a style="font-family:consolas" href="https://pt.wikipedia.org/wiki/F%C3%B3rmula_de_haversine">Fórmula de haversine – Wikipédia</a>
*/

/*markdown
### <h3><p style = "font-family: consolas">1.1. Lat e Long de <b style = "color: lightgreen">"geolocation"</b> para <b style = "color: lightgreen">"sellers"</b></p>
*/

WITH geolocation2 AS (
    SELECT
        geolocation_zip_code_prefix as seller_zip_code_prefix, 
        round( avg( geolocation_lat )::numeric, 6 ) as seller_lat, 
        round( avg( geolocation_lng )::numeric, 6 ) as seller_lng
    FROM geolocation
    GROUP BY geolocation_zip_code_prefix -- garantir que exista apenas 1 CEP para cada linha


), sellers2 as (
    SELECT
        *
    FROM sellers
    LEFT JOIN geolocation2
        USING (seller_zip_code_prefix)
)


SELECT * FROM sellers2 LIMIT 5

/*markdown
### <h3><p style="font-family:consolas">1.2. Lat e Long de <b style="color:lightgreen">"geolocation"</b> para <b style="color:lightgreen">"customers"</b>
*/

WITH geolocation2 AS (
    SELECT 
        geolocation_zip_code_prefix as customer_zip_code_prefix, 
        round( avg( geolocation_lat )::numeric, 6 ) as customer_lat, 
        round( avg( geolocation_lng )::numeric, 6 ) as customer_lng
    FROM geolocation 
    GROUP BY geolocation_zip_code_prefix


), customers2 AS (
    SELECT 
        *
    FROM customers
    LEFT JOIN geolocation2
        USING (customer_zip_code_prefix)


)


SELECT * FROM customers2 LIMIT 5

/*markdown
### <h3><p style="font-family:consolas">2. UF, Cidade, Lat e Long de <b style="color:lightgreen">"customers"</b> para <b style="color:lightgreen">"orders"</b> 
*/

WITH geolocation2 AS (
    SELECT 
        geolocation_zip_code_prefix as customer_zip_code_prefix, 
        round( avg( geolocation_lat )::numeric, 6 ) as customer_lat, 
        round( avg( geolocation_lng )::numeric, 6 ) as customer_lng
    FROM geolocation 
    GROUP BY geolocation_zip_code_prefix


), customers2 AS (
    SELECT 
        *
    FROM customers
    LEFT JOIN geolocation2
        USING (customer_zip_code_prefix)


), orders2 AS (
    SELECT 
        orders.order_id, 
        orders.customer_id, 
        orders.order_delivered_customer_date,
	    customers2.customer_zip_code_prefix, 
        customers2.customer_city, 
        customers2.customer_state, 
        customers2.customer_lat, 
        customers2.customer_lng
    FROM orders
    LEFT JOIN customers2
        USING (customer_id)


)


SELECT * FROM orders2 LIMIT 5

/*markdown
### <h3><p style="font-family:consolas">3. UF, Cidade, Lat, Long e Data_Entrega de <b style="color:lightgreen">"orders"</b> para <b style="color:lightgreen">"order_items"</b></p>
*/

WITH geolocation2 AS (
    SELECT 
        geolocation_zip_code_prefix as customer_zip_code_prefix, 
        round( avg( geolocation_lat )::numeric, 6 ) as customer_lat, 
        round( avg( geolocation_lng )::numeric, 6 ) as customer_lng
    FROM geolocation 
    GROUP BY geolocation_zip_code_prefix


), customers2 AS (
    SELECT 
        *
    FROM customers
    LEFT JOIN geolocation2
        USING (customer_zip_code_prefix)


), orders2 AS (
    SELECT 
        orders.order_id, 
        orders.customer_id, 
        orders.order_delivered_customer_date,
	    customers2.customer_zip_code_prefix, 
        customers2.customer_city, 
        customers2.customer_state, 
        customers2.customer_lat, 
        customers2.customer_lng
    FROM orders
    LEFT JOIN customers2
        USING (customer_id)


), order_items2 AS (
    SELECT 
		*
    FROM order_items
    LEFT JOIN orders2
        USING (order_id)


)


SELECT * FROM order_items2 LIMIT 5

/*markdown
### <h3><p style="font-family:consolas">4. Categoria de Produto, Peso e Volume_m³ para <b style="color:lightgreen">"order_items"</b>
*/

WITH geolocation2 AS (
    SELECT 
        geolocation_zip_code_prefix as customer_zip_code_prefix, 
        round( avg( geolocation_lat )::numeric, 6 ) as customer_lat, 
        round( avg( geolocation_lng )::numeric, 6 ) as customer_lng
    FROM geolocation 
    GROUP BY geolocation_zip_code_prefix


), customers2 AS (
    SELECT 
        *
    FROM customers
    LEFT JOIN geolocation2
        USING (customer_zip_code_prefix)


), orders2 AS (
    SELECT 
        orders.order_id, 
        orders.customer_id, 
        orders.order_delivered_customer_date,
	    customers2.customer_zip_code_prefix, 
        customers2.customer_city, 
        customers2.customer_state, 
        customers2.customer_lat, 
        customers2.customer_lng
    FROM orders
    LEFT JOIN customers2
        USING (customer_id)


), order_items2 AS (
    SELECT 
		*
    FROM order_items
    LEFT JOIN orders2
        USING (order_id)


), products2 AS (
    SELECT 
        product_id, 
        product_category_name, 
        round(product_weight_g::numeric / 1000, 3) as product_weight_kg,
        product_length_cm * product_height_cm * product_width_cm / 100^3 AS volume_m3
    FROM products


), order_items3 AS (
    SELECT
        *
    FROM order_items2
    LEFT JOIN products2
        USING (product_id)


)


SELECT * FROM order_items3 LIMIT 5

/*markdown
### <h3><p style="font-family:consolas">5. UF, Cidade, Lat e Long dos <b style="color:lightgreen">"sellers"</b> para <b style="color:lightgreen">"order_items"</b>
*/

WITH geolocation2 AS (
    SELECT 
        geolocation_zip_code_prefix as customer_zip_code_prefix, 
        round( avg( geolocation_lat )::numeric, 6 ) as customer_lat, 
        round( avg( geolocation_lng )::numeric, 6 ) as customer_lng
    FROM geolocation 
    GROUP BY geolocation_zip_code_prefix


), customers2 AS (
    SELECT 
        *
    FROM customers
    LEFT JOIN geolocation2
        USING (customer_zip_code_prefix)


), orders2 AS (
    SELECT 
        orders.order_id, 
        orders.customer_id, 
        orders.order_delivered_customer_date,
	    customers2.customer_zip_code_prefix, 
        customers2.customer_city, 
        customers2.customer_state, 
        customers2.customer_lat, 
        customers2.customer_lng
    FROM orders
    LEFT JOIN customers2
        USING (customer_id)


), order_items2 AS (
    SELECT 
		*
    FROM order_items
    LEFT JOIN orders2
        USING (order_id)


), products2 AS (
    SELECT 
        product_id, 
        product_category_name, 
        round(product_weight_g::numeric / 1000, 3) as product_weight_kg,
        product_length_cm * product_height_cm * product_width_cm / 100^3 AS volume_m3
    FROM products


), order_items3 AS (
    SELECT
        *
    FROM order_items2
    LEFT JOIN products2
        USING (product_id)


), geolocation3 AS (
    SELECT
        geolocation_zip_code_prefix as seller_zip_code_prefix, 
        round( avg( geolocation_lat )::numeric, 6 ) as seller_lat, 
        round( avg( geolocation_lng )::numeric, 6 ) as seller_lng
    FROM geolocation
    GROUP BY geolocation_zip_code_prefix -- garantir que exista apenas 1 CEP para cada linha


), sellers2 as (
    SELECT
        *
    FROM sellers
    LEFT JOIN geolocation3
        USING (seller_zip_code_prefix)


), order_items4 AS (
    SELECT
        *
    FROM order_items3
    LEFT JOIN sellers2
        USING (seller_id)
)

SELECT * FROM order_items4 limit 5

/*markdown
### <h3><p style="font-family:consolas">7. Adicionar distância por <b style = "color:pink">Haversine</b>
*/

CREATE TABLE order_items_proc AS (

WITH geolocation2 AS (
    SELECT 
        geolocation_zip_code_prefix as customer_zip_code_prefix, 
        round( avg( geolocation_lat )::numeric, 6 ) as customer_lat, 
        round( avg( geolocation_lng )::numeric, 6 ) as customer_lng
    FROM geolocation 
    GROUP BY geolocation_zip_code_prefix


), customers2 AS (
    SELECT 
        *
    FROM customers
    LEFT JOIN geolocation2
        USING (customer_zip_code_prefix)


), orders2 AS (
    SELECT 
        orders.order_id, 
        orders.customer_id, 
        orders.order_delivered_customer_date,
	    customers2.customer_zip_code_prefix, 
        customers2.customer_city, 
        customers2.customer_state, 
        customers2.customer_lat, 
        customers2.customer_lng
    FROM orders
    LEFT JOIN customers2
        USING (customer_id)


), order_items2 AS (
    SELECT 
		*
    FROM order_items
    LEFT JOIN orders2
        USING (order_id)


), products2 AS (
    SELECT 
        product_id, 
        product_category_name, 
        round(product_weight_g::numeric / 1000, 3) as product_weight_kg,
        product_length_cm * product_height_cm * product_width_cm / 100^3 AS volume_m3
    FROM products


), order_items3 AS (
    SELECT
        *
    FROM order_items2
    LEFT JOIN products2
        USING (product_id)


), geolocation3 AS (
    SELECT
        geolocation_zip_code_prefix as seller_zip_code_prefix, 
        round( avg( geolocation_lat )::numeric, 6 ) as seller_lat, 
        round( avg( geolocation_lng )::numeric, 6 ) as seller_lng
    FROM geolocation
    GROUP BY geolocation_zip_code_prefix -- garantir que exista apenas 1 CEP para cada linha


), sellers2 as (
    SELECT
        *
    FROM sellers
    LEFT JOIN geolocation3
        USING (seller_zip_code_prefix)


), order_items4 AS (
    SELECT
        *
    FROM order_items3
    LEFT JOIN sellers2
        USING (seller_id)


), order_items5 AS (
    SELECT
        *,
        round(
            1.19 * 2 * 6378.1 * ASIN( SQRT(
                    SIN( ( radians(customer_lat) - radians(seller_lat) ) / 2 )^2 +
                    COS( radians(seller_lat) ) * COS( radians(customer_lat) ) *
                    SIN( ( radians(customer_lng) - radians(seller_lng) ) / 2 )^2
            ) )::numeric
            , 2 
        ) as distancia_km
    FROM order_items4
)

    SELECT * FROM order_items5
)

/*markdown
### <h3><p style="font-family:consolas">8. Exportar CSV</b>
*/

COPY ( SELECT * FROM order_items_proc )
    TO 'order_items_proc.csv' 
    WITH DELIMITER ',' 
    CSV HEADER

/*markdown
## Rascunho
*/

WITH "geolocation2" AS (
    SELECT 
        "geolocation_zip_code_prefix", 
        round( avg( DISTINCT("geolocation_lat") )::numeric, 6 ) as "geolocation_lat", 
        round( avg( DISTINCT("geolocation_lat") )::numeric, 6 ) as "geolocation_lng"
    FROM "geolocation" 
    GROUP BY "geolocation_zip_code_prefix"


), "customers2" AS (
    SELECT 
        "customers"."customer_id", 
        "customers"."customer_unique_id", 
        "customers"."customer_zip_code_prefix", 
        "customers"."customer_city", 
        "customers"."customer_state",
        "geolocation2"."geolocation_lat", 
        "geolocation2"."geolocation_lng"
    FROM "customers"
    LEFT JOIN "geolocation2"
        ON "customers"."customer_zip_code_prefix" = "geolocation2"."geolocation_zip_code_prefix"


), "orders2" AS (
    SELECT 
        "orders"."order_id", 
        "orders"."customer_id", 
        "orders"."order_delivered_customer_date",
        "customers2"."customer_city", 
        "customers2"."customer_state", 
        "customers2"."geolocation_lat", 
        "customers2"."geolocation_lng"
    FROM "orders"
    LEFT JOIN "customers2"
        ON "orders"."customer_id" = "customers2"."customer_id"


), "order_items2" AS (
    SELECT 
        "order_items"."order_id", 
        "order_items"."order_item_id" as "order_item", 
        "order_items"."product_id", 
        "order_items"."seller_id", 
        "order_items"."price", 
        "order_items"."freight_value" as "V_Freight",
        "orders2"."order_delivered_customer_date" as "Data_Entrega", 
        "orders2"."customer_city", 
        "orders2"."customer_state", 
        "orders2"."geolocation_lat" as "customer_lat", 
        "orders2"."geolocation_lng" as "customer_lng"
    FROM "order_items"
    LEFT JOIN "orders2"
        ON "order_items"."order_id" = "orders2"."order_id"


), "products2" AS (
    SELECT 
        "product_id", "product_category_name", 
        round("product_weight_g"::numeric / 1000, 3) as "product_weight_kg",
        "product_length_cm" * "product_height_cm" * "product_width_cm" / 100^3 AS "Volume_m3"
    FROM "products"
)

SELECT * FROM "order_items2" LIMIT 5

    SELECT
        *,
        2 * 6378.1 * ASIN( SQRT(
                SIN( (customer_lat - seller_lat) / 2)^2 +
                COS(seller_lat) * COS(customer_lat) *
                SIN( (customer_lng - seller_lng) / 2)^2
        ) ) as distancia_km

with "products2" AS (
    SELECT 
        "product_id", "product_category_name", 
        round("product_weight_g"::numeric / 1000, 3) as "product_weight_kg",
        "product_length_cm" * "product_height_cm" * "product_width_cm" / 100^3 AS "Volume_m3"
    FROM "products"
)
SELECT * FROM "products2" LIMIT 5

    SELECT 
        "customers"."customer_id", "customers"."customer_unique_id", "customers"."customer_zip_code_prefix", "customers"."customer_city", "customers"."customer_state",
        "geolocation"."geolocation_lat", "geolocation"."geolocation_lng"
        FROM "customers"
        LEFT JOIN "geolocation"
            ON "customers"."customer_zip_code_prefix" = "geolocation"."geolocation_zip_code_prefix"
        LIMIT 4

SELECT 
    "geolocation_zip_code_prefix", 
    avg( DISTINCT("geolocation_lat") ) as "geolocation_lat", 
    avg( DISTINCT("geolocation_lat") ) as "geolocation_lng"
    --,"geolocation_city", "geolocation_state"
FROM "geolocation" 
GROUP BY "geolocation_zip_code_prefix" --, "geolocation_city", "geolocation_state"
LIMIT 10






/*markdown
$\begin{CD} A @>a>> B \\ @VbVV @AAcA \\ C @= D \end{CD}$
*/