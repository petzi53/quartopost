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
        miniUI::miniContentPanel(
            shiny::fillRow(flex = c(4,2),
                    shiny::textInput(
                        inputId = "title",
                        label = "Title, max. 40 character",
                        placeholder = "Name of your blog post",
                        width = "100%"
                        ),
                    shiny::textInput(
                        inputId = "author",
                        label = "Author",
                        value = getOption("quartopost.author"),
                        placeholder = "Name of your blog post",
                        ),
                    height = "70px"
                ),
            shiny::fillRow(shiny::textInput(
                inputId = "subtitle",
                label = "Subtitle",
                placeholder = "subtitle (optional)",
                width = "100%"
                ),
                height = "70px"
            ),
            shiny::fillRow(shiny::textAreaInput(
                inputId = "description",
                label = "Description",
                placeholder = "Write optional a short description, about one paragraph",
                width = "100%"
                ),
                height = "100px"
            ),
            shiny::fillRow(
                shiny::fileInput('newimg', 'Image', placeholder = 'Select external image'),
                shiny::column(width = 6, offset = 2, shiny::uiOutput('overbutton')),
                height = '90px'
            ),
            shiny::fillRow(
                shiny::textInput('w', 'Width', '', "50%", '(optional) e.g., 400px or"80%'),
                shiny::textInput('h', 'Height', '', "50%", '(optional) e.g., 200px'),
                height = '70px'
            ),
            shiny::fillRow(
                shiny::textInput('alt', 'Alternative text', '', "100%", '(optional but recommended) e.g., awesome screenshot'),
                height = '70px'
            ),
            shiny::fillRow(
                shiny::textInput('target', 'Target file path', '', "100%", '(optional) customize if necessary'),
                height = '70px'
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
         shiny::dialogViewer("Search Hypothes.is notes", width = 600, height = 600)
    )
}
