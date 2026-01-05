# Brainstorming: Future Direction for sankeyD3plus

## Path 1: Improve the D3-based Approach

*Philosophy: Trust that D3.js sankey is excellent at what it does. Focus on making it more accessible from R and solving the PNG export problem.*

---

### Approach 1.1: Streamline the webshot Workflow

**Idea**: Keep everything as-is, but add convenience functions that make HTML→PNG conversion seamless and invisible to the user.

**Implementation**:
```r
# New function that wraps sankeyNetwork + export
sankeyNetwork_png <- function(..., file, width = 800, height = 500) {
 widget <- sankeyNetwork(...)
 tmp <- tempfile(fileext = ".html")
 htmlwidgets::saveWidget(widget, tmp, selfcontained = TRUE)
 webshot2::webshot(tmp, file, vwidth = width, vheight = height)
 unlink(tmp)
 invisible(file)
}
```

**Pros**:
- Minimal changes to existing code
- webshot2 is mature and reliable
- Users get PNG with one function call

**Cons**:
- Requires PhantomJS or Chrome (webshot2 dependency)
- Extra dependency for users
- Rendering happens in external process (slower, potential issues)
- Still fundamentally HTML-based

**Effort**: Low (days)

---

### Approach 1.2: Server-side D3 Rendering with V8/Node

**Idea**: Use the V8 R package to run JavaScript directly in R, rendering D3 to SVG, then convert SVG to PNG with native R tools.

**Implementation**:
```r
library(V8)
ctx <- v8()
ctx$source("d3.min.js")
ctx$source("d3-sankey.min.js")

# Run D3 code in V8, output SVG string
svg_string <- ctx$call("renderSankey", nodes, links, options)

# Convert SVG to PNG using rsvg
rsvg::rsvg_png(charToRaw(svg_string), file = "output.png")
```

**Pros**:
- No browser/webshot dependency
- True server-side rendering
- SVG is vector (can also output PDF, high-res PNG)
- V8 is lightweight

**Cons**:
- D3 DOM manipulation assumes browser environment
- Would need to use d3-node or jsdom-like approach
- Significant rewrite of the JavaScript code
- V8 package can be tricky to set up

**Effort**: Medium-High (weeks)

---

### Approach 1.3: Rebuild on plotly Instead of D3

**Idea**: Abandon custom D3 code, rebuild the R interface on top of plotly's sankey trace, which already has PNG export via kaleido.

**Implementation**:
```r
sankeyNetwork <- function(Links, Nodes, ...) {
 # Convert our familiar API to plotly format
 fig <- plotly::plot_ly(
   type = "sankey",
   node = list(
     label = Nodes$label,
     color = Nodes$color,
     x = Nodes$x,  # 0-1 scaled
     y = Nodes$y   # 0-1 scaled
   ),
   link = list(
     source = Links$source,
     target = Links$target,
     value = Links$value,
     color = Links$color
   )
 )
 fig
}

# PNG export via kaleido
plotly::save_image(fig, "output.png")
```

**Pros**:
- plotly is well-maintained, popular
- kaleido PNG export exists (though requires Python)
- Interactive features for free
- We keep our R API, just change backend

**Cons**:
- **Loses features**: No NodePosY (vertical ordering), no value labels above nodes, no `showNodeValues`
- kaleido requires Python environment setup
- Different visual style (may not match current output)
- Dependency on plotly's roadmap

**Effort**: Medium (1-2 weeks for basic, longer to work around missing features)

---

## Path 2: Pure ggplot2 Approach

*Philosophy: Native R graphics, no JavaScript. Full control, familiar syntax, direct PNG/PDF output.*

---

### Approach 2.1: Fork and Extend ggsankey

**Idea**: Fork ggsankey, modify it to accept aggregated source-target-value data instead of requiring one-row-per-unit.

**Implementation**:
```r
# New geom that accepts weighted data
geom_sankey_weighted <- function(mapping = aes(source, target, value), ...) {
 # Internally expand or compute positions from aggregated data
 # Instead of make_long(), accept direct source-target-value
}
```

**Changes needed**:
- Rewrite `make_long()` or bypass it
- Modify `stat_sankey()` to compute positions from values
- Add support for non-conserved flows

**Pros**:
- Build on existing work
- Stay in ggplot2 ecosystem
- Familiar syntax for users

**Cons**:
- ggsankey's architecture may fight against this
- "Fork and extend" often becomes "rewrite anyway"
- ggsankey is not on CRAN, unclear maintenance status
- May inherit limitations we don't want

**Effort**: Medium-High (weeks, depends on how much fits vs. needs rewriting)

---

### Approach 2.2: Build Custom ggplot2 Geoms from Scratch

**Idea**: Write new `geom_sankey_node()`, `geom_sankey_link()`, and `stat_sankey_layout()` that implement the full sankey layout algorithm natively in R.

**Implementation**:
```r
# Core layout function (port of d3-sankey algorithm)
compute_sankey_layout <- function(nodes, links, width, height, iterations = 32) {
 # 1. Compute node x-positions (graph depth)
 # 2. Compute node values (max of in/out)
 # 3. Iteratively position nodes on y-axis
 # 4. Compute link y-positions within nodes
 # Return positioned nodes and links
}

# Custom geoms
geom_sankey_node <- function(...) {
 # Draw rectangles for nodes
}

geom_sankey_link <- function(...) {
 # Draw bezier ribbons for links using ggforce or custom
}

# User-facing function
ggplot(data) +
 stat_sankey(aes(source = from, target = to, value = n)) +
 geom_sankey_node(aes(fill = node_color)) +
 geom_sankey_link(aes(fill = link_color))
```

**Pros**:
- Complete control over everything
- Native PNG/PDF via ggsave()
- Full ggplot2 integration (themes, facets, etc.)
- No JavaScript, no external dependencies
- Could be a valuable contribution to R ecosystem

**Cons**:
- **Significant effort**: Layout algorithm is ~500 lines in d3-sankey
- Bezier ribbon rendering is non-trivial
- Edge cases (cycles, self-loops, etc.) need handling
- Testing and validation against known-good output

**Effort**: High (months for production quality)

---

### Approach 2.3: Direct grid Graphics (Skip ggplot2)

**Idea**: Use R's grid graphics system directly, without ggplot2 abstraction. More verbose but potentially simpler for this specific visualization.

**Implementation**:
```r
draw_sankey <- function(nodes, links, file = NULL, width = 800, height = 500) {
 if (!is.null(file)) png(file, width = width, height = height)
 grid.newpage()

 # Compute layout
 layout <- compute_sankey_layout(nodes, links, width, height)

 # Draw links (bezier curves with grid.bezier or xspline)
 for (link in layout$links) {
   grid.polygon(
     x = link$polygon_x,
     y = link$polygon_y,
     gp = gpar(fill = link$color, col = NA)
   )
 }

 # Draw nodes (rectangles)
 for (node in layout$nodes) {
   grid.rect(
     x = node$x, y = node$y,
     width = node$width, height = node$height,
     gp = gpar(fill = node$color)
   )
   grid.text(node$label, x = node$label_x, y = node$label_y)
 }

 if (!is.null(file)) dev.off()
}
```

**Pros**:
- Direct control, no abstraction layers
- Potentially simpler than fighting ggplot2's grammar
- Native PNG/PDF output
- Minimal dependencies (just grid, which is base R)

**Cons**:
- Lose ggplot2 benefits (themes, legends, faceting)
- Users expect ggplot2 syntax
- Still need to implement layout algorithm
- Less composable/extensible

**Effort**: Medium-High (layout algorithm is the same work, but rendering is simpler)

---

## Comparison Matrix

| Aspect | 1.1 webshot | 1.2 V8/SVG | 1.3 plotly | 2.1 Fork ggsankey | 2.2 ggplot2 scratch | 2.3 grid |
|--------|:-----------:|:----------:|:----------:|:-----------------:|:-------------------:|:--------:|
| **Effort** | Low | Med-High | Medium | Med-High | High | Med-High |
| **PNG quality** | Good | Excellent | Good | Excellent | Excellent | Excellent |
| **Dependencies** | webshot2 | V8 | plotly+Python | ggplot2 | ggplot2+ggforce | base R |
| **Maintains current features** | Yes | Yes | No* | Partial | Yes | Yes |
| **ggplot2 syntax** | No | No | No | Yes | Yes | No |
| **Future maintainability** | Easy | Medium | Easy | Medium | Medium | Easy |
| **Value to R community** | Low | Medium | Low | Medium | High | Medium |

*plotly lacks NodePosY, showNodeValues

---

## Analysis

### Path 1 (D3-based) Summary

**Best option: 1.1 (webshot workflow)**
- Pragmatic, low effort, solves the immediate pain point
- The D3 sankey code already works well
- webshot2 is reliable and Chrome-based

**1.2 (V8/SVG)** is elegant but risky - D3's DOM assumptions make server-side rendering tricky.

**1.3 (plotly)** loses too many features we specifically built sankeyD3plus to have.

### Path 2 (ggplot2-based) Summary

**Best option: 2.2 (ggplot2 from scratch)**
- If we're going to do the work, do it right
- Forking ggsankey (2.1) likely leads to rewriting anyway
- grid-only (2.3) loses too much ggplot2 goodness

**But**: This is a significant undertaking. The layout algorithm alone is substantial.

---

## Conclusion & Recommendation

### Short-term (now): Approach 1.1
Implement `sankeyNetwork_png()` and similar convenience functions. This:
- Solves the immediate PNG pain point
- Requires minimal effort
- Keeps all existing features working
- Buys time to consider longer-term options

### Long-term (future): Approach 2.2
A native ggplot2 sankey implementation would be:
- The "right" solution for the R ecosystem
- Free from JavaScript dependencies
- Fully integrated with R graphics workflows

**However**, this is a significant project that could be:
- A separate package (`ggsankey2` or `ggflow`)
- A collaborative effort with the R community
- A funded project if there's demand

### Hybrid possibility
Keep sankeyD3plus as the "feature-rich, D3-based" option while developing a lighter ggplot2 alternative. Different tools for different needs.

---

*Document created: 2025-01-05*
