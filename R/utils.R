# convert to latin-ascii (first line) and then
# convert to kebab case and
# remove non space or alphanumeric characters
title_kebab <-  function(title) {
    # https://stackoverflow.com/a/38171652/7322615
    stringi::stri_trans_general((title), "latin-ascii") |>
    stringr::str_to_lower() |>
    stringr::str_remove_all("[^[:alnum:][:space:]]") |>
    stringr::str_replace_all(" ", "-")
}


# wrap description at 77 characters (are URLs allowed?)
long_yaml_text <- function(txt) {
    stringr::str_wrap(txt, width = 77) |>
    stringr::str_replace_all("[\n]", "\n  ")
    }


# formatting for long or empty description
prepare_description <- function(txt) {
    ifelse(txt != "",
        paste0("description:  |\n  ", long_yaml_text(txt)),
        'description: ""')
}

# check if an image is provided
prepare_image_name <-  function(txt) {
    ifelse(is.null(txt), "", txt$name)
}

# flatten categories vector
prepare_categories <-  function(cat, new) {
    if (new == "") {new = NULL}
    cat <- stringr::str_sort(c(cat, new)) |>
        stringr::str_flatten(collapse = ", ")
}


# build YAML
prepare_yaml <-  function(args, desc, img_name, cats) {
    paste(c(
        "---",
        glue::glue('title: "{args$title}"'),
        glue::glue('subtitle: "{args$subtitle}"'),
        glue::glue('{desc}'),
        glue::glue('author: "{args$author}"'),
        glue::glue('date: "{args$date}"'),
        glue::glue('image: "{img_name}"'),
        glue::glue('image-alt: "{args$alt}"'),
        glue::glue('categories: [{cats}]'),
        # date-modified starts always with date choice
        glue::glue('date-modified: "{args$date}"'),
        glue::glue('draft: true'),
        "---\n"
        ), collapse = "\n"
    )
}

# extract categories form yaml with square brackets
# look for "categories:" AND followed by zero or more white-space characters AND
# "[" AND followed by zero or more character class of white-space and nonwhite characters AND
# finally followed by the closing bracket "]"
extract_cat_brackets <- function(f) {
    stringr::str_extract(f, "categories:\\s*\\[[\\s\\S]*\\]") |>
    stringr::str_remove("categories:\\s*\\[") |>
    stringr::str_remove("\\]") |>
    stringr::str_split_1(",") |>
    stringr::str_remove_all('\"') |>
    stringr::str_trim()
}

# extract categories from yaml with dashed
extract_cat_dashes <-  function(f) {
    stringr::str_remove(f, '^[\\s\\S]*categories:\\s') |>
    stringr::str_remove('\\n[:alpha:].*\\n(.*)\\n---') |>
    stringr::str_split_1('\\n\\s*-') |>
    stringr::str_remove_all('\"') |>
    stringr::str_trim() |>
    stringi::stri_omit_empty('')
}


# collect categories
get_cat <- function() {
    f_list = list()
    cat_vec = NULL


    # find all "*.qmd" files under folder "posts"
    fp <- fs::dir_ls(path = here::here("posts"), recurse = TRUE, glob = "*.qmd")

    # read file contents into list variable
    for (i in 1:length(fp)) {
        f_list[i] <- readr::read_file(fp[i]) |>
            stringr::str_extract(stringr::regex("^---[\\s\\S]*^---", multiline = TRUE))
    }

    # extract yaml content
    for (i in 1:length(f_list)) {
        if (stringr::str_detect(f_list[[i]], "categories:")) {
            if (stringr::str_detect(f_list[[i]], "categories:\\s*\\[")) { # bracket notation
                cat_vec <- c(cat_vec, extract_cat_brackets(f_list[[i]]))
            } else {
                cat_vec <- c(cat_vec, extract_cat_dashes(f_list[[i]]))
            }
        }
    }
    return(unique(cat_vec))
}

