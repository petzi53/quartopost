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
                         width = "70%"
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

