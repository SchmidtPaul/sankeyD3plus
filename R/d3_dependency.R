#' D3 v7 Dependency for sankeyD3plus
#'
#' This function provides the D3.js v7 dependency for sankeyD3plus.
#' If you want to use the latest D3 v7, you need to download it manually.
#'
#' @details
#' To use D3 v7:
#' 1. Download d3.v7.min.js from https://unpkg.com/d3@7.9.0/dist/d3.min.js
#' 2. Place it in inst/htmlwidgets/lib/d3/d3.v7.min.js
#' 3. The package will automatically use it
#'
#' If D3 v7 is not found, the package falls back to d3r::d3_dep_v4()
#'
#' @return An htmlDependency object
#' @keywords internal
#' @noRd
d3_dep_v7 <- function() {
  # Path to D3 v7 in the package
  d3v7_path <- system.file("htmlwidgets/lib/d3", package = "sankeyD3plus")

  # Check if D3 v7 file exists
  d3v7_file <- file.path(d3v7_path, "d3.v7.min.js")

  if (file.exists(d3v7_file)) {
    # Use D3 v7
    htmltools::htmlDependency(
      name = "d3",
      version = "7.9.0",
      src = c(file = d3v7_path),
      script = "d3.v7.min.js"
    )
  } else {
    # Fall back to D3 v4 from d3r package
    message("D3 v7 not found. Using D3 v4 from d3r package. See ?d3_dep_v7 for upgrade instructions.")
    d3r::d3_dep_v4()
  }
}

#' Get D3 dependency (v7 if available, otherwise v4)
#'
#' @return An htmlDependency object for D3
#' @keywords internal
#' @noRd
d3_dep <- function() {
  d3_dep_v7()
}
