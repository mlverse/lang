library(tidyverse)

iso <- read_csv("utils/iso_639-1.csv")

codes <- iso |> 
  mutate(
    name = str_to_lower(name),
    code = `639-1`
  ) |> 
  select(name, code)

clean_codes <- codes |> 
  mutate(name = str_replace(name, "\\(farsi\\)", ", farsi")) |> 
  mutate(name = str_remove(name, "\\(tonga islands\\)")) |> 
  mutate(name = str_remove(name, "\\(saṁskṛta\\)")) |> 
  mutate(name = str_remove(name, "\\(eastern\\)")) |> 
  mutate(name = str_remove(name, "\\(marāṭhī\\)")) |> 
  separate_longer_delim(name, ",") |> 
  mutate(name = str_remove(name, "\\(modern\\)")) |> 
  mutate(name = str_remove(name, "standard")) |> 
  mutate(name = str_trim(name)) |> 
  arrange(code) |> 
  group_by(name, code) |> 
  summarise() |> 
  group_by(code) |> 
  mutate(number = row_number()) |> 
  ungroup() |> 
  arrange(code)

write_rds(clean_codes, "inst/iso/codes.rds")
