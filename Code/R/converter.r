# Water Quality Data Format Converter
# -----------------------------------
# Author: A.J. Brown
# Position: Agricultural Data Scientist
# Email: Ansley.Brown@colostate.edu

# Description:
# This script provides functionalities to convert between new and old water 
# quality data formats. It's designed as both a utility tool and an educational 
# resource to showcase data conversion methodologies in R.

# example usage
# converted_data <- convert_old_to_new(old_data, format_dictionary_updated, old_cols)
# converted_data <- convert_new_to_old(new_data, format_dictionary_updated, old_cols)


# TODO:
    # test all functions since this was drafted in ChatGPT
    # Clean old data
        # needs initial testing
    # New to old conversion
        # needs initial testing
    # Old to new conversion
        # continue diagnosis as to why it shows up in a long-ish format
    # column name mapping
        # needs initial testing

# Load necessary libraries
library(tidyverse)

# Import data
old_data <- read.csv('Example Data/old_data_format.csv', skip = 1)
new_data <- read.csv('Example Data/new_data_format.csv')
old_cols <- c('Location', 'Date', 'Irr/Storm', 'Station', 'Dup', 'event', 'ID', 'op',
              'no2', 'no3', 'tkn', 'tp', 'selenium (mg/L)', 'TSS', 'E COLI', 'fecal',
              'tss', 'Flow', 'OP', 'NO3', 'NH4', 'TKN', 'TP', 'E COLI.1', 'fecal.1',
              'notes')
new_cols <- c('sample.id', 'lab.id.x', 'method', 'cas.number', 'analyte', 'result',
              'units', 'dilution', 'result.reported.to', 'mdl', 'rl', 'report.basis',
              'percent.moisture', 'percent.solid', 'non.detect', 'duplicate',
              'location.name', 'treatment.name', 'method.name', 'event.type',
              'event.count', 'lab.id.y', 'matrix', 'collected', 'received', 'hold',
              'flag')


# Clean old data
clean_old_data <- function(old_df) {
  # Strip trailing spaces from column names in old_data
  names(old_df) <- str_trim(names(old_df))
  
  # If there's a 'Rep' column, rename it to 'Dup'.
  if ("Rep" %in% names(old_df)) {
    names(old_df)[names(old_df) == "Rep"] <- "Dup"
  }
  
  # Convert values in 'Dup' column from "1" to "N" and "2" to "Y".
  old_df$Dup <- ifelse(old_df$Dup == "1", "N", 
                       ifelse(old_df$Dup == "2", "Y", old_df$Dup))
  
  # Identify duplicates and fill into Dup column
  old_df$Dup <- ifelse(str_detect(old_df$ID, "-D"), TRUE, FALSE)
  
  # Identify NA values and replace
  old_df <- old_df %>%
    mutate(across(everything(), ~na_if(., c("NA", "U", "ND", "nan", "NAN", "N/A", ""))))
  
  # Correct MT, ST, CT, and IN to be MT1, ST1, CT1, and INF, respectively
  old_df$Station <- recode(old_df$Station, "MT" = "MT1", "ST" = "ST1", "CT" = "CT1", "IN" = "INF")
  
  # Correct E COLI to be e coli
  old_df$op <- recode(old_df$op, "E COLI" = "e coli")
  
  return(old_df)
}

# Create dictionary to map equivalent columns and analyte names between formats
format_dictionary_updated <- list(
  op = 'Phosphorus, Total Orthophosphate (as P)',
  no2 = 'Nitrogen, Nitrite  (As N)',
  no3 = 'Nitrogen, Nitrate (As N)',
  tkn = 'Nitrogen, Total Kjeldahl',
  tp = 'Phosphorus, Total (As P)',
  `selenium (mg/L)` = 'Selenium, Total',
  TSS = c('TSS', 'Suspended Solids (Residue, Non-Filterable)'),
  Location = 'location.name',
  Date = 'collected',
  `Irr/Storm` = 'event.count',
  Station = 'treatment.name',
  Dup = 'duplicate',
  ID = 'sample.id'
)

# Convert old data to new format
convert_old_to_new <- function(old_df, format_dict, output_csv = FALSE) {
  # Clean the old data format
  old_df <- clean_old_data(old_df)
  
  # Add method dataframe
  method_df <- tibble(
    method = c('M4500 NH3 D - TKN_W 4500NH3 D', 'E300 - 300_W', 'E300 - 300_W', 
               'SM4500P E - P-Ortho M4500P E', 'SM4500P E - P_TW M4500P E', 
               'E160.1 - TDS_W_160.1', 'E120.1 - COND_W',
               'SW9040C - pH_W_9040C', 'SW9040C - pH_W_9040C', 
               'E160.2 - TSS_W_160.2', '200.8'),
    cas.number = c('7727-37-9TKN', '14797-55-8', '14797-65-0', '7723-14-0', 
                   '7723-14-0', 'TDS', 'COND', 'PH', 'TEMP', 'TSS', 'SE'),
    analyte = c('Nitrogen, Total Kjeldahl', 'Nitrogen, Nitrate (As N)',
                'Nitrogen, Nitrite  (As N)', 
                'Phosphorus, Total Orthophosphate (as P)', 
                'Phosphorus, Total (As P)', 
                'Total Dissolved Solids (Residue, Filterable)',
                'EC', 'pH', 'Temp Deg C @pH', 'TSS', 'Selenium, Total'),
    mdl = c(0.1, 0.15, 0.15, 0.01, 0.02, 5, 5, 0.1, 0, 2.5, 0.2),
    rl = c(0.5, 0.5, 0.5, 0.05, 0.05, 10, 5, 0.1, 0, 2.5, 0.2)
  )
  
  # Melt the old dataframe to convert analyte columns to rows
  melted_data <- old_df %>%
    pivot_longer(cols = names(old_df)[!(names(old_df) %in% names(format_dict))],
                 names_to = "analyte", values_to = "result")
  
  # Map the old analyte names to the new ones using format_dict
  melted_data$analyte <- map_chr(melted_data$analyte, ~format_dict[[.x]][1])
  
  # Add default values or calculate new values for non-intersecting columns
  melted_data <- melted_data %>%
    mutate(
      units = case_when(
        analyte == 'Selenium, Total' ~ "ug/L",
        analyte == 'EC' ~ "umhos/cm",
        analyte == 'pH' ~ "pH",
        analyte == 'Temp Deg C @pH' ~ "Celcius",
        TRUE ~ "mg/L"
      ),
      non.detect = result == 0
    )
  
  # Merge with method_df to add method and cas.number columns
  merged_data <- left_join(melted_data, method_df, by = "analyte")
  
  # Rename columns based on format_dict for consistency
  names(merged_data) <- map_chr(names(merged_data), ~ifelse(.x %in% names(format_dict), format_dict[[.x]], .x))
  
  # Ensure all columns from the new format are present
  for (col in names(new_data)) {
    if (!(col %in% names(merged_data))) {
      merged_data[[col]] <- NA
    }
  }
  
  # Export to csv if output_csv is TRUE
  if (output_csv) {
    write_csv(merged_data, 'Output/old_to_new_data_R.csv')
  }
  
  return(merged_data)
}

# Convert new data to old format
convert_new_to_old <- function(new_df, format_dict, old_cols, output_csv = FALSE) {
  # Pivot new data so each analyte becomes a column
  pivoted_new_data <- new_df %>%
    group_by(sample.id) %>%
    pivot_wider(names_from = analyte, values_from = result)
  
  # Create a dataframe with unique sample.id values and other non-analyte columns
  unique_sample_data <- new_df %>%
    select(sample.id, location.name, collected, event.type, treatment.name, duplicate) %>%
    distinct()
  
  # Merge unique_sample_data with pivoted data
  merged_new_data <- left_join(unique_sample_data, 
                               pivoted_new_data, 
                               by = "sample.id")
  
  # Create a reverse mapping from old to new format
  reverse_format_dict <- list()
  for (key in names(format_dict)) {
    if (is.character(format_dict[[key]])) {
      reverse_format_dict[format_dict[[key]]] <- key
    } else {
      for (item in format_dict[[key]]) {
        reverse_format_dict[item] <- key
      }
    }
  }
  
  # Rename columns to map from new format back to old format
  names(merged_new_data) <- map_chr(names(merged_new_data), ~ifelse(.x %in% names(reverse_format_dict), reverse_format_dict[[.x]], .x))
  
  # Check if 'Dup' column exists and replace its values
  if ("Dup" %in% names(merged_new_data)) {
    merged_new_data$Dup <- ifelse(merged_new_data$Dup == TRUE, "Y", "N")
  }
  
  # Ensure all columns from the old format are present
  for (col in old_cols) {
    if (!(col %in% names(merged_new_data))) {
      merged_new_data[[col]] <- NA
    }
  }
  
  # Retain the order of columns as in the old format
  converted_data <- merged_new_data[, old_cols, drop = FALSE]

  # Export to csv if output_csv is TRUE
  if (output_csv) {
    write_csv(df_compressed, 'Output/new_to_old_data_R.csv')
  }
  
  return(converted_data)
}
converted_data <- convert_new_to_old(new_data, 
                    format_dictionary_updated, 
                    old_cols,
                    output_csv = TRUE)
View(converted_data)




# Diagnostic function to check the conversion
report_non_overlapping_columns <- function(df1, df2) {
  columns_df1 <- names(df1)
  columns_df2 <- names(df2)
  
  unique_to_df1 <- setdiff(columns_df1, columns_df2)
  unique_to_df2 <- setdiff(columns_df2, columns_df1)
  intersecting_columns <- intersect(columns_df1, columns_df2)
  
  cat("Column names unique to df1:", unique_to_df1, "\n")
  cat("Column names unique to df2:", unique_to_df2, "\n")
  cat("Column names that intersect:", intersecting_columns, "\n")
}
