\name{data.adult}
\alias{data.adult}
\docType{data}
\title{
Data Example (binary)
}
\description{
This data example contains binary (0/1) responses of 684 participants to 12 items. Particpants were classified into 34 clusters and 2 groups.
}
\usage{data("data.adult")}
\format{
  A data frame with 684 observations on the following 14 variables.
  \describe{
    \item{\code{Cluster}}{The cluster variable}
    \item{\code{I1}}{Item 1}
    \item{\code{I2}}{Item 2}
    \item{\code{I3}}{Item 3}
    \item{\code{I4}}{Item 4}
    \item{\code{I5}}{Item 5}
    \item{\code{I6}}{Item 6}
    \item{\code{I7}}{Item 7}
    \item{\code{I8}}{Item 8}
    \item{\code{I9}}{Item 9}
    \item{\code{I10}}{Item 10}
    \item{\code{I11}}{Item 11}
    \item{\code{I12}}{Item 12}
    \item{\code{Group}}{Binary group membership variable}
  }
}
\details{
A data set with 14 variables: (1) binary (0/1) responses of 684 participants to 12 items; (2) a cluster indicator variable; and (3) a group indicator variable.}
\examples{
data(data.adult)
## maybe str(data.adult) ; plot(data.adult) ...
}
\keyword{datasets}
