library(duckdb)
library(tidyverse)


con <- dbConnect(duckdb(dbdir = "db/competencia_01.duckdb"))

dbExecute(conn = con, 
          glue::glue("ATTACH 'host={Sys.getenv('ip')} user={Sys.getenv('usersrv')} password={Sys.getenv('password')} port=3306 database=competencia_uno' AS mysql_db (TYPE MYSQL);"))

dbExecute(conn = con, 
          "CREATE or replace TABLE competencia_uno.competencia_01_columnas_adicionales
          as select *
          from competencia_01_columnas_adicionales;"
          )

