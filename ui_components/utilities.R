upload_file_panel = tabsetPanel(type = "tabs",
                                #selected = 'Default', # TODO remove, used for debug only
                                tabPanel("Custom", 
                                         fileInput("file_input", h4("Upload custom file:"),
                                                    accept=c('csv', 'comma-separated-values','.csv')),
                                         h4("File Format:"),
                                         h5("\"date\",\"value\""),
                                         h5("2021-01-31 23:59:52,720")
                                ),
                                tabPanel("Default",
                                         div(style='display: flex',
                                             div(style='width:70%;padding-right:20px', 
                                                  selectInput('default_filename', label=h4('Select default file:'),
                                                                choices=c('basic', 'medium', 'advanced'))),
                                             div(style='width:20%;padding-top:45px', 
                                                 actionButton('load_default', 'Load', style='padding:6px;width:60px'))
                                         )
                                )
                    )




current_info_panel =  tabsetPanel(type = "tabs",
                                  selected = 'Stats', # TODO remove, used for debug only
                                  tabPanel("Stats",
                                           img(src='work_in_progress.png', height = '250px', width = '400px')
                                  ),
                                  tabPanel("Current model",
                                           img(src='work_in_progress.png', height = '250px', width = '400px')
                                  )
                      )
