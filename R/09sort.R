#' Sort a BibEntry Object
#'
#' Sorts a \code{BibEntry} object by specified fields.  The possible fields used
#' for sorting and the order they are used in correspond with the options
#' available in BibLaTeX.
#'
#' @param x an object of class BibEntry
#' @param decreasing logical; should the sort be increasing or decreasing?
#' @param sorting sort method to use, see \bold{Details}.
#' @param .bibstyle bibliography style; used when \code{sort} is called by
#' \code{\link{print.BibEntry}}
#' @param ... internal use only
#' @return the sorted BibEntry object
#' @method sort BibEntry
#' @export
#' @keywords manip methods
#' @importFrom methods hasArg
#' @details The possible values for argument \code{sorting} are
#' \itemize{
#' \item nty - sort by name, then by title, then by year
#' \item nyt - sort by name, then by year, then title
#' \item nyvt - sort by name, year, volume, title
#' \item anyt - sort by alphabetic label, name, year, title
#' \item anyvt - sort by alphabetic label, name, year, volume, title
#' \item ynt - sort by year, name, title
#' \item ydnt - sort by year (descending), name, title
#' \item debug - sort by keys
#' \item none - no sorting is performed
#' }
#'
#' All sorting methods first consider the field presort, if available.
#' Entries with no presort field are assigned presort
#' value \dQuote{mm}. Next the sortkey field is used.
#'
#' When sorting by name, the sortname field is used first.  If it is not present,
#' the author field is used,
#' if that is not present editor is used, and if that is not present translator is
#' used.  All of these fields are affected
#' by the value of \code{max.names} in .BibOptions()$max.names.
#'
#' When sorting by title, first the field sorttitle is considered.  Similarly,
#' when sorting by year, the field sortyear is
#' first considered.
#'
#' When sorting by volume, if the field is present it is padded to four digits
#' with leading zeros; otherwise, the string \dQuote{0000} is used.
#'
#' When sorting by alphabetic label, the labels that would be generating with
#' the \dQuote{alphabetic} bibstyle are used.  First the shorthand field is
#' considered, then label, then shortauthor, shorteditor, author, editor,
#' and translator.  Refer to the BibLaTeX manual Sections 3.1.2.1 and 3.5 and
#' Appendix C.2 for more information.
#' @references Lehman, Philipp and Kime, Philip and Boruvka, Audrey and
#' Wright, J. (2013). The biblatex Package.
#' \url{http://mirrors.ibiblio.org/CTAN/macros/latex/contrib/biblatex/doc/biblatex.pdf}.
#' @seealso \code{\link{BibEntry}}, \code{\link{print.BibEntry}}, \code{\link{order}}
#' @importFrom tools bibstyle getBibstyle
#' @examples
#' if (requireNamespace("bibtex")) {
#'     file.name <- system.file("Bib", "biblatexExamples.bib", package="RefManageR")
#'     bib <- suppressMessages(ReadBib(file.name)[[70:73]])
#'     BibOptions(sorting = "none")
#'     bib
#'     sort(bib, sorting = "nyt")
#'     sort(bib, sorting = "ynt")
#'     BibOptions(restore.defaults = TRUE)
#' }
sort.BibEntry <- function(x, decreasing = FALSE, sorting = BibOptions()$sorting,
                          .bibstyle = BibOptions()$bib.style, ...){
  sort.fun.env <- GetFormatFunctions(DateFormatter = I)
  if (is.null(sorting))
    sorting <- "nty"
  if (sorting == 'debug' || .bibstyle == 'draft')
    return(x[order(names(x))])
  if (sorting != "none"  || .bibstyle == "alphabetic"){
    aut <- sort.fun.env$sortKeys(x)
    yr <- sort.fun.env$sortKeysY(x)
    ps <- sort.fun.env$sortKeysPS(x)
    ttl <- sort.fun.env$sortKeysT(x)
    if (sorting %in% c('nyvt', 'anyvt'))
      vol <- sort.fun.env$sortKeysV(x)
  }
  if (.bibstyle == 'alphabetic' || sorting == 'anyt' || sorting == 'anyvt')
    alabs <- sort.fun.env$sortKeysLA(x, yr)

  if (sorting != "none"){
    ord <- switch(sorting, nyt = order(ps, aut, yr, ttl,
                                       decreasing = decreasing),
                  nyvt = order(ps, aut, yr, vol, ttl,
                               decreasing = decreasing),
                  anyt = order(ps, alabs, aut, yr, ttl,
                               decreasing = decreasing),
                  anyvt = order(ps, alabs, aut, yr, vol, ttl,
                                decreasing = decreasing),
                  ynt = order(ps, yr, aut, ttl,
                              decreasing = decreasing),
                  ydnt = order(ps, -as.numeric(yr), aut, ttl,
                               decreasing = decreasing),
                  ## DEFAULT = nty
                  order(ps, aut, ttl, yr, decreasing = decreasing))
    suppressWarnings(x <- x[ord])
    aut <- aut[ord]
    if (.bibstyle == "alphabetic"){
      lab.ord <- order(alabs)
      alabs[lab.ord] <- paste0(alabs[lab.ord],
                               unlist(lapply(rle(alabs[lab.ord])$len,
                                             function(x){
                                               if (x == 1)
                                                 ''
                                               else letters[seq_len(x)]
                                             })))

      alabs <- alabs[ord]
    }
  }
  # create labels if needed
  if (hasArg(return.labs) && !length(unlist(x$.index))){
    if (.bibstyle %in% c("authoryear", "authortitle")){
      if (sorting == "none")
        aut <- sort.fun.env$sortKeys(x)
      suppressWarnings({
        ind <- nchar(aut) == 0L & !x$bibtype %in% c("XData", "Set")
        aut[ind] <- x$title[ind]
        x$.duplicated <- duplicated(aut)
      })
      if (.bibstyle == "authoryear"){
        tmp <- sort.fun.env$GetLastNames(x)

        ## can't call sortKeysY because need to ignore sortyear field
        YearLab <- function(date){
                       if (inherits(date, "POSIXct"))
                           as.character(year(date))
                       else if (inherits(date, "Interval"))
                           as.character(year(int_start(date)))
                       else
                           ""
                   }
        yr <- vapply(x$dateobj, YearLab, "")
        tmp <- paste0(tmp, yr)

        lab.ord <- order(tmp)
        alabs <- character(length(x))
        alabs[lab.ord] <- unlist(lapply(rle(tmp[lab.ord])$len,
                                                     function(x){
                                                       if (x == 1)
                                                         ''
                                                       else
                                                           letters[seq_len(x)]
                                                     }))
      }
    }
    suppressWarnings(x$.index <- switch(.bibstyle, numeric = {
      ind <- which(!unlist(x$bibtype) %in% c('Set', 'XData'))
      index <- numeric(length(x))
      index[ind] <- seq_along(ind)
      index
      }, alphabetic = alabs, authoryear = alabs, NULL))
  }
  x
}

