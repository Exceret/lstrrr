# Regenerate pkgdown/favicon from man/figures/logo.png.
#
# `pkgdown::build_favicons()` uploads the logo to realfavicongenerator.net,
# which is unreachable on some networks. This script builds the same set of
# files locally with ImageMagick, so favicons can be refreshed offline.
#
#   source("data-raw/make-favicons.R")

library(magick)

logo <- "man/figures/logo.png"
out <- "pkgdown/favicon"

dir.create(out, showWarnings = FALSE, recursive = TRUE)

src <- image_read(logo)
info <- image_info(src)

# Icon sizes are square, so centre the logo on a square white canvas.
side <- max(info$width, info$height)
square <- image_extent(
  src,
  sprintf("%dx%d", side, side),
  gravity = "center",
  color = "white"
)

sizes <- c(
  "favicon-96x96.png" = 96,
  "apple-touch-icon.png" = 180,
  "web-app-manifest-192x192.png" = 192,
  "web-app-manifest-512x512.png" = 512
)
for (file in names(sizes)) {
  image_resize(square, sprintf("%d", sizes[[file]])) |>
    # Drop the tIME chunk so re-runs produce identical bytes.
    image_write(
      file.path(out, file),
      format = "png",
      define = c("png:exclude-chunk" = "time")
    )
}

# Multi-resolution .ico for browser tabs.
ico <- lapply(c(48, 32, 16), function(size) {
  image_resize(square, sprintf("%d", size))
})
# Largest first, so the 48px frame is the default.
image_write(
  do.call(image_join, ico),
  file.path(out, "favicon.ico"),
  format = "ico"
)

# SVG wrapper around an embedded PNG, mirroring what the web service produces.
svg_png <- image_resize(square, sprintf("%d", side)) |>
  image_write(format = "png", define = c("png:exclude-chunk" = "time"))
writeLines(
  sprintf(
    paste0(
      '<svg xmlns="http://www.w3.org/2000/svg" ',
      'xmlns:xlink="http://www.w3.org/1999/xlink" width="%1$d" height="%1$d" ',
      'viewBox="0 0 %1$d %1$d"><image width="%1$d" height="%1$d" ',
      'xlink:href="data:image/png;base64,%2$s"/></svg>'
    ),
    side,
    openssl::base64_encode(svg_png)
  ),
  file.path(out, "favicon.svg")
)

manifest <- file.path(out, "site.webmanifest")
if (!file.exists(manifest)) {
  writeLines(
    c(
      "{",
      '  "name": "lstrrr",',
      '  "short_name": "lstrrr",',
      '  "icons": [',
      '    {',
      '      "src": "/web-app-manifest-192x192.png",',
      '      "sizes": "192x192",',
      '      "type": "image/png",',
      '      "purpose": "maskable"',
      "    },",
      "    {",
      '      "src": "/web-app-manifest-512x512.png",',
      '      "sizes": "512x512",',
      '      "type": "image/png",',
      '      "purpose": "maskable"',
      "    }",
      "  ],",
      '  "theme_color": "#ffffff",',
      '  "background_color": "#ffffff",',
      '  "display": "standalone"',
      "}"
    ),
    manifest
  )
}
