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
                        
                    if (isTRUE(percentil)) {

                      q1 <- glue::glue("ntile(100) OVER (ORDER BY {var}) AS percentil_{var}")
                                            
                    }
                    
                    if (isTRUE(decil)) {
                      
                      q2 <- glue::glue("ntile(10) OVER (ORDER BY {var}) AS decil_{var}")
                      
                    }
                    
                    if (isTRUE(cuartil)) {
                      
                      q3 <- glue::glue("ntile(4) OVER (ORDER BY {var}) AS cuartil_{var}")
                      
                    }
                    
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
exportcsv_query <-  "COPY competencia_01 TO 'datasets/competencia_01_lags.csv' (HEADER, DELIMITER ',');"
# 
# dbExecute(con, exportparquet_query)
dbExecute(con, exportcsv_query)

# limite credito compra total ----------------------------------------------------

# Master_mlimitecompra + Visa_mlimitecompra

# limite financiacion total -----------------------------------------------

# Visa_mfinanciacion_limite + Master_mfinanciacion_limite

# variacion limite total compra --------------------------------------------------

# delta respecto a t-1 de Master_mlimitecompra + Visa_mlimitecompra

# saldo total credito -----------------------------------------------------

# Master_msaldototal + Visa_msaldototal

#  variacion saldo total credito -------------------------------------------

# delta a t-1 de Master_msaldototal + Visa_msaldototal

#  patrimonio en cuenta ---------------------------------------------------

# mcuentas_saldo + minversion1_pesos + minversion2 + mplazo_fijo_dolares +mplazo_fijo_pesos

# suma haberes ---------------------------------------------------

# cpayroll2_trx + cpayroll_trx 

# haberes respecto a promedio anterior o mes previo  ---------------------------------------------------

# cpayroll2_trx + cpayroll_trx / lag(cpayroll2_trx + cpayroll_trx, 1 )

# prestamos  ---------------------------------------------------

# mprestamos_personales + mprestamos_prendarios + mprestamos_hipotecarios


# var prestamos -----------------------------------------------------------

# delta t-1  mprestamos_personales + mprestamos_prendarios + mprestamos_hipotecarios

# vars falopa -------------------------------------------------------------

# var si cumplio anios como var entre edad y lag(edad)
# var si sumo o resto extensiones u adicionales (hijxs pareja etc)
# var cliente_antiguedad binned (responde a quienes entraron juntos)

