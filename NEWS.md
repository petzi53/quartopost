# quartopost 0.3.0

* New UI: Bigger window holds all fields in one tab
* Add proof if title is valid inside the dialog window.
* Provide feedback of status of title field after loosing focus
* Remove failed file creation if title is not valid (not needed anymore)
* Add configuration for draft post status
* Add configuration to show or hide empty fields
* Resolve bug: Put cursor at the end of the YAML front matter.

# quartopost 0.2.2

* Find the first YAML header to prevent that YAML from R code example is taken 


# quartopost 0.2.1

* Resolved bug to find YAML header

# quartopost 0.2.0

* Added configuration settings
    - verbose = FALSE: 
      - Do not ask user for confirmation before action 
      - Do not show error message when user cancels


* Added checks for user input
    - Is it a quarto website?
    - Is a title provided?
    - Does the file name already exist?

# quartopost 0.1.0

* Added a `NEWS.md` file to track changes to the package.
