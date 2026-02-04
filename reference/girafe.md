# Create a girafe object

Create an interactive graphic with a ggplot object to be used in a web
browser.

## Usage

``` r
girafe(
  ggobj = NULL,
  code,
  pointsize = 12,
  width_svg = NULL,
  height_svg = NULL,
  options = list(),
  dependencies = NULL,
  check_fonts_registered = FALSE,
  check_fonts_dependencies = FALSE,
  ...
)
```

## Arguments

- ggobj:

  ggplot object to print. Argument `code` will be ignored if this
  argument is supplied.

- code:

  Plotting code to execute

- pointsize:

  the default pointsize of plotted text in pixels, default to 12.

- width_svg, height_svg:

  The width and height of the graphics region in inches. The default
  values are 6 and 5 inches. This will define the aspect ratio of the
  graphic as it will be used to define viewbox attribute of the SVG
  result.

  If you use `girafe()` in an 'R Markdown' document, we recommend not
  using these arguments so that the knitr options `fig.width` and
  `fig.height` are used instead.

- options:

  a list of options for girafe rendering, see
  [`opts_tooltip()`](https://davidgohel.github.io/ggiraph/reference/opts_tooltip.md),
  [`opts_hover()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md),
  [`opts_selection()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md),
  ...

- dependencies:

  Additional widget HTML dependencies, see
  [`htmlwidgets::createWidget()`](https://rdrr.io/pkg/htmlwidgets/man/createWidget.html).

- check_fonts_registered:

  whether to check if fonts families found in the ggplot are registered
  with 'systemfonts'.

- check_fonts_dependencies:

  whether to check if fonts families found in the ggplot are found in
  the `dependencies` list.

- ...:

  arguments passed on to
  [`dsvg()`](https://davidgohel.github.io/ggiraph/reference/dsvg.md)

## Details

Use `geom_zzz_interactive` to create interactive graphical elements.

Tooltips can be displayed when mouse is over graphical elements.

If id are associated with points, they get animated when mouse is over
and can be selected when used in shiny apps.

On click actions can be set with javascript instructions. This option
should not be used simultaneously with selections in Shiny applications
as both features are "on click" features.

When a zoom effect is set, "zoom activate", "zoom desactivate" and "zoom
init" buttons are available in a toolbar.

When selection type is set to 'multiple' (in Shiny applications), lasso
selection and lasso anti-selections buttons are available in a toolbar.

## Managing Grouping with Interactive Aesthetics

Adding an interactive aesthetic like `tooltip` can sometimes alter the
implicit grouping that ggplot2 performs automatically.

In these cases, you **must explicitly** specify the `group` aesthetic to
ensure correct graph rendering by clearly defining the variables that
determine the grouping.

    mapping = ggplot2::aes(tooltip = .data_tooltip, group = interaction(factor1, factor2, ...))

This precaution is necessary:

- ggplot2 automatically determines grouping based on the provided
  aesthetics

- Interactive aesthetics added by ggiraph can interfere with this logic

- Explicit `group` specification prevents unexpected behavior and
  ensures predictable results

## Widget options

girafe animations can be customized with function
[`girafe_options()`](https://davidgohel.github.io/ggiraph/reference/girafe_options.md).
Options are available to customize tooltips, hover effects, zoom effects
selection effects and toolbar.

Options passed to `girafe()` are merged with defaults set via
[`set_girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/set_girafe_defaults.md).
This means you can define global styles once and override only specific
parameters per plot. For example, if you set a custom tooltip CSS
globally, you can still adjust `offx` and `offy` in a specific
`girafe()` call without losing your CSS styling.

## Widget sizing

girafe graphics are responsive, which mean, they will be resized
according to their container. There are two responsive behavior
implementations:

- one for Shiny applications and flexdashboard documents,

- and another one for other documents (i.e. R markdown and
  `saveWidget`).

Graphics are created by an R graphic device (i.e pdf, png, svg here) and
need arguments width and height to define a graphic region. Arguments
`width_svg` and `height_svg` are used as corresponding values. They are
defining the aspect ratio of the graphic. This proportion is always
respected when the graph is displayed.

When a girafe graphic is in a Shiny application, graphic will be resized
according to the arguments `width` and `height` of the function
`girafeOutput`. Default values are '100\\ outer bounding box of the
graphic (the HTML element that will contain the graphic with an aspect
ratio).

When a girafe graphic is in an R markdown document (producing an HTML
document), the graphic will be resized according to the argument `width`
of the function `girafe`. Its value is beeing used to define a relative
width of the graphic within its HTML container. Its height is
automatically adjusted regarding to the argument `width` and the aspect
ratio.

## See also

[`girafe_options()`](https://davidgohel.github.io/ggiraph/reference/girafe_options.md),
[`validated_fonts()`](https://davidgohel.github.io/ggiraph/reference/validated_fonts.md),
[`dsvg()`](https://davidgohel.github.io/ggiraph/reference/dsvg.md)

## Examples

``` r
library(ggplot2)
library(ggiraph)
library(gdtools)

register_liberationsans()
#> [1] TRUE

dataset <- mtcars
dataset$carname <- row.names(mtcars)

gg_point <- ggplot(
  data = dataset,
  mapping = aes(
    x = wt,
    y = qsec,
    color = disp,
    tooltip = carname,
    data_id = carname
  )
) +
  geom_point_interactive(hover_nearest = TRUE, size = 11 / .pt) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)

x <- girafe(
  ggobj = gg_point,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)

x

{"x":{"html":"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' class='ggiraph-svg' role='graphics-document' id='svg_e78b9fa4e88aa8ad' viewBox='0 0 432 360'>\n <defs id='svg_e78b9fa4e88aa8ad_defs'>\n  <clipPath id='svg_e78b9fa4e88aa8ad_c1'>\n   <rect x='0' y='0' width='432' height='360'/>\n  <\/clipPath>\n  <clipPath id='svg_e78b9fa4e88aa8ad_c2'>\n   <rect x='32.79' y='5.48' width='334.36' height='323.64'/>\n  <\/clipPath>\n <\/defs>\n <g id='svg_e78b9fa4e88aa8ad_rootg' class='ggiraph-svg-rootg'>\n  <g clip-path='url(#svg_e78b9fa4e88aa8ad_c1)'>\n   <rect x='0' y='0' width='432' height='360' fill='#FFFFFF' fill-opacity='1' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.75' stroke-linejoin='round' stroke-linecap='round' class='ggiraph-svg-bg'/>\n   <rect x='0' y='0' width='432' height='360' fill='#FFFFFF' fill-opacity='1' stroke='none'/>\n  <\/g>\n  <g clip-path='url(#svg_e78b9fa4e88aa8ad_c2)'>\n   <polyline points='32.79,296.89 367.16,296.89' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='32.79,226.84 367.16,226.84' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='32.79,156.79 367.16,156.79' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='32.79,86.74 367.16,86.74' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='32.79,16.69 367.16,16.69' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='46.98,329.12 46.98,5.48' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='124.70,329.12 124.70,5.48' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='202.42,329.12 202.42,5.48' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='280.14,329.12 280.14,5.48' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='357.86,329.12 357.86,5.48' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='0.53' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='32.79,261.87 367.16,261.87' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='32.79,191.82 367.16,191.82' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='32.79,121.76 367.16,121.76' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='32.79,51.71 367.16,51.71' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='85.84,329.12 85.84,5.48' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='163.56,329.12 163.56,5.48' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='241.28,329.12 241.28,5.48' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='319.00,329.12 319.00,5.48' fill='none' stroke='#EBEBEB' stroke-opacity='1' stroke-width='1.07' stroke-linejoin='round' stroke-linecap='butt'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e1' cx='134.03' cy='245.75' r='3.36pt' fill='#214667' fill-opacity='1' stroke='#214667' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Mazda RX4' data-id='Mazda RX4' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e2' cx='153.85' cy='226.14' r='3.36pt' fill='#214667' fill-opacity='1' stroke='#214667' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Mazda RX4 Wag' data-id='Mazda RX4 Wag' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e3' cx='110.71' cy='170.45' r='3.36pt' fill='#193652' fill-opacity='1' stroke='#193652' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Datsun 710' data-id='Datsun 710' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e4' cx='180.27' cy='141.38' r='3.36pt' fill='#316692' fill-opacity='1' stroke='#316692' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Hornet 4 Drive' data-id='Hornet 4 Drive' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e5' cx='197.76' cy='226.14' r='3.36pt' fill='#4289C1' fill-opacity='1' stroke='#4289C1' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Hornet Sportabout' data-id='Hornet Sportabout' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e6' cx='199.31' cy='114.06' r='3.36pt' fill='#2B5B83' fill-opacity='1' stroke='#2B5B83' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Valiant' data-id='Valiant' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e7' cx='207.86' cy='267.47' r='3.36pt' fill='#4289C1' fill-opacity='1' stroke='#4289C1' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Duster 360' data-id='Duster 360' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e8' cx='178.33' cy='121.76' r='3.36pt' fill='#1F4262' fill-opacity='1' stroke='#1F4262' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Merc 240D' data-id='Merc 240D' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e9' cx='175.22' cy='20.19' r='3.36pt' fill='#1E405F' fill-opacity='1' stroke='#1E405F' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Merc 230' data-id='Merc 230' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e10' cx='197.76' cy='181.31' r='3.36pt' fill='#22486A' fill-opacity='1' stroke='#22486A' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Merc 280' data-id='Merc 280' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e11' cx='197.76' cy='160.29' r='3.36pt' fill='#22486A' fill-opacity='1' stroke='#22486A' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Merc 280C' data-id='Merc 280C' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e12' cx='246.72' cy='212.83' r='3.36pt' fill='#346C9A' fill-opacity='1' stroke='#346C9A' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Merc 450SE' data-id='Merc 450SE' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e13' cx='220.3' cy='205.83' r='3.36pt' fill='#346C9A' fill-opacity='1' stroke='#346C9A' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Merc 450SL' data-id='Merc 450SL' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e14' cx='224.18' cy='191.82' r='3.36pt' fill='#346C9A' fill-opacity='1' stroke='#346C9A' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Merc 450SLC' data-id='Merc 450SLC' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e15' cx='338.43' cy='192.52' r='3.36pt' fill='#56B1F7' fill-opacity='1' stroke='#56B1F7' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Cadillac Fleetwood' data-id='Cadillac Fleetwood' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e16' cx='351.96' cy='198.12' r='3.36pt' fill='#54ADF1' fill-opacity='1' stroke='#54ADF1' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Lincoln Continental' data-id='Lincoln Continental' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e17' cx='345.82' cy='212.13' r='3.36pt' fill='#50A5E7' fill-opacity='1' stroke='#50A5E7' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Chrysler Imperial' data-id='Chrysler Imperial' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e18' cx='101.38' cy='140.33' r='3.36pt' fill='#142D46' fill-opacity='1' stroke='#142D46' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Fiat 128' data-id='Fiat 128' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e19' cx='55.92' cy='173.6' r='3.36pt' fill='#142C45' fill-opacity='1' stroke='#142C45' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Honda Civic' data-id='Honda Civic' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e20' cx='73.02' cy='125.27' r='3.36pt' fill='#132B43' fill-opacity='1' stroke='#132B43' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Toyota Corolla' data-id='Toyota Corolla' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e21' cx='121.98' cy='121.41' r='3.36pt' fill='#1A3A57' fill-opacity='1' stroke='#1A3A57' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Toyota Corona' data-id='Toyota Corona' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e22' cx='203.98' cy='231.39' r='3.36pt' fill='#3B7AAD' fill-opacity='1' stroke='#3B7AAD' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Dodge Challenger' data-id='Dodge Challenger' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e23' cx='197.37' cy='216.33' r='3.36pt' fill='#3875A7' fill-opacity='1' stroke='#3875A7' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='AMC Javelin' data-id='AMC Javelin' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e24' cx='228.85' cy='282.53' r='3.36pt' fill='#4085BC' fill-opacity='1' stroke='#4085BC' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Camaro Z28' data-id='Camaro Z28' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e25' cx='229.24' cy='225.09' r='3.36pt' fill='#4997D4' fill-opacity='1' stroke='#4997D4' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Pontiac Firebird' data-id='Pontiac Firebird' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e26' cx='80.79' cy='160.29' r='3.36pt' fill='#142D46' fill-opacity='1' stroke='#142D46' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Fiat X1-9' data-id='Fiat X1-9' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e27' cx='96.72' cy='237.35' r='3.36pt' fill='#1A3A57' fill-opacity='1' stroke='#1A3A57' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Porsche 914-2' data-id='Porsche 914-2' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e28' cx='47.99' cy='230.34' r='3.36pt' fill='#17324D' fill-opacity='1' stroke='#17324D' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Lotus Europa' data-id='Lotus Europa' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e29' cx='176.77' cy='314.4' r='3.36pt' fill='#4085BD' fill-opacity='1' stroke='#4085BD' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Ford Pantera L' data-id='Ford Pantera L' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e30' cx='145.69' cy='279.38' r='3.36pt' fill='#1E4161' fill-opacity='1' stroke='#1E4161' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Ferrari Dino' data-id='Ferrari Dino' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e31' cx='207.86' cy='310.9' r='3.36pt' fill='#3874A5' fill-opacity='1' stroke='#3874A5' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Maserati Bora' data-id='Maserati Bora' nearest='true'/>\n   <circle id='svg_e78b9fa4e88aa8ad_e32' cx='146.46' cy='170.8' r='3.36pt' fill='#1B3A57' fill-opacity='1' stroke='#1B3A57' stroke-opacity='1' stroke-width='0.71' stroke-linejoin='round' stroke-linecap='round' title='Volvo 142E' data-id='Volvo 142E' nearest='true'/>\n  <\/g>\n  <g clip-path='url(#svg_e78b9fa4e88aa8ad_c1)'>\n   <text x='18.07' y='264.89' font-size='6.6pt' font-family='Liberation Sans' fill='#4D4D4D' fill-opacity='1'>16<\/text>\n   <text x='18.07' y='194.84' font-size='6.6pt' font-family='Liberation Sans' fill='#4D4D4D' fill-opacity='1'>18<\/text>\n   <text x='18.07' y='124.79' font-size='6.6pt' font-family='Liberation Sans' fill='#4D4D4D' fill-opacity='1'>20<\/text>\n   <text x='18.07' y='54.74' font-size='6.6pt' font-family='Liberation Sans' fill='#4D4D4D' fill-opacity='1'>22<\/text>\n   <text x='83.39' y='340.1' font-size='6.6pt' font-family='Liberation Sans' fill='#4D4D4D' fill-opacity='1'>2<\/text>\n   <text x='161.11' y='340.1' font-size='6.6pt' font-family='Liberation Sans' fill='#4D4D4D' fill-opacity='1'>3<\/text>\n   <text x='238.83' y='340.1' font-size='6.6pt' font-family='Liberation Sans' fill='#4D4D4D' fill-opacity='1'>4<\/text>\n   <text x='316.56' y='340.1' font-size='6.6pt' font-family='Liberation Sans' fill='#4D4D4D' fill-opacity='1'>5<\/text>\n   <text x='194.47' y='352.24' font-size='8.25pt' font-family='Liberation Sans'>wt<\/text>\n   <text transform='translate(13.05,178.92) rotate(-90.00)' font-size='8.25pt' font-family='Liberation Sans'>qsec<\/text>\n   <text x='383.59' y='125.14' font-size='8.25pt' font-family='Liberation Sans'>disp<\/text>\n   <image x='383.59' y='131.76' width='17.28' height='86.4' preserveAspectRatio='none' xlink:href='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAEsCAYAAAACUNnVAAAAmElEQVQ4ja2UQRLDMAgDd3hk/tnX5agcknFaCoa0vnkMCEnGsL12GQhDYDpPwoDrpBFlRDWi/9Wu6AHC9FkLYLrzlhD3oJ3mDvRHRYy7IC8A7bCK8gpWKYDzeQVArDcDyD2YAnSofZvzaOA6Q7Oahp/dmRuVTQ0xU5TGP2o8Waool1obVuv1q8qP9xPvg633XlGLDtfIhNUBcBeA5ss0BXMAAAAASUVORK5CYII=' xmlns:xlink='http://www.w3.org/1999/xlink'/>\n   <polyline points='397.42,211.81 400.87,211.81' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='397.42,190.33 400.87,190.33' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='397.42,168.85 400.87,168.85' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='397.42,147.37 400.87,147.37' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='387.05,211.81 383.59,211.81' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='387.05,190.33 383.59,190.33' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='387.05,168.85 383.59,168.85' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt'/>\n   <polyline points='387.05,147.37 383.59,147.37' fill='none' stroke='#FFFFFF' stroke-opacity='1' stroke-width='0.37' stroke-linejoin='round' stroke-linecap='butt'/>\n   <text x='406.35' y='214.84' font-size='6.6pt' font-family='Liberation Sans'>100<\/text>\n   <text x='406.35' y='193.36' font-size='6.6pt' font-family='Liberation Sans'>200<\/text>\n   <text x='406.35' y='171.88' font-size='6.6pt' font-family='Liberation Sans'>300<\/text>\n   <text x='406.35' y='150.4' font-size='6.6pt' font-family='Liberation Sans'>400<\/text>\n  <\/g>\n <\/g>\n<\/svg>","js":null,"uid":"svg_e78b9fa4e88aa8ad","ratio":1.2,"settings":{"tooltip":{"css":".tooltip_SVGID_ { padding:5px;background:black;color:white;border-radius:2px;text-align:left; ; position:absolute;pointer-events:none;z-index:9999;}","placement":"doc","opacity":0.9,"offx":10,"offy":10,"use_cursor_pos":true,"use_fill":false,"use_stroke":false,"delay_over":200,"delay_out":500},"hover":{"css":".hover_data_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_data_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_data_SVGID_ { fill:orange;stroke:black; }\nline.hover_data_SVGID_, polyline.hover_data_SVGID_ { fill:none;stroke:orange; }\nrect.hover_data_SVGID_, polygon.hover_data_SVGID_, path.hover_data_SVGID_ { fill:orange;stroke:none; }\nimage.hover_data_SVGID_ { stroke:orange; }","reactive":true,"nearest_distance":null},"hover_inv":{"css":""},"hover_key":{"css":".hover_key_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_key_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_key_SVGID_ { fill:orange;stroke:black; }\nline.hover_key_SVGID_, polyline.hover_key_SVGID_ { fill:none;stroke:orange; }\nrect.hover_key_SVGID_, polygon.hover_key_SVGID_, path.hover_key_SVGID_ { fill:orange;stroke:none; }\nimage.hover_key_SVGID_ { stroke:orange; }","reactive":true},"hover_theme":{"css":".hover_theme_SVGID_ { fill:orange;stroke:black;cursor:pointer; }\ntext.hover_theme_SVGID_ { stroke:none;fill:orange; }\ncircle.hover_theme_SVGID_ { fill:orange;stroke:black; }\nline.hover_theme_SVGID_, polyline.hover_theme_SVGID_ { fill:none;stroke:orange; }\nrect.hover_theme_SVGID_, polygon.hover_theme_SVGID_, path.hover_theme_SVGID_ { fill:orange;stroke:none; }\nimage.hover_theme_SVGID_ { stroke:orange; }","reactive":true},"select":{"css":".select_data_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_data_SVGID_ { stroke:none;fill:red; }\ncircle.select_data_SVGID_ { fill:red;stroke:black; }\nline.select_data_SVGID_, polyline.select_data_SVGID_ { fill:none;stroke:red; }\nrect.select_data_SVGID_, polygon.select_data_SVGID_, path.select_data_SVGID_ { fill:red;stroke:none; }\nimage.select_data_SVGID_ { stroke:red; }","type":"multiple","only_shiny":true,"selected":[]},"select_inv":{"css":""},"select_key":{"css":".select_key_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_key_SVGID_ { stroke:none;fill:red; }\ncircle.select_key_SVGID_ { fill:red;stroke:black; }\nline.select_key_SVGID_, polyline.select_key_SVGID_ { fill:none;stroke:red; }\nrect.select_key_SVGID_, polygon.select_key_SVGID_, path.select_key_SVGID_ { fill:red;stroke:none; }\nimage.select_key_SVGID_ { stroke:red; }","type":"single","only_shiny":true,"selected":[]},"select_theme":{"css":".select_theme_SVGID_ { fill:red;stroke:black;cursor:pointer; }\ntext.select_theme_SVGID_ { stroke:none;fill:red; }\ncircle.select_theme_SVGID_ { fill:red;stroke:black; }\nline.select_theme_SVGID_, polyline.select_theme_SVGID_ { fill:none;stroke:red; }\nrect.select_theme_SVGID_, polygon.select_theme_SVGID_, path.select_theme_SVGID_ { fill:red;stroke:none; }\nimage.select_theme_SVGID_ { stroke:red; }","type":"single","only_shiny":true,"selected":[]},"zoom":{"min":1,"max":1,"duration":300,"default_on":false},"toolbar":{"position":"topright","pngname":"diagram","tooltips":null,"fixed":false,"hidden":[],"delay_over":200,"delay_out":500},"sizing":{"rescale":true,"width":1}}},"evals":[],"jsHooks":[]}
```
