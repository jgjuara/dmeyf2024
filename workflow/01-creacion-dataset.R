library(duckdb)
# library(duckplyr)

con <- dbConnect(duckdb())

data <- duckdb_read_csv(conn = con, "competencia_01_crudo",
                        files = here::here("datasets", "competencia_01_crudo.csv"))

query <- "create or replace table competencia_01 as
with periodos as (
  select distinct foto_mes from competencia_01_crudo
), clientes as (
  select distinct numero_de_cliente from competencia_01_crudo
), todo as (
  select numero_de_cliente, foto_mes from clientes cross join periodos
), clase_ternaria as (
  select
  c.*
    , if(c.numero_de_cliente is null, 0, 1) as mes_0
  , lead(mes_0, 1) over (partition by t.numero_de_cliente order by foto_mes) as mes_1
  , lead(mes_0, 2) over (partition by t.numero_de_cliente order by foto_mes) as mes_2
  , if (mes_2 = 1, 'CONTINUA',
          if (mes_1 = 1 and mes_2 = 0, 'BAJA+2',
              if (mes_1 = 0 and mes_2 = 0, 'BAJA+1', null))) as clase_ternaria
  from todo t
  left join competencia_01_crudo c using (numero_de_cliente, foto_mes)
) select
* EXCLUDE (mes_0, mes_1, mes_2)
from clase_ternaria
where mes_0 = 1"


dbExecute(con, query)

conteo <- "select count(clase_ternaria) as casos, clase_ternaria from competencia_01 group by clase_ternaria"

dbGetQuery(conn = con, statement = conteo)

exportparquet_query <-  "COPY competencia_01 TO 'datasets/competencia_01.parquet' (FORMAT PARQUET);"
exportcsv_query <-  "COPY competencia_01 TO 'datasets/competencia_01.csv' (HEADER, DELIMITER ',');"

dbExecute(con, exportparquet_query)
dbExecute(con, exportcsv_query)
