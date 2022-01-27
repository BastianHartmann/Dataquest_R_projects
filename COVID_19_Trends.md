Investigating COVID-19 Virus Trends
================

A pneumonia of unknown cause detected in Wuhan, China was first
internationally reported from China on 31 December 2019. Today we know
this virus as Coronavirus. COVID-19 which stands for COronaVIrus Disease
is the disease caused by this virus. Since then, the world has been
engaged in the fight against this pandemic. Several measures have
therefore been taken to “flatten the curve”. We have consequently
experienced social distancing and many people have passed away as well.

In the solidarity to face this unprecedented global crisis, several
organizations did not hesitate to share several datasets allowing the
conduction of several kinds of analysis in order to understand this
pandemic.

Here, I use [a dataset, from
Kaggle](https://www.kaggle.com/lin0li/covid19testing), that
**Dataquest** has prepared and made [available here for
download](https://dq-content.s3.amazonaws.com/505/covid19.csv). This
dataset was collected between the 20th of January and the 1st of June
2020.

This analysis tries to provide an answer to this question: **Which
countries have had the highest number of positive cases against the
number of tests?**

## Understanding the Data

### Loading the Data

``` r
library(readr)

# Loading the dataset
covid_df = read.csv("sources/covid19.csv")
```

After loading the dataset, we can explore it:

``` r
# Displaing the dimension of the data: 
dim(covid_df)
```

    ## [1] 10903    14

``` r
# Storing the column names in a variable
vector_cols <- colnames(covid_df)

# Displaing the variable vector_cols
vector_cols
```

    ##  [1] "Date"                    "Continent_Name"         
    ##  [3] "Two_Letter_Country_Code" "Country_Region"         
    ##  [5] "Province_State"          "positive"               
    ##  [7] "hospitalized"            "recovered"              
    ##  [9] "death"                   "total_tested"           
    ## [11] "active"                  "hospitalizedCurr"       
    ## [13] "daily_tested"            "daily_positive"

``` r
# Showing the first few rows of the dataset
head(covid_df)
```

    ##         Date Continent_Name Two_Letter_Country_Code Country_Region
    ## 1 2020-01-20           Asia                      KR    South Korea
    ## 2 2020-01-22  North America                      US  United States
    ## 3 2020-01-22  North America                      US  United States
    ## 4 2020-01-23  North America                      US  United States
    ## 5 2020-01-23  North America                      US  United States
    ## 6 2020-01-24           Asia                      KR    South Korea
    ##   Province_State positive hospitalized recovered death total_tested active
    ## 1     All States        1            0         0     0            4      0
    ## 2     All States        1            0         0     0            1      0
    ## 3     Washington        1            0         0     0            1      0
    ## 4     All States        1            0         0     0            1      0
    ## 5     Washington        1            0         0     0            1      0
    ## 6     All States        2            0         0     0           27      0
    ##   hospitalizedCurr daily_tested daily_positive
    ## 1                0            0              0
    ## 2                0            0              0
    ## 3                0            0              0
    ## 4                0            0              0
    ## 5                0            0              0
    ## 6                0            5              0

``` r
# Showing a global view of the dataset.
library(tibble)
glimpse(covid_df)
```

    ## Rows: 10,903
    ## Columns: 14
    ## $ Date                    <chr> "2020-01-20", "2020-01-22", "2020-01-22", "202~
    ## $ Continent_Name          <chr> "Asia", "North America", "North America", "Nor~
    ## $ Two_Letter_Country_Code <chr> "KR", "US", "US", "US", "US", "KR", "US", "US"~
    ## $ Country_Region          <chr> "South Korea", "United States", "United States~
    ## $ Province_State          <chr> "All States", "All States", "Washington", "All~
    ## $ positive                <int> 1, 1, 1, 1, 1, 2, 1, 1, 4, 0, 3, 0, 0, 0, 0, 1~
    ## $ hospitalized            <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0~
    ## $ recovered               <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0~
    ## $ death                   <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0~
    ## $ total_tested            <int> 4, 1, 1, 1, 1, 27, 1, 1, 0, 0, 0, 0, 0, 0, 0, ~
    ## $ active                  <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0~
    ## $ hospitalizedCurr        <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0~
    ## $ daily_tested            <int> 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0~
    ## $ daily_positive          <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0~

Our dataset contains the following columns:  
1.`Date`: Date  
2. `Continent_Name`: Continent names  
3. `Two_Letter_Country_Code`: Country codes  
4. `Country_Region`: Country names  
5. `Province_State`: States/province names; value is `All States` when
state/provincial level data is not available  
6. `positive`: Cumulative number of positive cases reported.  
7. `active`: Number of active cases on that **day**.  
8. `hospitalized`: Cumulative number of hospitalized cases reported.  
9. `hospitalizedCurr`: Number of actively hospitalized cases on that
**day**.  
10. `recovered`: Cumulative number of recovered cases reported.  
11. `death`: Cumulative number of deaths reported.  
12. `total_tested`: Cumulative number of tests conducted.  
13. `daily_tested`: Number of tests conducted on the **day**; if daily
data is unavailable, daily tested is averaged across number of days in
between.  
14. `daily_positive`: Number of positive cases reported on the **day**;
if daily data is unavailable, daily positive is averaged across number
of days in.  

## Isolating the Rows We Need

Looking at the few lines of our dataset we displayed in the previous
step, we can see that the `Province_State` column mixes data from
different levels: country level and state/province level. Since we
cannot run an analysis on all these levels at the same time, we need to
filter what we are interested in.

We will, therefore, extract only the country-level data in order to not
bias our analyses. To do so, we filter the data to keep only the data
related to `"All States"`. `"All States"` represents the value of the
column Province_State to specify that the COVID-19 data is only
available at the country level.

``` r
library(dplyr)
```

    ## 
    ## Attache Paket: 'dplyr'

    ## Die folgenden Objekte sind maskiert von 'package:stats':
    ## 
    ##     filter, lag

    ## Die folgenden Objekte sind maskiert von 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
covid_df_all_states <- covid_df %>% filter(Province_State == "All States") %>% select(-Province_State)

# Data glimpse
head(covid_df_all_states)
```

    ##         Date Continent_Name Two_Letter_Country_Code Country_Region positive
    ## 1 2020-01-20           Asia                      KR    South Korea        1
    ## 2 2020-01-22  North America                      US  United States        1
    ## 3 2020-01-23  North America                      US  United States        1
    ## 4 2020-01-24           Asia                      KR    South Korea        2
    ## 5 2020-01-24  North America                      US  United States        1
    ## 6 2020-01-25        Oceania                      AU      Australia        4
    ##   hospitalized recovered death total_tested active hospitalizedCurr
    ## 1            0         0     0            4      0                0
    ## 2            0         0     0            1      0                0
    ## 3            0         0     0            1      0                0
    ## 4            0         0     0           27      0                0
    ## 5            0         0     0            1      0                0
    ## 6            0         0     0            0      0                0
    ##   daily_tested daily_positive
    ## 1            0              0
    ## 2            0              0
    ## 3            0              0
    ## 4            5              0
    ## 5            0              0
    ## 6            0              0

## Isolating the Columns We Need

Revisiting the description of the dataset columns, we can notice that
there are columns that provide daily information and others that provide
cumulative information.

Hence, we should manage those cases (columns with cumulative and daily
information) separately because we cannot work with both together.
Actually, our analysis would be biased if we made the mistake of
comparing a column containing cumulative data and another one containing
only one-day data.

Thereafter, we work mainly with daily data. So let’s extract the columns
related to the daily measures.

``` r
covid_df_all_states_daily <- covid_df_all_states %>% select(Date, Country_Region, active, hospitalizedCurr, daily_tested, daily_positive)

# Data glimpse
head(covid_df_all_states_daily)
```

    ##         Date Country_Region active hospitalizedCurr daily_tested daily_positive
    ## 1 2020-01-20    South Korea      0                0            0              0
    ## 2 2020-01-22  United States      0                0            0              0
    ## 3 2020-01-23  United States      0                0            0              0
    ## 4 2020-01-24    South Korea      0                0            5              0
    ## 5 2020-01-24  United States      0                0            0              0
    ## 6 2020-01-25      Australia      0                0            0              0

## Extracting the Top Ten Tested Cases Countries

Our goal here is to extract the top ten cases countries data. Acting
like a data scientist, at this step, these are the questions we are
asking ourselves.

-   How can we get the overall number of COVID-19 tested, positive,
    active and hospitalized cases by country since we currently have
    daily data?

-   How do we then extract the top ten?

First of all, we group the dataset by the `Counrtry_Region` column and
compute the sum of the number of tested, positive, active and
hospitalized cases and arrange the dataframe accordingly:

``` r
covid_df_all_states_daily_sum <- covid_df_all_states_daily %>% group_by(Country_Region) %>% summarize(tested=sum(daily_tested), positive=sum(daily_positive), active=sum(active), hospitalized=sum(hospitalizedCurr)) %>% arrange(-tested)

# Visualisation of generated dataframe:
covid_df_all_states_daily_sum
```

    ## # A tibble: 108 x 5
    ##    Country_Region   tested positive  active hospitalized
    ##    <chr>             <int>    <int>   <int>        <int>
    ##  1 United States  17282363  1877179       0            0
    ##  2 Russia         10542266   406368 6924890            0
    ##  3 Italy           4091291   251710 6202214      1699003
    ##  4 India           3692851    60959       0            0
    ##  5 Turkey          2031192   163941 2980960            0
    ##  6 Canada          1654779    90873   56454            0
    ##  7 United Kingdom  1473672   166909       0            0
    ##  8 Australia       1252900     7200  134586         6655
    ##  9 Peru             976790    59497       0            0
    ## 10 Poland           928256    23987  538203            0
    ## # ... with 98 more rows

Now, we can extract the top-ten countries:

``` r
covid_top_10 <- covid_df_all_states_daily_sum %>% head(10)
```

## Identifying the Highest Positive Against Tested Cases

As a remainder, our goal is to answer this question: \*\* Which
countries have had the highest number of positive cases against the
number of tests?\*\*

Therefore we extract the columns as vectors:

``` r
# extract vectors
countries <- covid_top_10$Country_Region
tested_cases <- covid_top_10$tested
positive_cases  <- covid_top_10$positive
active_cases  <- covid_top_10$active
hospitalized_cases  <- covid_top_10$hospitalized

# name the values of the vectors
names(tested_cases) <- countries
names(positive_cases) <- countries
names(active_cases) <- countries
names(hospitalized_cases) <- countries
```

Now, we can identify the top three positive against tested cases:

``` r
positive_against_tested <- positive_cases / tested_cases

positive_against_tested_sorted <- sort(positive_against_tested, decreasing= TRUE)

positive_tested_top_3 <- positive_against_tested_sorted[1:3]

positive_tested_top_3
```

    ## United Kingdom  United States         Turkey 
    ##     0.11326062     0.10861819     0.08071172

## Keeping relevant information

Our goal is to find a way to keep all the information available for the
top three countries that have had the highest number of positive cases
against the number of tests.

The previous step allowed identifying those top three countries as:

``` r
positive_tested_top_3
```

    ## United Kingdom  United States         Turkey 
    ##     0.11326062     0.10861819     0.08071172

To make sure we won’t lose other information about these countries we
can create a matrix that contains the ratio and the overall number of
COVID-19 tested, positive, active and hospitalized cases.

``` r
# creating country vectors
united_kingdom <- c(0.11, 1473672, 166909, 0, 0)
united_states <- c(0.10, 17282363, 1877179, 0, 0)
turkey <- c(0.08, 2031192, 163941, 2980960, 0)

# creating matrix from vectors
covid_mat <- rbind(united_kingdom,united_states,turkey)
colnames(covid_mat) <- c("Ratio", "tested", "positive", "active", "hospitalized")
covid_mat
```

    ##                Ratio   tested positive  active hospitalized
    ## united_kingdom  0.11  1473672   166909       0            0
    ## united_states   0.10 17282363  1877179       0            0
    ## turkey          0.08  2031192   163941 2980960            0

## Putting all together

Here, our goal is to put all our answers and datasets together. Since a
list can contain several types of objects, we are able to store all the
data of our project together. This allows us to have a global view from
a single variable and the ability to export our results for other uses.

``` r
# Create a character variable that contains our question
question <- "Which countries have had the highest number of positive cases against the number of tests?"

# Create a character variable that contains our answer
answer <- c("Positive tested cases" = positive_tested_top_3)

# Create lists that contain the data structures we created
dataframe_list <- list(original = covid_df,
                       allstates = covid_df_all_states,
                       daily = covid_df_all_states_daily,
                       top_10 = covid_top_10)
matrix_list <- list(covid_mat)
vector_list <- list(vector_cols,countries)

# Create a named list that contains the three previous lists associated with the data structure names
data_structure_list <- list("dataframe" = dataframe_list,
                            "matrix" = matrix_list,
                            "vector" = vector_list)

# Create a list that summarizes our results
covid_analysis_list <- list(question,answer,data_structure_list)

# Display the second element
covid_analysis_list[[2]]
```

    ## Positive tested cases.United Kingdom  Positive tested cases.United States 
    ##                           0.11326062                           0.10861819 
    ##         Positive tested cases.Turkey 
    ##                           0.08071172
