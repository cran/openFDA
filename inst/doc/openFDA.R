## ----include = FALSE----------------------------------------------------------
# save the built-in output hook
hook_output <- knitr::knit_hooks$get("output")

# set a new output hook to truncate text output
knitr::knit_hooks$set(output = function(x, options) {
  if (!is.null(n <- options$out.lines)) {
    x <- strsplit(x, split = "\n")[[1]]
    if (length(x) > n) {
      # truncate the output
      x <- c(head(x, n), "....\n")
    }
    x <- paste(x, collapse = "\n")
  }
  hook_output(x, options)
})

knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----load_openFDA-------------------------------------------------------------
library(openFDA)

## ----set_key------------------------------------------------------------------
set_api_key("tvzdUXoC3Yi21hhxtKKochJlQgm6y1Lr7uhmjcpT")

## ----example1-----------------------------------------------------------------
search <- openFDA(search = "", endpoint = "drug-event", limit = 1)
search

## ----example2_json------------------------------------------------------------
json <- httr2::resp_body_json(search)

## ----example_2a_json_meta-----------------------------------------------------
json$meta

## ----example_2b_json_results, out.lines = 10----------------------------------
json$results

## ----example_3_count----------------------------------------------------------
count <- openFDA(search = "",
                 endpoint = "drug-drugsfda",
                 limit = 3,
                 count = "openfda.manufacturer_name.exact") |>
  httr2::resp_body_json()
count$results

## ----example3a_single_search_term_unrefined, out.lines = 15-------------------
search_unrefined <- openFDA(
  search = "openfda.pharm_class_epc:thiazide diuretic",
  endpoint = "drug-drugsfda",
  limit = 1
)
httr2::resp_body_json(search_unrefined)$meta$results$total

## ----example3a_single_search_term_refined, out.lines = 15---------------------
search_refined <- openFDA(
  search = "openfda.pharm_class_epc:\"thiazide diuretic\"",
  endpoint = "drug-drugsfda",
  limit = 1
)
httr2::resp_body_json(search_refined)$meta$results$total

## ----example 3b_supply_scalar_search_term-------------------------------------
search_term <- "openfda.manufacturer_name:Walmart+AND+openfda.route=oral"
search <- openFDA(search = search_term,
                  limit = 5,
                  endpoint = "drug-drugsfda")
json <- httr2::resp_body_json(search)
purrr::map(json$results, .f = \(x) {
  purrr::pluck(x, "openfda", "brand_name", 1)
})

## ----example3b_format_scalar_search_term, out.lines = 15----------------------
search <- openFDA(search = c("openfda.generic_name" = "amoxicillin"),
                  endpoint = "drug-drugsfda")
httr2::resp_body_json(search)$meta$results$total

## ----example3b_format_nonscalar_search_term, out.lines = 15-------------------
search <- openFDA(search = c("openfda.generic_name" = "amoxicillin",
                             "openfda.route" = "oral"),
                  endpoint = "drug-drugsfda", limit = 1)
httr2::resp_body_json(search)$meta$results$total

## ----example3b_format_nonscalar_search_term_with_and, out.lines = 15----------
search_term <- format_search_term(c("openfda.generic_name" = "amoxicillin",
                                    "openfda.route" = "oral"),
                                  mode = "and")
search <- openFDA(search = search_term,
                  endpoint = "drug-drugsfda", limit = 1)
httr2::resp_body_json(search)$meta$results$total

## ----example4_wildcards, out.lines = 15---------------------------------------
search_term <- format_search_term(c("openfda.generic_name" = "*sartan"),
                                  exact = FALSE)
search <- openFDA(search = search_term,
                  count = "openfda.manufacturer_name.exact",
                  endpoint = "drug-drugsfda",
                  limit = 5)
terms <- purrr::map(
  .x = httr2::resp_body_json(search)$results,
  .f = purrr::pluck("term")
)
counts <- purrr::map(
  .x = httr2::resp_body_json(search)$results,
  .f = purrr::pluck("count")
)

setNames(counts, terms)

