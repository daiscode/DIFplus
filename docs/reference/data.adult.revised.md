# Modified data.adult by removing all strata with zero marginal means.

This data example contains binary (0/1) responses of 684 participants to
12 items. Particpants were classified into 10 clusters, 2 groups, and 3
strata.

## Usage

``` r
data("data.adult.revised")
```

## Format

A data frame with 684 observations on the following 15 variables.

- `Cluster`:

  The cluster variable

- `I1`:

  Item 1

- `I2`:

  Item 2

- `I3`:

  Item 3

- `I4`:

  Item 4

- `I5`:

  Item 5

- `I6`:

  Item 6

- `I7`:

  Item 7

- `I8`:

  Item 8

- `I9`:

  Item 9

- `I10`:

  Item 10

- `I11`:

  Item 11

- `I12`:

  Item 12

- `Group`:

  Binary group membership variable

- `Stratum`:

  A prespecified matching variable with three levels

## Details

A data set with 15 variables: (1) binary (0/1) responses of 684
participants to 12 items; (2) a cluster indicator variable with ten
levels; (3) a group indicator variable with two levels; and (4) a
stratum variable with three levels.

## Examples

``` r
data(data.adult.revised)
## maybe str(data.adult.revised) ; plot(data.adult.revised) ...
```
