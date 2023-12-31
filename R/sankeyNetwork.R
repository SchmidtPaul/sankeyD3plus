#' Shiny bindings for sankeyD3plus widgets
#'
#' Output and render functions for using sankeyD3plus widgets within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{"100\%"},
#'   \code{"400px"}, \code{"auto"}) or a number, which will be coerced to a
#'   string and have \code{"px"} appended.
#' @param expr An expression that generates a sankeyD3plus graph
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @importFrom htmlwidgets shinyWidgetOutput
#' @importFrom htmlwidgets shinyRenderWidget
#'
#' @name sankeyD3plus-shiny
NULL

#' Create a D3 JavaScript Sankey diagram
#'
#' @param Links a data frame object with the links between the nodes. It should
#' have include the \code{Source} and \code{Target} for each link. An optional
#' \code{Value} variable can be included to specify the size (default is 1).
#' @param Nodes a data frame containing the node id and properties of the nodes.
#' If no ID is specified then the nodes must be in the same order as the
#' \code{Source} variable column in the \code{Links} data frame. Currently only
#' one grouping variable is allowed.
#' @param Source character string naming the network source variable in the
#' \code{Links} data frame.
#' @param Target character string naming the network target variable in the
#' \code{Links} data frame.
#' @param Value character string naming the variable in the \code{Links} data
#' frame for how far away the nodes are from one another.
#' @param NodeID character string specifying the node IDs in the \code{Nodes}.
#' data frame. Must be 0-indexed.
#' @param NodeGroup character string specifying the node groups in the
#' \code{Nodes}. Used to color the nodes in the network.
#' @param LinkGroup character string specifying the groups in the
#' \code{Links}. Used to color the links in the network.
#' @param NodePosX character specifying a column in the \code{Nodes} data
#' frame that specifies the 0-based ordering of the nodes along the x-axis.
#' @param NodePosY character specifying a column in the \code{Nodes} data
#' frame that specifies the 0-based ordering of the nodes along the y-axis.
#' @param NodeValue character specifying a column in the \code{Nodes} data
#' frame with the value/size of each node. If \code{NULL}, the value is
#' calculated based on the maximum of the sum of incoming and outoging
#' links
#' @param NodeColor character specifying a column in the \code{Nodes} data
#' frame with the color of each node. Overrides colourScale.
#' @param NodeFontColor character specifying a column in the \code{Nodes} data
#' frame with the color of the label of each node.
#' @param NodeFontSize character specifying a column in the \code{Nodes} data
#' frame with the size of the label of each node.
#' @param units character string describing physical units (if any) for Value
#' @param colourScale character string specifying the categorical colour
#' scale for the nodes. See
#' \url{https://github.com/mbostock/d3/wiki/Ordinal-Scales}.
#' @param fontSize numeric font size in pixels for the node text labels. Default is 12.
#' @param fontFamily font family for the node text labels. Default is 'Arial'.
#' @param fontColor font color for the node text labels.
#' @param nodeWidth numeric width of each node.
#' @param nodePadding numeric essentially influences the width height. By default, it's the same as the fontSize parameter.
#' @param nodeStrokeWidth numeric width of the stroke around nodes.
#' @param nodeCornerRadius numeric Radius for rounded nodes.
#' @param numberFormat number format in tooltips - see https://github.com/d3/d3-format for options. Default is ',.1f'.
#' @param margin an integer or a named \code{list}/\code{vector} of integers
#' for the plot margins. If using a named \code{list}/\code{vector},
#' the positions \code{top}, \code{right}, \code{bottom}, \code{left}
#' are valid.  If a single integer is provided, then the value will be
#' assigned to the right margin. Set the margin appropriately
#' to accomodate long text labels.
#' @param height numeric height for the network graph's frame area in pixels. Default is 500.
#' @param width numeric width for the network graph's frame area in pixels. Default is 800.
#' @param title character Title of plot, put in the upper-left corner of the Sankey
#' @param iterations numeric. Number of iterations in the diagramm layout for
#' computation of the depth (y-position) of each node. Note: this runs in the
#' browser on the client so don't push it too high.
#' @param align character Alignment of the nodes. One of 'right', 'left', 'justify', 'center', 'none'.
#' If 'none', then the labels of the nodes are always to the right of the node. Default is 'left'.
#' @param zoom logical value to enable (\code{TRUE}) or disable (\code{FALSE})
#' zooming
#' @param nodeLabelMargin numeric margin between node and label.
#' @param linkColor numeric Color of links.
#' @param linkOpacity numeric Opacity of links.
#' @param linkGradient boolean Add a gradient to the links?
#' @param dragX boolean Allow moving nodes along the x-axis? Default is FALSE.
#' @param dragY boolean Allow moving nodes along the y-axis? Default is TRUE.
#' @param nodeShadow boolean Add a shadow to the nodes?
#' @param xScalingFactor numeric Scale the computed x position of the nodes by this value.
#' @param xAxisDomain character[] If xAxisDomain is given, an axis with those value is
#' added to the bottom of the plot. Only sensible when also NodeXPos are given.
#' @param linkType character One of 'bezier', 'l-bezier', 'trapezoid', 'path1' and 'path2'.
#' @param orderByPath boolean Order the nodes vertically along a path - this layout only
#' works well for trees where each node has maximum one parent.
#' @param highlightChildLinks boolean Highlight all the links going right from a node or
#' link.
#' @param doubleclickTogglesChildren boolean Show/hide target nodes and paths to the left
#'  on double-click. Does not hide incoming links of target nodes, yet.
#' @param curvature numeric Curvature parameter for bezier links - between 0 and 1.
#' @param showNodeValues boolean Show values above nodes. Might require and increased node margin.
#' @param scaleNodeBreadthsByString Put nodes at positions relatively to string lengths -
#' only work well currently with align='none'
#' @param yOrderComparator Order nodes on the y axis by a custom function instead of ascending or
#' descending depth.
#'
#' @export
sankeyNetwork <- function(Links,
                          Nodes,
                          Source,
                          Target,
                          Value,
                          NodeID,
                          NodeGroup = NULL,
                          NodeColor = NULL,
                          NodePosX = NULL,
                          NodePosY = NULL,
                          NodeValue = NULL,
                          NodeFontColor = NULL,
                          NodeFontSize = NULL,
                          LinkGroup = NULL,
                          linkColor = "#A0A0A0",
                          units = "",
                          colourScale = NULL,
                          fontSize = 12,
                          fontFamily = "Arial",
                          fontColor = NULL,
                          nodeWidth = 15,
                          nodePadding = NULL,
                          nodeStrokeWidth = 1,
                          nodeCornerRadius = 0,
                          margin = NULL,
                          title = NULL,
                          numberFormat = ",.1f",
                          orderByPath = FALSE,
                          highlightChildLinks  = FALSE,
                          doubleclickTogglesChildren = FALSE,
                          xAxisDomain = NULL,
                          dragX = FALSE,
                          dragY = TRUE,
                          height = 500,
                          width = 800,
                          iterations = 32,
                          zoom = FALSE,
                          align = "left",
                          showNodeValues = TRUE,
                          linkType = "bezier",
                          curvature = .5,
                          nodeLabelMargin = 2,
                          linkOpacity = .5,
                          linkGradient = FALSE,
                          nodeShadow = FALSE,
                          scaleNodeBreadthsByString = FALSE,
                          xScalingFactor = 1,
                          yOrderComparator = NULL)
{
    # Deal with Links ---------------------------------------------------------
    # convert Links to data.frame
    Links <- as.data.frame(Links)
    assert_that(is.data.frame(Links), msg = "'as.data.frame(Links)' must be a data frame class object.")

    # if Source or Target are missing assume...
    # ...source is the first column
    if (missing(Source)){Source = 1}
    # ...target is the second column
    if (missing(Target)){Target = 2}

    # Check if data is zero indexed
    check_zero(Links[, Source], Links[, Target])

    # constrcut LinksDF
    LinksDF <- data.frame(source=Links[, Source], target = Links[, Target])

    # if missing, set values to 1
    if (missing(Value)) {
      LinksDF$value = 1
    } else {
      LinksDF$value <- Links[, Value]
    }

    # default colourScale
    colourScale <- as.character(JS("d3.scaleOrdinal().range(d3.schemeCategory20)"))

    # if linkColor is set to a column name in Links, use those color names
    if (linkColor %in% colnames(Links)) {

      LinkGroup <- linkColor

      # Check if all color names are valid (either named colors or HEX colors)
      colour_names <- unique(as.character(Links[, linkColor]))
      if (all(colour_names %in% grDevices::colors() | grepl("^#[0-9A-Fa-f]{6}$", colour_names))) {
        colourScale <- as.character(get_d3_colourScale(setNames(colour_names, colour_names)))
        LinksDF$group <- Links[, LinkGroup]
      } else {
        stop(paste0("You wrote 'linkColor = ", linkColor,
                    "' which is a column in your links. However, not all values in that column are valid color names or HEX color codes. ",
                    "Maybe use 'LinkGroup = ", linkColor, "' instead?"))
      }
    }


    # Deal with Nodes ---------------------------------------------------------
    # default Nodes = get_nodes_from_links(Links)
    if (missing(Nodes)) {
      Nodes <- get_nodes_from_links(
        Links = Links,
        source = Source,
        target = Target
      )
    }

    # convert Nodes to data.frame
    Nodes <- as.data.frame(Nodes)
    assert_that(is.data.frame(Nodes), msg = "'as.data.frame(Nodes)' must be a data frame class object.")

    # if NodeID is missing assume NodeID is the first column
    if (missing(NodeID)) {
      NodeID = 1
    }
    NodesDF <- data.frame(name=Nodes[, NodeID], stringsAsFactors = FALSE)

    # add node group if specified
    if (is.character(NodeGroup)) {
      NodesDF$group <- Nodes[, NodeGroup]
    }

    if (is.character(NodePosY)) {
      NodesDF$posY <- Nodes[, NodePosY]
      orderByPosY <- TRUE
    } else{
      orderByPosY <- FALSE
    }

    if (is.character(NodePosX)) {
      NodesDF$posX <- Nodes[, NodePosX]
    }

    if (is.character(NodeValue)) {
      NodesDF$value <- Nodes[, NodeValue]
    }

    if (is.character(NodeColor)) {
      NodesDF$color = Nodes[, NodeColor]
    }

    if (is.character(NodeFontSize)) {
      NodesDF$fontSize = Nodes[, NodeFontSize]
    }

    if (is.character(NodeFontColor)) {
      NodesDF$fontColor = Nodes[, NodeFontColor]
    }

    if (is.character(LinkGroup)) {
      LinksDF$group <- Links[, LinkGroup]
    }

    # Change nodePadding to fontSize if it is NULL
    if (is.null(nodePadding)) {
      nodePadding <- fontSize
    }

    margin <- margin_handler(margin)

    # create options
    options = list(
      NodeID = NodeID,
      NodeGroup = NodeGroup,
      LinkGroup = LinkGroup,
      orderByPosY = orderByPosY,
      colourScale = colourScale,
      fontSize = fontSize,
      fontFamily = fontFamily,
      fontColor = fontColor,
      nodeWidth = nodeWidth,
      nodePadding = nodePadding,
      nodeStrokeWidth = nodeStrokeWidth,
      nodeCornerRadius = nodeCornerRadius,
      dragX = dragX,
      dragY = dragY,
      numberFormat = numberFormat,
      orderByPath = orderByPath,
      units = units,
      margin = margin,
      iterations = iterations,
      zoom = zoom,
      linkType = linkType,
      curvature = curvature,
      highlightChildLinks = highlightChildLinks,
      doubleclickTogglesChildren = doubleclickTogglesChildren,
      showNodeValues = showNodeValues,
      align = align,
      xAxisDomain = xAxisDomain,
      title = title,
      nodeLabelMargin = nodeLabelMargin,
      linkColor = linkColor,
      linkOpacity = linkOpacity,
      linkGradient = linkGradient,
      nodeShadow = nodeShadow,
      scaleNodeBreadthsByString = scaleNodeBreadthsByString,
      xScalingFactor = xScalingFactor,
      yOrderComparator = yOrderComparator
    )

    # create widget
    htmlwidgets::createWidget(
      name = "sankeyNetwork",
      x = list(
        links = LinksDF,
        nodes = NodesDF,
        options = options
      ),
      width = width,
      height = height,
      sizingPolicy = htmlwidgets::sizingPolicy(padding = 10, browser.fill = TRUE),
      dependencies = list(d3r::d3_dep_v4(), sankey_dep()),
      package = "sankeyD3plus"
    )
}

#' @keywords internal
sankey_dep <- function() {
  filePath <- system.file("htmlwidgets/lib/d3-sankey/src", package = "sankeyD3plus")

  if (!file.exists(filePath)) {
    stop("File path not found: ", filePath)
  }

  htmltools::htmlDependency(
    name = "sankey",
    version = "0.1",
    src = c(file = filePath),
    script = "sankey.js"
  )
}


#' @rdname sankeyD3plus-shiny
#' @export
sankeyNetworkOutput <-
  function(outputId,
           width = "100%",
           height = "500px") {
    htmlwidgets::shinyWidgetOutput(outputId, "sankeyNetwork", width, height, package = "sankeyD3plus")
  }

#' @rdname sankeyD3plus-shiny
#' @export
renderSankeyNetwork <-
  function(expr,
           env = parent.frame(),
           quoted = FALSE) {
    if (!quoted) {expr <- substitute(expr)}
    htmlwidgets::shinyRenderWidget(expr, sankeyNetworkOutput, env, quoted = TRUE)
  }
