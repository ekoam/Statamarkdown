
.onLoad <- function (libname, pkgname) {
    if (!requireNamespace("utils")) stop("Requires utils package.")
    utils::globalVariables("hook_orig") # to suppress CHECK note
}

.onAttach <- function (libname, pkgname) {
  if (!requireNamespace("knitr")) stop("Requires knitr package.")
  knitr::knit_engines$set(stata=stata_engine)

  knitr::opts_chunk$set(#engine="stata", #engine.path=stataexe,
                        error=TRUE, cleanlog=TRUE, comment=NA)

  stata_collectcode()

  assign("hook_orig", knitr::knit_hooks$get("output"), pos=2)
  # knitr::knit_hooks$set(output = Statamarkdown::stataoutputhook)
  knitr::knit_hooks$set(output = stataoutputhook)

  packageStartupMessage("The 'stata' engine is ready to use.")

}
