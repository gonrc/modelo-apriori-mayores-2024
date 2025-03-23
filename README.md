# Modelo Apriori para movimientos contables

## 📋 Descripción

Este repositorio contiene un script en R diseñado para generar **reglas de asociación** a partir de movimientos contables utilizando el algoritmo **Apriori** del paquete `arules`. El script está optimizado para organizaciones que registran transacciones categóricas (proveedor, usuario, actividad, cuenta contable, etc.).

El script incluye:

- Limpieza de datos (eliminación de valores vacíos y ceros)
- Conversión automática de columnas a factores
- Transformación del dataset a formato `transactions`
- Ejecución del algoritmo Apriori con soporte relativo
- Filtrado de reglas redundantes
- Selección de reglas relevantes según parámetros configurables
- Exportación automática a CSV separado por `|` con timestamp
- Control y reporte detallado de errores

## 🛠 Requisitos

- R 4.0 o superior
- Paquetes: `arules`, `arulesViz`, `dplyr`, `readr`, `stringr`, `forcats`

Instalación recomendada:

```r
install.packages(c("arules", "arulesViz", "dplyr", "readr", "stringr", "forcats"))
```

## ⚙️ Parámetros personalizables

Al inicio del script se puede configurar:

- `input_file_name`: Nombre del archivo CSV de entrada.
- `input_folder`: Path donde se encuentra el archivo de entrada.
- `min_support_abs`: Soporte absoluto mínimo (cantidad mínima de transacciones).
- `min_conf`: Confianza mínima requerida para las reglas.
- `min_rule_length`: Longitud mínima que deben tener las reglas.
- `relevant_rules`: Lista con reglas específicas que deseas extraer (campos a predecir y campos excluidos).

## 📤 Salida

Genera un archivo CSV separado por `|` en la misma carpeta que el archivo de entrada. El nombre del archivo incluye un timestamp en el formato `yy-mm-dd--HH_MM_SS`. Contiene:

- `lhs`: Antecedente de la regla
- `rhs`: Consecuente de la regla
- `confidence`: Confianza de la regla (redondeado a 4 decimales)
- `lift`: Métrica de independencia (redondeado a 4 decimales)
- `count`: Número absoluto de transacciones que respaldan la regla

Es recomendable abrir este archivo en Excel usando la opción **"Texto en columnas"** con el separador `|`.

## 🛑 Manejo de errores

El script cuenta con un manejo de errores que identifica claramente el paso en el cual ocurrió una falla y proporciona mensajes detallados.

---

## 👤 Autor

[Gonzalo Ruiz Camauer](https://github.com/gonrc/)  
✉️ Contacto: recipes_ficus_0s@icloud.com

