# Why sankeyD3plus? A Comparison of R Packages for Sankey Diagrams

## Goal

Create Sankey diagrams in R with the following requirements:

| Requirement | Description |
|-------------|-------------|
| **Non-conserved flows** | Totals at each x-position can differ (e.g., 84.3M people split into groups where only some continue to the next stage) |
| **Per-node colors** | Individual color control for each node |
| **Per-link colors** | Individual color control for each link/flow |
| **Vertical node positioning** | Control over the y-order of nodes within a column |
| **Horizontal node positioning** | Control over which column a node appears in |
| **Value labels** | Display values above/on nodes |
| **Number formatting** | Custom formatting for displayed values |
| **PNG output** | Static image export for reports/publications |
| **Pure R** | No JavaScript knowledge required from the user |

## Available R Packages

### 1. ggsankey

- **Source**: [github.com/davidsjoberg/ggsankey](https://github.com/davidsjoberg/ggsankey)
- **Type**: ggplot2 extension (static output)
- **Installation**: GitHub only (`devtools::install_github("davidsjoberg/ggsankey")`)

**How it works**: Expects data in "wide" format where each row represents one unit flowing through stages. Uses `make_long()` to convert data for plotting.

**Fundamental limitation**: The data model is incompatible with pre-aggregated source-target-value data. If you have "3.7 million people flow from A to B", ggsankey expects 3.7 million rows (one per person), not one row with `value = 3.7`. There is no weight/value parameter in `make_long()`.

**Verdict**: Cannot recreate our examples without impractical data expansion.

---

### 2. ggalluvial

- **Source**: [CRAN](https://cran.r-project.org/package=ggalluvial), [Documentation](https://corybrunson.github.io/ggalluvial/)
- **Type**: ggplot2 extension (static output)
- **Installation**: CRAN

**How it works**: Designed for alluvial plots that track cohorts across categorical stages. Can handle frequency data through the `y` aesthetic.

**Fundamental limitation**: Assumes **flow conservation** - what flows into a stage must flow out. This is the mathematical definition of an alluvial plot. Our use case has non-conserved flows where:
- 84.3M German residents split into groups
- Only 26.6M continue to "Metropolitans" while 57.7M go to "Non-Metropolitans" (terminal node)

ggalluvial cannot represent nodes that absorb flow without passing it on.

**Verdict**: Cannot recreate our examples due to flow conservation assumption.

---

### 3. networkD3

- **Source**: [CRAN](https://cran.r-project.org/package=networkD3), [GitHub](https://github.com/christophergandrud/networkD3)
- **Type**: htmlwidget (HTML/JavaScript output)
- **Installation**: CRAN

**How it works**: Uses D3.js via htmlwidgets. Accepts source-target-value data format. This is actually the predecessor/inspiration for sankeyD3plus.

**Limitations**:
- No per-node color control (uses automatic color scale)
- No per-link color control
- No vertical node positioning (`NodePosY`)
- No value labels above nodes
- Produces HTML, not PNG (requires `webshot` for conversion)
- Has not incorporated improvements from community forks

**Verdict**: This is exactly why sankeyD3plus was created - to add missing features.

---

### 4. plotly

- **Source**: [CRAN](https://cran.r-project.org/package=plotly), [R Documentation](https://plotly.com/r/sankey-diagram/)
- **Type**: htmlwidget (HTML/JavaScript output)
- **Installation**: CRAN

**How it works**: Uses plotly.js for interactive visualizations. Supports source-target-value data format natively.

**What it supports**:
- Non-conserved flows
- Per-node colors (`node$color`)
- Per-link colors (`link$color`)
- Horizontal node positioning (`node$x`, values 0-1)
- Vertical node positioning (`node$y`, values 0-1) - but requires manual calculation

**Limitations**:
- **PNG export requires Python**: Uses `kaleido` (Python package) or `orca` (deprecated) for static image export. Not pure R.
- No automatic value labels above nodes
- Node positioning uses 0-1 coordinates, not intuitive ordering
- Different syntax from ggplot2 ecosystem

**Verdict**: Closest match, but fails the "pure R" and "easy PNG export" requirements.

---

### 5. Pure ggplot2 (custom implementation)

**Theoretical approach**: Use `geom_rect()` for nodes and `ggforce::geom_bezier()` or custom polygons for curved links.

**Why it's hard**:
1. **Layout algorithm**: Need to compute node positions (x, y, height) based on links - this is what d3-sankey does automatically (~200 lines of code)
2. **Bezier ribbons**: ggplot2 has no native "bezier ribbon" geom. `geom_bezier()` draws lines, not filled ribbons. Would need to compute polygon vertices along bezier curves (~100 lines)
3. **Link stacking**: Multiple links from/to a node must stack within the node's height - complex bookkeeping
4. **Edge cases**: Cycles, overlapping links, etc.

**Verdict**: Possible but requires significant development effort (400+ lines of layout/rendering code).

---

## Comparison Matrix

| Feature | ggsankey | ggalluvial | networkD3 | plotly | sankeyD3plus |
|---------|:--------:|:----------:|:---------:|:------:|:------------:|
| Non-conserved flows | - | - | + | + | + |
| Source-target-value data | - | ~ | + | + | + |
| Per-node colors | ~ | ~ | - | + | + |
| Per-link colors | ~ | ~ | - | + | + |
| Vertical node positioning | - | - | - | ~ | + |
| Horizontal node positioning | - | - | - | + | + |
| Value labels on nodes | - | - | - | - | + |
| Custom number formatting | - | - | ~ | ~ | + |
| Native PNG output | + | + | - | - | - |
| Pure R (no JS knowledge) | + | + | + | + | + |
| ggplot2 syntax | + | + | - | - | - |

**Legend**: + supported, ~ partial/workaround, - not supported

---

## Conclusion

**No existing R package fully satisfies our requirements.**

- **ggsankey** and **ggalluvial** have incompatible data models (no aggregated values, flow conservation)
- **networkD3** lacks customization features (colors, positioning, labels)
- **plotly** is the closest match but requires Python for PNG export and lacks some features

**sankeyD3plus fills a genuine gap** by providing:
1. The flexible D3.js sankey layout (non-conserved flows, any graph structure)
2. Full customization (per-node colors, per-link colors, positioning, labels)
3. An R-friendly interface (no JavaScript knowledge required)

The trade-off is HTML output requiring `webshot`/`webshot2` for PNG conversion - but this is the same trade-off plotly makes, and sankeyD3plus offers more sankey-specific features.

---

## Future Considerations

1. **Improve PNG workflow**: Streamline the HTML-to-PNG conversion with helper functions
2. **Pure ggplot2 alternative**: Long-term, a native ggplot2 implementation would be ideal but requires significant development
3. **Consider plotly backend**: Could potentially rebuild on plotly instead of D3, but would lose some features

---

*Document created: 2025-01-05*
*Purpose: Justify development of sankeyD3plus and document limitations of alternatives*
