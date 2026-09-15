\name{data.ordinal}
\alias{data.ordinal}
\docType{data}
\title{
Data Example (Ordinal)
}
\description{
This data example contains ordinal (1/2/3/4) responses of 300 participants to 5 items. Participants were classified into 6 clusters and 2 groups.
}
\usage{data("data.ordinal")}
\format{
  A data frame with 300 observations on the following 7 variables.
  \describe{
    \item{\code{Group}}{Group membership}
    \item{\code{Cluster}}{Cluster membership}
    \item{\code{I1}}{Item 1}
    \item{\code{I2}}{Item 2}
    \item{\code{I3}}{Item 3}
    \item{\code{I4}}{Item 4}
    \item{\code{I5}}{Item 5}
  }
}
\details{
A data set with 7 variables: (1) ordinal (1/2/3/4) responses of 300 participants to 5 items; (2) a cluster indicator variable with six levels; and (3) a group indicator variable with two levels.}
\examples{
data(data.ordinal)
## maybe str(data.ordinal) ; plot(data.ordinal) ...
}
\keyword{datasets}
