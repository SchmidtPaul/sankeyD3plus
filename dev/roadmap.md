# Development Roadmap

## Track 1: Improve sankeyD3plus (Short-term)

Low-hanging fruit improvements to the existing D3-based package.

### 1.1 PNG Export Convenience
- [ ] Add `save_sankey()` function that wraps webshot2
- [ ] Auto-detect webshot vs webshot2 availability
- [ ] Handle temp file cleanup
- [ ] Support width/height/scale parameters

### 1.2 Documentation & Examples
- [ ] Review and improve existing vignettes
- [ ] Add more real-world examples
- [ ] Document all parameters properly

### 1.3 API Improvements
- [ ] Review function signatures for consistency
- [ ] Improve error messages
- [ ] Add input validation with helpful errors

### 1.4 Bug Fixes & Maintenance
- [ ] Review open issues on GitHub
- [ ] Update dependencies if needed
- [ ] Ensure CRAN compatibility (if desired)

---

## Track 2: New ggplot2-based Package (Long-term)

A native R implementation: **ggsankey2** (working title)

### Phase 1: Core Layout Algorithm
- [ ] Port d3-sankey layout algorithm to R
  - [ ] Compute node x-positions (topological depth)
  - [ ] Compute node values (max of in/out flows)
  - [ ] Iterative y-positioning (relaxation algorithm)
  - [ ] Link y-position stacking within nodes

### Phase 2: Basic Geoms
- [ ] `stat_sankey()` - computes layout from data
- [ ] `geom_sankey_node()` - draws rectangles
- [ ] `geom_sankey_link()` - draws bezier ribbons

### Phase 3: Features
- [ ] Per-node colors via `fill` aesthetic
- [ ] Per-link colors via `fill` aesthetic
- [ ] Node labels (`geom_sankey_label()`)
- [ ] Value labels above nodes
- [ ] Custom node positioning (x and y control)

### Phase 4: Polish
- [ ] Theme integration
- [ ] Documentation and vignettes
- [ ] Performance optimization
- [ ] Edge case handling (cycles, self-loops)

---

## Next Steps

**Immediate:** Start with Track 1.1 (PNG export) - highest impact, lowest effort

**Then:** Explore Track 2 Phase 1 - prototype the layout algorithm to assess feasibility

---

*Last updated: 2025-01-05*
