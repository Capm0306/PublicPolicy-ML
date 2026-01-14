# Proyecto priorización manzanas política de cuidado

#Instalación de paqueterias
library(FactoMineR)
library(ggplot2)
library(factoextra)

#1.Vamos a importar la base de datos
library(readxl)
Base_de_datos_MZ <- read_excel("~/Downloads/Base de datos MZ.xlsx")
View(Base_de_datos_MZ)  

#2. De aquí vamos a eliminar variables para quedarnos con las importantes
Base<-Base_de_datos_MZ
library(dplyr)
Base<-Base%>%
  select(CVEGEO,POBTOT,POBFEM,POBMAS,P_3A5,P_6A11,P_60YMAS,P3YM_HLI,P3HLINHE,PCON_DISC,PCON_LIMI,PCLIM_PMEN,P3A5_NOA,PE_INAC,PE_INAC_F,PDESOCUP,PSINDER,P12YM_SEPA,HOGJEF_F,PHOGJEF_F,VPH_S_ELEC,VPH_AGUAFV,VPH_NODREN,VPH_NDEAED,VPH_SINLTC,VPH_SINCINT)
#Ya la reducimos a 26 variables
glimpse(Base)

#Seleccionamos las 26 variables excluyendo el ID que son las manzanas
datos_pca <- Base %>% select(-CVEGEO)

# Aplicar PCA a las 26 variables
pca_result <- PCA(datos_pca, scale.unit = TRUE, graph = FALSE)

# Mostrar la varianza explicada por cada componente
summary(pca_result)

# Graficar la importancia de las variables en el PCA
fviz_pca_var(pca_result, col.var = "cos2", repel = TRUE)

#Varianza por componente
summary(pca_result)

#Creamos la base en csv
write.csv(Base,file="Base_reducida.csv",row.names = FALSE)

#Seleccionando variables relevantes con base a la presentación IMPLAN
# Seleccionar solo las columnas necesarias
base_reducida_filtrada <- Base%>%
  select(CVEGEO, POBFEM,P_3A5,P_6A11,PSINDER,PCON_DISC,PCON_LIMI,P_60YMAS,P3A5_NOA,PE_INAC,PE_INAC_F,PDESOCUP,HOGJEF_F,PHOGJEF_F)

#Vamos a normalizar las variables
# Función para normalizar una columna
normalize <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

# Aplicar la normalización a todas las columnas excepto CVEGEO
variables_normalizadas <- base_reducida_filtrada %>%
  mutate(across(-CVEGEO, normalize))

# Agregar CVEGEO nuevamente
variables_normalizadas <- cbind(base_reducida_filtrada["CVEGEO"], variables_normalizadas)

# Verificar que las variables están normalizadas (todas deben estar entre 0 y 1)
summary(variables_normalizadas)

#Analisis de componentes principales con las variables preseleccionadas

# Aplicar PCA a las variables normalizadas (excluyendo CVEGEO)
pca_result <- PCA(variables_normalizadas[,-1], scale.unit = TRUE, ncp = 1, graph = FALSE)

# Extraer los pesos del primer componente
pesos <- abs(pca_result$var$coord[,1])

# Mostrar los pesos asignados a cada variable
pesos

#Mostrar los pesos en un data frame
# Crear un dataframe con las variables y sus pesos en PC1
pesos_df <- data.frame(
  Variable = c("POBTOT", "POBFEM", "POBMAS", "P_3A5", "P_6A11", "P_60YMAS", "P3YM_HLI", "P3HLINHE", "PCON_DISC",
               "PCON_LIMI", "PCLIM_PMEN", "P3A5_NOA", "PE_INAC", "PE_INAC_F", "PDESOCUP", "PSINDER", "P12YM_SEPA", "HOGJEF_F",
               "PHOGJEF_F", "VPH_S_ELEC", "VPH_AGUAFV", "VPH_NODREN", "VPH_NDEAED", "VPH_SINLTC", "VPH_SINCINT"),
  Peso_PC1 = c(0.97707452, 0.97383141, 0.96115739, 0.86743669, 0.91747806, 0.67046002, 0.71627156, 0.06496474, 0.72961359,
               0.77577285, 0.46754750, 0.76217768, 0.87919828, 0.94964555, 0.52124133, 0.92712876, 0.89052790, 0.88947773,
               0.89795983, 0.11615891, 0.08464050, 0.06653957, 0.06618537, 0.47123286, 0.76942065)
)

# Ordenar los pesos de mayor a menor
pesos_df <- pesos_df[order(-pesos_df$Peso_PC1),]

# Mostrar la tabla
print(pesos_df)

# Guardar la tabla en un archivo CSV si lo necesitas
write.csv(pesos_df, "Pesos_PCA.csv", row.names = FALSE)


#Cálculo indice de vulnerabilidad 

# Eliminar la columna CVEGEO antes de definir variables_en_datos
variables_numericas <- variables_normalizadas %>%
  select(-CVEGEO)

# Ahora sí, obtener los nombres de las columnas sin CVEGEO
variables_en_datos <- colnames(variables_numericas)

# Filtrar pesos para mantener solo las variables que están en variables_normalizadas
pesos_filtrados <- pesos[names(pesos) %in% variables_en_datos]
class(variables_numericas)
variables_matrix <- as.matrix(variables_numericas)

# Multiplicar variables normalizadas por los pesos del PCA
indice_vulnerabilidad <- as.vector(variables_matrix %*% pesos_filtrados)

# Agregar el índice de vulnerabilidad al dataframe original
base_reducida_filtrada$Indice_Vulnerabilidad <- indice_vulnerabilidad

# Mostrar las primeras filas para verificar
head(base_reducida_filtrada)

# Ordenar las colonias de mayor a menor vulnerabilidad
base_reducida_ranked <- base_reducida_filtrada %>%
  arrange(desc(Indice_Vulnerabilidad))

# Mostrar las primeras filas para verificar
head(base_reducida_ranked)

# Seleccionar las 30 colonias más vulnerables
top_30 <- head(base_reducida_ranked, 30)

# Guardar en un archivo CSV
write.csv(top_30, file = "Top_30_Colonias_Vulnerables.csv", row.names = FALSE)

# Mostrar las 10 colonias más vulnerables
head(top_30, 10)

# Graficar el Top 10 de colonias más vulnerables
ggplot(head(base_reducida_ranked, 10), aes(x = reorder(CVEGEO, -Indice_Vulnerabilidad), y = Indice_Vulnerabilidad)) +
  geom_bar(stat = "identity", fill = "red") +
  coord_flip() +
  labs(title = "Top 10 Colonias Más Vulnerables",
       x = "Colonia (CVEGEO)",
       y = "Índice de Vulnerabilidad") +
  theme_minimal() 

# Comprobar si hay valores NA en el índice
sum(is.na(base_reducida_filtrada$Indice_Vulnerabilidad))

# Comprobar el resumen del índice de vulnerabilidad
summary(base_reducida_filtrada$Indice_Vulnerabilidad)

#Exportar base completa
write.csv(base_reducida_ranked,file="Prioridad.csv",row.names = FALSE)
