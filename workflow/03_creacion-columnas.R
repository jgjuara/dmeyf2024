library(duckdb)
library(tidyverse)

con <- dbConnect(duckdb())

data <- duckdb_read_csv(conn = con, "competencia_01",
                        files = "datasets/competencia_01_imp_nulos.csv")

reglas <- read_csv("workflow/rankscsv.csv")

# para los arboles lo unico importante es el orden
# trabajar con ranks o deciles etc nos permite despreocuparnos de temas relacionados a cambios nominales de mes a mes
# traerse el t-1 y t-2 de todas las variables
# jugar con funciones de min,max ej max()


# creacion de ranks -------------------------------------------------------

reglas <- reglas %>% select(var, percentil, decil, cuartil)

reglas  <- reglas %>% filter(!if_all(c(percentil, cuartil, decil),
                                             is.na))

querys_prep <- pmap(reglas, 
                    function(var, percentil, decil, cuartil) {
                    
                    q1 <- NULL
                    q2 <- NULL
                    q3 <- NULL
                        
                    # if (isTRUE(percentil)) {
                    # 
                    #   q1 <- glue::glue("ntile(100) over (partition by foto_mes order by {var}) AS percentil_{var}")
                    #                         
                    # }
                    
                    if (isTRUE(decil)) {
                      
                      q2 <- glue::glue("ntile(10) over (partition by foto_mes order by {var}) AS decil_{var}")
                      
                    }
                    
                    # if (isTRUE(cuartil)) {
                    #   
                    #   q3 <- glue::glue("ntile(4) over (partition by foto_mes order by {var}) AS cuartil_{var}")
                    #   
                    # }
                    
                    paste(c(q1,q2,q3), collapse = ", ")
                      
                    
                      
        })


querys_prep <- querys_prep %>% unlist()

querys_prep <- paste(querys_prep, collapse = ", ")

dbExecute(con, glue::glue("create or replace table competencia_01 as  
                select *, 
                {querys_prep},
                from competencia_01"))


# exportparquet_query <-  "COPY competencia_01 TO 'datasets/competencia_01_ranks.parquet' (FORMAT PARQUET);"
# exportcsv_query <-  "COPY competencia_01 TO 'datasets/competencia_01_ranks.csv' (HEADER, DELIMITER ',');"
# 
# dbExecute(con, exportparquet_query)
# dbExecute(con, exportcsv_query)


# creacion de lags --------------------------------------------------------

columnas <- dbGetQuery(con, "SELECT column_name
FROM information_schema.columns
WHERE table_name = 'competencia_01';")

columnas <- columnas[["column_name"]]

columnas <- columnas[! grepl("numero_de_cliente|foto_mes", columnas)]


querys_lag <- sapply(columnas, function(x) {
  glue::glue("LAG({x}, 1) over (partition by numero_de_cliente order by foto_mes) AS lag1_{x}")
})

querys_lag <- paste(querys_lag, collapse = ", ")

dbExecute(con, glue::glue("create or replace table competencia_01 as  
                select *, 
                {querys_lag},
                from competencia_01"))

# exportparquet_query <-  "COPY competencia_01 TO 'datasets/competencia_01_ranks.parquet' (FORMAT PARQUET);"
# exportcsv_query <-  "COPY competencia_01 TO 'datasets/competencia_01_lags.csv' (HEADER, DELIMITER ',');"
# 
# dbExecute(con, exportparquet_query)
# dbExecute(con, exportcsv_query)



# limite credito compra total ----------------------------------------------------

query <- "Master_mlimitecompra + Visa_mlimitecompra as total_mlimitecompra,
          lag1_Master_mlimitecompra + lag1_Visa_mlimitecompra as lag1_total_mlimitecompra"

dbExecute(con, glue::glue("create or replace table competencia_01 as  
                select *, 
                {query},
                from competencia_01"))

# limite financiacion total -----------------------------------------------

# Visa_mfinanciacion_limite + Master_mfinanciacion_limite

query <- "Visa_mfinanciacion_limite + Master_mfinanciacion_limite as total_mfinanciacion_limite,
          lag1_Visa_mfinanciacion_limite + lag1_Master_mfinanciacion_limite as lag1_total_mfinanciacion_limite "

dbExecute(con, glue::glue("create or replace table competencia_01 as  
                select *, 
                {query},
                from competencia_01"))


# saldo total credito -----------------------------------------------------

# Master_msaldototal + Visa_msaldototal

query <- "Master_msaldototal + Visa_msaldototal as total_msaldototal,
          lag1_Master_msaldototal + lag1_Visa_msaldototal as lag1_total_msaldototal"

dbExecute(con, glue::glue("create or replace table competencia_01 as  
                select *, 
                {query},
                from competencia_01"))


#  patrimonio en cuenta ---------------------------------------------------

# mcuentas_saldo + minversion1_pesos + minversion2 + mplazo_fijo_dolares +mplazo_fijo_pesos


query <- "mcuentas_saldo + minversion1_pesos + minversion2 + mplazo_fijo_dolares + mplazo_fijo_pesos as total_patrimonio,
          lag1_mcuentas_saldo + lag1_minversion1_pesos + lag1_minversion2 + lag1_mplazo_fijo_dolares + lag1_mplazo_fijo_pesos as lag1_total_patrimonio"

dbExecute(con, glue::glue("create or replace table competencia_01 as  
                select *, 
                {query},
                from competencia_01"))

# suma haberes ---------------------------------------------------

# cpayroll2_trx + cpayroll_trx 

query <- "cpayroll2_trx + cpayroll_trx as total_payroll,
          lag1_cpayroll2_trx + lag1_cpayroll_trx as lag1_total_payroll"

dbExecute(con, glue::glue("create or replace table competencia_01 as  
                select *, 
                {query},
                from competencia_01"))

# prestamos  ---------------------------------------------------

# mprestamos_personales + mprestamos_prendarios + mprestamos_hipotecarios

query <- "mprestamos_personales + mprestamos_prendarios + mprestamos_hipotecarios as total_prestamos,
          lag1_mprestamos_personales + lag1_mprestamos_prendarios + lag1_mprestamos_hipotecarios as lag1_total_prestamos"

dbExecute(con, glue::glue("create or replace table competencia_01 as  
                select *, 
                {query},
                from competencia_01"))

# vars falopa -------------------------------------------------------------

# var si cumplio anios como var entre edad y lag(edad)

query <- "cliente_edad - lag1_cliente_edad as cumpleanios"

dbExecute(con, glue::glue("create or replace table competencia_01 as  
                select *, 
                {query},
                from competencia_01"))

# var cliente_antiguedad binned (responde a quienes entraron juntos)


# regresiones -------------------------------------------------------------

columnas <- dbGetQuery(con, "SELECT column_name
FROM information_schema.columns
WHERE table_name = 'competencia_01';")

columnas <- columnas[["column_name"]]

columnas <- columnas[! grepl("numero_de_cliente|foto_mes", columnas)]

columnas <- columnas[! grepl("lag1|cumpleanios", columnas)]

querys_reg <- sapply(columnas, function(x) {
  glue::glue("regr_slope({var}) over ventana_3 as betareg_{}
             from competencia_01
             window ventana_3 as (partition by numero_de_cliente order by foto_mes rows between 1 preceding and current row)")
})

querys_reg <- paste(querys_reg, collapse = ", ")

dbExecute(con, glue::glue("create or replace table competencia_01 as  
                select *, 
                {querys_reg},
                from competencia_01"))



# exportparquet_query <-  "COPY competencia_01 TO 'datasets/competencia_01_aum.parquet' (FORMAT PARQUET);"
# exportcsv_query <-  "COPY competencia_01 TO 'datasets/competencia_01_aum.csv' (HEADER, DELIMITER ',');"

# exportparquet_query <-  "COPY competencia_01 TO 'datasets/competencia_01_aum.parquet' (FORMAT PARQUET);"
# dbExecute(con, exportparquet_query)
