# List of validated default fonts

Validates and possibly modifies the fonts to be used as default value in
a graphic according to the fonts available on the machine. It processes
elements named "sans", "serif", "mono" and "symbol".

Default font resolution is delegated to
[`gdtools::font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.html),
which uses Liberation fonts (bundled by 'fontquiver', SIL Open Font
License) for reproducible offline output.

## Usage

``` r
validated_fonts(fonts = list())
```

## Arguments

- fonts:

  Named list of font names to be aliased with fonts installed on your
  system. If unspecified, the defaults from
  [`gdtools::font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.html)
  are used.

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
#> [1] "Liberation Sans"
#> 
#> $serif
#> [1] "Liberation Serif"
#> 
#> $mono
#> [1] "Liberation Mono"
#> 
#> $symbol
#> [1] "Liberation Sans"
#> 
```
