
library(arules)
library(arulesViz)
library(dplyr)
library(readr)
library(stringr)
library(forcats)

# ========================== #
# Parámetros configurables   #
# ========================== #

# Nombre del archivo de entrada (solo el nombre, sin el path)
input_file_name <- "2024_MAYORES_UNIFICADOS.csv"

# Path a la carpeta donde está el archivo de entrada (sin barra final)
input_folder <- "/path/a/tu/carpeta"

# Soporte absoluto mínimo: la regla debe aparecer en al menos estas transacciones
min_support_abs <- 2

# Confianza mínima para las reglas
min_conf <- 0.85

# Longitud mínima de las reglas
min_rule_length <- 2

# Reglas relevantes a extraer: qué campo se quiere predecir (rhs) y qué campo excluir del antecedente (lhs)
relevant_rules <- list(
  list(predicts = "cuenta_contable", exclude_from_lhs = "actividad"),
  list(predicts = "actividad", exclude_from_lhs = "cuenta_contable")
)

# ====================== #
# Manejo de errores      #
# ====================== #
handle_error <- function(step, e) {
  cat(paste("Error en", step, ":", conditionMessage(e), "\n"))
  stop(e)
}

tryCatch({
  # Cargar el dataset
  file_path <- file.path(input_folder, input_file_name)
  cat("Cargando dataset desde:", file_path, "\n")
  data <- read_delim(file_path, delim = ";", col_types = cols(.default = "c"))
  cat("Dataset cargado correctamente.\n")
}, error = function(e) handle_error("Carga del dataset", e))

tryCatch({
  # Normalizar nombres de columnas
  cat("Normalizando nombres de columnas...\n")
  colnames(data) <- tolower(str_replace_all(colnames(data), " ", "_"))
  cat("Nombres de columnas normalizados.\n")
}, error = function(e) handle_error("Normalización de columnas", e))

tryCatch({
  # Limpieza de datos
  cat("Limpiando datos...\n")
  data <- data %>% mutate(across(everything(), ~na_if(.x, "0")))
  data[is.na(data)] <- ""
  cat("Limpieza completada.\n")
}, error = function(e) handle_error("Limpieza de datos", e))

tryCatch({
  # Conversión a factores
  cat("Convirtiendo columnas a factores...\n")
  data <- data %>% mutate(across(everything(), as.factor))
  cat("Conversión a factores completada.\n")
}, error = function(e) handle_error("Conversión a factores", e))

tryCatch({
  # Validación de soporte mínimo
  if (nrow(data) < min_support_abs) {
    stop(paste("El dataset tiene solo", nrow(data), "filas. Debe tener al menos", min_support_abs, "para generar reglas."))
  }
}, error = function(e) handle_error("Validación de cantidad de transacciones", e))

tryCatch({
  # Conversión a formato transaccional
  cat("Preparando datos para transacciones...\n")
  transactions_matrix <- as(data, "transactions")
  cat("Datos preparados como transacciones.\n")
}, error = function(e) handle_error("Conversión a transacciones", e))

tryCatch({
  # Apriori + eliminación de redundantes
  support_rel <- min_support_abs / nrow(data)
  cat("Ejecutando Apriori con soporte relativo basado en", min_support_abs, "ocurrencias mínimas:", support_rel, "\n")
  
  rules <- apriori(transactions_matrix, parameter = list(supp = support_rel, conf = min_conf, minlen = min_rule_length))
  cat("Apriori ejecutado. Total de reglas generadas:", length(rules), "\n")
  
  cat("Eliminando reglas redundantes...\n")
  rules <- rules[!is.redundant(rules)]
  cat("Reglas restantes después de eliminar redundancias:", length(rules), "\n")
}, error = function(e) handle_error("Ejecución de Apriori", e))

tryCatch({
  # Filtrar reglas relevantes definidas por parámetros
  cat("Filtrando reglas relevantes...\n")
  filtered_rules_list <- list()
  
  for (rule_def in relevant_rules) {
    cat("Filtrando reglas que predicen", rule_def$predicts, "sin", rule_def$exclude_from_lhs, "en el antecedente...\n")
    filtered <- subset(rules, rhs %pin% rule_def$predicts & !lhs %pin% rule_def$exclude_from_lhs)
    filtered_rules_list[[rule_def$predicts]] <- filtered
    cat("Reglas encontradas para", rule_def$predicts, ":", length(filtered), "\n")
  }
}, error = function(e) handle_error("Filtrado de reglas", e))

tryCatch({
  # Construir dataframe con todas las reglas filtradas
  cat("Extrayendo reglas finales...\n")
  
  # Filtrar reglas no vacías y del tipo correcto
  filtered_rules_non_empty <- Filter(function(x) inherits(x, "rules") && length(x) > 0, filtered_rules_list)
  
  if (length(filtered_rules_non_empty) == 0) {
    rules_df <- data.frame(lhs = character(), rhs = character(), confidence = numeric(), lift = numeric(), count = integer())
    cat("No se encontraron reglas luego del filtrado.\n")
  } else {
    combined_rules <- do.call("c", unname(filtered_rules_non_empty))
    
    lhs_labels <- labels(lhs(combined_rules), itemSep = ",", setStart = "", setEnd = "")
    rhs_labels <- labels(rhs(combined_rules), itemSep = ",", setStart = "", setEnd = "")
    
    confidence_vals <- quality(combined_rules)$confidence
    lift_vals <- quality(combined_rules)$lift
    support_vals <- quality(combined_rules)$support
    
    rules_df <- data.frame(
      lhs = lhs_labels,
      rhs = rhs_labels,
      confidence = round(confidence_vals, 4),
      lift = round(lift_vals, 4),
      count = round(support_vals * nrow(data))
    )
    cat("Reglas extraídas correctamente.\n")
  }
}, error = function(e) handle_error("Extracción de reglas", e))

tryCatch({
  # Exportar a CSV con timestamp
  cat("Exportando a CSV con separador '|'\n")
  timestamp <- format(Sys.time(), "%y-%m-%d--%H_%M_%S")
  output_file <- file.path(input_folder, paste0("reglas_asoc_filtradas_", timestamp, ".csv"))
  write_delim(rules_df, output_file, delim = "|")
  cat("Reglas exportadas correctamente a:", output_file, "\n")
  cat("Abrí el archivo en Excel y usá 'Texto en columnas' con separador '|'\n")
}, error = function(e) handle_error("Exportación a CSV", e))



