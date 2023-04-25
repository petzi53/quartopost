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


#################################################################
qp <-  function() {
    params <- get_args()

    slug <- paste0("posts/", params$date, "-",
                        title_kebab(params$title)
                )

    new_post_file <- paste0(slug, '/', "index.qmd")
    description <- long_yaml_text(params$description)


    # build YAML
    post_yaml <- c(
        "---",
        glue::glue('title: "{params$title}"'),
#        "subtitle:  |",
        glue::glue('subtitle: "{params$subtitle}"'),
        "description: |",
        glue::glue('  {description}'),
        glue::glue('author: "{params$author}"'),
        glue::glue('date: "{params$date}"'),
        "---\n"
        )
    paste(post_yaml, collapse = "\n")

    # create directory
    fs::dir_create(
        path = slug
    )

    # create file
    fs::file_create(new_post_file)
    writeLines(
        text = post_yaml,
        con = new_post_file
    )

    rstudioapi::documentOpen(new_post_file, line = (length(post_yaml) + 1))
    invisible()
}


#################################################################
get_args <- function() {

    ui <- miniUI::miniPage(
        # change CSS for hr:
        # https://stackoverflow.com/questions/43592163/horizontal-rule-hr-in-r-shiny-sidebar
        htmltools::tags$head(
            htmltools::tags$style(htmltools::HTML("hr {border-top: 1px solid #000000;}"))
        ),
        miniUI::miniTabstripPanel(
            miniUI::miniTabPanel("Essentials", icon = shiny::icon("sliders"),
                                 miniUI::miniContentPanel(
                                     shiny::fillRow(flex = c(7,4,3),
                                                    shiny::textInput(
                                                        inputId = "title",
                                                        label = "Title, max. 40 character",
                                                        placeholder = "Name of your blog post",
                                                    ),
                                                    shiny::textInput(
                                                        inputId = "author",
                                                        label = "Author",
                                                        value = getOption("quartopost.author"),
                                                        placeholder = "Name of your blog post",
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
                                         choices = c("Item1", "Item2", "Item3", "another Item"),
                                         multiple = TRUE,
                                         width = "100%"
                                        ),
                                    ),
                                ),
            ),

            # shiny::fillRow(htmltools::hr(), height = '50px'),
            miniUI::miniTabPanel("Image", icon = shiny::icon("area-chart"),
                                 miniUI::miniContentPanel(
                                     shiny::fillRow(
                                         shiny::fileInput('newimg', 'Image', placeholder = 'Select external image'),
                                         shiny::column(width = 6, offset = 2, shiny::uiOutput('overbutton')),
                                         height = '70px'
                                     ),
                                     # shiny::fillRow(
                                     #     shiny::textInput('w', 'Width', '', "50%", '(optional) e.g., 400px or"80%'),
                                     #     shiny::textInput('h', 'Height', '', "50%", '(optional) e.g., 200px'),
                                     #     height = '70px'
                                     # ),
                                     shiny::fillRow(
                                         shiny::textInput('alt', 'Alternative text', '', "100%", '(optional but recommended) e.g., awesome screenshot'),
                                         height = '70px'
                                     ),
                                     shiny::fillRow(
                                         shiny::textInput('target', 'Target file path', '', "100%", '(optional) customize if necessary'),
                                         height = '70px'
                                     ),
                                 ),
            ),


            miniUI::miniTabPanel("Description", icon = shiny::icon("table"),
                                 miniUI::miniContentPanel(
                                     shiny::fillRow(shiny::textAreaInput(
                                         inputId = "description",
                                         label = "Description",
                                         placeholder = "Write (optional) a short description, summary or introductory paragraph. Markdown is allowed.",
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
        # Define reactive expressions, outputs, etc.
        output$title <- shiny::renderText({ input$title })
        output$author <- shiny::renderText({ input$author })
        # my_list = paste(shiny::renderText( { input$title } ),
        #                 shiny::renderText( { input$author })
        #                 )

        # When the Done button is clicked, return a value
        shiny::observeEvent(input$done, {
            returnValue <- list(input$title, input$author, input$date,
                                input$subtitle, input$description)
            names(returnValue) <- c("title", "author", "date",
                                    "subtitle", "description")
            shiny::stopApp(returnValue)
        })
    }

    shiny::runGadget(ui, server, viewer =
         shiny::dialogViewer("Search Hypothes.is notes", width = 650, height = 350)
    )
}

