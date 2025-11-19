# Phase 2: Official d3-sankey Integration Guide

## Overview

This guide explains how to integrate the official d3-sankey v0.12.3 library while preserving all custom rendering features.

## Architecture Change

### Before (v0.2):
```
Custom sankey.js (661 lines)
├── Layout Algorithm ← Positioning logic (buggy)
├── Link Rendering  ← Custom path generation
└── Node Rendering  ← Standard rectangles
```

### After (v0.3):
```
Official d3-sankey v0.12.3
└── Layout Algorithm ← Bulletproof positioning

sankeyNetwork.js (Enhanced)
├── Custom Link Rendering ← trapez, path1, path2, l-bezier
├── Custom Node Rendering ← Rounded corners, values
└── Feature Integration  ← Curvature, positioning
```

## Step 1: Download d3-sankey v0.12.3

### Option A: Manual Download
```bash
# Download from unpkg
cd /path/to/sankeyD3plus/inst/htmlwidgets/lib
mkdir -p d3-sankey-official
cd d3-sankey-official
wget https://unpkg.com/d3-sankey@0.12.3/dist/d3-sankey.min.js
```

### Option B: Using R
```r
download.file(
  url = "https://unpkg.com/d3-sankey@0.12.3/dist/d3-sankey.min.js",
  destfile = system.file("htmlwidgets/lib/d3-sankey-official/d3-sankey.min.js",
                         package = "sankeyD3plus"),
  mode = "wb"
)
```

### Option C: Using npm (if you have Node.js)
```bash
npm install d3-sankey@0.12.3
cp node_modules/d3-sankey/dist/d3-sankey.min.js inst/htmlwidgets/lib/d3-sankey-official/
```

## Step 2: Update Dependencies in R

Create new dependency function in `R/sankeyNetwork.R`:

```r
# Add near the sankey_dep() function (around line 323)
sankey_official_dep <- function() {
  sankey_path <- system.file("htmlwidgets/lib/d3-sankey-official",
                             package = "sankeyD3plus")

  if (!file.exists(file.path(sankey_path, "d3-sankey.min.js"))) {
    # Fall back to custom implementation
    message("Official d3-sankey not found. Using custom implementation.")
    return(sankey_dep())
  }

  htmltools::htmlDependency(
    name = "d3-sankey",
    version = "0.12.3",
    src = c(file = sankey_path),
    script = "d3-sankey.min.js"
  )
}
```

Update the createWidget call to use official d3-sankey:

```r
# In sankeyNetwork function, around line 320
dependencies = list(
  d3_dep(),
  sankey_official_dep(),  # Use official d3-sankey
  custom_rendering_dep()  # Our custom rendering layer (new)
)
```

## Step 3: Create Custom Rendering Layer

Create `inst/htmlwidgets/lib/custom-rendering/sankeyCustom.js`:

```javascript
// Custom Link Rendering Functions
// These work with official d3-sankey's node positions

var sankeyCustom = (function() {
  'use strict';

  // SVG path helper functions
  function xy(x, y) { return x + "," + y; }
  function M(x, y) { return "M" + xy(x, y); }
  function L(x, y) { return "L" + xy(x, y); }
  function C(x1,y1,x2,y2,x,y) { return "C" + xy(x1,y1) + " " + xy(x2,y2) + " " + xy(x,y); }
  function H(x) { return "H" + x; }
  function v(dy) { return "v" + dy; }
  function Z() { return "Z"; }

  // Custom link path generators
  function customLinkPath(linkType, curvature, nodeCornerRadius) {
    curvature = curvature || 0.5;
    nodeCornerRadius = nodeCornerRadius || 0;

    return function(d) {
      // Official d3-sankey provides: d.source.x0, x1, y0, y1 and d.target.x0, x1, y0, y1
      var x0 = d.source.x1 - nodeCornerRadius,
          x1 = d.target.x0 + nodeCornerRadius,
          xi = d3.interpolateNumber(x0, x1),
          x2 = xi(curvature),
          x3 = xi(1 - curvature);

      var y0 = d.y0,
          y1 = d.y1;

      switch(linkType) {
        case "trapez":
          return M(x0, d.source.y0 + y0) +
                 L(x0, d.source.y0 + y1) +
                 L(x1, d.target.y0 + y1) +
                 L(x1, d.target.y0 + y0) +
                 Z();

        case "path1":
          return M(x0, d.source.y0 + y0) +
                 C(x2, d.source.y0 + y0, x3, d.target.y0 + y0, x1, d.target.y0 + y0) +
                 L(x1, d.target.y0 + y1) +
                 C(x3, d.target.y0 + y1, x2, d.source.y0 + y1, x0, d.source.y0 + y1) +
                 Z();

        case "path2":
          var dy = y1 - y0;
          var x4 = x3 + ((dy < 15) ? ((d.source.y0 < d.target.y0) ? -1 * dy : dy) : 0);
          var x5 = x2 + ((dy < 15) ? ((d.source.y0 < d.target.y0) ? -1 * dy : dy) : 0);
          return M(x0, d.source.y0 + y0) +
                 C(x2, d.source.y0 + y0, x3, d.target.y0 + y0, x1, d.target.y0 + y0) +
                 v(dy) +
                 C(x4, d.target.y0 + y1, x5, d.source.y0 + y1, x0, d.source.y0 + y1) +
                 Z();

        case "l-bezier":
          var ym0 = d.source.y0 + (y0 + y1) / 2;
          var ym1 = d.target.y0 + (y0 + y1) / 2;
          var x4 = x0 + (d.source.x1 - d.source.x0) / 4;
          var x5 = x1 - (d.target.x1 - d.target.x0) / 4;
          x2 = Math.max(xi(curvature), x4 + (y1-y0));
          x3 = Math.min(xi(curvature), x5 - (y1-y0));
          return M(x0, ym0) + H(x4) + C(x2, ym0, x3, ym1, x5, ym1) + H(x1);

        case "bezier":
        default:
          var ym0 = d.source.y0 + (y0 + y1) / 2;
          var ym1 = d.target.y0 + (y0 + y1) / 2;
          return M(x0, ym0) + C(x2, ym0, x3, ym1, x1, ym1);
      }
    };
  }

  return {
    linkPath: customLinkPath
  };
})();
```

## Step 4: Refactor sankeyNetwork.js

Major changes to `inst/htmlwidgets/sankeyNetwork.js`:

```javascript
renderValue: function(el, x, instance) {
  // ... existing setup code ...

  // STEP 1: Use OFFICIAL d3-sankey for layout
  var sankeyGenerator = d3.sankey()
    .nodeWidth(options.nodeWidth)
    .nodePadding(options.nodePadding)
    .extent([[margin.left, margin.top],
             [width - margin.right, height - margin.bottom]])
    .nodeAlign(d3[getAlignmentFunction(options.align)])
    .iterations(options.iterations);

  // Add custom node sorting if provided
  if (options.nodeSort) {
    sankeyGenerator.nodeSort(new Function('return ' + options.nodeSort)());
  }

  // Compute the layout
  var graph = sankeyGenerator({
    nodes: nodes.map(d => Object.assign({}, d)),
    links: links.map(d => Object.assign({}, d))
  });

  // STEP 2: Draw using custom rendering
  var customPath = sankeyCustom.linkPath(
    options.linkType,
    options.curvature,
    options.nodeCornerRadius
  );

  // Draw links
  var link = svg.selectAll(".link")
    .data(graph.links)
    .enter().append("path")
    .attr("class", "link")
    .attr("d", customPath)  // Use our custom path generator!
    .style("stroke-width", function(d) { return Math.max(1, d.width); })
    // ... rest of link styling ...

  // Draw nodes (now using x0, x1, y0, y1 from official d3-sankey)
  var node = svg.selectAll(".node")
    .data(graph.nodes)
    .enter().append("g")
    .attr("class", "node");

  node.append("rect")
    .attr("x", function(d) { return d.x0; })
    .attr("y", function(d) { return d.y0; })
    .attr("height", function(d) { return d.y1 - d.y0; })
    .attr("width", function(d) { return d.x1 - d.x0; })
    .attr("rx", options.nodeCornerRadius)
    .attr("ry", options.nodeCornerRadius)
    // ... rest of node styling ...

  // ... rest of rendering code ...
}
```

## Step 5: Update Alignment Function Mapping

Add helper to map string alignment to d3-sankey functions:

```javascript
function getAlignmentFunction(align) {
  var alignmentMap = {
    'left': 'sankeyLeft',
    'right': 'sankeyRight',
    'center': 'sankeyCenter',
    'justify': 'sankeyJustify',
    'none': 'sankeyLeft'  // Closest match for 'none'
  };
  return alignmentMap[align] || 'sankeyJustify';
}
```

## Step 6: Handle Custom Features

### NodePosX and NodePosY
Official d3-sankey supports custom positioning via node properties:

```javascript
// Before calling sankeyGenerator()
if (options.NodePosX) {
  nodes.forEach(function(d, i) {
    if (d.posX !== undefined) {
      d.layer = d.posX;  // d3-sankey uses 'layer' for x position
    }
  });
}
```

### Manual Node Sorting (orderByPosY)
```javascript
if (options.orderByPosY) {
  sankeyGenerator.nodeSort(function(a, b) {
    if (a.posY !== undefined && b.posY !== undefined) {
      return a.posY - b.posY;
    }
    return 0;
  });
}
```

## Step 7: Testing

Create test file `tests/testthat/test-official-sankey.R`:

```r
test_that("Official d3-sankey integration works", {
  links <- data.frame(source = 0:2, target = 1:3)
  nodes <- data.frame(name = c("A", "B", "C", "D"))

  # Test basic rendering
  p <- sankeyNetwork(Links = links, Nodes = nodes,
                     Source = "source", Target = "target",
                     NodeID = "name")
  expect_s3_class(p, "sankeyNetwork")

  # Test custom link types
  for (linkType in c("bezier", "trapez", "path1", "path2", "l-bezier")) {
    p <- sankeyNetwork(Links = links, Nodes = nodes,
                       Source = "source", Target = "target",
                       NodeID = "name", linkType = linkType)
    expect_s3_class(p, "sankeyNetwork")
  }
})
```

## Step 8: Backward Compatibility

Ensure all existing examples still work:

```r
# Run all examples from vignettes
source("vignettes/Examples.Rmd")  # Should run without errors

# Test old API still works
old_style <- sankeyNetwork(
  Links = links,
  Source = "source",
  Target = "target",
  Value = "value"
)

# Should work identically to v0.2
```

## Benefits of This Architecture

1. **Stability**: Official d3-sankey handles positioning (community-tested)
2. **Flexibility**: Custom rendering preserves unique features
3. **Maintainability**: Clear separation of concerns
4. **Future-proof**: Easy to update d3-sankey independently
5. **Performance**: Optimized layout algorithm
6. **Compatibility**: All existing code still works

## Troubleshooting

### "Official d3-sankey not found" message
Follow Step 1 to download d3-sankey.min.js

### Links not rendering correctly
Check that customLinkPath uses correct property names:
- D3-sankey v0.12: `d.source.x0, x1, y0, y1`
- Old custom: `d.source.x, y, dx, dy`

### Nodes in wrong position
Verify extent is set correctly:
```javascript
.extent([[margin.left, margin.top], [width - margin.right, height - margin.bottom]])
```

## Next Steps

After completing Phase 2:
- ✅ All 5 link types work with official d3-sankey
- ✅ Backward compatibility maintained
- ✅ Cleaner, more maintainable code
- ✅ Ready for Phase 3 (refactoring) and Phase 4 (circular links)

## References

- Official d3-sankey API: https://github.com/d3/d3-sankey
- d3-sankey examples: https://observablehq.com/@d3/sankey
- Migration from custom to official: See MODERNIZATION_CHANGELOG.md
