# Evidencia para la Política Pública: ML Causal y Priorización Territorial

Este repositorio contiene herramientas analíticas desarrolladas para fortalecer la toma de decisiones en el sector público. El enfoque principal es la transición de una gestión basada en intuición hacia una **gestión basada en evidencia**, utilizando técnicas avanzadas de ciencia de datos y aprendizaje de máquinas.

## 🚀 Contenido del Repositorio

### 1. Modelo de Priorización: Índice de Vulnerabilidad (Sistema de Cuidados)
**Archivo:** `priorizacion_manzanas.R`  
Desarrollo de un modelo híbrido para la identificación de zonas de atención prioritaria en el municipio de **Benito Juárez, Quintana Roo**, enfocado en el diseño de un Sistema Local de Cuidados.

* **Metodología:** Análisis de Componentes Principales (PCA) sobre 26 indicadores censales a nivel manzana (AGEB/Manzana).
* **Proceso:** Normalización de variables de cuidado (población infantil, adultos mayores, personas con discapacidad) y ponderación técnica basada en la varianza explicada.
* **Impacto:** Clasificación de las 30 zonas más críticas para la intervención urbana y social, permitiendo una asignación de presupuesto más eficiente y transparente.

### 2. Optimización de Programas: Policy Learning & Causal ML
**Archivo:** `policy_learning_causal.R`  
Implementación de algoritmos prescriptivos para maximizar el impacto social de programas públicos (ej. Microcréditos).

* **Técnica:** Estimación de efectos de tratamiento heterogéneos (CATE) mediante **Policy Trees** y **Doubly Robust Scores**.
* **Innovación:** El script no solo evalúa si un programa funciona, sino que identifica **a quién** se debe tratar. Compara modelos de profundidad 2 y 3 (árboles híbridos) para derivar reglas de asignación óptimas.
* **Validación:** Cálculo de intervalos de confianza por nodo terminal para asegurar la robustez estadística de las decisiones de política recomendadas.

---

## 🛠️ Tecnologías Utilizadas
* **Lenguaje:** R
* **Librerías Clave:** * `policytree` & `grf`: Inferencia causal y aprendizaje de reglas.
    * `FactoMineR` & `factoextra`: Análisis multivariado de vulnerabilidad.
    * `tidyverse` (`dplyr`, `ggplot2`): Manipulación y visualización de datos.

---

## 📈 Visualizaciones
*El análisis genera representaciones gráficas de los árboles de decisión y mapas de calor de componentes principales, herramientas fundamentales para comunicar resultados técnicos a tomadores de decisiones no técnicos.*

---

## 👤 Contacto
**José Manuel, PhD** *Especialista en Políticas Públicas y ML Causal.* Asesor de gobiernos subnacionales interesado en la transformación ética de la administración pública mediante tecnología.
