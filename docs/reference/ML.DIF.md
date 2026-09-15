# Main function to compute adjusted Mantel-Haenszel statistics

This main function computes both unadjusted and adjusted MH statistics
in the presence of clustered data based on Begg (1999)
\<doi:10.1111/j.0006-341X.1999.00302.x\>, Begg & Paykin (2001)
\<doi:10.1080/00949650108812115\>, and French & Finch (2013) \<doi:
10.1177/0013164412472341\>.

## Usage

``` r
ML.DIF (Response.data, Response.code=c(0,1),Cluster, Group, 
       group.names=NULL, Stratum=NULL, correct.factor=0.85, 
       missing.code="NA", missing.impute="LW", 
       anchor.items=NULL, purification=FALSE, 
       max.iter=10, alpha = .05)
```

## Arguments

- Response.data:

  A scored item responses matrix in the form of matrix or data frame.
  This matrix should not include any other variables (group, stratum,
  cluser, etc.).

- Response.code:

  A numerical vector of all possible item responses. By default,
  Response.code=c(0,1).

- Cluster:

  The cluster variable. Its length should be equal to the sample size of
  the item response matrix.

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

- correct.factor:

  The value of adjustment applied to the adjusted MH statistic (i.e.,
  f). The default value used here is .85. The adjusted MH statistic was
  found to exhibit low statistical power for DIF detection in some
  conditions. One solution to this is to reduce the magnitude of f
  through multiplying it by the correct factor (e.g., .85, .90, .95).
  The value of .85 is suggested by French & Finch (2013) \<doi:
  10.1177/0013164412472341\>.

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
  Note: If any missing data are detected on group, cluster, or stratum
  variables, listwise deletion will be used before handling missing item
  responses.

- anchor.items:

  A scored item responses matrix of selected anchor items. This matrix
  should be a subset of the response data matrix specified above. By
  default, anchor.items=NULL.

- purification:

  True of false argument, indicating whether purification will be used.
  By default, purification=FALSE.\
  Note: Purification will not be applied if anchor items are specified
  and/or the matching variable is defined.

- max.iter:

  The maximum number of iterations for purification. The default value
  is 10.

- alpha:

  The alpha value used to decide on the DIF items. The default value is
  .05.

## Value

A list of MH statistcs, contigency tables, etc.

- MH.values:

  Summary of estimated MH statistics and corresponding p-values.
  Specifically,\
  \* MH.unadj is the unadjusted MH test statistic.\
  \* MH.score is the MH statistic based on working score test (Begg,
  1999).\
  \* MH.GMH is the MH test statistic based on Holland & Thayer's (1998)
  formula.\
  \* MH.Yates is the MH.GMH statistic with Yates' correction.\
  \* MH.adj is the adjusted MH statistic for clustered data;\
  \* f.adj is the adjustment value based on Begg (1999).\
  \* f.adj.correct is the product of f and the correction factor (.85,
  etc.).\
  \* DIF.Item (Yes) = 1 indicates the item is flagged as a DIF item;\
  \* N.Valid, N.Strata, and N.Cluster refer to the sample size, number
  of valid stata and cluster that are used in the analysis.

- Stratum.statistics:

  summary statistics for each item: n.valid.strata, n.valid.category,
  and also sample sizes for each stratum across items.

- c.table.list.all:

  A list that contains all contigency tables across items and strata.

- c.table.list.valid:

  A list that contains only valid contigency tables across items and
  strata. Strata that have missign item response categories or zero
  marginal means are removed.

- data.out:

  A cleaned data set with variables "Group", "Group.factor","Cluster",
  "Stratum", and all item responses (with missing data handled).

## Details

This main function computes both unadjusted and adjusted Mantel-Haenszel
statistics in the presence of multilevel data.

## References

Begg, M. D. (1999). "Analyzing k (2 × 2) Tables Under Cluster Sampling."
Biometrics, 55(1), 302-307. doi:10.1111/j.0006-341X.1999.00302.x.

Begg, M. D. & Paykin, A. B. (2001). "Performance of and software for a
modified mantel-haenszel statistic for correlated data." Journal of
Statistical Computation and Simulation, 70(2), 175-195.
doi:10.1080/00949650108812115.

French, B. F. & Finch, W. H. (2013). "Extensions of Mantel-Haenszel for
Multilevel DIF Detection." Educational and Psychological Measurement,
73(4), 648-671. doi:10.1177/0013164412472341.

Holland, P. W. & Thayer, D. T. (1988). "Differential item performance
and the Mantel-Haenszel procedure." In H. Wainer & H. I. Braun (Eds.),
Test validity (pp.129-145). Lawrence Erlbaum Associates, Inc.

## Examples

``` r
#Specify the item responses matrix
data(data.adult)
Response.data<-data.adult[,2:13]
#Run the function with specifications      
ML.DIF.out<-ML.DIF (Response.data, Response.code=c(0,1),Cluster=data.adult$Cluster, 
Group=data.adult$Group, group.names=c('Reference','Focal'), 
Stratum=NULL, correct.factor=0.85, 
missing.code="NA", missing.impute="LW",
anchor.items=NULL, purification=FALSE,
max.iter=10, alpha = .05)
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
ML.DIF.out$MH.values
#>     MH.unadj p.value MH.score p.value MH.GMH p.value MH.Yates p.value MH.adj
#> I1    0.0118  0.9136   0.0120  0.9127 0.0118  0.9136   0.0002  0.9885 0.0138
#> I2    0.4608  0.4973   0.4709  0.4926 0.4608  0.4973   0.3138  0.5754 0.6012
#> I3    0.0570  0.8114   0.0581  0.8095 0.0570  0.8114   0.0180  0.8932 0.0898
#> I4    3.3111  0.0688   3.3782  0.0661 3.3111  0.0688   2.9228  0.0873 2.6796
#> I5    0.5145  0.4732   0.5311  0.4661 0.5145  0.4732   0.3322  0.5644 1.1912
#> I6    2.2278  0.1355   2.2850  0.1306 2.2278  0.1355   1.8646  0.1721 3.5481
#> I7    0.9424  0.3317   0.9626  0.3265 0.9424  0.3317   0.7031  0.4017 1.1798
#> I8    6.7045  0.0096   6.8548  0.0088 6.7045  0.0096   6.1680  0.0130 7.1362
#> I9    4.2590  0.0390   4.3991  0.0360 4.2590  0.0390   3.6148  0.0573 3.1500
#> I10   0.1487  0.6998   0.1534  0.6953 0.1487  0.6998   0.0651  0.7986 0.2093
#> I11   0.0076  0.9307   0.0078  0.9298 0.0076  0.9307   0.0015  0.9693 0.0135
#> I12   0.6504  0.4200   0.6670  0.4141 0.6504  0.4200   0.4673  0.4943 1.1292
#>     p.value  f.adj f.adj.correct DIF.Item (Yes) N.Valid N.Strata N.Cluster
#> I1   0.9065 1.0270        0.8730              0     477       11        29
#> I2   0.4381 0.9215        0.7832              0     439        9        29
#> I3   0.7645 0.7619        0.6476              0     477       11        29
#> I4   0.1016 1.4832        1.2607              0     441        9        27
#> I5   0.2751 0.5245        0.4459              0     396       10        28
#> I6   0.0596 0.7577        0.6440              0     466       10        29
#> I7   0.2774 0.9598        0.8158              0     441        9        27
#> I8   0.0076 1.1301        0.9606              1     477       11        29
#> I9   0.0759 1.6430        1.3965              0     477       11        29
#> I10  0.6473 0.8622        0.7329              0     477       11        29
#> I11  0.9076 0.6785        0.5767              0     371        9        26
#> I12  0.2879 0.6950        0.5907              0     477       11        29
ML.DIF.out$Stratum.statistics
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
```
