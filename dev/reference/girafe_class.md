# Add, remove or toggle CSS classes on girafe elements

These functions allow programmatic manipulation of CSS classes on SVG
elements within a girafe output in Shiny applications. Elements are
targeted by their `data-id`, `key-id`, or `theme-id` attributes.

## Usage

``` r
girafe_class_add(
  session,
  id,
  class,
  data_id = NULL,
  key_id = NULL,
  theme_id = NULL
)

girafe_class_remove(
  session,
  id,
  class,
  data_id = NULL,
  key_id = NULL,
  theme_id = NULL
)

girafe_class_toggle(
  session,
  id,
  class,
  data_id = NULL,
  key_id = NULL,
  theme_id = NULL
)
```

## Arguments

- session:

  The Shiny session object.

- id:

  The output id of the girafe element (the `outputId` used in
  [`girafeOutput()`](https://davidgohel.github.io/ggiraph/dev/reference/girafeOutput.md)).

- class:

  A non-empty character string of CSS class names to add, remove, or
  toggle.

- data_id:

  A character vector of `data-id` values identifying the target
  elements.

- key_id:

  A character vector of `key-id` values identifying the target elements.

- theme_id:

  A character vector of `theme-id` values identifying the target
  elements.

## Details

At least one of `data_id`, `key_id`, or `theme_id` must be provided.

These functions send a custom message to the JavaScript side, which
applies the CSS class operation to all matching SVG elements within the
girafe root node.

## Examples

``` r
if (FALSE) { # \dontrun{
# In a Shiny server function:
girafe_class_add(session, "plot", "highlighted", data_id = "some_id")
girafe_class_remove(session, "plot", "highlighted", data_id = "some_id")
girafe_class_toggle(session, "plot", "highlighted", data_id = "some_id")
} # }
```
