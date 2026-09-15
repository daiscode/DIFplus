\name{data.adult.revised}
\alias{data.adult.revised}
\docType{data}
\title{
Modified data.adult by removing all strata with zero marginal means.
}
\description{
This data example contains binary (0/1) responses of 684 participants to 12 items. Particpants were classified into 10 clusters, 2 groups, and 3 strata.
}
\usage{data("data.adult.revised")}
\format{
  A data frame with 684 observations on the following 15 variables.
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
    \item{\code{Stratum}}{A prespecified matching variable with three levels}
  }
}
\details{
A data set with 15 variables: (1) binary (0/1) responses of 684 participants to 12 items; (2) a cluster indicator variable with ten levels; (3) a group indicator variable with two levels; and (4) a stratum variable with three levels.}
\examples{
data(data.adult.revised)
## maybe str(data.adult.revised) ; plot(data.adult.revised) ...
}
\keyword{datasets}

