# Upgrading to D3.js v7

sankeyD3plus now supports D3.js v7.9.0 for better performance, security, and modern features.

## Quick Upgrade (Recommended)

Run this command in R to download D3 v7 automatically:

```r
# Download D3 v7.9.0
download.file(
  url = "https://unpkg.com/d3@7.9.0/dist/d3.min.js",
  destfile = system.file("htmlwidgets/lib/d3/d3.v7.min.js", package = "sankeyD3plus"),
  mode = "wb"
)

# Verify the installation
file.exists(system.file("htmlwidgets/lib/d3/d3.v7.min.js", package = "sankeyD3plus"))
```

## Manual Upgrade

If the automatic download doesn't work:

1. **Download D3 v7:**
   - Visit: https://unpkg.com/d3@7.9.0/dist/d3.min.js
   - Save the file as `d3.v7.min.js`

2. **Find your package installation directory:**
   ```r
   system.file("htmlwidgets/lib/d3", package = "sankeyD3plus")
   ```

3. **Copy the file:**
   - Place `d3.v7.min.js` in the directory from step 2
   - Create the `d3` folder if it doesn't exist

4. **Verify:**
   ```r
   file.exists(system.file("htmlwidgets/lib/d3/d3.v7.min.js", package = "sankeyD3plus"))
   # Should return TRUE
   ```

## What if I don't upgrade?

The package will automatically fall back to D3 v4.13 (via the `d3r` package), which still works fine. However, you'll miss out on:

- **Performance improvements** in D3 v7
- **Bug fixes** from 5+ years of development
- **Better browser compatibility**
- **Modern JavaScript features**

## Benefits of D3 v7

- **Faster rendering** for large diagrams
- **Better memory management**
- **Improved zoom and drag behaviors**
- **Modern module system** (ES6)
- **Better TypeScript support**
- **Security updates**

## Troubleshooting

### "D3 v7 not found" message

This is just an informational message. The package works fine with D3 v4. Follow the upgrade steps above if you want D3 v7.

### Download blocked by firewall

If your network blocks CDN access:
1. Download the file on another machine
2. Transfer it manually
3. Place it in the correct directory

### Permission errors

You may need administrator/sudo privileges to write to the package installation directory.

## Verifying Your D3 Version

After upgrading, create a simple Sankey and check the browser console:

```r
library(sankeyD3plus)
links <- data.frame(source = 0:1, target = 1:2)
sankeyNetwork(Links = links, Source = "source", Target = "target")
```

In the browser console (F12), type:
```javascript
d3.version
// Should show "7.9.0" if upgrade successful
```

## Questions?

If you encounter issues, please report them at:
https://github.com/SchmidtPaul/sankeyD3plus/issues
