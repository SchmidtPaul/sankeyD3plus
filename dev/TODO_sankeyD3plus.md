# TODO: sankeyD3plus Improvements

Short-term improvements to the existing D3-based package.

## High Priority

### PNG Export Convenience
- [ ] Create `save_sankey()` function
  - [ ] Wrap `htmlwidgets::saveWidget()` + `webshot2::webshot()`
  - [ ] Auto-detect webshot vs webshot2 availability
  - [ ] Handle temp file cleanup automatically
  - [ ] Support parameters: `file`, `width`, `height`, `scale`, `delay`
  - [ ] Return the file path invisibly for piping
- [ ] Add webshot2 to Suggests in DESCRIPTION
- [ ] Document the function with examples
- [ ] Add to vignette showing PNG workflow

## Medium Priority

### Documentation
- [ ] Review all `@param` descriptions for clarity
- [ ] Ensure all examples in `man/` pages work
- [ ] Add more real-world examples to vignettes
- [ ] Document the NodePosX/NodePosY features better (these are unique to this package!)

### API Improvements
- [ ] Review error messages - make them actionable
- [ ] Add `assertthat` or `cli` based input validation
- [ ] Consider adding `...` parameter passthrough for advanced htmlwidgets options

### Code Quality
- [ ] Add more unit tests (currently minimal)
- [ ] Set up GitHub Actions for R CMD check
- [ ] Consider lintr/styler for code consistency

## Low Priority

### Features (if requested)
- [ ] Color palette helper functions
- [ ] Theme presets (dark mode, publication-ready, etc.)
- [ ] Animation controls

### CRAN Submission (if desired)
- [ ] Run `devtools::check()` and fix all NOTEs
- [ ] Ensure all dependencies are on CRAN
- [ ] Write cran-comments.md
- [ ] Submit via `devtools::release()`

## Known Issues to Investigate
- [ ] Review GitHub issues for bug reports
- [ ] fontSize not affecting xAxisDomain (Issue #3)

---

*Last updated: 2025-01-05*
