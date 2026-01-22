# List of validated default fonts

Validates and possibly modifies the fonts to be used as default value in
a graphic according to the fonts available on the machine. It process
elements named "sans", "serif", "mono" and "symbol".

## Usage

``` r
validated_fonts(fonts = list())
```

## Arguments

- fonts:

  Named list of font names to be aliased with fonts installed on your
  system. If unspecified, the R default families "sans", "serif", "mono"
  and "symbol" are aliased to the family returned by
  [`match_family()`](https://davidgohel.github.io/ggiraph/dev/reference/match_family.md).

  If fonts are available, the default mapping will use these values:

  |          |                 |              |                |
  |----------|-----------------|--------------|----------------|
  | R family | Font on Windows | Font on Unix | Font on Mac OS |
  | `sans`   | Arial           | DejaVu Sans  | Helvetica      |
  | `serif`  | Times New Roman | DejaVu serif | Times          |
  | `mono`   | Courier         | DejaVu mono  | Courier        |
  | `symbol` | Symbol          | DejaVu Sans  | Symbol         |

## Value

a named list of validated font family names

## See also

[`girafe()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe.md),
[`dsvg()`](https://davidgohel.github.io/ggiraph/dev/reference/dsvg.md)

Other functions for font management:
[`match_family()`](https://davidgohel.github.io/ggiraph/dev/reference/match_family.md)

## Examples

``` r
validated_fonts()
#> $sans
#> [1] "DejaVu Sans"
#> 
#> $serif
#> [1] "DejaVu serif"
#> 
#> $mono
#> [1] "DejaVu Sans"
#> 
#> $symbol
#> [1] "DejaVu Sans"
#> 
```
