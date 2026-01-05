# Claude Code Session: Create a New ggplot2-based Sankey Package

Copy everything below this line into a new Claude Code session.

---

## Context & Motivation

I need to create a **new R package for Sankey diagrams** built entirely on ggplot2, without any JavaScript dependencies.

### Why this package needs to exist

I've thoroughly evaluated all existing R packages for Sankey diagrams:

| Package | Problem |
|---------|---------|
| **ggsankey** | Requires one-row-per-unit data format. Cannot handle aggregated source-target-value data (e.g., "3.7 million people flow from A to B" as one row). |
| **ggalluvial** | Assumes **flow conservation** - totals must be equal at each axis. Cannot represent non-conserved flows where nodes absorb flow without passing it on. |
| **networkD3** | HTML/JavaScript output only. Lacks per-node colors, per-link colors, vertical positioning. |
| **plotly** | Closest match, but requires Python (kaleido) for PNG export. Lacks vertical node ordering and value labels above nodes. |

**None of these packages can create the Sankey diagrams I need** with:
- Non-conserved flows (totals can differ at each x-position)
- Per-node and per-link color control
- Vertical and horizontal node positioning control
- Value labels displayed above nodes
- Native PNG/PDF output via `ggsave()`
- Pure R (no JavaScript, no Python dependencies)

### What I currently have

I have an existing package called **sankeyD3plus** that uses D3.js via htmlwidgets. It works well but:
- Outputs HTML, requiring webshot for PNG conversion
- Requires understanding JavaScript to deeply customize
- Has external dependencies

I want a **pure ggplot2 alternative** that produces static graphics directly.

---

## Package Specification

### Proposed name: `ggsankey2` (or suggest alternatives)

### Core requirements

1. **Data format**: Accept aggregated source-target-value data
```r
links <- data.frame(
  source = c("A", "A", "B"),
  target = c("B", "C", "C"),
  value = c(10, 20, 10)
)
```

2. **Non-conserved flows**: Totals don't need to match across positions. Node A can output 30, while nodes B and C together receive 40 (because B also receives from elsewhere or has its own value).

3. **Full color control**:
   - Per-node fill colors
   - Per-link fill colors
   - Settable via ggplot2 aesthetics

4. **Node positioning control**:
   - Horizontal: which column/x-position
   - Vertical: order within a column

5. **Labels**:
   - Node name labels (beside nodes)
   - Value labels (above nodes)
   - Custom number formatting

6. **Output**: Native PNG/PDF via `ggsave()` - no HTML, no webshot

### Desired API (example)

```r
library(ggsankey2)

links <- data.frame(
  source = c("Germany", "Germany", "Germany", "Berlin", "Other cities"),
  target = c("Berlin", "Other cities", "Rural", "Metropolitan", "Metropolitan"),
  value = c(3.7, 22.9, 57.7, 3.7, 22.9),
  link_color = c("#e56b6f", "#e56b6f", "#355070", "#e56b6f", "#e56b6f")
)

nodes <- data.frame(
  name = c("Germany", "Berlin", "Other cities", "Rural", "Metropolitan"),
  node_color = c("#6d597a", "#eaac8b", "#b56576", "#355070", "#e56b6f"),
  x_pos = c(0, 1, 1, 2, 2),
  y_order = c(1, 1, 2, 2, 1)
)

ggplot() +
  geom_sankey(
    data = links,
    aes(source = source, target = target, value = value, fill = link_color)
  ) +
  geom_sankey_node(
    data = nodes,
    aes(name = name, fill = node_color, x = x_pos, y = y_order)
  ) +
  geom_sankey_label(
    data = nodes,
    aes(name = name, label = name)
  ) +
  theme_sankey()

ggsave("sankey.png", width = 10, height = 6)
```

---

## Technical Approach

### The core challenge: Layout Algorithm

The hard part is computing node and link positions. This is what d3-sankey does:

1. **Node x-positions**: Compute graph depth (topological sort)
2. **Node values**: Max of incoming vs outgoing flow
3. **Node y-positions**: Iterative relaxation to minimize link crossings
4. **Node heights**: Proportional to value
5. **Link y-positions**: Stack within source and target nodes

Reference: https://github.com/d3/d3-sankey/blob/main/src/sankey.js

### Implementation plan

**Phase 1: Layout algorithm in R**
- Port the d3-sankey algorithm to R
- Create `compute_sankey_layout(nodes, links, width, height)` function
- Return positioned nodes (x, y, height) and links (source_y, target_y, thickness)

**Phase 2: Basic geoms**
- `stat_sankey()` - calls layout algorithm, prepares data for geoms
- `geom_sankey_node()` - draws rectangles (`geom_rect` wrapper)
- `geom_sankey_link()` - draws bezier ribbons (using `ggforce::geom_bezier` or custom polygon)

**Phase 3: Features**
- Color aesthetics
- Label geoms
- Positioning controls
- Themes

### Key dependency: ggforce

For bezier curves, we'll likely need `ggforce::geom_bezier()` or compute bezier polygons manually.

---

## Modern R Package Development

Please use these modern best practices:

### Package setup
```r
usethis::create_package("ggsankey2")
usethis::use_git()
usethis::use_github()  # if desired
```

### Documentation
```r
usethis::use_roxygen_md()  # Markdown in roxygen
usethis::use_package_doc()  # Package-level documentation
usethis::use_readme_rmd()   # README.Rmd
usethis::use_news_md()      # NEWS.md for changelog
usethis::use_vignette("introduction")
```

### Testing
```r
usethis::use_testthat()
usethis::use_test("layout")
usethis::use_test("geoms")
```

### Dependencies
```r
usethis::use_package("ggplot2", min_version = "3.4.0")
usethis::use_package("ggforce")
usethis::use_package("cli")        # For nice error messages
usethis::use_package("rlang")      # For tidy evaluation
usethis::use_package("vctrs")      # If needed for data handling
```

### Code quality
```r
usethis::use_tidy_description()
usethis::use_lifecycle()
lintr::lint_package()
styler::style_pkg()
```

### CI/CD
```r
usethis::use_github_actions()
usethis::use_github_action_check_standard()
usethis::use_pkgdown()
usethis::use_pkgdown_github_pages()
```

### DESCRIPTION fields
- Use Authors@R format with ORCID
- Proper licensing (MIT or GPL-3)
- Good title and description
- URL and BugReports fields

---

## Setup Instructions

I'm on **Windows**. Please help me:

1. Create the package in a local folder (I'll specify the path)
2. Set up the project structure using `usethis`
3. Initialize git
4. Create the basic file structure

Start by asking me where I want to create the package, then proceed with setup.

---

## Reference Files

For reference, here's sample data and expected output from my existing package:

### Sample data
```r
links <- tribble(
  ~source, ~target, ~value,
  0,       1,       3.7,
  0,       2,       22.9,
  0,       3,       57.7,
  1,       4,       3.7,
  2,       4,       22.9
)

nodes <- tribble(
  ~id, ~label,                  ~nodecolor,
  0,   "German residents",      "#6d597a",
  1,   "Berlin Residents",      "#eaac8b",
  2,   "Other cities (>100k)",  "#b56576",
  3,   "Non-Metropolitans",     "#355070",
  4,   "Metropolitans (>100k)", "#e56b6f"
)
```

This represents:
- 84.3M German residents split into Berlin (3.7M), other big cities (22.9M), and non-metropolitans (57.7M)
- Berlin + other big cities (26.6M) combine into "Metropolitans"
- Non-conserved: 84.3M → 57.7M + 26.6M (flows split, not all continue)

---

## Let's begin!

Please start by:
1. Asking me for the folder path where I want to create the package
2. Then set up the package structure with all modern best practices
3. Then we'll implement the layout algorithm together

---
