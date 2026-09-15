# Function to create contigency tables

This function creates contigency tables by strata for each item. Both
dichotomous and polytomous item responses are allowed. It also handles
missing responses and returns a cleaned data set with no missing data.

## Usage

``` r
ContigencyTables (Response.data, Response.code=c(0,1), 
       Group, group.names=NULL, Stratum=NULL, Cluster=NULL, 
       missing.code="NA", missing.impute="LW", print.information=TRUE)
```

## Arguments

- Response.data:

  A scored item responses matrix in the form of matrix or data frame.
  This matrix should not include any other variables (group, stratum,
  cluser, etc.).

- Response.code:

  A numerical vector of all possible item responses. By default,
  Response.code=c(0,1).

- Group:

  The variable of group membership (e.g., gender). Its length should be
  equal to the sample size of the item response matrix.

- group.names:

  Names for each defined group (e.g., c('Male','Female')). This argument
  is optional. By default, group.names=NULL. If not provided, group
  names of "Group.1, Group.2, etc." will be automatically generated.

- Stratum:

  The matching variable. By default, Stratum=NULL. If not provided, the
  observed total score will be used.

- Cluster:

  The cluster variable. Its length should be equal to the sample size of
  the item response matrix. By default, Cluster=NULL. This variable will
  not be used to generate contigency tables. It will be included in the
  returned data set for DIF analysis.

- missing.code:

  Indication of how missing values were defined in the data. By default,
  missing.code="NA".

- missing.impute:

  The approach selected to handle missing item responses. By default,
  missing.impute="LW", indicating the list-wise deletion will be used.
  Other options include: "PM" (person mean or row mean imputation),"IM"
  (item mean or column mean imputation), "TW" (two-way imputation), "LR"
  (logistic regression imputation), and EM (EM imputation). Check the
  package "TestDataImputation"
  (<https://cran.r-project.org/package=TestDataImputation>) for more
  details.\
  Note. If any missing data are detected on group, cluster, or stratum
  variables, listwise deletion will be used before handling missing item
  responses.

- print.information:

  Indicator of whether function running information is printed on
  screen. By default, print.information=TRUE.

## Value

A list of strata statistcs, contigency tables, etc.

- Strata.stats:

  Summary statistics for each item: n.valid.strata, n.valid.category,
  and also sample sizes for each stratum across items.

- c.table.list.all:

  A list that contains all contigency tables across items and strata.

- c.table.list.valid:

  A list that contains only valid contigency tables across items and
  strata. Strata that have missing item response categories or zero
  marginal means are removed.

- data.out:

  A cleaned data set with variables "Group", "Group.factor","Cluster",
  "Stratum", and all item responses (with missing data handled).

## Details

This function creats contigency tables.

## Examples

``` r
#Specify the item responses matrix
data(data.adult)
Response.data<-data.adult[,2:13]
#Run the function with specifications      
c.table.out<-ContigencyTables(Response.data, Response.code=c(0,1), 
                              Group=data.adult$Group, group.names=NULL, 
                              Stratum=NULL, Cluster=NULL, missing.code="NA", 
                              missing.impute= "LW",print.information = TRUE)
#> [1] "Item I1 Stratum 0 showed missing response categories."
#> [1] "Item I1 Stratum 1 showed zero marginal means."
#> [1] "Item I1 Stratum 12 showed missing response categories."
#> [1] "Item I1 Stratum 13 showed zero marginal means."
#> [1] "Item I2 Stratum 0 showed missing response categories."
#> [1] "Item I2 Stratum 1 showed zero marginal means."
#> [1] "Item I2 Stratum 1 showed missing response categories."
#> [1] "Item I2 Stratum 2 showed zero marginal means."
#> [1] "Item I2 Stratum 3 showed missing response categories."
#> [1] "Item I2 Stratum 4 showed zero marginal means."
#> [1] "Item I2 Stratum 12 showed missing response categories."
#> [1] "Item I2 Stratum 13 showed zero marginal means."
#> [1] "Item I3 Stratum 0 showed missing response categories."
#> [1] "Item I3 Stratum 1 showed zero marginal means."
#> [1] "Item I3 Stratum 12 showed missing response categories."
#> [1] "Item I3 Stratum 13 showed zero marginal means."
#> [1] "Item I4 Stratum 0 showed missing response categories."
#> [1] "Item I4 Stratum 1 showed zero marginal means."
#> [1] "Item I4 Stratum 1 showed missing response categories."
#> [1] "Item I4 Stratum 2 showed zero marginal means."
#> [1] "Item I4 Stratum 2 showed missing response categories."
#> [1] "Item I4 Stratum 3 showed zero marginal means."
#> [1] "Item I4 Stratum 12 showed missing response categories."
#> [1] "Item I4 Stratum 13 showed zero marginal means."
#> [1] "Item I5 Stratum 0 showed missing response categories."
#> [1] "Item I5 Stratum 1 showed zero marginal means."
#> [1] "Item I5 Stratum 11 showed missing response categories."
#> [1] "Item I5 Stratum 12 showed zero marginal means."
#> [1] "Item I5 Stratum 12 showed missing response categories."
#> [1] "Item I5 Stratum 13 showed zero marginal means."
#> [1] "Item I6 Stratum 0 showed missing response categories."
#> [1] "Item I6 Stratum 1 showed zero marginal means."
#> [1] "Item I6 Stratum 1 showed missing response categories."
#> [1] "Item I6 Stratum 2 showed zero marginal means."
#> [1] "Item I6 Stratum 12 showed missing response categories."
#> [1] "Item I6 Stratum 13 showed zero marginal means."
#> [1] "Item I7 Stratum 0 showed missing response categories."
#> [1] "Item I7 Stratum 1 showed zero marginal means."
#> [1] "Item I7 Stratum 1 showed missing response categories."
#> [1] "Item I7 Stratum 2 showed zero marginal means."
#> [1] "Item I7 Stratum 2 showed missing response categories."
#> [1] "Item I7 Stratum 3 showed zero marginal means."
#> [1] "Item I7 Stratum 12 showed missing response categories."
#> [1] "Item I7 Stratum 13 showed zero marginal means."
#> [1] "Item I8 Stratum 0 showed missing response categories."
#> [1] "Item I8 Stratum 1 showed zero marginal means."
#> [1] "Item I8 Stratum 12 showed missing response categories."
#> [1] "Item I8 Stratum 13 showed zero marginal means."
#> [1] "Item I9 Stratum 0 showed missing response categories."
#> [1] "Item I9 Stratum 1 showed zero marginal means."
#> [1] "Item I9 Stratum 12 showed missing response categories."
#> [1] "Item I9 Stratum 13 showed zero marginal means."
#> [1] "Item I10 Stratum 0 showed missing response categories."
#> [1] "Item I10 Stratum 1 showed zero marginal means."
#> [1] "Item I10 Stratum 12 showed missing response categories."
#> [1] "Item I10 Stratum 13 showed zero marginal means."
#> [1] "Item I11 Stratum 0 showed missing response categories."
#> [1] "Item I11 Stratum 1 showed zero marginal means."
#> [1] "Item I11 Stratum 2 showed missing response categories."
#> [1] "Item I11 Stratum 3 showed zero marginal means."
#> [1] "Item I11 Stratum 11 showed missing response categories."
#> [1] "Item I11 Stratum 12 showed zero marginal means."
#> [1] "Item I11 Stratum 12 showed missing response categories."
#> [1] "Item I11 Stratum 13 showed zero marginal means."
#> [1] "Item I12 Stratum 0 showed missing response categories."
#> [1] "Item I12 Stratum 1 showed zero marginal means."
#> [1] "Item I12 Stratum 12 showed missing response categories."
#> [1] "Item I12 Stratum 13 showed zero marginal means."
#Obtain results
c.tables.all<-c.table.out$c.table.list.all
c.tables.valid<-c.table.out$c.table.list.valid
c.table.out$Strata.stats
#>         n.valid.strata n.valid.category  0  1  2  3  4  5  6  7  8  9 10 11  12
#> Overall             13                2 17 11 23 27 22 32 41 31 54 65 92 83 186
#> I1                  11                2 NA 11 23 27 22 32 41 31 54 65 92 83  NA
#> I2                   9                2 NA NA 23 NA 22 32 41 31 54 65 92 83  NA
#> I3                  11                2 NA 11 23 27 22 32 41 31 54 65 92 83  NA
#> I4                   9                2 NA NA NA 27 22 32 41 31 54 65 92 83  NA
#> I5                  10                2 NA 11 23 27 22 32 41 31 54 65 92 NA  NA
#> I6                  10                2 NA NA 23 27 22 32 41 31 54 65 92 83  NA
#> I7                   9                2 NA NA NA 27 22 32 41 31 54 65 92 83  NA
#> I8                  11                2 NA 11 23 27 22 32 41 31 54 65 92 83  NA
#> I9                  11                2 NA 11 23 27 22 32 41 31 54 65 92 83  NA
#> I10                 11                2 NA 11 23 27 22 32 41 31 54 65 92 83  NA
#> I11                  9                2 NA 11 NA 27 22 32 41 31 54 65 92 NA  NA
#> I12                 11                2 NA 11 23 27 22 32 41 31 54 65 92 83  NA
data.use<-c.table.out$data.out
```
