# Find best family match with systemfonts

`match_family()` is deprecated: use
[`systemfonts::match_fonts()`](https://systemfonts.r-lib.org/reference/match_fonts.html)
instead. It is no longer used by ggiraph, and its equivalent in
'gdtools' is deprecated too.

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
