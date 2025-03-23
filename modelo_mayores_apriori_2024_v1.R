library(arules)
library(arulesViz)
library(dplyr)
library(readr)
library(stringr)
library(forcats)

# ========================== #
# Parámetros configurables   #
# ========================== #

input_file_name <- "2024_MAYORES_UNIFICADOS.csv"
input_folder <- "/path/a/tu/carpeta"
min_support_abs <- 2
min_conf <- 0.85
min_rule_length <- 2

relevant_rules <- list(
  list(predicts = "cuenta_contable", exclude_from_lhs = "actividad"),
  list(predicts = "actividad", exclude_from_lhs = "cuenta_contable")
)

# ========================== #
# Funciones auxiliares       #
# ========================== #

handle_error <- function(step, e) {
  cat(paste("Error en", step, ":", conditionMessage(e), "\n"))
  stop(e)
}

cargar_y_preparar_datos <- function(file_path) {
  cat("Cargando dataset desde:", file_path, "\n")
  data <- read_delim(file_path, delim = ";", col_types = cols(.default = "c"))
  
  cat("Normalizando nombres de columnas...\n")
  colnames(data) <- tolower(str_replace_all(colnames(data), " ", "_"))
  
  cat("Limpiando datos...\n")
  data <- data %>% mutate(across(everything(), ~na_if(.x, "0")))
  data[is.na(data)] <- ""
  
  cat("Convirtiendo columnas a factores...\n")
  data <- data %>% mutate(across(everything(), as.factor))
  
  if (nrow(data) < min_support_abs) {
    stop(paste("El dataset tiene solo", nrow(data), "filas. Debe tener al menos", min_support_abs))
  }
  
  cat("Preparando datos como transacciones...\n")
  transactions_matrix <- as(data, "transactions")
  
  list(data = data, transactions = transactions_matrix)
}

ejecutar_apriori <- function(transactions_matrix, support_rel, conf, minlen) {
  cat("Ejecutando Apriori con soporte relativo:", support_rel, "\n")
  rules <- apriori(transactions_matrix, parameter = list(supp = support_rel, conf = conf, minlen = minlen))
  cat("Apriori ejecutado. Total de reglas generadas:", length(rules), "\n")
  
  cat("Eliminando reglas redundantes...\n")
  rules <- rules[!is.redundant(rules)]
  cat("Reglas después de eliminar redundancias:", length(rules), "\n")
  
  return(rules)
}

filtrar_reglas_relevantes <- function(rules, relevant_rules) {
  cat("Filtrando reglas relevantes...\n")
  filtered <- list()
  for (rule_def in relevant_rules) {
    cat("Filtrando reglas que predicen", rule_def$predicts, "sin", rule_def$exclude_from_lhs, "en el antecedente...\n")
    subset_rules <- subset(rules, rhs %pin% rule_def$predicts & !lhs %pin% rule_def$exclude_from_lhs)
    cat("Reglas encontradas para", rule_def$predicts, ":", length(subset_rules), "\n")
    filtered[[rule_def$predicts]] <- subset_rules
  }
  return(filtered)
}

construir_dataframe <- function(filtered_rules_list, total_rows) {
  cat("Construyendo dataframe final...\n")
  filtered_non_empty <- Filter(function(x) inherits(x, "rules") && length(x) > 0, filtered_rules_list)
  
  if (length(filtered_non_empty) == 0) {
    cat("No se encontraron reglas luego del filtrado.\n")
    return(data.frame(lhs = character(), rhs = character(), confidence = numeric(), lift = numeric(), count = integer()))
  }
  
  combined_rules <- do.call("c", unname(filtered_non_empty))
  
  lhs_labels <- labels(lhs(combined_rules), itemSep = ",", setStart = "", setEnd = "")
  rhs_labels <- labels(rhs(combined_rules), itemSep = ",", setStart = "", setEnd = "")
  
  quality_vals <- quality(combined_rules)
  
  data.frame(
    lhs = lhs_labels,
    rhs = rhs_labels,
    confidence = round(quality_vals$confidence, 4),
    lift = round(quality_vals$lift, 4),
    count = round(quality_vals$support * total_rows)
  )
}

exportar_csv <- function(df, output_folder) {
  timestamp <- format(Sys.time(), "%y-%m-%d--%H_%M_%S")
  output_file <- file.path(output_folder, paste0("reglas_asoc_filtradas_", timestamp, ".csv"))
  write_delim(df, output_file, delim = "|")
  cat("Archivo exportado correctamente a:", output_file, "\n")
  cat("Abrí el archivo en Excel y usá 'Texto en columnas' con separador '|'\n")
}

# ========================== #
# Ejecución principal        #
# ========================== #

main <- function() {
  tryCatch({
    file_path <- file.path(input_folder, input_file_name)
    
    resultado <- cargar_y_preparar_datos(file_path)
    data <- resultado$data
    transactions <- resultado$transactions
    
    support_rel <- min_support_abs / nrow(data)
    rules <- ejecutar_apriori(transactions, support_rel, min_conf, min_rule_length)
    
    reglas_filtradas <- filtrar_reglas_relevantes(rules, relevant_rules)
    rules_df <- construir_dataframe(reglas_filtradas, nrow(data))
    
    exportar_csv(rules_df, input_folder)
    
  }, error = function(e) handle_error("main", e))
}

# Ejecutar el script
main()
