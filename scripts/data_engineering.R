library(zoo)

posixtc_from_date_and_time <- function(date, time) {
  return(as.POSIXct(paste(date, time), format="%Y-%m-%d %H:%M", tz='UTC'))
}

highlight_missing_values <- function(df, frequency) {
  
  start = min(df$date)
  end   = max(df$date)
  
  complete_df = data.frame(
    date = seq(start, end, by=frequency)
  )
  
  return(merge(df, complete_df, by = "date", all = TRUE))
}

normalize_ts <- function(df, method= 'remove_na') {
  
  if(method == 'remove_na'){
    return(na.omit(df))
  }
}

# C++ implementation of NumericVector diff
cppFunction('NumericVector numeric_diff(NumericVector ts) {
              int n = ts.size();
              NumericVector result(n-1);
              for(int i = 0; i < n-1; ++i) {
                result[i] = ts[i+1]-ts[i];
              }
              return result;}')

check_frequency <- function(df) {

  diff_vector = numeric_diff(as.numeric(df$date))
  
  if (var(as.vector(diff_vector)) == 0)
    return(diff_vector[1])
  else
    return(FALSE)
}

# C++ implementation of checking above/below threshold
cppFunction("LogicalVector find_outliers(NumericVector values, int threshold, char method) {
              int n = values.size();
              LogicalVector result(n);
              
              if (method == 'a')
              {
                for(int i = 0; i < n-1; ++i) {
                  result[i] = values[i] > threshold;
                }
              }
              
              else
              if (method == 'b')
              {
                for(int i = 0; i < n-1; ++i) {
                  result[i] = values[i] < threshold;
                }
              }
              return result;}")


select_outliers <- function(df, method, thresholds) {
  if (method == 'above')
    df$selected = find_outliers(df$value, thresholds[1], 'a')
    #df = df %>% mutate(selected = if_else(value >= thresholds[1], T, F))
  else if (method == 'below')
    df$selected = find_outliers(df$value, thresholds[1], 'b')
    #df = df %>% mutate(selected = if_else(value <= thresholds[1], T, F))
  else if (method == 'between')
    df = df %>% mutate(selected = if_else((date >= thresholds[1] & date <= thresholds[2]), T, F))
  else
    return(NULL)
  return(df)
}

update_frequency <- function(df, frequency_value, frequency_uom, method) {
  
  if (!is.numeric(frequency_value) | frequency_value == 0 | frequency_value%%1!=0) return(df)
  
  seconds_rounding =  switch(frequency_uom, 'sec'= 1, 'min'= 1*60, 'hour'= 1*60*60, 'day'= 1*60*60*24)
  data_format =       switch(frequency_uom, 'sec'= '0', 'min'= '%S', 'hour'= '%M%S', 'day'= '%H%M%S')
  
  if (method == 'interpolation'){
    aux_df = data.frame(date = seq(from = align.time(min(df$date), n=seconds_rounding), to = align.time(max(df$date), n=seconds_rounding), 
                                   by = paste(frequency_value, frequency_uom)))
    return(
      df %>%
        full_join(aux_df) %>%
        arrange(date) %>%
        mutate(value = approx(value, n = n())$y, selected=T) %>%
        #filter(as.numeric(format(date, data_format)) == 0) %>%
        #filter(!duplicated(format(date, '%Y-%m-%d %H:%M:%S'))) %>%
        filter(date %in% aux_df$date) %>%
        select(date, value, selected)
    )}
  else if (method == 'cumulated'){
    aux_df = data.frame(date = seq(from = align.time(min(df$date), n=seconds_rounding), to = align.time(max(df$date), n=seconds_rounding), 
                                   by = paste(frequency_value, frequency_uom)))
    
    full_df = data.frame(date = seq(from = align.time(min(df$date), n=seconds_rounding), to = align.time(max(df$date), n=seconds_rounding), 
                                   by = paste(60, 'sec')))

    rolling_mean_window_length = frequency_value * switch(frequency_uom, "min" = 1, "hour" = 60, "day" = 24*60) 

    return(
      df %>%
        mutate(time_diff = c(0, diff(as.numeric(date)))) %>%
        mutate(value_in_time = value*time_diff/3600) %>%
        mutate(cumulated = cumsum(value_in_time)) %>%
        mutate(original_ts=as.numeric(date)) %>%
        full_join(full_df) %>%
        mutate(final_ts= as.numeric(date)) %>%
        arrange(date) %>%
        mutate(cumulated_interp = approx(x=original_ts[!is.na(original_ts)], 
                                         y=cumulated[!is.na(cumulated)], 
                                         xout=final_ts)$y, selected=T) %>%
        filter(date %in% full_df$date) %>%
        mutate(cumulated_interp_diff = c(0, diff(cumulated_interp))) %>%
        mutate(value_final = cumulated_interp_diff*60) %>%
        mutate(value=rollapply(value_final,rolling_mean_window_length,mean,align='center',fill=NA)) %>%
        filter(date %in% aux_df$date) %>%
        select(date, value, selected)
    )}
  else
    return(FALSE)
}

replace_missing_values = function(df, method, datetime_from, datetime_to) {
  
  if (method == 'Day before')
    new_df = df %>% filter(df$date > datetime_from - 24*60*60 & df$date < datetime_to - 24*60*60) %>% mutate(date = date + 24*60*60) 
  else if (method == 'Day after')
    new_df = df %>% filter(df$date > datetime_from + 24*60*60 & df$date < datetime_to + 24*60*60) %>% mutate(date = date - 24*60*60) 
  else if (method == 'Week before')
    new_df = df %>% filter(df$date > datetime_from - 7*24*60*60 & df$date < datetime_to - 7*24*60*60) %>% mutate(date = date + 7*24*60*60) 
  else if (method == 'Week after')
    new_df = df %>% filter(df$date > datetime_from + 7*24*60*60 & df$date < datetime_to + 7*24*60*60) %>% mutate(date = date - 7*24*60*60) 
  else
    return(FALSE)
  
  df = df[!(df$date > datetime_from & df$date < datetime_to),]
  df = rbind(df, new_df, make.row.names=FALSE) %>% arrange(date)
  return(df)
}



### Here we compare speeds between functions implemented in C++ and in R
# pacman::p_load(microbenchmark)
# set.seed(42)
# data = sample(1:1000, 100000, replace=TRUE)


### numeric_diff implemented in C++ corresponds to the diff command in R

#microbenchmark(diff(data), numeric_diff(data)) 

###  Unit: microseconds
###  expr                min      lq        mean       median   uq        max       neval
###  diff(data)          1149.962 2256.184  3147.311  2321.6290 2460.372  14853.60   100
###  numeric_diff(data)  323.691  916.004   1146.798  951.1375  1000.116  13896.93   100


###  find_outliers implemented in C++ corresponds to the a basic command in R (c(x,y,z) > threshold)

#microbenchmark(data>500, find_outliers(data, 500, 'a')) 

###  Unit: microseconds
###  expr                            min       lq          mean        median    uq          max         neval
###  data > 500                      299.565   437.8080    444.2371    456.3585  479.2100    637.696     100
###  find_outliers(data, 500, "a")   272.913   703.3755    1097.5726   736.1120  769.3065    14743.210   100

### We notice that, while in the first case the C++ function performs 4 times better, in the second case the R function is faster,
###  This could be due to the fact that the R function does not have overhead and can vectorize the operation
