# Reactive version of girafe

Makes a reactive version of girafe object for use in Shiny.

## Usage

``` r
renderGirafe(expr, env = parent.frame(), quoted = FALSE, outputArgs = list())
```

## Arguments

- expr:

  An expression that returns a
  [`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
  object.

- env:

  The environment in which to evaluate expr.

- quoted:

  Is `expr` a quoted expression

- outputArgs:

  A list of arguments to be passed through to the implicit call to
  [`girafeOutput()`](https://davidgohel.github.io/ggiraph/reference/girafeOutput.md)
  when `renderGirafe` is used in an interactive R Markdown document.
