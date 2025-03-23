# 📊 Modelo Apriori para movimientos contables

Este repositorio contiene un script desarrollado en **R** para generar **reglas de asociación** a partir de movimientos contables, utilizando el algoritmo **Apriori** disponible en el paquete `arules`.

---

## ⚙️ Funcionalidades

El proceso incluye:

- Limpieza automática del dataset (eliminación de valores vacíos y ceros).
- Conversión automática de todas las columnas a factores.
- Transformación del dataset al formato `transactions` necesario para Apriori.
- Ejecución del algoritmo Apriori con soporte relativo calculado dinámicamente.
- Filtrado automático de reglas redundantes.
- Extracción personalizada de reglas relevantes según configuración previa.
- Exportación automática de resultados en formato CSV (`|` como separador) incluyendo un timestamp.
- Gestión y reporte detallado de errores.

---

## 📌 Requisitos de instalación

- **R versión 4.0** o superior.
- Paquetes necesarios:

```r
install.packages(c("arules", "arulesViz", "dplyr", "readr", "stringr", "forcats"))
```

---

## 🛠 Parámetros personalizables

Puedes configurar estos parámetros al inicio del script:

- **`input_file_name`**: Nombre del archivo CSV de entrada.
- **`input_folder`**: Ruta al directorio que contiene el archivo.
- **`min_support_abs`**: Soporte absoluto mínimo requerido.
- **`min_conf`**: Confianza mínima para considerar una regla válida.
- **`min_rule_length`**: Longitud mínima de las reglas generadas.
- **`relevant_rules`**: Especifica reglas a extraer con campos a predecir y campos que deseas excluir del antecedente.

Ejemplo:

```r
relevant_rules <- list(
  list(predicts = "cuenta_contable", exclude_from_lhs = "actividad"),
  list(predicts = "actividad", exclude_from_lhs = "cuenta_contable")
)
```

---

## 📁 Formato de salida

El resultado es exportado automáticamente a un archivo CSV en la misma carpeta del archivo de entrada, nombrado según el patrón:

```
reglas_asoc_filtradas_yy-mm-dd--HH_MM_SS.csv
```

El archivo contiene:

- **`lhs`**: Antecedente de la regla.
- **`rhs`**: Consecuente de la regla.
- **`confidence`**: Confianza de la regla (4 decimales).
- **`lift`**: Métrica de independencia (4 decimales).
- **`count`**: Cantidad absoluta de transacciones que soportan la regla.

Para visualizar adecuadamente en Excel, usa la opción **"Texto en columnas"** con separador `|`.

---

## 🛑 Manejo de errores

El script incluye manejo de errores, proporcionando mensajes claros y detallados sobre en qué etapa se produjo la falla.

---

## 👤 Autor

[Gonzalo Ruiz Camauer](https://github.com/gonrc/)  
✉️ [recipes_ficus_0s@icloud.com](mailto:recipes_ficus_0s@icloud.com)

