library(gfonts)
library(ggiraph)
library(systemfonts)
library(ggplot2)

if(!dir.exists("fonts")) {
  dir.create("fonts")

  variants <- c("regular", "italic", "700", "700italic")

  setup_font(id = "open-sans", output_dir = "fonts",
             variants = variants, prefer_local_source = FALSE)

  setup_font(id = "roboto", output_dir = "fonts",
             variants = variants, prefer_local_source = FALSE)

  setup_font(id = "comic-neue", output_dir = "fonts",
             variants = variants, prefer_local_source = FALSE)
}


if(!font_family_exists("Open Sans")){
  register_font(name = "Open Sans",
                plain = list("fonts/fonts/open-sans-v18-latin-regular.woff", 0),
                bold = list("fonts/fonts/open-sans-v18-latin-700.woff", 0),
                italic = list("fonts/fonts/open-sans-v18-latin-italic.woff", 0),
                bolditalic = list("fonts/fonts/open-sans-v18-latin-700italic.woff", 0)
  )
}
if(!font_family_exists("Roboto")){
  register_font(name = "Roboto",
                plain = list("fonts/fonts/roboto-v27-latin-regular.woff", 0),
                bold = list("fonts/fonts/roboto-v27-latin-700.woff", 0),
                italic = list("fonts/fonts/roboto-v27-latin-italic.woff", 0),
                bolditalic = list("fonts/fonts/roboto-v27-latin-700italic.woff", 0)
  )
}
if(!font_family_exists("Comic Neue")){
  register_font(name = "Comic Neue",
                plain = list("fonts/fonts/comic-neue-v2-latin-regular.woff", 0),
                bold = list("fonts/fonts/comic-neue-v2-latin-700.woff", 0),
                italic = list("fonts/fonts/comic-neue-v2-latin-italic.woff", 0),
                bolditalic = list("fonts/fonts/comic-neue-v2-latin-700italic.woff", 0)
  )
}

theme_set(theme_minimal(base_size = 12, base_family = "Open Sans"))
