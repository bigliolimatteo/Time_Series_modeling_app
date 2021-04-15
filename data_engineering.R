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

check_frequency <- function(df) {

  diff_vector = diff(df$date)
  
  units(diff_vector) = 'secs'
  if (var(as.vector(diff_vector)) == 0)
    return(diff_vector[1])
  else
    return(FALSE)
}

select_outliers <- function(df, method, thresholds) {
  if (method == 'above')
    df = df %>% mutate(selected = if_else(value >= thresholds[1], T, F))
  else if (method == 'below')
    df = df %>% mutate(selected = if_else(value <= thresholds[1], T, F))
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