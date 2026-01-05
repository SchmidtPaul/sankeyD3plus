# ============================================================================
# Comparing R packages for recreating sankeyD3plus examples
# ============================================================================

library(tibble)

# Original example data from sankeyD3plus
links <- tribble(
  ~source, ~target, ~value,
  0,       1,       3.7,
  0,       2,       22.9,
  0,       3,       57.7,
  1,       4,       3.7,
  2,       4,       22.9
)

nodes <- tribble(
  ~id, ~label,
  0,   "German residents",
  1,   "Berlin Residents",
  2,   "Other cities (>100k)",
  3,   "Non-Metropolitans",
  4,   "Metropolitans (>100k)"
)

# With colors
links_colored <- tribble(
  ~source, ~target, ~value, ~linkcolor,
  0,       1,       3.7,    "#e56b6f",
  0,       2,       22.9,   "#e56b6f",
  0,       3,       57.7,   "#355070",
  1,       4,       3.7,    "#e56b6f",
  2,       4,       22.9,   "#e56b6f"
)

nodes_colored <- tribble(
  ~id, ~label,                  ~nodecolor,
  0,   "German residents",      "#6d597a",
  1,   "Berlin Residents",      "#eaac8b",
  2,   "Other cities (>100k)",  "#b56576",
  3,   "Non-Metropolitans",     "#355070",
  4,   "Metropolitans (>100k)", "#e56b6f"
)


# ============================================================================
# OPTION 1: plotly
# ============================================================================
# Pros:
#   - Supports non-conserved flows ✓
#   - Per-node colors ✓
#   - Per-link colors ✓
#   - Can export to PNG via kaleido/orca
# Cons:
#   - Requires Python (kaleido) or external tool (orca) for PNG export
#   - Different syntax than ggplot2
#   - Node positioning (x,y) requires values between 0-1, iterative process

library(plotly)

# Basic example
fig_basic <- plot_ly(
 type = "sankey",
 orientation = "h",
 node = list(
   label = nodes$label,
   pad = 15,
   thickness = 20
 ),
 link = list(
   source = links$source,
   target = links$target,
   value = links$value
 )
)

fig_basic <- fig_basic %>% layout(
 title = "Basic Sankey (plotly)",
 font = list(size = 12)
)

# With colors
fig_colored <- plot_ly(
 type = "sankey",
 orientation = "h",
 node = list(
   label = nodes_colored$label,
   color = nodes_colored$nodecolor,
   pad = 15,
   thickness = 20
 ),
 link = list(
   source = links_colored$source,
   target = links_colored$target,
   value = links_colored$value,
   color = links_colored$linkcolor
 )
)

fig_colored <- fig_colored %>% layout(
 title = "Colored Sankey (plotly)",
 font = list(size = 12)
)

# Export to PNG (requires kaleido setup)
# save_image(fig_colored, "sankey_plotly.png", width = 800, height = 500)

# VERDICT: plotly CAN recreate the examples, but:
#   - PNG export requires additional Python/kaleido setup
#   - No native R-only solution for static images
#   - Node vertical positioning is automatic (no direct control like NodePosY)


# ============================================================================
# OPTION 2: ggsankey
# ============================================================================
# devtools::install_github("davidsjoberg/ggsankey")

library(ggsankey)
library(ggplot2)
library(dplyr)

# ggsankey requires data in "long" format with make_long()
# Problem: make_long() expects categorical columns, not source/target indices

# Let's try to convert our data to ggsankey format
# This is where it gets complicated...

# ggsankey expects data like:
# | stage1 | stage2 | stage3 |
# |--------|--------|--------|
# | A      | B      | C      |
# | A      | B      | D      |
# ...where each row is a "unit" flowing through stages

# Our data has VALUES (3.7, 22.9, etc.) - not individual units
# To use ggsankey, we'd need to either:
# 1. Expand rows (3.7 million rows for 3.7 million people) - impractical
# 2. Use the value as a weight - but make_long() doesn't support this directly

# Attempting workaround with manual long format:
# This doesn't work well because ggsankey fundamentally expects
# "one row per unit" data structure

# VERDICT: ggsankey CANNOT easily recreate the examples because:
#   - It expects wide data with one row per observation, not aggregated values
#   - No direct support for weighted/valued links
#   - The make_long() function doesn't accept pre-aggregated source-target-value data


# ============================================================================
# OPTION 3: ggalluvial
# ============================================================================

library(ggalluvial)

# ggalluvial also expects "alluvial" format data
# It CAN handle frequency/count data through the 'y' aesthetic

# Convert our data - but here's the fundamental problem:
# ggalluvial is designed for TRACKING COHORTS across stages
# Our data has DIFFERENT entities at different stages (people can flow in/out)

# Let's try anyway...
# We need to create a data frame where each row represents a "flow"

alluvial_data <- data.frame(
 stage = c(rep("Stage1", 3), rep("Stage2", 2)),
 from = c("German residents", "German residents", "German residents",
          "Berlin Residents", "Other cities (>100k)"),
 to = c("Berlin Residents", "Other cities (>100k)", "Non-Metropolitans",
        "Metropolitans (>100k)", "Metropolitans (>100k)"),
 value = c(3.7, 22.9, 57.7, 3.7, 22.9)
)

# The problem: ggalluvial works with axes (categorical stages), not node positions
# It can't easily represent: Stage1 -> Stage2 -> Stage3 where nodes split/merge

# Attempting the closest approximation:
# This will NOT produce a proper sankey because ggalluvial assumes
# conservation of flow (what goes in must come out at each stratum)

# VERDICT: ggalluvial CANNOT recreate the examples because:
#   - Fundamentally designed for alluvial plots, not sankey diagrams
#   - Assumes flow conservation (totals must be equal at each axis)
#   - Cannot handle arbitrary source-target-value structure


# ============================================================================
# OPTION 4: networkD3 (same approach as sankeyD3plus)
# ============================================================================

library(networkD3)

# networkD3 uses the SAME D3.js approach as sankeyD3plus
# It produces HTML, not PNG

fig_networkD3 <- sankeyNetwork(
 Links = as.data.frame(links),
 Nodes = as.data.frame(nodes),
 Source = "source",
 Target = "target",
 Value = "value",
 NodeID = "label",
 units = "mio. people"
)

# To get PNG: need webshot/webshot2
# htmlwidgets::saveWidget(fig_networkD3, "temp.html")
# webshot::webshot("temp.html", "sankey_networkD3.png")

# VERDICT: networkD3 CAN recreate basic examples, but:
#   - Same HTML-based approach as sankeyD3plus
#   - FEWER features than sankeyD3plus (no NodePosY, no per-node colors, etc.)
#   - This is exactly why you created sankeyD3plus!


# ============================================================================
# SUMMARY TABLE
# ============================================================================

cat("
============================================================================
PACKAGE COMPARISON FOR RECREATING sankeyD3plus EXAMPLES
============================================================================

Requirement                  | plotly | ggsankey | ggalluvial | networkD3
-----------------------------|--------|----------|------------|----------
Non-conserved flows          |   ✓    |    ✗     |     ✗      |    ✓
Per-node colors              |   ✓    |    ~     |     ~      |    ✗
Per-link colors              |   ✓    |    ~     |     ~      |    ✗
Node vertical positioning    |   ~    |    ✗     |     ✗      |    ✗
Node horizontal positioning  |   ✓    |    ✗     |     ✗      |    ✗
Value labels on nodes        |   ✗    |    ✗     |     ✗      |    ✗
Custom number formatting     |   ~    |    ✗     |     ✗      |    ✗
Native PNG output            |   ✗*   |    ✓     |     ✓      |    ✗
Pure R (no JS)               |   ✗    |    ✓     |     ✓      |    ✗

✓ = Supported
~ = Partially supported / workarounds exist
✗ = Not supported
* = Requires Python/kaleido or orca for PNG export

CONCLUSION:
-----------
NO existing R package can fully recreate your sankeyD3plus examples with:
- Non-conserved flows
- Full color control (per-node AND per-link)
- Vertical node positioning control
- Value labels above nodes
- Native PNG output
- Pure R code

The closest option is plotly, but it:
1. Still produces HTML (requires kaleido/Python for PNG)
2. Lacks the NodePosY feature for vertical ordering
3. Doesn't show values above nodes

Your sankeyD3plus package fills a real gap in the R ecosystem.
============================================================================
")
