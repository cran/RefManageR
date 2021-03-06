% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/WriteBib.R
\name{WriteBib}
\alias{WriteBib}
\title{Create a BibTeX File from a BibEntry Object
e
Creates a Bibtex File from a BibEntry object for use with either BibTeX
or BibLaTex.}
\usage{
WriteBib(
  bib,
  file = "references.bib",
  biblatex = TRUE,
  append = FALSE,
  verbose = TRUE,
  ...
)
}
\arguments{
\item{bib}{a BibEntry object to be written to file}

\item{file}{character string naming a file, should; end in \dQuote{.bib}.
Can be \code{NULL}, in which case the BibEntry object will be written
to \code{\link{stdout}}.}

\item{biblatex}{boolean; if \code{TRUE}, \code{\link{toBiblatex}} is used
and no conversions of the BibEntry object
are done; if \code{FALSE} entries will be converted as described in
\code{\link{toBibtex.BibEntry}}.}

\item{append}{as in \code{write.bib} in package \code{bibtex}}

\item{verbose}{as in \code{write.bib} in package \code{bibtex}}

\item{...}{additional arguments passed to \code{\link{writeLines}}}
}
\value{
\code{bib} - invisibly
}
\description{
Create a BibTeX File from a BibEntry Object
e
Creates a Bibtex File from a BibEntry object for use with either BibTeX
or BibLaTex.
}
\note{
To write the contents of \code{bib} \dQuote{as is}, the argument
\code{biblatex} should be \code{TRUE}, otherwise
conversion is done as in \code{\link{toBibtex.BibEntry}}.
}
\examples{
if (requireNamespace("bibtex")){
    bib <- BibEntry("Article", key = "Carroll_2012",
                    doi = "10.1080/01621459.2012.699793",
                    year = "2012", month = "sep",
                    volume = 107, number = 499,
                    pages = {1166--1177},
      author = "R. Carroll and A. Delaigle and P. Hall",
      title = "Deconvolution When Classifying Noisy Data ...",
      journal = "Journal of the American Statistical Association")

  ## Write bib if no server error and bibtex available
  if (length(bib)){
    tfile <- tempfile(fileext = ".bib")
    WriteBib(bib, tfile, biblatex = TRUE)
    identical(ReadBib(tfile), bib)
    unlink(tfile)
  }
}
}
\seealso{
\code{write.bib} in package \code{bibtex}, \code{\link{ReadBib}},
\code{\link{toBibtex.BibEntry}}, \code{\link{toBiblatex}},
\code{\link{BibEntry}}
}
\author{
McLean, M. W. based on \code{write.bib} by Gaujoux, R.
in package \code{bibtex}.
}
\keyword{IO}
