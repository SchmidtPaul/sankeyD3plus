# Claude Code Session: Create ggsankeyflow Package

Copy everything below this line into a new Claude Code session.

---

## Context & Motivation

I need to create a **new R package called `ggsankeyflow`** for Sankey diagrams built entirely on ggplot2, without any JavaScript dependencies.

### Sankey vs Alluvial: Why This Distinction Matters

**Alluvial diagrams** have a strict rule: *every band must connect to a node at EACH horizontal position*. This means they track the same units/cohorts across all stages - flow is implicitly conserved.

**Sankey diagrams** are more flexible:
- Flows can split, merge, or **terminate** at any node
- Nodes can absorb flow without passing it on (terminal nodes)
- Non-conservation is allowed - this was the original purpose (showing energy *losses* in steam engines)

**My use case requires Sankey, not alluvial:**
```
84.3M Germans
    ├── 3.7M  → Berlin ────────┐
    ├── 22.9M → Other cities ──┼── 26.6M Metropolitans
    └── 57.7M → Non-Metros (TERMINAL - flow stops here)
```

The 57.7M "disappears" into a terminal node. Alluvial packages cannot represent this because they require all flow to continue through every stage.

### Why Existing R Packages Fail

| Package | Problem |
|---------|---------|
| **ggsankey** | Requires one-row-per-unit data format. Cannot handle aggregated source-target-value data (e.g., "3.7 million people flow from A to B" as one row). |
| **ggalluvial** | Enforces flow conservation (the alluvial constraint). Cannot represent terminal nodes or non-conserved flows. |
| **ggsankeyfier** | On CRAN, but similar limitations to ggalluvial. |
| **networkD3** | HTML/JavaScript output only. Lacks per-node colors, per-link colors, vertical positioning. |
| **plotly** | Closest match, but requires Python (kaleido) for PNG export. Lacks vertical node ordering and value labels above nodes. |

**None of these packages can create the Sankey diagrams I need** with:
- Non-conserved flows (totals can differ at each x-position)
- Terminal nodes that absorb flow
- Per-node and per-link color control
- Vertical and horizontal node positioning control
- Value labels displayed above nodes
- Native PNG/PDF output via `ggsave()`
- Pure R (no JavaScript, no Python dependencies)

### What I Currently Have

I have an existing package called **sankeyD3plus** that uses D3.js via htmlwidgets. It works well but:
- Outputs HTML, requiring webshot for PNG conversion
- Requires understanding JavaScript to deeply customize
- Has external dependencies

I want a **pure ggplot2 alternative** that produces static graphics directly.

---

## Package Specification

### Name: `ggsankeyflow`

Why this name:
- `gg` prefix follows ggplot2 extension convention
- `sankey` is the correct term (not alluvial) for diagrams with non-conserved flows
- `flow` emphasizes the flow visualization aspect
- Searchable: users typing "ggsankey" will find it

### Core Requirements

1. **Data format**: Accept aggregated source-target-value data
```r
links <- data.frame(
 source = c("A", "A", "B"),
 target = c("B", "C", "C"),
 value = c(10, 20, 10)
)
```

2. **Non-conserved flows / Terminal nodes**:
 - Totals don't need to match across positions
 - Nodes can absorb flow without outputting it
 - This is THE key differentiator from alluvial packages

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
library(ggsankeyflow)

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

# Option A: Single geom approach
ggplot() +
 geom_sankeyflow(
   data = links,
   aes(source = source, target = target, value = value, fill = link_color),
   nodes = nodes,
   node_aes = aes(fill = node_color)
 ) +
 theme_sankeyflow()

# Option B: Layered geom approach
ggplot() +
 geom_sankey_link(
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
 theme_sankeyflow()

ggsave("sankey.png", width = 10, height = 6)
```

---

## Technical Approach

### The Core Challenge: Layout Algorithm

The hard part is computing node and link positions. This is what d3-sankey does:

1. **Node x-positions**: Compute graph depth (topological sort) or use user-specified positions
2. **Node values**: Max of incoming vs outgoing flow (allows non-conservation!)
3. **Node y-positions**: Iterative relaxation to minimize link crossings, or user-specified order
4. **Node heights**: Proportional to value
5. **Link y-positions**: Stack links within source and target nodes

Reference: https://github.com/d3/d3-sankey/blob/main/src/sankey.js (~500 lines)

### Key Insight for Non-Conservation

The d3-sankey algorithm computes node value as:
```javascript
node.value = Math.max(
 sum(node.incoming_links),
 sum(node.outgoing_links)
)
```

This naturally handles:
- **Source nodes**: value = outgoing (no incoming)
- **Terminal nodes**: value = incoming (no outgoing)
- **Pass-through nodes**: value = max(in, out)

This is exactly what we need - no artificial conservation constraint!

### Implementation Plan

**Phase 1: Layout algorithm in R**
- Port the d3-sankey algorithm to R
- Create `compute_sankey_layout(nodes, links, width, height)` function
- Return positioned nodes (x, y, height) and links (source_y, target_y, thickness)
- Ensure non-conserved flows work correctly

**Phase 2: Basic geoms**
- `stat_sankeyflow()` - calls layout algorithm, prepares data for geoms
- `geom_sankey_node()` - draws rectangles (`geom_rect` based)
- `geom_sankey_link()` - draws bezier ribbons (using `ggforce::geom_diagonal_wide` or custom polygon)

**Phase 3: Features**
- Color aesthetics (per-node, per-link)
- Label geoms (node names, values)
- Positioning controls (NodePosX, NodePosY equivalents)
- Themes

**Phase 4: Polish**
- Documentation and vignettes
- Edge cases (cycles, self-loops)
- Performance optimization

### Key Dependency: ggforce

For bezier curves, we'll likely need `ggforce::geom_diagonal_wide()` or compute bezier polygons manually.

---

## Modern R Package Development

Please use these modern best practices (2025/2026 standards):

### Package Setup
```r
usethis::create_package("ggsankeyflow")
usethis::use_git()
usethis::use_github()
```

### Documentation
```r
usethis::use_roxygen_md()
usethis::use_package_doc()
usethis::use_readme_rmd()
usethis::use_news_md()
usethis::use_vignette("ggsankeyflow")
```

### Testing
```r
usethis::use_testthat()
usethis::use_test("layout")
usethis::use_test("geoms")
usethis::use_test("non-conserved-flows")
```

### Dependencies
```r
usethis::use_package("ggplot2", min_version = "3.4.0")
usethis::use_package("ggforce")
usethis::use_package("cli")
usethis::use_package("rlang")
usethis::use_package("dplyr")
usethis::use_package("tidyr")
```
### Code Quality
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

### DESCRIPTION Fields
- Use `Authors@R` format with ORCID
- License: MIT
- Proper Title: "Create Sankey Flow Diagrams with ggplot2"
- Description mentioning: non-conserved flows, terminal nodes, per-node/link colors

---

## Setup Instructions

I'm on **Windows**. Please help me:

1. Create the package in a local folder (I'll specify the path)
2. Set up the project structure using `usethis`
3. Initialize git
4. Create the basic file structure

Start by asking me where I want to create the package, then proceed with setup.

---

## Reference: Sample Data and Expected Behavior

### Basic Example
```r
links <- data.frame(
 source = c("German residents", "German residents", "German residents",
            "Berlin Residents", "Other cities (>100k)"),
 target = c("Berlin Residents", "Other cities (>100k)", "Non-Metropolitans",
            "Metropolitans (>100k)", "Metropolitans (>100k)"),
 value = c(3.7, 22.9, 57.7, 3.7, 22.9)
)
```

This represents:
- 84.3M German residents split into Berlin (3.7M), other big cities (22.9M), and non-metropolitans (57.7M)
- Berlin + other big cities (26.6M) combine into "Metropolitans"
- **Non-conserved**: "Non-Metropolitans" is a terminal node (57.7M absorbed, not passed on)
- The alluvial constraint would require 84.3M at every x-position - we explicitly reject this

### With Colors
```r
links <- data.frame(
 source = c("German residents", "German residents", "German residents",
            "Berlin Residents", "Other cities (>100k)"),
 target = c("Berlin Residents", "Other cities (>100k)", "Non-Metropolitans",
            "Metropolitans (>100k)", "Metropolitans (>100k)"),
 value = c(3.7, 22.9, 57.7, 3.7, 22.9),
 link_color = c("#e56b6f", "#e56b6f", "#355070", "#e56b6f", "#e56b6f")
)

nodes <- data.frame(
 name = c("German residents", "Berlin Residents", "Other cities (>100k)",
          "Non-Metropolitans", "Metropolitans (>100k)"),
 node_color = c("#6d597a", "#eaac8b", "#b56576", "#355070", "#e56b6f")
)
```

### With Positioning Control
```r
nodes <- data.frame(
 name = c("German residents", "Berlin Residents", "Other cities (>100k)",
          "Non-Metropolitans", "Metropolitans (>100k)"),
 x_pos = c(0, 1, 1, 2, 2),
 y_order = c(1, 1, 2, 2, 1)
)
```

---

## Let's Begin!

Please start by:
1. Asking me for the folder path where I want to create the package
2. Then set up the package structure with all modern best practices
3. Then we'll implement the layout algorithm together

---
