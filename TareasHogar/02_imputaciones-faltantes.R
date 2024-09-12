library(duckdb)

con <- dbConnect(duckdb())

data <- duckdb_read_csv(conn = con, "competencia_01_crudo",
                        files = "datasets/competencia_01.csv")
