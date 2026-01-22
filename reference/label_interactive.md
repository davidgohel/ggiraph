# Create an interactive label

This function returns an object that can be used as a label via the
[`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html)
family of functions or when setting a `scale`/`guide` name/title or key
label. It passes the interactive parameters to a theme element created
via
[`element_text_interactive()`](https://davidgohel.github.io/ggiraph/reference/element_interactive.md)
or via an interactive guide.

## Usage

``` r
label_interactive(label, ...)
```

## Arguments

- label:

  The text for the label (scalar character)

- ...:

  any of the
  [interactive_parameters](https://davidgohel.github.io/ggiraph/reference/interactive_parameters.md).

## Value

an interactive label object

## See also

[interactive_parameters](https://davidgohel.github.io/ggiraph/reference/interactive_parameters.md),
[`labeller_interactive()`](https://davidgohel.github.io/ggiraph/reference/labeller_interactive.md)

## Examples

``` r
library(ggplot2)
library(ggiraph)

gg_jitter <- ggplot(
  mpg, aes(cyl, hwy, group = cyl)) +
  geom_boxplot() +
  labs(title =
         label_interactive(
           "title",
           data_id = "id_title",
           onclick = "alert(\"title\")",
           tooltip = "title" )
  ) +
  theme(plot.title = element_text_interactive())

x <- girafe(ggobj = gg_jitter)
if( interactive() ) print(x)
```
