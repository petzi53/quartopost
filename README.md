
# quartopost

<!-- badges: start -->
<!-- badges: end -->

The goal of `quartopost` is to create and open a Quarto blog post in
RStudio.

`quartopost()` displays a dialog window where you can enter the data for
the YAML header of a new blog post. After clicking the “Done” button the
function generates the core skeleton of a Quarto post. This includes: -
creating the directory (named with the date and title in kebab
notation) - (optionally) copying images from your hard disk into this
new folder - creating the `index.qmd` file with the YAML header
populated from the data of the dialog window - opening the blog post
file in RStudio for editing.

You can choose from your categories already created or add new
categories. With the package comes also an RStudio Addin so you can bind
the `quartopost()` with a shortcut.

## Installation

You can install the development version of `quartopost` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("petzi53/quartopost")
#> Downloading GitHub repo petzi53/quartopost@HEAD
#> rlang (1.1.0 -> 1.1.1) [CRAN]
#> fs    (1.6.1 -> 1.6.2) [CRAN]
#> vroom (1.6.1 -> 1.6.3) [CRAN]
#> Installing 3 packages: rlang, fs, vroom
#> Installing packages into '/private/var/folders/sd/g6yc4rq1731__gh38rw8whvc0000gq/T/RtmpRKKyNk/temp_libpath177934f432b52'
#> (as 'lib' is unspecified)
#> 
#> The downloaded binary packages are in
#>  /var/folders/sd/g6yc4rq1731__gh38rw8whvc0000gq/T//Rtmp46LhIn/downloaded_packages
#> ── R CMD build ─────────────────────────────────────────────────────────────────
#> * checking for file ‘/private/var/folders/sd/g6yc4rq1731__gh38rw8whvc0000gq/T/Rtmp46LhIn/remotes1803d10902f2c/petzi53-quartopost-2749f8d/DESCRIPTION’ ... OK
#> * preparing ‘quartopost’:
#> * checking DESCRIPTION meta-information ... OK
#> * checking for LF line-endings in source and make files and shell scripts
#> * checking for empty or unneeded directories
#> * building ‘quartopost_0.0.0.9000.tar.gz’
#> Installing package into '/private/var/folders/sd/g6yc4rq1731__gh38rw8whvc0000gq/T/RtmpRKKyNk/temp_libpath177934f432b52'
#> (as 'lib' is unspecified)
```

## Example

``` r
library(quartopost)

if (interactive()) quartopost()
```
