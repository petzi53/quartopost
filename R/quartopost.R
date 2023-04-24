#' create a new quarto blog post
#'
#' Sets up the directory for a new blog post.
#' Note this function was modified from the one originally supplied
#' by [Tom Mock](https://themockup.blog/posts/2022-11-08-use-r-to-generate-a-quarto-blogpost/).
#'
#' Title
#'
#' @return
#' @export
#'
#' @examples
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
                                         placeholder = "Write (optional) a short description, about one paragraph",
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
            returnValue <- list(input$title, input$author,
                                input$subtitle, input$description)
            names(returnValue) <- c("title", "author",
                                    "subtitle", "description")
            shiny::stopApp(returnValue)
        })
    }

    shiny::runGadget(ui, server, viewer =
         shiny::dialogViewer("Search Hypothes.is notes", width = 650, height = 350)
    )
}
