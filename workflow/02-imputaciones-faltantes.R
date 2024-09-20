library(duckdb)
library(tidyverse)

con <- dbConnect(duckdb())

data <- duckdb_read_csv(conn = con, "competencia_01",
                        files = "datasets/competencia_01.csv")

reglas <- readr::read_csv("DiccionarioDatos_2024_nulos.txt")

reglas <- reglas %>% select(var, CASO_NULL)

vars_not_nulls  <- reglas %>% filter(is.na(CASO_NULL)) %>% pull(var) 

vars_not_nulls <- paste(vars_not_nulls, collapse = ", ")

reglas <- reglas %>% filter(!is.na(CASO_NULL))

query_imputacion_nulos <- map2(reglas$var, reglas$CASO_NULL,
     function(x,y) {
       glue::glue("ifnull ({x}, {y}) as {x}")
     })

query_imputacion_nulos <- unlist(query_imputacion_nulos)

query_imputacion_nulos <- paste(query_imputacion_nulos, collapse = ", ")

dbExecute(con, glue::glue("create or replace table competencia_01 as  
                select {vars_not_nulls},
                clase_ternaria,
                {query_imputacion_nulos}
                from competencia_01"))

exportparquet_query <-  "COPY competencia_01 TO 'datasets/competencia_01_imp_nulos.parquet' (FORMAT PARQUET);"
exportcsv_query <-  "COPY competencia_01 TO 'datasets/competencia_01_imp_nulos.csv' (HEADER, DELIMITER ',');"

dbExecute(con, exportparquet_query)
dbExecute(con, exportcsv_query)


columnas <- dbGetQuery(con, "SELECT column_name
FROM information_schema.columns
WHERE table_name = 'competencia_01';")

x <- list()
for (i in columnas$column_name[! grepl("foto_mes", columnas$column_name)]) {
  x[[i]] <- dbGetQuery(con, glue::glue("select {i}, foto_mes
                                   from competencia_01
                                  where {i} is NULL;")) %>% 
    count(foto_mes)
  
  print(x[[i]])
}

x %>% bind_rows(, .id = "var")