## Test environments

* local R installation, R 4.3.2
* Ubuntu, mac-os and windows with R release
* win-builder (older, release and devel)

## R CMD check results

There were no ERROR, WARNING or NOTE.

## Reverse dependencies

There is a new issue related to ggiraph with package 'vlda' because
`ggiraphOutput()` has been deprecated in favor of `girafeOutput()`.
Author of 'vlda' was notified almost a year ago that this 
function would be deprecated (https://github.com/pnuwon/vlda/issues/1).

