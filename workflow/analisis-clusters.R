library(tidyverse)
library(arrow)
library(ggplot2)

# Cluster 2 (p = 0.867, q = 1725) vs. Resto:
# - ctrx_quarter
# - lag1_ctrx_quarter
# - mpayroll
# - mprestamos_personales
# - variacion_decil_matm_other

# df <- arrow::read_parquet("datasets/dfclusters.parquet")
# 
# df %>% 
#   group_by(cluster == 2) %>% 
#   summarise(
#     ctrx_quarter = mean(ctrx_quarter, na.rm = T),
#     mpayroll = mean(mpayroll, na.rm = T),
#     mprestamos_personales = mean(mprestamos_personales, na.rm = T)
#     )

# comentario:
# para abril al menos la gran mayoria de los baja caen en un mismo cluster
# ¿realmente hay tipos diferentes de baja lo bastante importantes para estrategias especificas?

df <- arrow::open_dataset("datasets/competencia_01_aum_nonimp.parquet")
# 
# df_bajas <- df %>% 
#   filter(foto_mes %in% c(202101:202104)) %>% 
#   filter(clase_ternaria != "CONTINUA")
# 
# df_bajas <- df_bajas %>% collect()
# 
# arrow::write_parquet(df_bajas, sink = "datasets/bajas.parquet")
# 
# df_continua <- df %>% 
#     filter(foto_mes %in% c(202101:202104)) %>%
#     filter(clase_ternaria == "CONTINUA")
# 
# ids_continua <- df_continua %>%
#   select(numero_de_cliente, foto_mes)
# 
# ids_continua <- ids_continua %>% 
#   collect()
# 
# ids_continua <- ids_continua %>% 
#   group_by(foto_mes) %>% 
#   slice_sample(n = 3000)
# 
# df_continua <- df_continua %>% 
#   inner_join(ids_continua)
#   
# df_continua <- df_continua %>% 
#   collect()

# arrow::write_parquet(df_continua, "datasets/continua_sample.parquet")

continua <- arrow::open_dataset("datasets/continua_sample.parquet")
bajas <- arrow::open_dataset("datasets/bajas.parquet")


df_continua1 <- continua %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2,
         lag1_total_mpayroll = lag1_mpayroll + lag1_mpayroll2) %>% 
  group_by(foto_mes) %>%
  summarise(
    edad = mean(cliente_edad, na.rm = T), 
    cliente_antiguedad = mean(cliente_antiguedad, na.rm = T),
    cproductos = mean(cproductos, na.rm = T), # cantidad total de productos contratados
    total_patrimonio = mean(total_patrimonio, na.rm = T),
    # lag1_total_patrimonio = mean(lag1_total_patrimonio, na.rm = T),
    ctrx_quarter = mean(ctrx_quarter, na.rm = T), # Cantidad de movimientos voluntarios
    total_cpayroll = mean(total_payroll, na.rm = T), # cantidad de pagos salariales
    # lag1_total_cpayroll = mean(lag1_total_payroll, na.rm = T), # lag1 cantidad de pagos salariales
    total_mpayroll = mean(total_mpayroll, na.rm = T), # monto de pagos salariales
    # lag1_total_mpayroll = mean(lag1_total_mpayroll, na.rm = T), # lag1 monto de pagos salariales
    total_prestamos = mean(total_prestamos, na.rm = T), # monto total prestamos tomados
    total_msaldototal = mean(total_msaldototal, na.rm = T) #monto saldo total de master + visa
    # lag1_total_msaldototal = mean(lag1_total_msaldototal, na.rm = T)
  ) %>% 
  collect()
  # pivot_longer(-foto_mes, names_to = "vars", values_to = "values") %>% 
  # view()

df_bajas1 <- bajas %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2,
         lag1_total_mpayroll = lag1_mpayroll + lag1_mpayroll2) %>% 
  group_by(foto_mes) %>%
  summarise(
    edad = mean(cliente_edad, na.rm = T), 
    cliente_antiguedad = mean(cliente_antiguedad, na.rm = T),
    cproductos = mean(cproductos, na.rm = T), # cantidad total de productos contratados
    total_patrimonio = mean(total_patrimonio, na.rm = T),
    # lag1_total_patrimonio = mean(lag1_total_patrimonio, na.rm = T),
    ctrx_quarter = mean(ctrx_quarter, na.rm = T), # Cantidad de movimientos voluntarios
    total_cpayroll = mean(total_payroll, na.rm = T), # cantidad de pagos salariales
    # lag1_total_cpayroll = mean(lag1_total_payroll, na.rm = T), # lag1 cantidad de pagos salariales
    total_mpayroll = mean(total_mpayroll, na.rm = T), # monto de pagos salariales
    # lag1_total_mpayroll = mean(lag1_total_mpayroll, na.rm = T), # lag1 monto de pagos salariales
    total_prestamos = mean(total_prestamos, na.rm = T), # monto total prestamos tomados
    total_msaldototal = mean(total_msaldototal, na.rm = T) #monto saldo total de master + visa
    # lag1_total_msaldototal = mean(lag1_total_msaldototal, na.rm = T)
  ) %>% 
  collect() 
  # pivot_longer(-foto_mes, names_to = "vars", values_to = "values") %>% 



df_bajas2 <- bajas %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2,
         lag1_total_mpayroll = lag1_mpayroll + lag1_mpayroll2) %>% 
  group_by(foto_mes) %>%
  summarise(
    edad = mean(cliente_edad), 
    cproductos = mean(cproductos, na.rm = T), # cantidad total de productos contratados
    total_patrimonio = mean(total_patrimonio, na.rm = T),
    # lag1_total_patrimonio = mean(lag1_total_patrimonio, na.rm = T),
    ctrx_quarter = mean(ctrx_quarter, na.rm = T), # Cantidad de movimientos voluntarios
    total_cpayroll = mean(total_payroll, na.rm = T), # cantidad de pagos salariales
    lag1_total_cpayroll = mean(lag1_total_payroll, na.rm = T), # lag1 cantidad de pagos salariales
    total_mpayroll = mean(total_mpayroll, na.rm = T), # monto de pagos salariales
    lag1_total_mpayroll = mean(lag1_total_mpayroll, na.rm = T), # lag1 monto de pagos salariales
    total_prestamos = mean(total_prestamos, na.rm = T), # monto total prestamos tomados
    total_msaldototal = mean(total_msaldototal, na.rm = T), #monto saldo total de master + visa
    lag1_total_msaldototal = mean(lag1_total_msaldototal, na.rm = T)
  ) %>% 
  collect() 

clientes_bajas <- bajas %>% 
  distinct(numero_de_cliente) %>%  
  collect()

clientes_bajas <- clientes_bajas %>% 
  pull(numero_de_cliente)

df_clientes_que_bajaran <- df %>% 
  filter(numero_de_cliente %in% clientes_bajas)
  

df_bajas3 <- df_clientes_que_bajaran %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2) %>%
  select(numero_de_cliente,
         foto_mes,
         ctrx_quarter,
         total_payroll,
         total_mpayroll,
         total_prestamos,
         total_msaldototal,
         cproductos,
         total_patrimonio,
         cliente_antiguedad,
         cliente_vip) %>%
  collect() %>% 
  group_by(numero_de_cliente) %>% 
  arrange(foto_mes) %>%
  mutate(
    lag1_ctrx_quarter = lag(ctrx_quarter, 1), # Cantidad de movimientos voluntarios
    lag2_ctrx_quarter = lag(ctrx_quarter, 2), # Cantidad de movimientos voluntarios
    lag1_total_payroll = lag(total_payroll, 1), # cantidad de pagos salariales
    lag2_total_payroll = lag(total_payroll, 2), # cantidad de pagos salariales
    lag1_total_mpayroll = lag(total_mpayroll, 1), # monto de pagos salariales
    lag2_total_mpayroll = lag(total_mpayroll, 2), # monto de pagos salariales
    lag1_total_prestamos = lag(total_prestamos, 1), # monto total prestamos tomados
    lag2_total_prestamos = lag(total_prestamos, 2), # monto total prestamos tomados
    lag1_total_msaldototal = lag(total_msaldototal, 1), #monto saldo total de master + visa
    lag2_total_msaldototal = lag(total_msaldototal, 2) #monto saldo total de master + visa
    ) %>% 
  ungroup() %>% 
  group_by(foto_mes) %>%
  summarise(
    ctrx_quarter = mean(ctrx_quarter, na.rm = T), # Cantidad de movimientos voluntarios
    lag1_ctrx_quarter = mean(lag1_ctrx_quarter, na.rm = T), # Cantidad de movimientos voluntarios
    lag2_ctrx_quarter = mean(lag2_ctrx_quarter, na.rm = T), # Cantidad de movimientos voluntarios
    total_cpayroll = mean(total_payroll, na.rm = T), # cantidad de pagos salariales
    lag1_total_cpayroll = mean(lag1_total_payroll, na.rm = T), # cantidad de pagos salariales
    lag2_total_cpayroll = mean(lag2_total_payroll, na.rm = T), # cantidad de pagos salariales
    total_mpayroll = mean(total_mpayroll, na.rm = T), # monto de pagos salariales
    lag1_total_mpayroll = mean(lag1_total_mpayroll, na.rm = T), # monto de pagos salariales
    lag2_total_mpayroll = mean(lag2_total_mpayroll, na.rm = T), # monto de pagos salariales
    total_prestamos = mean(total_prestamos, na.rm = T), # monto total prestamos tomados
    lag1_total_prestamos = mean(lag1_total_prestamos, na.rm = T), # monto total prestamos tomados
    lag2_total_prestamos = mean(lag2_total_prestamos, na.rm = T), # monto total prestamos tomados
    total_msaldototal = mean(total_msaldototal, na.rm = T), #monto saldo total de master + visa
    lag1_total_msaldototal = mean(lag1_total_msaldototal, na.rm = T), #monto saldo total de master + visa
    lag2_total_msaldototal = mean(lag2_total_msaldototal, na.rm = T) #monto saldo total de master + visa
  ) %>% 
  collect() 


# separacion de clusters ------------

bajas %>% 
  select(# numero_de_cliente,
         # foto_mes,
         ctrx_quarter #,
         # total_payroll,
         # total_mpayroll,
         # total_prestamos,
         # total_msaldototal,
         # cproductos,
         # total_patrimonio,
         # cliente_antiguedad,
         # cliente_vip
         ) %>%
  collect() %>% 
  ggplot() +
  geom_histogram(aes(ctrx_quarter)) +
  scale_x_continuous(limits = c(0,300))

bajas %>% 
  select(# numero_de_cliente,
    # foto_mes,
    # ctrx_quarter #,
    total_payroll #,
    # total_mpayroll,
    # total_prestamos,
    # total_msaldototal,
    # cproductos,
    # total_patrimonio,
    # cliente_antiguedad,
    # cliente_vip
  ) %>%
  collect() %>% 
  ggplot() +
  geom_histogram(aes(total_payroll)) +
  scale_x_continuous()

bajas %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2) %>%
  select(# numero_de_cliente,
    # foto_mes,
    # ctrx_quarter #,
    # total_payroll #,
    total_mpayroll # ,
    # total_prestamos,
    # total_msaldototal,
    # cproductos,
    # total_patrimonio,
    # cliente_antiguedad,
    # cliente_vip
  ) %>%
  collect() %>% 
  count(total_mpayroll) %>% 
  ggplot() +
  geom_col(aes(x = total_mpayroll, y = n))


bajas %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2) %>%
  select(# numero_de_cliente,
    # foto_mes,
    # ctrx_quarter #,
    # total_payroll #,
    # total_mpayroll # ,
    total_prestamos #,
    # total_msaldototal,
    # cproductos,
    # total_patrimonio,
    # cliente_antiguedad,
    # cliente_vip
  ) %>%
  collect() %>% 
  ggplot() +
  geom_histogram(aes(total_prestamos))



bajas %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2) %>%
  select(# numero_de_cliente,
    # foto_mes,
    # ctrx_quarter #,
    # total_payroll #,
    # total_mpayroll # ,
    # total_prestamos #,
    total_msaldototal# ,
    # cproductos,
    # total_patrimonio,
    # cliente_antiguedad,
    # cliente_vip
  ) %>%
  collect() %>% 
  ggplot() +
  geom_histogram(aes(total_msaldototal))


bajas %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2) %>%
  select(# numero_de_cliente,
    # foto_mes,
    # ctrx_quarter #,
    # total_payroll #,
    # total_mpayroll # ,
    # total_prestamos #,
    # total_msaldototal# ,
    cproductos #,
    # total_patrimonio,
    # cliente_antiguedad,
    # cliente_vip
  ) %>%
  collect() %>% 
  ggplot() +
  geom_histogram(aes(cproductos))



bajas %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2) %>%
  select(# numero_de_cliente,
    # foto_mes,
    # ctrx_quarter #,
    # total_payroll #,
    # total_mpayroll # ,
    # total_prestamos #,
    # total_msaldototal# ,
    # cproductos #,
    total_patrimonio #,
    # cliente_antiguedad,
    # cliente_vip
  ) %>%
  collect() %>% 
  ggplot() +
  geom_histogram(aes(total_patrimonio))




bajas %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2) %>%
  select(# numero_de_cliente,
    # foto_mes,
    # ctrx_quarter #,
    # total_payroll #,
    # total_mpayroll # ,
    # total_prestamos #,
    # total_msaldototal# ,
    # cproductos #,
    # total_patrimonio #,
    cliente_antiguedad #,
    # cliente_vip
  ) %>%
  collect() %>% 
  ggplot() +
  geom_histogram(aes(cliente_antiguedad))



bajas %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2) %>%
  select(# numero_de_cliente,
    # foto_mes,
    # ctrx_quarter #,
    # total_payroll #,
    # total_mpayroll # ,
    # total_prestamos #,
    # total_msaldototal# ,
    # cproductos #,
    # total_patrimonio #,
    # cliente_antiguedad #,
    cliente_vip
  ) %>%
  collect() %>% 
  ggplot() +
  geom_bar(aes(cliente_vip))

bajas %>% 
  select(ctrx_quarter) %>% 
  collect() %>% 
  mutate(ctrx_quarter_0 = ctrx_quarter == 0) %>% 
  ggplot() +
  geom_bar(aes(ctrx_quarter_0, fill = ctrx_quarter_0))

bajas %>% 
  select(mpayroll) %>% 
  collect() %>% 
  mutate(mpayroll = mpayroll == 0) %>% 
  ggplot() +
  geom_bar(aes(mpayroll, fill = mpayroll))

bajas %>% 
  select(cliente_antiguedad) %>% 
  count(antiguedad = cliente_antiguedad < 90) %>% 
  collect() %>% 
  mutate(n = n/sum(n)) %>% 
  # filter(mprestamos_personales < 100000) %>% 
  ggplot() + 
  geom_col(aes(x= antiguedad, y = n))



df_bajas4 <- bajas %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2) %>%
  select(numero_de_cliente,
         foto_mes,
         ctrx_quarter,
         total_payroll,
         total_mpayroll,
         total_prestamos,
         total_msaldototal,
         cproductos,
         total_patrimonio,
         cliente_antiguedad,
         cliente_vip) %>%
  collect() %>% 
  group_by(numero_de_cliente) %>% 
  arrange(foto_mes) %>%
  mutate(
    lag1_ctrx_quarter = lag(ctrx_quarter, 1), # Cantidad de movimientos voluntarios
    lag2_ctrx_quarter = lag(ctrx_quarter, 2), # Cantidad de movimientos voluntarios
    lag1_total_payroll = lag(total_payroll, 1), # cantidad de pagos salariales
    lag2_total_payroll = lag(total_payroll, 2), # cantidad de pagos salariales
    lag1_total_mpayroll = lag(total_mpayroll, 1), # monto de pagos salariales
    lag2_total_mpayroll = lag(total_mpayroll, 2), # monto de pagos salariales
    lag1_total_prestamos = lag(total_prestamos, 1), # monto total prestamos tomados
    lag2_total_prestamos = lag(total_prestamos, 2), # monto total prestamos tomados
    lag1_total_msaldototal = lag(total_msaldototal, 1), #monto saldo total de master + visa
    lag2_total_msaldototal = lag(total_msaldototal, 2) #monto saldo total de master + visa
  ) %>% 
  ungroup() %>% 
  group_by(ctrx_quarter == 0) %>%
  summarise(
    ctrx_quarter = mean(ctrx_quarter, na.rm = T), # Cantidad de movimientos voluntarios
    lag1_ctrx_quarter = mean(lag1_ctrx_quarter, na.rm = T), # Cantidad de movimientos voluntarios
    lag2_ctrx_quarter = mean(lag2_ctrx_quarter, na.rm = T), # Cantidad de movimientos voluntarios
    total_cpayroll = mean(total_payroll, na.rm = T), # cantidad de pagos salariales
    lag1_total_cpayroll = mean(lag1_total_payroll, na.rm = T), # cantidad de pagos salariales
    lag2_total_cpayroll = mean(lag2_total_payroll, na.rm = T), # cantidad de pagos salariales
    total_mpayroll = mean(total_mpayroll, na.rm = T), # monto de pagos salariales
    lag1_total_mpayroll = mean(lag1_total_mpayroll, na.rm = T), # monto de pagos salariales
    lag2_total_mpayroll = mean(lag2_total_mpayroll, na.rm = T), # monto de pagos salariales
    total_prestamos = mean(total_prestamos, na.rm = T), # monto total prestamos tomados
    lag1_total_prestamos = mean(lag1_total_prestamos, na.rm = T), # monto total prestamos tomados
    lag2_total_prestamos = mean(lag2_total_prestamos, na.rm = T), # monto total prestamos tomados
    total_msaldototal = mean(total_msaldototal, na.rm = T), #monto saldo total de master + visa
    lag1_total_msaldototal = mean(lag1_total_msaldototal, na.rm = T), #monto saldo total de master + visa
    lag2_total_msaldototal = mean(lag2_total_msaldototal, na.rm = T) #monto saldo total de master + visa
  ) %>% 
  collect() 



df_bajas5 <- bajas %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2,
         lag1_total_mpayroll = lag1_mpayroll + lag1_mpayroll2,
         total_patrimonio = mcuentas_saldo + minversion1_pesos + minversion2 + mplazo_fijo_dolares + mplazo_fijo_pesos,
         tarjetas_cconsumos  = Master_cconsumos + Visa_cconsumos) %>% 
  group_by(ctrx_quarter == 0) %>%
  summarise(
    N = n(),
    edad = mean(cliente_edad, na.rm = T), 
    cliente_antiguedad = mean(cliente_antiguedad, na.rm = T),
    cproductos = mean(cproductos, na.rm = T), # cantidad total de productos contratados
    mcuentas_saldo = mean(mcuentas_saldo, na.rm = T),
    ctrx_quarter = mean(ctrx_quarter, na.rm = T), # Cantidad de movimientos voluntarios
    total_cpayroll = mean(total_payroll, na.rm = T), # cantidad de pagos salariales
    total_mpayroll = mean(total_mpayroll, na.rm = T), # monto de pagos salariales
    total_prestamos = mean(total_prestamos, na.rm = T), # monto total prestamos tomados
    total_msaldototal = mean(total_msaldototal, na.rm = T), #monto saldo total de master + visa
    ctarjeta_visa = mean(ctarjeta_visa, na.rm = T),
    tarjetas_cconsumos = mean(tarjetas_cconsumos, na.rm = T),
    mrentabilidad_annual = mean(mrentabilidad_annual, na.rm = T),
    mrentabilidad = mean(mrentabilidad, na.rm = T),
    cpagodeservicios = mean(cpagodeservicios, na.rm = T)
    
    
  ) %>% 
  collect() %>% 
  mutate(clase = "bajas")


df_continua5 <- continua %>% 
  mutate(total_mpayroll = mpayroll + mpayroll2,
         lag1_total_mpayroll = lag1_mpayroll + lag1_mpayroll2,
         total_patrimonio = mcuentas_saldo + minversion1_pesos + minversion2 + mplazo_fijo_dolares + mplazo_fijo_pesos,
         tarjetas_cconsumos  = Master_cconsumos + Visa_cconsumos) %>% 
  group_by(ctrx_quarter == 0) %>%
  summarise(
    N = n(),
    edad = mean(cliente_edad, na.rm = T), 
    cliente_antiguedad = mean(cliente_antiguedad, na.rm = T),
    cproductos = mean(cproductos, na.rm = T), # cantidad total de productos contratados
    mcuentas_saldo = mean(mcuentas_saldo, na.rm = T),
    ctrx_quarter = mean(ctrx_quarter, na.rm = T), # Cantidad de movimientos voluntarios
    total_cpayroll = mean(total_payroll, na.rm = T), # cantidad de pagos salariales
    total_mpayroll = mean(total_mpayroll, na.rm = T), # monto de pagos salariales
    total_prestamos = mean(total_prestamos, na.rm = T), # monto total prestamos tomados
    total_msaldototal = mean(total_msaldototal, na.rm = T), #monto saldo total de master + visa
    ctarjeta_visa = mean(ctarjeta_visa, na.rm = T),
    tarjetas_cconsumos = mean(tarjetas_cconsumos, na.rm = T),
    mrentabilidad_annual = mean(mrentabilidad_annual, na.rm = T),
    mrentabilidad = mean(mrentabilidad, na.rm = T),
    cpagodeservicios = mean(cpagodeservicios, na.rm = T)
    
    
    
  ) %>% 
  collect() %>% 
  mutate(clase = "continua")

df5 <- bind_rows(df_bajas5, df_continua5)
