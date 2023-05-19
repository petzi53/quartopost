
# javascript: set cursor into title field <-  focus title field
jsFocus <- '
    $(document).on("shiny:connected", function(){
        $("input#title").focus();
      });
    '

# display dialog window to fill data for creating Quarto post
get_args <- function() {

  # start mini page
  ui <- miniUI::miniPage(
    # put javascript into html header
    htmltools::tags$head(htmltools::tags$script(htmltools::HTML(jsFocus))),

    # initialize shinyFeedback
    shinyFeedback::useShinyFeedback(),

    # start with panel
    miniUI::miniContentPanel(

      # first panel part: title, author, date, subtitle
      shiny::fillRow(height = "100px",
            flex = c(NA,2,1),
            shiny::textInput(
              inputId = "title",
              label = "Title (required)",
              placeholder = "Name of your blog post"
            ),
            shiny::textInput(
              inputId = "author",
              label = "Author",
              value = getOption("quartopost.author"),
              placeholder = "Author of this post"
            ),
            shiny::dateInput(
              inputId = "date",
              label = "Date",
              value = lubridate::today(),
            ),

      ),

      # subtitle
      shiny::fillRow(height = "70px",
        shiny::textInput(
            inputId = "subtitle",
            label = "Subtitle",
            placeholder = "subtitle (optional)",
            width = "100%",
        ),
      ),
      htmltools::hr(),
############ end of title, author, date, subtitle ##############

          # start panel part for categories
          # don't display selectInput if there are no categories
          if (!is.null(my_cats <- get_cat())) {
              shiny::fillRow(height = "70px",
                  shiny::selectInput(
                      inputId = "categories",
                      label = "Categories",
                      multiple = TRUE,
                      choices = c(
                        "Choose one of the categories already used" = "",
                        stringr::str_sort(get_cat())
                      ),
                  ),
                  shiny::textInput(
                      inputId = "newcat",
                      label = "Add categories, separated with comma",
                      placeholder = "cat1, cat2, cat3"
                  ),
              )
         } else {
             shiny::fillRow(height = "70px",
                shiny::textInput(
                    inputId = "newcat",
                    label = "No categories available. Add your first categories, separated with comma",
                    placeholder = "cat1, cat2, cat3",
                    width = "100%"
                ),
             )
         },
          htmltools::hr(),
################     end of categories   #######################

            # start panel for image upload
            shiny::fillRow(
            shiny::fileInput("newimg", "Image",
              placeholder =
                "Select external image", accept = "image/*"
            ),
            shiny::column(width = 6, offset = 2),
            height = "70px"
          ),
          shiny::fillRow(
            shiny::textInput(
              "alt", "Alternative text", "", "100%",
              "Replacement text when image is not available"
            ),
            height = "70px"
          ),
          htmltools::hr(),
####################     end of images    ######################

          # start panel for description
          shiny::fillRow(
            shiny::textAreaInput(
              inputId = "description",
              label = "Description",
              placeholder =
                "Write (optional) a short description, summary or introductory paragraph. Markdown is allowed.",
              width = "100%",
              rows = 8
            ),
            height = "70px"
          ),
##############   end of description ###########################
    ), # end of mini content panel

    miniUI::gadgetTitleBar("Enter the YAML fields for your post"),

  ) # end of mini page


  server <- function(input, output, session) {

    # Check status of title and return feedback message
    title_ok <- shiny::reactive({
        shinyFeedback::hideFeedback("title")
        if (title_empty <- (is.null(input$title) || input$title == "")) {
            shinyFeedback::feedbackWarning("title", show = TRUE, "Enter a title or click the 'Cancel' button")
            shiny::req(!title_empty)
        } else {
            slug <- paste0(
                "posts/", input$date, "-",
                title_kebab(input$title)
            )
            new_post_file <- paste0(slug, "/", "index.qmd")
            if (title_exists <- file.exists(new_post_file)) {
                shinyFeedback::feedbackDanger("title", show = TRUE, "File already exists, rename it")
                shiny::req(!title_exists)
            }
            shinyFeedback::feedbackSuccess("title", show = TRUE, "Valid file name")
            return(list(title = input$title, slug = slug, filename = new_post_file))
        }
    })

    # observe title field for feedback messages
    shiny::observeEvent(
        eventExpr = input$title,
        handlerExpr = title_ok(),
        ignoreInit = TRUE
    )

    # When the Done button is clicked, return a value
    shiny::observeEvent(input$done, {
      returnValue <- list(
        title_ok(), input$author,
        input$date, input$newimg, input$alt,
        input$subtitle, input$description,
        input$categories, input$newcat
      )
      names(returnValue) <- c(
        "file_data", "author", "date",
        "image", "alt", "subtitle", "description",
        "categories", "newcat"
      )
      shiny::stopApp(returnValue)
    })

    # No error message when user presses "Cancel" button
    shiny::observeEvent(input$cancel, {
      shiny::stopApp(NULL)
    })
  }

  shiny::runGadget(ui, server,
    viewer =
      shiny::dialogViewer("Quarto Blog Post Fields", width = 650, height = 800)
  )
}
