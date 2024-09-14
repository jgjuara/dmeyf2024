library(duckdb)
library(tidyverse)

con <- dbConnect(duckdb())

data <- duckdb_read_csv(conn = con, "competencia_01",
                        files = "datasets/competencia_01.csv")


# summary de cols ---------------------------------------------------------


cols <- dbGetQuery(con, "describe competencia_01")

num_cols <- cols$column_name[cols$column_type != "VARCHAR"]

query_stats_basicas <- sapply(num_cols, function(x) {
  
  glue::glue("min({x}) as min__{x}, max({x}) as max__{x}, count(DISTINCT {x}) nunique__{x}, sum(case when {x} is null then 1 else 0 end) nulls__{x}")
  
})

query_stats_basicas <- paste(query_stats_basicas, collapse = ", ")

resumen_data <- dbGetQuery(con, glue::glue("SELECT {query_stats_basicas},
                           from competencia_01"))


resumen_data <- resumen_data %>% 
  pivot_longer(cols = everything(),
               names_to = "cols", values_to = "value")

resumen_data <- resumen_data %>% 
  mutate(var = str_extract(cols,"(?=__).*") %>% 
           gsub("__","", .),
         stat = str_extract(cols,".*(?=__)"))

resumen_data <- resumen_data %>%
  select(var, stat, value)

resumen_data <- resumen_data %>% 
  pivot_wider(names_from = stat, values_from = value)

write_excel_csv(resumen_data, "TareasHogar/resumen_cols.csv")

