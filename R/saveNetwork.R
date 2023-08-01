#' Save a Sankey diagram to an HTML or PNG file
#'
#' Save a Sankey diagram created via \code{sankeyNetwork()} to an HTML or PNG
#' file. The HTML can include its dependencies in an adjacent directory or can
#' bundle all dependencies into the HTML file (via base64 encoding). PNG files
#' are converted from HTML using the webshot package.
#'
#' @param network Network to save, i.e. result of \code{sankeyNetwork()}.
#' @param file file to be saved - either html or png.
#' @param vwidth Viewport width in pixels. Defaults to network$width.
#' @param vheight Viewport height in pixels. Defaults to network$height.
#' @param zoom Zoom factor. 1 means actual size, 2 means 50% zoom, etc.
#' @param delay Time to delay before taking webshot, in seconds.
#'
#' @inheritParams htmlwidgets::saveWidget
#'
#' @export
saveNetwork <-
  function(network,
           file,
           selfcontained = TRUE,
           vwidth = network$width,
           vheight = network$height,
           zoom = 5,
           delay = 1) {
    file_ext <- regmatches(file, regexpr("\\.\\w+$", file))

    # Save as HTML
    htmlwidgets::saveWidget(network, file, selfcontained)

    if (file_ext == ".png") {
      # Ensure the webshot package is loaded
      if (!requireNamespace("webshot", quietly = TRUE)) {
        stop("The 'webshot' package is required to save the graph as a PNG file. Please install it with install.packages('webshot').")
      }

      png_file <- sub(".html$", ".png", file)

      webshot::webshot(
        file,
        png_file,
        delay = delay,
        vwidth = vwidth,
        vheight = vheight,
        zoom = zoom
      )

      # Delete the HTML file
      file.remove(file)
    } else if (file_ext != ".html") {
      stop("Unsupported file extension. Please use '.html' or '.png'.")
    }
  }
