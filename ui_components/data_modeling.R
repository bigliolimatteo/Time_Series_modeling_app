################################################################################
#                        Add Fourier element components                        #
################################################################################

add_fourier_elements_div = div(style = "height:320px;width:100%;padding:10px 15px;background-color: #464646",
                               sidebarLayout(
                                 sidebarPanel(style = "background-color: #464646",
                                   #h3('Add component'),
                                   div(style='width:300px;padding-right:10px', sliderInput("fourier_element_period", "Period:", min = 0, max = 200, value = 10)),
                                   div(style='width:300px;padding-right:10px', sliderInput("fourier_element_armonic", "Armonic::", min = 0, max = 200, value = 5)),
                                   radioButtons("fourier_element_show","Show", c("Sin" = "sin", "Cos" = "cos", "Sum" = "sum"), inline=T)
                                 ),
                                 mainPanel(
                                   plotOutput(outputId = 'sample_fourier_plot', height = '250px') %>% withSpinner(color="#0dc5c1"),
                                   div(style='display: flex; justify-content: flex-end;padding-top:5px;',
                                       actionButton(align='right', "add_fourier_element", 'add to model', style='background-color: #32bc8c')
                                   )
                                 )
                               )
                           )


fit_fourier_series_div = div(style = "height:230px;width:100%;padding:10px 15px;background-color: #464646",
                                  h3('FIT')
                          )


manage_fourier_elements_panel = bsCollapsePanel('Manage Fourier Series',
                                        fluidRow(
                                          column(9, add_fourier_elements_div),
                                          column(3, fit_fourier_series_div)
                                        ), style = 'success')

################################################################################
#                       Sampling frequency components                          #
################################################################################

compute_sampling_frequency_div = div(style = "height:210px;width:100%;padding:10px 15px;background-color: #464646",
                                     div(style = 'width:20', actionButton('compure_current_sampling_frequency', 'Compute Current',
                                                                          style='background-color: #3498db')),
                                     div(style = 'width:70%;margin:0 auto;padding-top:50px', textOutput("current_sampling_frequency"))
)

manage_outliers_by_value_div = div(style = "height:210px;width:100%;padding:10px 15px;background-color: #464646",
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


manage_sampling_frequency_panel = bsCollapsePanel('Manage sampling frequency',
                                                  fluidRow(
                                                    column(5, compute_sampling_frequency_div,
                                                           tags$head(tags$style("#current_sampling_frequency{color:#3498db;font-size:20px;text-align:center}"))
                                                    ),
                                                    column(7,manage_outliers_by_value_div)
                                                  ), style = 'info')

################################################################################
#                         Missing values components                            #
################################################################################

manage_missing_values_panel = bsCollapsePanel('Manage missing values',
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
                                              ), style = 'primary')