## Vamos a correr el polciy learning

install.packages("policytree")
install.packages("DiagrammeR")
library(policytree)
library(DiagrammeR)


#1.Ya tenemos los CATE´s y el bosque causal entrenado (cf,tau_hat)

#2. Obtenemos los scores doblemente robustos
dr.scores <- double_robust_scores(cf)
colnames(dr.scores)
head(dr.scores,10)

#Dvisión entrenamiento
set.seed(123)
n <- nrow(X)
train.idx <- sample(1:n, size = floor(0.8 * n))
test.idx <- setdiff(1:n, train.idx)

#3. Ajustamos el policy tree de profundidad 2
policy <- policy_tree(X[train.idx, ],
                      dr.scores[train.idx, ],
                      depth = 2,
                      min.node.size = 30)
print(policy)                 
plot(policy,leaf.labels = c("Control","Tratamiento"))

#Estadisticas por hoja
# dr.scores[test.idx, ] es una matriz con dos columnas (control, treated)
hoja <- predict(policy, X, type = "node.id")
table(hoja)
df <- data.frame(
  leaf = hoja,
  treated = dr.scores[, 2],  # columna tratados
  control = dr.scores[, 1]   # columna controles
)
# dr.scores[test.idx, ] es una matriz con dos columnas (control, treated)
stats.hoja <- aggregate(dr.scores,
                        by = list(leaf.node = hoja),
                        FUN = function(x) c(mean = mean(x),
                                            se = sd(x)/sqrt(length(x))))
print(stats.hoja)


#Construimos intervalos de confianza
# Datos
df_leaf <- data.frame(
  leaf.node    = c(4, 5, 6, 7),
  control.mean = c(0.212659690, 0.233296393, 0.295642839, 0.495572360),
  control.se   = c(0.008591055, 0.005513288, 0.020054398, 0.029463924),
  treated.mean = c(0.234776506, 0.212365175, 0.335319193, 0.373283146),
  treated.se   = c(0.009061139, 0.005394686, 0.017020735, 0.021678641)
)

# Calcular diferencias y IC95%
df_leaf <- df_leaf %>%
  mutate(
    diff       = treated.mean - control.mean,
    diff.se    = sqrt(control.se^2 + treated.se^2),   # asumiendo independencia
    diff.lower = diff - 1.96*diff.se,
    diff.upper = diff + 1.96*diff.se
  )
print(df_leaf[, c("leaf.node","diff","diff.lower","diff.upper")])



#Apliquemos un árbol de mayor prfundidad
tree2 <- hybrid_policy_tree(X[train.idx, ],
                            dr.scores[train.idx, ],
                            depth = 3,
                            search.depth = 2)
print(tree2)                    
plot(tree2,leaf.labels = c("Control","Tratamiento")) 


#hbyrid tree
#Estadisticas por hoja
# dr.scores[test.idx, ] es una matriz con dos columnas (control, treated)
hoja2 <- predict(tree2, X, type = "node.id") 

table(hoja2) #Observaciones de hogares a tratar y no tratar siguiendo esa condición

# dr.scores[test.idx, ] es una matriz con dos columnas (control, treated)
stats.hoja2 <- aggregate(dr.scores,
                        by = list(leaf.node = hoja2),
                        FUN = function(x) c(mean = mean(x),
                                            se = sd(x)/sqrt(length(x))))
print(stats.hoja2,digits=2)

#Construimos intervalos de confianza
# Datos
df_leaf2 <- data.frame(
  leaf.node    = c(8,9,10,11,12,13,14,15),
  control.mean = c(0.1940,0.2209,0.2415,0.2892,0.2894,0.3205,0.5154,0.1926),
  control.se   = c(0.0100,0.0065,0.0114,0.0143,0.0230,0.0402,0.0302,0.1251),
  treated.mean = c(0.2251,0.1968,0.2086,0.3164,0.3459,0.2929,0.3629,0.5321),
  treated.se   = c(0.0107,0.0062,0.0110,0.0152,0.0186,0.0415,0.0221,0.1022)
)

# Calcular diferencias y IC95%
  df_leaf2 <- df_leaf2 %>%
    mutate(
      diff       = treated.mean - control.mean,
      diff.se    = sqrt(control.se^2 + treated.se^2),   # asumiendo independencia
      diff.lower = diff - 1.96*diff.se,
      diff.upper = diff + 1.96*diff.se
    )
  
  print(df_leaf2[, c("leaf.node","diff","diff.lower","diff.upper")])


save.image("Policy learning Mexico.RData")



