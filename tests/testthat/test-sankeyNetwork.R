library(sankeyD3plus)
library(testthat)

testLinks <- data.frame(mySource = c(0, 0),
                        myTarget = c(1, 2))

# Why are the nodes green but not the links?!
# sankeyNetwork(
#   Links = testLinks,
#   Source = "mySource",
#   Target = "myTarget",
#   linkColor = "#00923f"
# )

# Check if linkColor is identified correctly
test_that("linkColor identification", {
  # expect_silent(
  #   sankeyNetwork(
  #     Links = testLinks,
  #     Source = "mySource",
  #     Target = "myTarget",
  #     linkColor = "#00923f"
  #   )
  # )

  # expect_error(
  #   sankeyNetwork(
  #     Links = testLinks,
  #     Source = "mySource",
  #     Target = "myTarget",
  #     linkColor = "not-a-color"
  #   )
  # )

  testLinks$linkcols <- c("red", "#00923F")
  expect_silent(
    sankeyNetwork(
      Links = testLinks,
      Source = "mySource",
      Target = "myTarget",
      linkColor = "linkcols"
    )
  )

  testLinks$linkcols <- c("red", "not-a-color")
  expect_error(
    sankeyNetwork(
      Links = testLinks,
      Source = "mySource",
      Target = "myTarget",
      linkColor = "linkcols"
    )
  )
})
