library(arrow)
library(dplyr)
library(tibble)
library(ggplot2)

df_ds <- open_dataset("datasets/competencia_01.parquet")

df_ds %>% 
  glimpse()

df_ds %>% 
  colnames()



# datos faltantes ---------------------------------------------------------


datos_faltantes <- lapply(colnames(df_ds), function(x) {
  
  sum(is.na(collect(df_ds[x])))
  
})

names(datos_faltantes) <- colnames(df_ds)

datos_faltantes <- unlist(datos_faltantes)


datos_faltantes <- datos_faltantes[datos_faltantes!= 0]

datos_faltantes <- tibble(var = names(datos_faltantes), q = datos_faltantes)

datos_faltantes %>% 
  mutate(var = forcats::fct_reorder(var, q)) %>%  
  ggplot() + geom_col(aes(x = var, y = q)) +
  coord_flip() 


# rangos ------------------------------------------------------------------



rangos_columnas <- lapply(names(select(df_ds,where(is.numeric))),
                          function(x) {
  
  x <- collect(df_ds[x])
  list(min = min(x, na.rm = T), max =  max(x, na.rm = T))
  
})

names(rangos_columnas) <- names(select(df_ds,where(is.numeric)))

rangos_columnas <- bind_rows(rangos_columnas, .id = "var")

rangos_columnas <- rangos_columnas %>% 
  mutate(rango = max - min)

rangos_columnas <- rangos_columnas %>% 
  mutate(var = forcats::fct_reorder(var, rango))

rangos_columnas %>% 
  filter(!(min == 0 & max == 1)) %>% 
  ggplot() + 
  geom_segment(aes(x = var, y = min, yend = max, group = var))

datos_faltantes <- tibble(var = names(datos_faltantes), q = datos_faltantes)

datos_faltantes %>% 
  mutate(var = forcats::fct_reorder(var, q)) %>%  
  ggplot() + geom_col(aes(x = var, y = q)) +
  coord_flip() 

