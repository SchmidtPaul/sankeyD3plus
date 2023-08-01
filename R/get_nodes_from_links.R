#' Get Nodes From Links
#'
#' This function takes a data frame of links and creates the respective nodes dataframe.
#'
#' @param Links A data frame containing links information.
#' @param source The name of the column in the Links data frame that contains the source nodes. Default is "source".
#' @param target The name of the column in the Links data frame that contains the target nodes. Default is "target".
#'
#' @return A data frame of unique nodes.
#' @export
#'
#' @examples
#' links <- data.frame(source = c("A", "B", "C"), target = c("B", "C", "A"))
#' get_nodes_from_links(links)
get_nodes_from_links <- function(Links,
                                 source = "source",
                                 target = "target") {

  # Check if source and target columns are present in Links
  if (!all(c(source, target) %in% colnames(Links))) {

    # Check if source column exists
    if (!(source %in% colnames(Links))) {
      source <- colnames(Links)[1]
      message(paste("The 'source' column was not found. Using the first column:", source))
    }

    # Check if target column exists
    if (!(target %in% colnames(Links))) {
      target <- colnames(Links)[2]
      message(paste("The 'target' column was not found. Using the second column:", target))
    }
  }

  nodes <- c(Links[[source]], Links[[target]])
  nodes <- sort(unique(nodes))
  NodesDF <- data.frame(NodeID = nodes)

  return(NodesDF)
}

