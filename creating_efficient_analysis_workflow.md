Creating An Efficient Data Analysis Workflow
================
Bastian Hartmann
22 Januar 2022

In this project, we will be acting as a data analyst for a company that
sells books for learning programming. Our company has produced multiple
books, and each has received many reviews. Our company wants us to check
out the sales data and see if we can extract any useful information from
it.

The dataset of textbook sales we use, can be downloaded
[here](https://data.world/dataquest/book-reviews).

To start, we first load the dataset and get familiar with it.

## Getting Familiar With The Data

It’s easy to lose context when we’re just talking about data analysis in
general. The first thing we should do before we do any analysis is to
get acquainted with our dataset. There are many, many things to check
with a dataset before we dive into any analysis. How much data is there?
What kind of data do we actually have on hand? Is there anything “weird”
that might interfere with any analyses we might need to do? Is there
missing data? Answering these questions now saves we time and effort
later.

If we don’t check the data beforehand, it’s easy to make some false
assumptions about the data that can hinder our progress later.

### Loading the Dataset

``` r
reviews <- read_csv("sources/book_reviews.csv")
```

    ## Rows: 2000 Columns: 4

    ## -- Column specification --------------------------------------------------------
    ## Delimiter: ","
    ## chr (3): book, review, state
    ## dbl (1): price

    ## 
    ## i Use `spec()` to retrieve the full column specification for this data.
    ## i Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
col_names <- colnames(reviews)
head(reviews)
```

    ## # A tibble: 6 x 4
    ##   book                               review    state      price
    ##   <chr>                              <chr>     <chr>      <dbl>
    ## 1 R Made Easy                        Excellent TX          20.0
    ## 2 R For Dummies                      Fair      NY          16.0
    ## 3 R Made Easy                        Excellent NY          20.0
    ## 4 R Made Easy                        Poor      FL          20.0
    ## 5 Secrets Of R For Advanced Students Great     Texas       50  
    ## 6 R Made Easy                        <NA>      California  20.0

``` r
dim(reviews)
```

    ## [1] 2000    4

Here, we can see that the dataset consists of 2000 rows and 4 columns.

The four columns are:

1.  `book` -> Title of the book. \[Type: character\]
2.  `review` -> The review of the sold book in word terms like
    “Excellent”, “Fair”, “Poor”, etc.. \[Type: character\]
3.  `state` -> The state where the book has been sold. \[Type:
    character\]
4.  `price` -> Price of the book as numeric values in US-Dollar. \[Type:
    double\]

Next, we want to observe the unique values and their counts of each
columns.

### The `book` Column

``` r
unique_book <- count(reviews,book,sort=TRUE)
unique_book
```

    ## # A tibble: 5 x 2
    ##   book                                   n
    ##   <chr>                              <int>
    ## 1 Fundamentals of R For Beginners      410
    ## 2 R For Dummies                        410
    ## 3 Secrets Of R For Advanced Students   406
    ## 4 R Made Easy                          389
    ## 5 Top 10 Mistakes R Beginners Make     385

In this summary of the `book` column, we can see that in the dataset are
five different books contained. Each has about 400 occurences.

### The `review` column

``` r
unique_review <- count(reviews,review,sort=TRUE)
unique_review
```

    ## # A tibble: 6 x 2
    ##   review        n
    ##   <chr>     <int>
    ## 1 Fair        369
    ## 2 Poor        368
    ## 3 Good        363
    ## 4 Great       349
    ## 5 Excellent   345
    ## 6 <NA>        206

Here, we can see that there are five different unique reviews. In the
dataset are also 206 entries without an review (NA values).

### The `state` column

``` r
unique_state <- count(reviews,state,sort=TRUE)
unique_state
```

    ## # A tibble: 8 x 2
    ##   state          n
    ##   <chr>      <int>
    ## 1 New York     272
    ## 2 Texas        271
    ## 3 CA           262
    ## 4 NY           259
    ## 5 California   256
    ## 6 FL           248
    ## 7 TX           231
    ## 8 Florida      201

We have 8 different states in the dataset mensioned in the `state`
column.

### The `price` column

``` r
unique_price <- count(reviews,price,sort=TRUE)
unique_price
```

    ## # A tibble: 5 x 2
    ##   price     n
    ##   <dbl> <int>
    ## 1  16.0   410
    ## 2  40.0   410
    ## 3  50     406
    ## 4  20.0   389
    ## 5  30.0   385

Each of our five book has an unique price value.

The prices range from US$15.99 to US$50.00.

## Handling Missing Data

We will take care of the missing values in the `review` column by
removing the rows with a `NA` value.

``` r
filtered_reviews <- reviews %>% filter((!is.na(reviews[["review"]])))
dim(filtered_reviews)
```

    ## [1] 1794    4

From the dimensions of `filtered_reviews`, we can see that the 206 rows
with the `NA` value are now dropped. (2000 - 206 = 1794)

## Transforming The Review Data

Our goal is to evaluate the ratings of each of the textbooks, but
there’s not much we can do with text versions of the review scores. It
would be better if we were to convert the reviews into a numerical form.
Thus, we create the new column `review_num` containing number from `1`
to `5` corresponding to the reviews from `"Poor"` to `"Excellent"`.

``` r
filtered_reviews_numReviews <- filtered_reviews %>% mutate(
  review_num = case_when(
    review == "Poor" ~ 1,
    review == "Fair" ~ 2,
    review == "Good" ~ 3,
    review == "Great" ~ 4,
    review == "Excellent" ~ 5
  )
)

head(filtered_reviews_numReviews)
```

    ## # A tibble: 6 x 5
    ##   book                               review    state   price review_num
    ##   <chr>                              <chr>     <chr>   <dbl>      <dbl>
    ## 1 R Made Easy                        Excellent TX       20.0          5
    ## 2 R For Dummies                      Fair      NY       16.0          2
    ## 3 R Made Easy                        Excellent NY       20.0          5
    ## 4 R Made Easy                        Poor      FL       20.0          1
    ## 5 Secrets Of R For Advanced Students Great     Texas    50            4
    ## 6 R Made Easy                        Great     Florida  20.0          4

Next, we also whant to have a column (`is_high_review`) that helps us
decide if a score is “high” (4 or higher) or not.

``` r
filtered_reviews_numAndHigh <-filtered_reviews_numReviews %>% mutate(
  is_high_review = if_else(review_num >= 4,TRUE,FALSE)
)

head(filtered_reviews_numAndHigh)
```

    ## # A tibble: 6 x 6
    ##   book                              review state price review_num is_high_review
    ##   <chr>                             <chr>  <chr> <dbl>      <dbl> <lgl>         
    ## 1 R Made Easy                       Excel~ TX     20.0          5 TRUE          
    ## 2 R For Dummies                     Fair   NY     16.0          2 FALSE         
    ## 3 R Made Easy                       Excel~ NY     20.0          5 TRUE          
    ## 4 R Made Easy                       Poor   FL     20.0          1 FALSE         
    ## 5 Secrets Of R For Advanced Studen~ Great  Texas  50            4 TRUE          
    ## 6 R Made Easy                       Great  Flor~  20.0          4 TRUE

## Analyzing The Data

It’s important to keep the overall goal in mind as we handle all the
little details of the cleaning. We are acting as an analyst trying to
figure out which books are the most profitable for the company.

Our main goal is to figure out what book is the most profitable. We will
judge this by calculating how much money each book generates overall.

``` r
book_revenues <- filtered_reviews_numAndHigh %>% group_by(book) %>% summarize(Revenue = sum(price), N = n()) %>% arrange(desc(Revenue))

book_revenues
```

    ## # A tibble: 5 x 3
    ##   book                               Revenue     N
    ##   <chr>                                <dbl> <int>
    ## 1 Secrets Of R For Advanced Students  18000    360
    ## 2 Fundamentals of R For Beginners     14636.   366
    ## 3 Top 10 Mistakes R Beginners Make    10646.   355
    ## 4 R Made Easy                          7036.   352
    ## 5 R For Dummies                        5772.   361

## Conclusion

Using our score, the most profitable book is **“Secrets Of R For
Advanced Students”**.
