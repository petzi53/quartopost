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

#################################################################
qp <-  function() {

    params <- get_args()

    stopifnot("Your blog post has no title!" =
              params$title != "")
    slug <- paste0("posts/", params$date, "-",
            title_kebab(params$title) )
    new_post_file <- paste0(slug, '/', "index.qmd")
    stopifnot("File name already exists!" =
         !file.exists(new_post_file))

    description <- prepare_description(params$description)
    image_name <- prepare_image_name(params$image)
    cats <- prepare_categories(params$categories, params$newcat)
    post_yaml <- prepare_yaml(params, description, image_name, cats)


    # create directory and file
    fs::dir_create(path = slug)
    fs::file_create(new_post_file)
    writeLines(
        text = post_yaml,
        con = new_post_file
    )

    # copy image
    if (!is.null(params$image)) {
        fs::file_copy(params$image$datapath,
                      paste0(slug, '/', params$image$name))
    }

    rstudioapi::documentOpen(new_post_file,
                             line = (length(post_yaml) + 1))
    invisible() # prevent console output
}


#################################################################
get_args <- function() {

    ui <- miniUI::miniPage(
        miniUI::miniTabstripPanel(
            miniUI::miniTabPanel("Essentials", icon = shiny::icon("sliders"),
                 miniUI::miniContentPanel(
                     shiny::fillRow(flex = c(7,4,3),
                        shiny::textInput(
                            inputId = "title",
                            label = "Title (try to be under 40 characters)",
                            placeholder = "Name of your blog post",
                        ),
                        shiny::textInput(
                            inputId = "author",
                            label = "Author",
                            value = getOption("quartopost.author"),
                            placeholder = "Author of this post",
                        ),
                        shiny::fillRow(shiny::dateInput(
                            inputId = "date",
                            label = "Date",
                            value = lubridate::today(),
                        ),
                        ),
                        height = "70px"
                     ),
                     shiny::fillRow(shiny::textInput(
                         inputId = "subtitle",
                         label = "Subtitle",
                         placeholder = "subtitle (optional)",
                         width = "100%"
                     ),
                     ),
                 ),
            ),
            miniUI::miniTabPanel("Categories", icon = shiny::icon("area-chart"),
                 miniUI::miniContentPanel(
                     shiny::fillRow(shiny::selectInput(
                         inputId = "categories",
                         label = "Categories",
                         choices = c("Choose one of the categories already used" = "",
                                     stringr::str_sort(get_cat())),
                         multiple = TRUE,
                         width = "100%"
                        ),
                        height = "100px"
                    ),
                    shiny::fillRow(shiny::textInput(
                        inputId = "newcat",
                        label = "Create a new categorie",
                        placeholder = "Add new categories separated with a comma",
                        width = "100%"
                    ),
                    height = "70px"
                    ),
                ),
            ),
            # shiny::fillRow(htmltools::hr(), height = '50px'),
            miniUI::miniTabPanel("Image", icon = shiny::icon("area-chart"),
                 miniUI::miniContentPanel(
                     shiny::fillRow(
                         shiny::fileInput('newimg', 'Image', placeholder =
                              'Select external image', accept = "image/*"),
                         shiny::column(width = 6, offset = 2, shiny::uiOutput('overbutton')),
                         height = '70px'
                     ),
                     shiny::fillRow(
                         shiny::textInput('alt', 'Alternative text', '', "100%",
                              'Replacement text when image is not available'),
                         height = '70px'
                     ),
                 ),
            ),


            miniUI::miniTabPanel("Description", icon = shiny::icon("table"),
                 miniUI::miniContentPanel(
                     shiny::fillRow(shiny::textAreaInput(
                         inputId = "description",
                         label = "Description",
                         placeholder =
"Write (optional) a short description, summary or introductory paragraph. Markdown is allowed.",
                         width = "100%",
                         rows = 8
                     ),
                     height = "70px"
                     )
                 )
            )
        ),
        miniUI::gadgetTitleBar("Enter the YAML fields for your post")
    )

    server <- function(input, output, session) {

        # When the Done button is clicked, return a value
        shiny::observeEvent(input$done, {
            returnValue <- list(input$title, input$author,
                input$date, input$newimg, input$alt,
                input$subtitle, input$description,
                input$categories, input$newcat)
            names(returnValue) <- c("title", "author", "date",
                "image", "alt", "subtitle", "description",
                "categories", "newcat")
            shiny::stopApp(returnValue)
        })
    }

    shiny::runGadget(ui, server, viewer =
         shiny::dialogViewer("Quarto Blog Post Fields", width = 650, height = 350)
    )
}

