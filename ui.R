
shinyUI(navbarPage("FORECASTING",
                  
                   tabPanel("PLAY",
                            sidebarLayout(
                                    sidebarPanel(
                                            
                                            selectInput("tsName", label = p(strong(h5("Choose a time series"))), 
                                                        choices = c("ausbeer", 
                                                                    "chocolate confectionery",
                                                                    "UKgas", 
                                                                    "austres",
                                                                    "JohnsonJohnson" ,
                                                                    "retail turnover",
                                                                    "reports of a French company"),
                                                        
                                                        selected = 1
                                            ),
                                            checkboxInput("adjust", label = p(strong(h5("Make the time series seasonally adjusted or not")) 
                                            ) , value = FALSE
                                            ),
                                            
                                            br(),
                                            
                                            uiOutput("R1Control"),
                                            uiOutput("R2Control"),
                                            helpText("Number of Quarters to forecast:" ),
                                            verbatimTextOutput("test"),
                                            
                                            uiOutput("RControl"),
                                            helpText("Number of Quarters used to forecast:" ),
                                            verbatimTextOutput("train"),
                                            br(),
                                            
                                            
                                            actionButton("go", h3(strong("Go"))),
                                            hr(),
                                            
                                            selectInput("measure", label = "Choose a measure of the forecast accuracy:", 
                                                        choices = list("MAPE" = "MAPE", "RMSE" = "RMSE", "MASE" = "MASE" ),
                                                        selected = 1
                                            )
                                    ),
                                    mainPanel(
                                            
                                            
                                            tabsetPanel(type = "tabs", 
                                                        
                                                        
                                                        tabPanel("TS SELECTED " ,
                                                                 hr(),
                                                                 
                                                                 h2(textOutput("curTsNm"), align = "center"),
                                                                 hr(),
                                                                 h4(textOutput("range")),
                                                                 hr(),
                                                                 
                                                                 h4(textOutput("smNm")),
                                                                 tableOutput("sm"),
                                                                 
                                                                 plotOutput("seasplot"),
                                                                 plotOutput("mnthplot"),
                                                                 plotOutput("acf")
                                                                 
                                                                 
                                                        ),
                                                        
                                                        
                                                        tabPanel("PLOT", 
                                                                 br(),
                                                                 
                                                                 h2(textOutput("plotNm"), align = "center"),
                                                                 
                                                                 plotOutput("plot") 
                                                                 
                                                        ), 
                                                        
                                                        tabPanel("ZOOM",
                                                                 br(),
                                                                 
                                                                 h2(textOutput("zoomNm"), align = "center"),
                                                                 
                                                                 plotOutput("zoom")
                                                                 
                                                        ), 
                                                        
                                                        tabPanel("ACCURACY",
                                                                 hr(),
                                                                 hr(),
                                                                 hr(),
                                                                 hr(),
                                                                 h2(textOutput("acNm"), align = "center"),
                                                                 hr(),
                                                                 hr(),
                                                                 hr(),
                                                                 fluidRow( 
                                                                         column(12,
                                                                                h4(textOutput("measureChoice")),
                                                                                br(),
                                                                                tableOutput("accuracy"),
                                                                                align = "center"
                                                                         )
                                                                 )
                                                                 
                                                        ),
                                                        
                                                        tabPanel("TABLE",
                                                                 hr(),
                                                                 h2(textOutput("tbNm"), align = "center"),
                                                                 h3("ACTUAL VALUES AND FORECASTS", align="center"),
                                                                 br(),
                                                                 p(strong(h4("Top 3 ranked models, starting from the best one"))),
                                                                 hr(),
                                                                 
                                                                 tableOutput("table")
                                                        ),
                                                        
                                                        tabPanel("RESIDUALS",
                                                                 hr(),
                                                                 h2(textOutput("resNm"), align = "center"),
                                                                 p(strong(h4("Residuals relative to the method of best accuracy :"
                                                                             , align="center"))),
                                                                 
                                                                 p(strong(h4(textOutput("name1"), align="center"))),
                                                                 br(),
                                                                 plotOutput("histRes"),
                                                                 plotOutput("acfRes")
                                                        )    
                                                        
                                            )
                                    )
                            )),
                   
                   
                   tabPanel("DOCUMENTATION",
                            p("This application displays on the same plot the forecasts made by 7 different methods 
once you have selected a time series from a drop-down list, then a period to forecast (test set)  
and a period used to forecast (training set) (these are consecutive) through 3 sliders.", br(),  
"Four methods, namely Mean, Naive, Drift and Seasonal naive are simple methods used as benchmarks.", br(),   
"The other three, Exponential smoothing, Multiple regression and Simple regression, are compared to these so as to
see whether they are doing better or not. 
",br(),br(),
"You will find more below in 'HOW TO USE IT'"),
hr(),
                            p("Links to the time series:", br(),
                              a( "ausbeer",
                                 href= "http://cran.r-project.org/web/packages/fpp/fpp.pdf"), br(),
                              a( "chocolate confectionery",
                                 href= "http://datamarket.com/data/set/22wm/quarterly-production-of-chocolate-confectionery-in-australia-tonnes-sep-1957-sep-1994#!ds=22wm&display=line"), br(), 
                              a( "UKgas",
                                 href= "http://stat.ethz.ch/R-manual/R-devel/library/datasets/html/UKgas.html"), br(), 
                              a("austres", 
                                href="http://stat.ethz.ch/R-manual/R-devel/library/datasets/html/austres.html"), br(), 
                              a("JohnsonJohnson",
                                href= "http://stat.ethz.ch/R-manual/R-devel/library/datasets/html/JohnsonJohnson.html"), br(),      
                              a( "retail turnover", 
                                 href= "http://datamarket.com/data/set/22n7/quarterly-retail-turnover-m-current-jun-1982-dec-1991#!ds=22n7&display=line"), br(),      
                              a( "reports of a French company", 
                                 href= "http://datamarket.com/data/set/22pj/quarterly-reports-of-a-french-company#!ds=22pj&display=line"), br()
                            ), 
                            
                            p("Reference:", br(),
                              a( "Forecasting: principles and practice",
                                 href= "http://www.otexts.org/fpp/"), "Rob J Hyndman and George Athanasopoulos"
                            ),
hr(),
                           p("HOW TO USE IT"),
hr(),

                            pre(includeText("documentation.txt"))
                   ),
                   
                   
                   navbarMenu("STATISTICS",
                              
                              tabPanel("PLOTS",
                                       p("Given a time series, we carried out a lot of tests, 
that is a lot of different positions for the 3 sliders, and were interested 
for each forecasting method in the percentage of times when this one ranked n°1 
and also in the mean and standard deviation of its MAPE.
You may want to see the tab STATISTICS/algorithm logic for more.", br(),
                                         "The following plots show these results."),
                                       br(),        
                                       p(h4("Please allow a few seconds", align="center")),
                                       
                                       fluidRow( h3(textOutput("title1"), align="center"),
                                               
                                               column(6,
                                                     
                                                      plotOutput("plot11")
                                               ),
                                               column(6,
                                                      plotOutput("plot12")
                                               )
                                               
                                       ),
                                       hr(),
                                       fluidRow( h3(textOutput("title2"), align="center"),
                                              
                                               column(6,
                                                      plotOutput("plot21")
                                               ),
                                               
                                               column(6,
                                                      plotOutput("plot22")
                                               )
                                               
                                       ),
                                       hr(),
                                       fluidRow(  h3(textOutput("title3"), align="center"),
                                              
                                               column(6,
                                                      plotOutput("plot31")
                                               ),
                                               
                                               column(6,
                                                      plotOutput("plot32")
                                               )
                                               
                                       ),
                                       hr(),
                                       fluidRow( h3(textOutput("title4"), align="center"),
                                              
                                               column(6,
                                                      plotOutput("plot41")
                                               ),
                                               
                                               column(6,
                                                      plotOutput("plot42")
                                               )
                                               
                                       ),
                                       hr(),
                                       fluidRow(  h3(textOutput("title5"), align="center"),
                                               
                                               column(6,
                                                      plotOutput("plot51")
                                               ),
                                               
                                               column(6,
                                                      plotOutput("plot52")
                                               )
                                               
                                       ),
                                       hr(),
                                       fluidRow( h3(textOutput("title6"), align="center"),
                                               
                                               column(6,
                                                      plotOutput("plot61")
                                               ),
                                               
                                               column(6,
                                                      plotOutput("plot62")
                                               )
                                               
                                       ),
                                       hr(),
                                       fluidRow( h3(textOutput("title7"), align="center"),
                                               
                                               column(6,
                                                      plotOutput("plot71")
                                               ),
                                               
                                               column(6,
                                                      plotOutput("plot72")
                                               )
                                               
                                       )
                              ),
                              tabPanel("plots code",
                                       pre(includeText("plots14_code.txt"))
                              ),
                              
                              tabPanel("statistics code",
                                       pre(includeText("statistics_code.txt"))
                              ),
                              
                              tabPanel("algorithm logic",
                                       pre(includeText("algo_logic.txt"))
                              )
                   ),
                   
                   tabPanel("SERVER_CODE",
                            
                            pre(includeText("server.txt"))
                   ),
                   
                   tabPanel("UI_CODE",
                            
                            pre(includeText("ui.txt"))
                   ),
                   
                   tabPanel("PITCH",
                            p( a( "LINK TO PITCH" , href= "http://lelayj.github.io/DATAPRODPITCH/pitch.html"), br(),br(),
                              "PITCH CHUNKS CODES below:", br()
                              ),
                            
                            pre(includeText("chunks_codes.txt"))
                   )
))

