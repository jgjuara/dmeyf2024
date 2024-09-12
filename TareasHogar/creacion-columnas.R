
# para los arboles lo unico importante es el orden
# trabajar con ranks o deciles etc nos permite despreocuparnos de temas relacionados a cambios nominales de mes a mes
# traerse el t-1 y t-2 de todas las variables
# jugar con funciones de min,max ej max()

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

# haberes respecto a promedio anterior o mes previo

# cpayroll2_trx + cpayroll_trx / lag(cpayroll2_trx + cpayroll_trx, 1 ) 



# rank

