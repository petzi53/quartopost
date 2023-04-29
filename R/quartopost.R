quartopost <-  function() {

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

