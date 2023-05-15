jsFocus <- '
    $(document).on("shiny:connected", function(){
        $("input#title").focus();
      });
    '

get_args <- function() {
  ui <- miniUI::miniPage(
    shinyjs::useShinyjs(),
    shinyFeedback::useShinyFeedback(),
    shinyfocus::shinyfocus_js_dependency(),
    htmltools::tags$head(htmltools::tags$script(htmltools::HTML(jsFocus))),
        miniUI::miniContentPanel(
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
          shiny::fillRow(height = "70px",
            shiny::textInput(
                inputId = "subtitle",
                label = "Subtitle",
                placeholder = "subtitle (optional)",
                width = "100%",
            ),
          ),
          htmltools::hr(),
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
          ),
          htmltools::hr(),
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
    ),
    miniUI::gadgetTitleBar("Enter the YAML fields for your post"),
  )


  server <- function(input, output, session) {

    # Check if title is OK

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

    shinyfocus::on_blur(
        "title",
        title_ok()
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
