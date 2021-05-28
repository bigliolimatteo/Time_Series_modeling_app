# library(shiny)
# library(shinythemes)
# library(dplyr)
# library(shinycssloaders)
# library(dqshiny)
# library(shinyBS)
# library(ggplot2)
# library(gghighlight)
# library(xts)

# Install libraries from CRAN
load_libraries <- function(){
  if(!require('pacman'))install.packages('pacman')
  pacman::p_load(shiny,shinythemes, dplyr, shinycssloaders, shinyBS, ggplot2, gghighlight, xts, Rcpp)
}

load_libraries()

# Install old library (for time input) removed by CRAN 
install.packages(file.path('.', 'old_dependencies', 'dqshiny_0.0.4.tar.gz'), repos = NULL, type="source")

library(dqshiny)

# Custom functions
source('data_engineering.R')

# Set max size for file uploading to 10MB
options(shiny.maxRequestSize = 10*1024^2)


# Define UI ----
ui <- fluidPage(
  # Theme and title
  theme = shinytheme("darkly"),
  titlePanel(title='Time-Series modeling'),

  # Utils to get the input changed inside observeEvent
  tags$head(
    tags$script(
      "$(document).on('shiny:inputchanged', function(event) {
          if (event.name != 'changed') {
            Shiny.setInputValue('changed', event.name);
          }
        });"
  )),

  sidebarLayout(
    sidebarPanel( width = 3, 
                  tabsetPanel(type = "tabs",
                              tabPanel("Custom", fileInput("file_input", h4("Upload custom file:"),
                                                           accept=c('csv', 'comma-separated-values','.csv')),
                                       h4("File Format:"),
                                       h5("\"date\",\"value\""),
                                       h5("2021-01-31 23:59:52,720")
                              ),
                              tabPanel("Default",
                                       div(style='display: flex',
                                           
                                           div(style='width:70%;padding-right:20px', selectInput('default_filename', label=h4('Select default file:'),
                                                                                                 choices=c('basic', 'medium', 'advanced'))),
                                           div(style='width:20%;padding-top:45px', actionButton('load_default', 'Load', style='padding:6px;width:60px'))
                                       )
                              )
                  ),
                  hr(),
                  downloadButton(outputId='download', label='Download current data')
    ),
    
    mainPanel(
    tabsetPanel(type = "tabs",
                  tabPanel("Data Cleaning",
                           br(),
                           div(style='display: flex;',
                               div(actionButton("data_cleaning_home_button", '', icon = icon("home"), style='padding:5px;height:35px')),
                               div(style='padding-left:15px', dateRangeInput('data_cleaning_date_range', label = NULL))
                           ),
                           plotOutput(outputId = 'data_cleaning_plot', height = '30vh') %>% withSpinner(color="#0dc5c1"),
                           hr(),
                           bsCollapsePanel('Manage outliers',
                                           fluidRow(
                                             column(5,
                                                    div(style = "height:230px;width:100%;padding:10px 15px;background-color: #464646",
                                                      h3('By value'),
                                                      div(style='display: flex',
                                                        div(style='width:150px;padding-right:10px', selectInput('below_above_outliers', label='', choices=c('above', 'below'))),
                                                        div(style='width:80px', numericInput("outliers_value", label='', value = 1)),
                                                        tags$head(tags$style(HTML('#outliers_value{height: 35px}')))
                                                      ),
                                                      div(style='display: flex; justify-content: flex-end;padding-top:25px',
                                                        actionButton(align='right', 'highlight_outliers_value', 'highlight', style='background-color: #32bc8c'),
                                                        actionButton(align='right', "remove_outliers_value", 'remove', style='background-color: #32bc8c')))),
    
                                             column(7,
                                                     div(style = "height:230px;width:100%;padding:10px 15px;background-color: #464646",
                                                            h3('By date range'),
                                                            div(style='display: flex',
                                                              div(h4('From', style = 'padding-top:20px;padding-right:20px')),
                                                              div(style='width:115px;padding-right:5px', dateInput("outliers_date_from", label='')),
                                                              div(time_input("outliers_time_from", '', value='00:00', width='125px')),
                                                              div(h4('To', style = 'padding-top:20px;padding-right:20px;padding-left:20px')),
                                                              div(style='width:115px;padding-right:5px', dateInput("outliers_date_to", label='')),
                                                              div(time_input("outliers_time_to", '', value='00:00', width='125px'))
                                                            ),
                                                         div(style='display: flex; justify-content: flex-end;padding-top:20px',
                                                              actionButton(align='right', 'highlight_outliers_date_range', 'highlight', style='background-color: #32bc8c'),
                                                              actionButton(align='right', 'remove_outliers_date_range', 'remove', style='background-color: #32bc8c')
                                                            )
                                                         )
                                                    )
                                           ), style = 'success'),
                           bsCollapsePanel('Manage sampling frequency',
                                           fluidRow(
                                             column(5,
                                                div(style = "height:210px;width:100%;padding:10px 15px;background-color: #464646",
                                                    div(style = 'width:20', actionButton('compure_current_sampling_frequency', 'Compute Current',
                                                                                         style='background-color: #3498db')),
                                                    div(style = 'width:70%;margin:0 auto;padding-top:50px', textOutput("current_sampling_frequency"))),
                                                    tags$head(tags$style("#current_sampling_frequency{color:#3498db;font-size:20px;text-align:center}"))
                                              ),
                                              column(7,
                                                     div(style = "height:210px;width:100%;padding:10px 15px;background-color: #464646",
                                                          h4('Set frequency to '),
                                                          div(style='display: flex',
                                                              div(style='width:100px;padding-right:20px', numericInput("frequency_value", label='', value = 20, min=1, step=1)),
                                                              tags$head(tags$style(HTML('#frequency_value{height: 35px}'))),
                                                              div(style='width:100px', selectInput('frequency_value_uom', label='', selected='min', choices=c('min', 'hour', 'day'))),
                                                              div(h4('using', style = 'padding-top:20px;padding-right:20px;padding-left:20px')),
                                                              div(style='width:200px', selectInput('frequency_method', label='', choices=c('interpolation', 'cumulated')))
                                                      ),
                                                      div(style='display: flex; justify-content: flex-end;padding-top:25px',
                                                          actionButton(align='right', 'frequency_preview', 'Activate Preview', style='background-color: #3498db'),
                                                          actionButton(align='right', 'frequency_apply', 'Apply', style='background-color: #3498db')
                                                      )
                                                     )
                                              )
                                            )
                                           , style = 'info'),
                           bsCollapsePanel('Manage missing values',
                                           div(style = "height:180px;width:100%;padding:10px 15px;background-color: #464646",
                                               div(style='display: flex',
                                                   div(h4('Replace values from', style = 'padding-top:20px;padding-right:15px;padding-left:20px')),
                                                   div(style='width:115px;padding-right:5px', dateInput("missing_values_date_from", label='')),
                                                   div(time_input("missing_values_time_from", '', value='00:00', width='140px')),
                                                   div(h4('to', style = 'padding-top:20px;padding-right:10px;padding-left:10px')),
                                                   div(style='width:115px;padding-right:5px', dateInput("missing_values_date_to", label='')),
                                                   div(time_input("missing_values_time_to", '', value='00:00', width='140px')),
                                                   div(h4('with', style = 'padding-top:20px;padding-right:10px;padding-left:10px')),
                                                   div(style='width:150px;padding-top:5px',selectInput('missing_values_method', label='', choices=c('Day before', 'Day after', 'Week before', 'Week after')))
                                               ),
                                               div(style='display: flex; justify-content: flex-end;padding-top:25px',
                                                   div(actionButton(align='right', 'missing_values_preview', 'Activate Preview', style='background-color: #375a7f')),
                                                   div(actionButton(align='right', "replace_missing_values", 'replace', style='background-color: #375a7f'))
                                               )
                                            )
                                           , style = 'primary')
                ),
                tabPanel("Model",
                         img(src='work_in_progress.png', height = '500px', width = '800px')
                ),
                tabPanel("Forecast",
                         img(src='work_in_progress.png', height = '500px', width = '800px')
                )
        ),width = 9
    )
  )
)





server <- function(input, output) {

# Declare reactive values for our dataset
  data = reactiveValues(current=NULL, frequency_preview=NULL, missing_values_preview=NULL)

# Declare reactive values for ui purposes
  ui_flags = reactiveValues(is_frequency_preview_active=FALSE, is_missing_values_preview_active=FALSE)

# Load dataset
  observeEvent(input$file_input, {
    raw = read.csv(input$file_input$datapath) # TODO add error for file formatting
    data$current = raw %>%
      mutate(date = as.POSIXct(date, format = '%Y-%m-%d %H:%M:%OS', tz='UTC'), selected=TRUE) %>%
      arrange(date)
  })
  
  observeEvent(input$load_default, {
    path = file.path('.',paste('default_datasets/', input$default_filename, '.csv', sep=''))
    raw = read.csv(path)
    data$current = raw %>%
      mutate(date = as.POSIXct(date, format = '%Y-%m-%d %H:%M:%OS', tz='UTC'), selected=TRUE) %>%
      arrange(date)
  })

# Set date inputs range from loaded dataset
  observeEvent(c(input$load_default, input$file_input), {
    if (!is.null(data$current)){

      default = start_date = min(as.Date(data$current$date), na.rm=TRUE)
      end_date = max(as.Date(data$current$date), na.rm=TRUE)

      updateDateRangeInput(session = getDefaultReactiveDomain(), 'data_cleaning_date_range',
                           start = start_date, end = end_date)

      updateDateInput(session = getDefaultReactiveDomain(), 'outliers_date_from',
                      min = start_date, max = end_date, value=start_date)

      updateDateInput(session = getDefaultReactiveDomain(), 'outliers_date_to',
                      min = start_date, max = end_date, value=start_date)

      updateDateInput(session = getDefaultReactiveDomain(), 'missing_values_date_from',
                      min = start_date, max = end_date, value=start_date)

      updateDateInput(session = getDefaultReactiveDomain(), 'missing_values_date_to',
                      min = start_date, max = end_date, value=start_date)
    }
  })

# Define date-range home button
  observeEvent(input$data_cleaning_home_button, {
    updateDateRangeInput(session = getDefaultReactiveDomain(), "data_cleaning_date_range",
                         start = min(as.Date(data$current$date), na.rm=TRUE),
                         end = max(as.Date(data$current$date), na.rm=TRUE))
  })

# Manage outliers
  observeEvent(c(input$highlight_outliers_value, input$highlight_outliers_date_range,
                 input$remove_outliers_value, input$remove_outliers_date_range), {
    req(input$changed)

    if (is.null(data$current))
      showModal(modalDialog(title='No data error', 'You must insert some data before', easyClose = TRUE))

    else{
      if (input$changed %in% c('highlight_outliers_value', 'remove_outliers_value'))
        data$current = select_outliers(data$current, input$below_above_outliers, c(input$outliers_value))

      else if (input$changed %in% c('highlight_outliers_date_range', 'remove_outliers_date_range'))
        if (input$outliers_date_from > input$outliers_date_to)
          showModal(modalDialog(title='Logical error', 'Start Date must be previous than End Date', easyClose = TRUE))
        else
          data$current =select_outliers(data$current, 'between', c(posixtc_from_date_and_time(input$outliers_date_from, input$outliers_time_from),
                                                                  posixtc_from_date_and_time(input$outliers_date_to, input$outliers_time_to)))

        if (input$changed %in% c('remove_outliers_value', 'remove_outliers_date_range'))
          data$current = data$current %>% filter(selected == FALSE) %>% mutate(selected=TRUE)
    }
  })

# Compute sampling frequency
  current_sampling_frequency = eventReactive(input$compure_current_sampling_frequency, {
    if (is.null(data$current))
      showModal(modalDialog(title='No data error', 'You must insert some data before', easyClose = TRUE))
    else{
      frequency = check_frequency(data$current)
      if( frequency == FALSE)
        return('Non-constant sampling frequency')
      else
        return(paste('Sampling frequency: ', as.character(frequency), ' sec'))
    }
  })
  output$current_sampling_frequency = renderText({current_sampling_frequency()})#current_sampling_frequency()})

# Manage sampling frequency
  observeEvent(c(input$frequency_preview, input$frequency_apply), {
    req(input$changed)

    if (is.null(data$current))
      showModal(modalDialog(title='No data error', 'You must insert some data before', easyClose = TRUE))
    else{

      if (input$changed == 'frequency_apply'){
        data$current = update_frequency(data$current, input$frequency_value, input$frequency_value_uom, input$frequency_method)
        ui_flags$is_frequency_preview_active = FALSE
        data$frequency_preview = NULL
      }
      else{
        ui_flags$is_frequency_preview_active = !ui_flags$is_frequency_preview_active

        if(ui_flags$is_frequency_preview_active)
          data$frequency_preview = update_frequency(data$current, input$frequency_value, input$frequency_value_uom, input$frequency_method)
        else
          data$frequency_preview = NULL
      }
    }
  })

  # Update frequecy preview button label
  observeEvent(c(input$frequency_value, input$frequency_value_uom, input$frequency_method), {
    if(ui_flags$is_frequency_preview_active){
      data$frequency_preview = NULL
      ui_flags$is_frequency_preview_active = FALSE
    }
  })

  observeEvent(ui_flags$is_frequency_preview_active, {
    preview_button_label = if(ui_flags$is_frequency_preview_active) 'Remove Preview' else 'Activate Preview'
    updateActionButton(session = getDefaultReactiveDomain(), 'frequency_preview', label=preview_button_label)
  })


# Manage missing values
  observeEvent(c(input$missing_values_preview, input$replace_missing_values), {

    req(input$changed)
    if (is.null(data$current))
      showModal(modalDialog(title='No data error', 'You must insert some data before', easyClose = TRUE))
    else{
      datetime_from = posixtc_from_date_and_time(input$missing_values_date_from, input$missing_values_time_from)
      datetime_to = posixtc_from_date_and_time(input$missing_values_date_to, input$missing_values_time_to)

      if (input$changed == 'frequency_apply'){
        data$current = replace_missing_values(data$current, input$missing_values_method, datetime_from, datetime_to)
        ui_flags$is_missing_values_preview_active = FALSE
        data$missing_values_preview = NULL
      }
      else{
        ui_flags$is_missing_values_preview_active = !ui_flags$is_missing_values_preview_active

        if(ui_flags$is_missing_values_preview_active)
          data$missing_values_preview = replace_missing_values(data$current, input$missing_values_method, datetime_from, datetime_to)
        else
          data$missing_values_preview = NULL
      }
    }
  })

  # Update missing_values preview button label
  observeEvent(c(input$missing_values_method,
                 input$missing_values_date_from, input$missing_values_time_from,
                 input$missing_values_date_to, input$missing_values_time_to), {
    if(ui_flags$is_missing_values_preview_active){
      data$missing_values_preview = NULL
      ui_flags$is_missing_values_preview_active = FALSE
    }
  })

  observeEvent(ui_flags$is_missing_values_preview_active, {
    preview_button_label = if(ui_flags$is_missing_values_preview_active) 'Remove Preview' else 'Activate Preview'
    updateActionButton(session = getDefaultReactiveDomain(), 'missing_values_preview', label=preview_button_label)
  })

# Manage plot
  output$data_cleaning_plot <- renderPlot({

    if (!is.null(data$current)){
      if(ui_flags$is_frequency_preview_active==TRUE & ui_flags$is_missing_values_preview_active==TRUE)
        ggplot() +
        annotate("text", x = 4, y = 25, size=20, label = "Disable one preview") +
        theme_void()
      else
        ggplot() +
        {if(ui_flags$is_frequency_preview_active==FALSE & ui_flags$is_missing_values_preview_active==FALSE)
          geom_line(data = data$current, aes(x = date, y= value))
        else
          geom_line(data = data$current, aes(x = date, y= value), alpha=.5)} +
        
        # Below we test two different ways of highlighting a preview
        {if(ui_flags$is_frequency_preview_active==TRUE & ui_flags$is_missing_values_preview_active==FALSE)  geom_line(data = data$frequency_preview, aes(date, value), color='red')} +
        {if(ui_flags$is_frequency_preview_active==FALSE & ui_flags$is_missing_values_preview_active==TRUE)  geom_line(data = data$missing_values_preview, aes(date, value), color='red')} +
        
        gghighlight(selected==TRUE) +
        scale_x_datetime(limits = as.POSIXct(c(input$data_cleaning_date_range[1], input$data_cleaning_date_range[2]), format = '%Y-%m-%d', tz='UTC'))
    }
    else{
      ggplot() +
      annotate("text", x = 4, y = 25, size=20, label = "Insert data to visualize plot") +
      theme_void()
    }
  })

# Download current data
  output$download = downloadHandler(
    filename = function() {paste('current_data.csv')},
    content = function(file) {
      write.csv(data$current %>% select(date,value), file, row.names = FALSE)
    }
  )
  
}

shinyApp(ui = ui, server = server)