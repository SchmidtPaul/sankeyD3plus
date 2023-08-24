#' Save a Sankey diagram to an HTML or PNG file
#'
#' Save a Sankey diagram created via \code{sankeyNetwork()} to an HTML or PNG
#' file. HTML files are created via \code{htmlwidgets::saveWidget()}.
#' PNG files are converted from HTML files via \code{webshot::webshot()}.
#'
#' @param network Network to save, i.e. result of \code{sankeyNetwork()}.
#' @param folder_path Path to the destination folder.
#' @param file_name File name without file extension.
#' @param png Should a png file be created and/or immediately opened? Can be either \code{"none"}, \code{"create"} or \code{"open"}.
#' @param html Should an html file be created and/or immediately opened? Can be either \code{"none"}, \code{"create"} or \code{"open"}.
#' @param selfcontained Passed to \code{htmlwidgets::saveWidget()}. Whether to save the HTML as a single self-contained file (with external resources base64 encoded) or a file with external resources placed in an adjacent directory. TRUE by default, but note that this does not always seem to work.
#' @param vwidth Passed to \code{webshot::webshot()}. Viewport width in pixels. Defaults to network$width, i.e. the width that was set in \code{sankeyNetwork()}.
#' @param vheight Passed to \code{webshot::webshot()}. Viewport height in pixels. Defaults to network$height, i.e. the height that was set in \code{sankeyNetwork()}.
#' @param zoom Passed to \code{webshot::webshot()}. Zoom factor. 1 means actual size, 2 means 50% zoom, etc.
#' @param delay Passed to \code{webshot::webshot()}. Time to delay before taking webshot, in seconds.
#'
#' @export
saveNetwork <- function(network,
                        folder_path = NULL,
                        file_name = "temp",
                        png = "create",
                        html = "none",
                        vwidth = network$width,
                        vheight = network$height,
                        zoom = 5,
                        delay = 0.5,
                        selfcontained = TRUE) {

  # Default folder path
  if (is.null(folder_path)) {
    if (requireNamespace("here", quietly = TRUE)) {
      folder_path <- here::here()
    } else {
      stop("Either provide a folder path or install the 'here' package so that the default folder path can be set to here::here().")
    }
  }

  # Check if at least one file should be created
  if (html == "none" && png == "none") {
    stop("Both 'html' and 'png' are set to 'none' so that nothing is being exported.")
  }

  # Full file paths
  file_html <- file.path(folder_path, paste0(file_name, ".html"))
  file_png  <- file.path(folder_path, paste0(file_name, ".png"))

  htmlwidgets::saveWidget(widget = network,
                          file = file_html,
                          selfcontained = selfcontained)

  # Convert HTML to PNG if required
  if (png %in% c("create", "open")) {
    if (!requireNamespace("webshot", quietly = TRUE)) {
      stop("The 'webshot' package is required to save the graph as a PNG file. Please install it with install.packages('webshot').")
    }

    webshot::webshot(
      url = file_html,
      file = file_png,
      delay = delay,
      vwidth = vwidth,
      vheight = vheight,
      zoom = zoom
    )
  }

  # Open files
  if (html == "open") {
    system(paste0('open "', file_html, '"'))
  }

  if (png == "open") {
    system(paste0('open "', file_png, '"'))
  }

  # Cleanup HTML if necessary
  if (html == "none") {
    file.remove(file_html)
    folder_html <- sub(".html$", "_files", file_html)
    if (dir.exists(folder_html)) {
      unlink(folder_html, recursive = TRUE)
    }
  }
}
