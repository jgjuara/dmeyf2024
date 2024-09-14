library(duckdb)
library(tidyverse)

con <- dbConnect(duckdb())

data <- duckdb_read_csv(conn = con, "competencia_01",
                        files = "datasets/competencia_01.csv")

reglas <- read_csv("DiccionarioDatos_2024_nulos.csv")

reglas <- reglas %>% select(var, CASO_NULL)

vars_not_nulls  <- reglas %>% filter(is.na(CASO_NULL)) %>% pull(var) 

vars_not_nulls <- paste(vars_not_nulls, collapse = ", ")

reglas <- reglas %>% filter(!is.na(CASO_NULL))

query_imputacion_nulos <- map2(reglas$var, reglas$CASO_NULL,
     function(x,y) {
       glue::glue("coalesce ({x}, {y}) as {x}_imp")
     })

query_imputacion_nulos <- unlist(query_imputacion_nulos)

query_imputacion_nulos <- paste(query_imputacion_nulos, collapse = ", ")

dbExecute(con, glue::glue("create or replace table competencia_01 as  
                select *, 
                {query_imputacion_nulos},
                from competencia_01"))

exportparquet_query <-  "COPY competencia_01 TO 'datasets/competencia_01_imp_nulos.parquet' (FORMAT PARQUET);"
exportcsv_query <-  "COPY competencia_01 TO 'datasets/competencia_01_imp_nulos.csv' (HEADER, DELIMITER ',');"

dbExecute(con, exportparquet_query)
dbExecute(con, exportcsv_query)
