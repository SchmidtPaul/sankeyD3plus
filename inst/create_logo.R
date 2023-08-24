library(hexSticker)
library(magick)
library(sankeyD3plus)
library(tibble)

links <- tribble(
  ~source, ~target, ~value, ~linkcolor,
  0,       1,       2,      "#e4572e",
  0,       2,       4,      "grey",
  0,       3,       1,      "#495057",
  2,       4,       2,      "grey",
  2,       5,       2,      "grey",
  1,       5,       2,      "#e4572e"
)

nodes <- tribble(
  ~id, ~label, ~nodecolor,
  0,   "S",    "#00923f",
  1,   "N",    "#e4572e",
  2,   "A",    "#00923f",
  3,   "K",    "#495057",
  4,   "Y",    "#00923f",
  5,   "E",    "#e4572e"
)

p <- sankeyNetwork(
  Links = links,
  Source = "source",
  Target = "target",
  Value = "value",
  units = "mio. people",
  linkColor = "linkcolor",
  Nodes = nodes,
  NodeID = "label",
  NodeColor = "nodecolor",
  numberFormat = ".0f",
  fontSize = 14,
  nodeWidth = 25,
  height = 200,
  width = 300,
  margin = list(
    top = 10,
    right = 10,
    bottom = -19,
    left = 1
  )
)

sankeyD3plus::saveNetwork(
  network = p,
  folder_path = here::here("inst", "figures"),
  file_name = "tempsankey",
  png = "create")

# Read image
tempsankey <- here::here("inst", "figures", "tempsankey.png")
img <- image_read(tempsankey)
if (file.exists(tempsankey)) {file.remove(tempsankey)}
img_transparent <- image_transparent(img, "white", fuzz = 1)

# create sticker
sticker(
  subplot = img_transparent,
  package = "sankeyD3plus",
  p_size = 18,
  p_y = 0.6,
  p_color = "#00923f",
  s_x = 1,
  s_y = 1.2,
  s_width = 1.4,
  s_height = 1,
  h_fill = "#ffffff",
  h_color = "#00923f",
  filename = "inst/figures/logo_sankeyD3plus.png"
)

# show sticker
system('open "inst/figures/logo_sankeyD3plus.png"')

# usethis::use_logo("inst/figures/logo_sankeyD3plus.png")
