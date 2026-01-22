# Find best family match with systemfonts

`match_family()` returns the best font family match.

## Usage

``` r
match_family(font = "sans", bold = TRUE, italic = TRUE, debug = NULL)
```

## Arguments

- font:

  family or face to match.

- bold:

  Wheter to match a font featuring a `bold` face.

- italic:

  Wheter to match a font featuring an `italic` face.

- debug:

  deprecated

## See also

Other functions for font management:
[`validated_fonts()`](https://davidgohel.github.io/ggiraph/dev/reference/validated_fonts.md)

## Examples

``` r
match_family("sans")
#> [1] "DejaVu Sans"
match_family("serif")
#> [1] "DejaVu Serif"
```
