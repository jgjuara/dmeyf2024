library(DBI)
# Connect to my-db as defined in ~/.my.cnf
con <- dbConnect(
  RMySQL::MySQL(),
  user = Sys.getenv("usersrv"),
  password = Sys.getenv('password'),
  dbname = 'competencia_uno',
  host = Sys.getenv('ip'),
  port = 3306
)

tabla <- "competencia_01_aum_nonimp"

df <- arrow::read_parquet(glue::glue("datasets/{tabla}.parquet"))

dbWriteTable(conn = con, name = "datos_")
