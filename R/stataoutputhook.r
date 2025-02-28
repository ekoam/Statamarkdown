stataoutputhook <- function(x, options) {
  if (options$noisey == TRUE) {
    message(paste("\n", options$engine, "output from chunk", options$label))
    message("input to stataoutputhook()")
    message(x)
  }
  x_noprofile <-
    sub(
      "^.*[R|r]unning[[:space:]].*p(\\\n>[[:space:]])?r(\\\n>[[:space:]])?o(\\\n>[[:space:]])?f(\\\n>[[:space:]])?i(\\\n>[[:space:]])?l(\\\n>[[:space:]])?e(\\\n>[[:space:]])?\\.(\\\n>[[:space:]])?d(\\\n>[[:space:]])?o(\\\n>[[:space:]])?[[:space:]](\\\n>[[:space:]])?\\.(\\\n>[[:space:]])?\\.(\\\n>[[:space:]])?\\.[[:space:]]?[[:space:]]?",
      "",
      x
    )
  if (options$engine == "stata") {
    y <- strsplit(x_noprofile, "\n")[[1]]
    # print("input to stata output parse")
    # print(y)
    # Remove "running profile.do"
    running <-
      grep("^\\.?[[:space:]]?[R|r]unning[[:space:]].*profile.do",
           y)
    if (length(running) > 0) {
      y[running] <-
        sub("^\\.?[[:space:]]?[R|r]unning[[:space:]].*profile.do",
            "",
            y[running])
    }
    # print("running removed")
    # print(y)
    # Remove command echo in Stata log
    if (length(options$cleanlog) == 0 | options$cleanlog != FALSE) {
      commandlines <- grep("^\\.[[:space:]]", y)
      # print(commandlines)
      if (length(commandlines) > 0) {
        # loopcommands <- grep("^[[:space:]][[:space:]][[:digit:]+]\\.", y)
        loopcommands <- grep("^[[:space:]]+[[:digit:]]+\\.", y)
        if (length(commandlines) > 0 && length(loopcommands) > 0) {
          for (i in 1:length(loopcommands)) {
            if ((loopcommands[i] - 1) %in% commandlines) {
              commandlines <- c(commandlines, loopcommands[i])
            }
          }
        }
      }
      # print(commandlines)
      continuations <- grep("^>[[:space:]]", y)
      #        print(y[continuations])
      if (length(commandlines) > 0 && length(continuations) > 0) {
        for (i in 1:length(continuations)) {
          if ((continuations[i] - 1) %in% commandlines) {
            commandlines <- c(commandlines, continuations[i])
          }
        }
      }
      # print(commandlines)
      # print("Stata command lines")
      # print(y[commandlines])
      if (length(commandlines) > 0) {
        y <- y[-(commandlines)]
      }

      # Some commands have a leading space?
      if (length(grep("^[[:space:]*]\\.", y)) > 0) {
        y <- y[-(grep("^[[:space:]*]\\.", y))]
      }
    }
    # Ensure a trailing blank line
    if (length(y) > 0 && y[length(y)] != "") {
      y <- c(y, "")
    }
    # print("Command lines removed")
    # print(y)
    # Remove blank lines at the top of the Stata log
    firsttext <- min(grep("[[:alnum:]]", y))
    if (firsttext != Inf &&
        firsttext != 1) {
      y <- y[-(1:(firsttext - 1))]
    }
  } else {
    y <- x
  }
  # print("from stataoutputhook")
  # print(y)
  # Now treat the result as regular output
  hook_orig(y, options)
}
