% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sankeyNetwork.R
\name{sankeyNetwork}
\alias{sankeyNetwork}
\title{Create a D3 JavaScript Sankey diagram}
\usage{
sankeyNetwork(
  Links,
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
  highlightChildLinks = FALSE,
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
  curvature = 0.5,
  nodeLabelMargin = 2,
  linkOpacity = 0.5,
  linkGradient = FALSE,
  nodeShadow = FALSE,
  scaleNodeBreadthsByString = FALSE,
  xScalingFactor = 1,
  yOrderComparator = NULL
)
}
\arguments{
\item{Links}{a data frame object with the links between the nodes. It should
have include the \code{Source} and \code{Target} for each link. An optional
\code{Value} variable can be included to specify the size (default is 1).}

\item{Nodes}{a data frame containing the node id and properties of the nodes.
If no ID is specified then the nodes must be in the same order as the
\code{Source} variable column in the \code{Links} data frame. Currently only
one grouping variable is allowed.}

\item{Source}{character string naming the network source variable in the
\code{Links} data frame.}

\item{Target}{character string naming the network target variable in the
\code{Links} data frame.}

\item{Value}{character string naming the variable in the \code{Links} data
frame for how far away the nodes are from one another.}

\item{NodeID}{character string specifying the node IDs in the \code{Nodes}.
data frame. Must be 0-indexed.}

\item{NodeGroup}{character string specifying the node groups in the
\code{Nodes}. Used to color the nodes in the network.}

\item{NodeColor}{character specifying a column in the \code{Nodes} data
frame with the color of each node. Overrides colourScale.}

\item{NodePosX}{character specifying a column in the \code{Nodes} data
frame that specifies the 0-based ordering of the nodes along the x-axis.}

\item{NodePosY}{character specifying a column in the \code{Nodes} data
frame that specifies the 0-based ordering of the nodes along the y-axis.}

\item{NodeValue}{character specifying a column in the \code{Nodes} data
frame with the value/size of each node. If \code{NULL}, the value is
calculated based on the maximum of the sum of incoming and outoging
links}

\item{NodeFontColor}{character specifying a column in the \code{Nodes} data
frame with the color of the label of each node.}

\item{NodeFontSize}{character specifying a column in the \code{Nodes} data
frame with the size of the label of each node.}

\item{LinkGroup}{character string specifying the groups in the
\code{Links}. Used to color the links in the network.}

\item{linkColor}{numeric Color of links.}

\item{units}{character string describing physical units (if any) for Value}

\item{colourScale}{character string specifying the categorical colour
scale for the nodes. See
\url{https://github.com/mbostock/d3/wiki/Ordinal-Scales}.}

\item{fontSize}{numeric font size in pixels for the node text labels. Default is 12.}

\item{fontFamily}{font family for the node text labels. Default is 'Arial'.}

\item{fontColor}{font color for the node text labels.}

\item{nodeWidth}{numeric width of each node.}

\item{nodePadding}{numeric essentially influences the width height. By default, it's the same as the fontSize parameter.}

\item{nodeStrokeWidth}{numeric width of the stroke around nodes.}

\item{nodeCornerRadius}{numeric Radius for rounded nodes.}

\item{margin}{an integer or a named \code{list}/\code{vector} of integers
for the plot margins. If using a named \code{list}/\code{vector},
the positions \code{top}, \code{right}, \code{bottom}, \code{left}
are valid.  If a single integer is provided, then the value will be
assigned to the right margin. Set the margin appropriately
to accomodate long text labels.}

\item{title}{character Title of plot, put in the upper-left corner of the Sankey}

\item{numberFormat}{number format in tooltips - see https://github.com/d3/d3-format for options. Default is ',.1f'.}

\item{orderByPath}{boolean Order the nodes vertically along a path - this layout only
works well for trees where each node has maximum one parent.}

\item{highlightChildLinks}{boolean Highlight all the links going right from a node or
link.}

\item{doubleclickTogglesChildren}{boolean Show/hide target nodes and paths to the left
on double-click. Does not hide incoming links of target nodes, yet.}

\item{xAxisDomain}{character[] If xAxisDomain is given, an axis with those value is
added to the bottom of the plot. Only sensible when also NodeXPos are given.}

\item{dragX}{boolean Allow moving nodes along the x-axis? Default is FALSE.}

\item{dragY}{boolean Allow moving nodes along the y-axis? Default is TRUE.}

\item{height}{numeric height for the network graph's frame area in pixels. Default is 500.}

\item{width}{numeric width for the network graph's frame area in pixels. Default is 800.}

\item{iterations}{numeric. Number of iterations in the diagramm layout for
computation of the depth (y-position) of each node. Note: this runs in the
browser on the client so don't push it too high.}

\item{zoom}{logical value to enable (\code{TRUE}) or disable (\code{FALSE})
zooming}

\item{align}{character Alignment of the nodes. One of 'right', 'left', 'justify', 'center', 'none'.
If 'none', then the labels of the nodes are always to the right of the node. Default is 'left'.}

\item{showNodeValues}{boolean Show values above nodes. Might require and increased node margin.}

\item{linkType}{character One of 'bezier', 'l-bezier', 'trapezoid', 'path1' and 'path2'.}

\item{curvature}{numeric Curvature parameter for bezier links - between 0 and 1.}

\item{nodeLabelMargin}{numeric margin between node and label.}

\item{linkOpacity}{numeric Opacity of links.}

\item{linkGradient}{boolean Add a gradient to the links?}

\item{nodeShadow}{boolean Add a shadow to the nodes?}

\item{scaleNodeBreadthsByString}{Put nodes at positions relatively to string lengths -
only work well currently with align='none'}

\item{xScalingFactor}{numeric Scale the computed x position of the nodes by this value.}

\item{yOrderComparator}{Order nodes on the y axis by a custom function instead of ascending or
descending depth.}
}
\description{
Create a D3 JavaScript Sankey diagram
}
