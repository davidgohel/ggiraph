## Test environments

* local mac-os R 4.4.2 installation
* Ubuntu and windows with R release and devel
* win-builder (older, release and devel)

## R CMD check results

There were no ERROR, WARNING or NOTE.

## Reverse dependencies

There is two issues related to ggiraph that have been detected with 
'packcircles' and 'ceterisParibus'. The deprecation message 
"Function `ggiraph()` is replaced by `girafe()` and will be removed soon."
is there since almost 2 years now. 'ceterisParibus' has been contacted
in March 2023 but did not answer. https://github.com/pbiecek/ceterisParibus/issues/24


