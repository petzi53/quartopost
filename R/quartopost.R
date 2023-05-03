#' Create a new quarto blog post
#'
#' `quartopost()` opens a dialog window to input title and other
#' desired data to create the file for the blog post.
#'
#' @return Nothing. What matters are the side effects:
#' - create a folder in kebab notation with the name of date followed by the post title
#' - create a "index.qmd" file
#' - copy the (optional) image file into the folder
#' - populate the YAML field
#' - open the file for editing
#' @export
#'
#' @examplesIf interactive()
#' quartopost()
quartopost <-  function() {

    # check if it is Quarto website and stop if not
    f <- readr::read_file("_quarto.yml")
    type_website <- stringr::str_extract(f, "type: website") == "type: website"
    if (is.na(type_website)) stop("This is not a Quarto website!")

    # display YAML header in console before creating folder and file?
    verbose = ifelse(is.null(getOption("quartopost.verbose")),
                     TRUE, getOption("quartopost.verbose"))

    # call the dialog window
    params <- get_args()

    # has the user canceled?
    if (is.null(params) & verbose == FALSE)
        return(invisible())
    if (is.null(params) & verbose == TRUE)
        return("User has cancelled")

    # is there a unique title?
    stopifnot("Your blog post has no title!" =
                  params$title != "")
    slug <- paste0("posts/", params$date, "-",
                   title_kebab(params$title) )
    new_post_file <- paste0(slug, '/', "index.qmd")
    stopifnot("File name already exists!" =
                  !file.exists(new_post_file))

    # prepare YAML header
    description <- prepare_description(params$description)
    image_name <- prepare_image_name(params$image)
    cats <- prepare_categories(params$categories, params$newcat)
    post_yaml <- prepare_yaml(params, description, image_name, cats)

    # display results in console
    if (verbose) {
        cat(paste0("New folder inside 'posts':",
        params$date, "-", title_kebab(params$title), "\n"))
        cat("YAML front matter:\n")
        cat(post_yaml)

        create_post <- (yesno::yesno("Create folder and file(s)?"))
        if (!create_post) return("Post creation canceled")
    }


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

    # open new post with YAML header in RStudio
    rstudioapi::documentOpen(new_post_file,
                             line = (length(post_yaml) + 1))
    invisible() # prevent console output
}

