
library(shiny)
library(fpp)
library(ggplot2)


# LOADING DATA
chocolate_confectionery <- readRDS("data/chocolate_confectionery.rds")
retail_turnover <- readRDS("data/retail_turnover.rds")
reports_of_a_French_company <- readRDS("data/reports_of_a_French_co.rds")

g <- readRDS("data/plots14.rds")

shinyServer(function(input, output) {
        
        
        # GETTING DATA
        
        data <-  reactive({
                switch(input$tsName,
                       "ausbeer" = ausbeer,
                       "chocolate confectionery"= chocolate_confectionery,
                       "UKgas"=UKgas, 
                       "austres"= austres,
                       "JohnsonJohnson"= JohnsonJohnson,
                       "retail turnover"= retail_turnover,
                       "reports of a French company"= reports_of_a_French_company
                       
                )
                
        })
        
        
        
        # time series s seasonally adjusted
        stlFit <-  reactive({
                stl(data(), s.window= "periodic")
        })
        
        dataA <- reactive({ 
                
                seasadj(stlFit()) 
        })
        
        # final time series 
        s0 <-reactive({ 
                
                if(input$adjust){ dataA() } else{data()}
        })
        
        # getting the time of the first observation (e.g. 1959.25 if 1959Q2)
        s0Start <- reactive({
                attributes(s0())$tsp[1]
                
        })
        # getting the time of the last observation (e.g. 1961.50 if 1961Q3)
        s0End <-   reactive({
                attributes(s0())$tsp[2]
                
        })
        
        
        # SLIDERS
        
        # step for sliders below
        step <- 0.25
        
        # creating a slider to choose the start of the period to forecast (test set)
        # s0Start()+ 7*step: this will allow the 3rd slider to have at least 2 quaters
        # s0End()- 3*step: this will allow the 2nd slider to have at least 2 quaters
        output$R1Control <- renderUI({
                
                min <- s0Start()+ 7*step 
                max <- s0End()- 3*step
                value <- ( min + 4*max ) %/% 5 # placing "value" at 80% of the interval (min,max)
                step <- step
                sliderInput("R1", 
                            # start of the forecast period
                            label = "Choose the start of the period to forecast (test set):", 
                            min = min, 
                            max = max,
                            value = value,
                            step=step,
                            ticks=FALSE
                            
                )
        })
        
        #  creating a slider to choose the end of the period to forecast
        output$R2Control <- renderUI({
                
                min <- input$R1+ 2*step 
                max <- s0End() 
                value <- max
                sliderInput("R2", label ="Choose the end of the period to forecast:", 
                            min = min, 
                            max = max,
                            value = value,
                            step=step ,
                            ticks=FALSE
                            
                )
                
        })
        
        # Number of Quarters to forecast
        output$test <- renderPrint({ 
                4*(input$R2-input$R1 ) 
        })
        
        
        #  creating a slider to choose the start of the period used for fitting 
        # a model (training set).
        # input$R1-6*step : this will allow the training set to have at least 6 quaters ,
        # number needed so as to avoid any problem with the Autocorrelation 
        # Function of the residuals
        output$RControl <- renderUI({
                min <-s0Start()
                max <- input$R1-6*step 
                value <- min
                sliderInput("R", label ="Choose the start of the period used as training set:", 
                            min = min, 
                            max = max,
                            value = value,
                            step=step ,
                            ticks=FALSE
                            
                )
        })
        
        # Number of Quarters used as training set:
        output$train <- renderPrint({ 
                4*(input$R1 - input$R)
        })
        
        
        
        # The Go button has been created to allow the sliders R and R2 to move each
        # to its own extreme position especially in case the slider R1 is moved
        # beyond their range. Without any Go button the calculations would actually begin
        # as soon as the mouse button is released resulting in an error.
        
        # eventReactive (invalidating in response to a click on the Go button) prevents 
        # from assigning new values to the following variables r, r1, r2 and s
        # until the Go button has been clicked. 
        # However, their values are NULL at the beginning of the session, and if the following 
        # observeEvent had not been introduced, asking directly either for the tab PLOT or ZOOM 
        # without first clicking the Go button would have caused an error.
        
        
        observeEvent(input$go,{
                
                # start of the period  to forecast:
                r1 <- eventReactive(input$go,{
                        input$R1
                })
                
                # end of the period to forecast:
                r2 <-  eventReactive(input$go,{
                        input$R2
                })
                
                # start of the training set:
                r <-  eventReactive(input$go,{
                        input$R
                })
                
                
                # if eventReactive were not introduced, creating s, an error may occur 
                # in case s0() has changed by clicking in the menu "Choose a time series"
                # since the calculations for the first 5 tabs of the main panel would be 
                # immediately carried out, whereas r, r1, r2  would still be 
                # waiting for "Go" to take their new values and would not be yet 
                # relative to the new s0() but to the former one.
                # On the other hand it is better to place s after r1, r2, r so as to allow
                # them some more time to take their new values (this asks more time than for s)
                
                s <-  eventReactive(input$go,{
                        s0()
                })
                sStart <- reactive({
                        attributes(s())$tsp[1]
                        
                })
                # getting the time of the last observation (e.g. 1961.50 if 1961Q3)
                sEnd <-   reactive({
                        attributes(s())$tsp[2]
                        
                })
                
                # title for tabs contents
                tsName_ <- eventReactive(input$go, {
                        input$tsName
                })  
                
                # GETTING INFORMATION ABOUT THE ACTUAL TIME SERIES SELECTED
                # for the SELECTED TS TAB
                
                output$curTsNm <- renderText({ 
                        tsName_()
                })
                
                
                # its range
                output$range <- renderText({
                        paste("Quaterly time series,  length= ", length(s()),
                              ", start = ", sStart(), ", end = ", sEnd()
                        )
                })
                
                # summary
                output$smNm <- renderText({
                        "Summary"
                })
                
                output$sm <- renderTable({
                        sm <- as.vector(summary( s()))
                        names(sm) <- c("Min.", "1st Qu.", "Median",  "Mean" , "3rd Qu.", "Max.")  
                        dsm <-as.data.frame(rbind(sm))
                        rownames(dsm) <- ""
                        dsm
                })
                
                # seasonal plots for TS SELECTED  tab
                
                # keeping a maximum of 80 observations so as to get more readable plots
                
                sEnd80 <- reactive({
                        min(sStart()+19.75, sEnd())
                })
                
                s_ <- reactive({
                        ts(s(), start=sStart(), end=sEnd80() , frequency = 4)
                })
                
                
                output$seasplot <- renderPlot({
                        seasonplot(s_(), main="Seasonal plot", year.labels=TRUE,
                                   year.labels.left=TRUE, col=1:20 )
                })
                
                #  here, no ceiling
                output$mnthplot <- renderPlot({
                        monthplot(s(), main="Seasonal deviation plot", ylab="" )
                })
                
                # Autocorrelation function
                
                output$acf <- renderPlot({
                        Acf(s(), main="Autocorrelation function" )
                })
                
                # FOR USE IN THE OTHER TABS
                
                
                # window of quarters used as training set
                s1 <- reactive({
                        window(s(), start=r(), end=r1()-0.1)
                })
                
                
                # window of quarters to forecast
                s2 <- reactive({
                        window(s(), start=r1(), end=r2()-0.1) })
                
                # Number of Quarters to forecast
                h <- reactive({
                        4*(r2()- r1() ) 
                }) 
                
                
                
                # window of quarters used as training and test sets
                s1s2 <- reactive({ 
                        window(s(),  start=r(), end=r2()-0.1) })
                
                # FORECASTING METHODS
                # Forecasts (and prediction intervals) made using 7  methods
                
                FUN_fc <- function(s1,h){ 
                        
                        regFit1 <- tslm(s1 ~ trend)
                        regFit2 <- tslm(s1 ~ trend + season) 
                        etsFit <- ets(s1)
                        
                        f1 <- forecast(etsFit, h=h)
                        f2 <- snaive(s1, h)  
                        f3 <- forecast( regFit2, h=h )
                        f4 <- forecast( regFit1, h=h )
                        f5 <- meanf(s1, h)
                        f6 <- naive(s1, h) 
                        f7 <- rwf(s1, h, drift=TRUE)
                        
                        
                        list(Exponential_Smoothing=f1, Seasonal_naive=f2, Multiple_regression =f3, 
                             Simple_regression=f4, Mean=f5, Naive=f6, Drift=f7
                        )
                } 
                
                # getting the forecasts relative to the actual s1 and h
                fc <-reactive({
                        FUN_fc(s1(),h())
                })
                
                # FORECASTS
                # PLOT, ZOOM
                
                FUN_PZ <- function(sr, fc, type){
                        # sr as series (s1s2 or s2), fc as list of 7 forecasts
                        # type as "PLOT" or "ZOOM"
                        cols <- c("purple","orange",  "red", "green", 
                                  "blue", "gray50", "goldenrod3", "indianred4")
                        
                        plot(sr, main="", 
                             xlab="Quarters", ylab="", lwd=2, col=cols[1])
                        
                        for(k in 1:7){
                                
                                lines(fc[[k]]$mean, lwd=2, col=cols[k+1])
                        }
                        
                        legend(ifelse(type=="PLOT","topleft","topright"), lwd=4, col=cols,
                               
                               legend=c("Actual values","Exponential smoothing","Seasonal naive",
                                        "Multiple regression","Simple regression","Mean", "Naive",
                                        "Drift" ))
                }
                
                output$plotNm <- renderText({ 
                        tsName_()
                })
                
                
                output$plot <- renderPlot({ 
                        FUN_PZ(s1s2(), fc(), "PLOT")
                        
                })
                
                
                # ZOOM
                
                # title for zoom
                output$zoomNm <- renderText({ 
                        tsName_()
                })
                
                output$zoom <- renderPlot({ 
                        FUN_PZ(s2(), fc(), "ZOOM")
                        
                })
                
                
                # ACCURACY
                
                output$acNm <- renderText({ 
                        tsName_()
                })
                
                # measures of the forecast accuracy: "MAPE", "RMSE" or "MASE",
                
                # title 
                output$measureChoice <- renderText({
                        switch(input$measure,
                               "MAPE"="MEAN ABSOLUTE PERCENTAGE ERROR",
                               "RMSE"="ROOT MEAN SQUARED ERROR",
                               "MASE"= "MEAN ABSOLUTE SCALED ERROR"
                        )
                })
                
                FUNmeasure <- function(f){
                        
                        round( accuracy(f, s2())[2, input$measure]
                               ,1 )
                }
                
                # Accuracy measure value  for each of the  forecasting methods
                a <-  reactive({ 
                        sapply(fc(), FUNmeasure)
                })
                
                # rank of each method according to its accuracy measure value
                rk <- reactive({ 
                        rank(a(), ties.method = "min")
                })
                
                output$accuracy <- renderTable({
                        
                        aRk <-  data.frame( rbind( a(), rk() )) 
                        rownames(aRk)<- c(input$measure, "rank")   
                        aRk
                        
                })
                
                
                # TABLE
                
                output$tbNm <- renderText({ 
                        tsName_()
                })
                
                output$table <- renderTable({
                        
                        df <- round( data.frame(Actual_values=s2(),
                                                Exponential_Smoothing=fc()[[1]]$mean,
                                                Seasonal_naive=fc()[[2]]$mean,
                                                Multiple_regression=fc()[[3]]$mean,
                                                Simple_regression=fc()[[4]]$mean,
                                                Mean=fc()[[5]]$mean,
                                                Naive=fc()[[6]]$mean,
                                                Drift=fc()[[7]]$mean)
                                     ,1)
                        # placing the variables of df in increasing order of their accuracy 
                        # measure values (a)
                        # (note from HELP in Details for order:
                        # any unresolved ties will be left in their original ordering)
                        # first, numbering them with their column number in df 
                        # (same number as in the vector a, plus 1)
                        nb <- 2:8
                        ord <- order( a() ) 
                        nb <- nb[ord]
                        # leaving the first column at the first place
                        df <-df[, c(1,nb) ] 
                        # keeping the best 3 methods only (and the first column)
                        df[, 1:4 ] 
                        
                })
                
                # RESIDUALS
                
                output$resNm <- renderText({ 
                        tsName_()
                })
                
                
                # fc elements placed according to their rank (1,2,...)
                
                ord <- reactive({ 
                        order(a())
                })
                
                fc_ord <-  reactive({ 
                        fc()[ord()]
                })
                
                # title for residuals
                output$name1 <- renderText({ 
                        names(fc_ord()[1])
                })
                
                
                res <- reactive({ 
                        residuals(fc_ord()[[1]] )
                })
                
                output$histRes <- renderPlot({
                        
                        hist(res(), main= "Histogram of residuals")
                })
                
                output$acfRes <- renderPlot({
                        
                        Acf(res(), main= "Autocorrelation Function of residuals")
                })
                
                
        })         
        
        # displaying the results of tests already carried out, stored in the file
        # "statistics.rds" generated by  the code stored in the file "statistics_code.Rmd",
        # presented in the form  of 14 bar plots stored in the file "plots14.rds".
        # 14 plots = 2 plots per time series x 7 time series. 
        # Given a time series, the first of the two shows for each forecasting method 
        # the percentage of tests for which the forecasting method ranked n°1, 
        # and the second one shows the mean MAPE of each method along with its standard deviation. 
        
        # see tab STATISTICS for more.
        
        output$title1 <- renderText({
                paste("Time series ausbeer,  length = ", length(ausbeer))
        })
        output$title2 <- renderText({
                paste("Time series chocolate confectionery,  length = ", length(chocolate_confectionery))
        })
        output$title3 <- renderText({
                paste("Time series UKgas,  length = ", length(UKgas))
        })
        output$title4 <- renderText({
                paste("Time series austres,  length = ", length(austres))
        })
        output$title5 <- renderText({
                paste("Time series JohnsonJohnson,  length = ", length(JohnsonJohnson))
        })
        output$title6 <- renderText({
                paste("Time series retail turnover,  length = ", length(retail_turnover))
        })
        output$title7 <- renderText({
                paste("Time series reports of a French company,  length = ", length(reports_of_a_French_company))
        })
        
        
        output$plot11 <- renderPlot({g[[1]][[1]] })
        output$plot12 <- renderPlot({g[[1]][[2]] })            
        output$plot21 <- renderPlot({g[[2]][[1]] })
        output$plot22 <- renderPlot({g[[2]][[2]] })                        
        output$plot31 <- renderPlot({g[[3]][[1]] })
        output$plot32 <- renderPlot({g[[3]][[2]] })            
        output$plot41 <- renderPlot({g[[4]][[1]] })
        output$plot42 <- renderPlot({g[[4]][[2]] })                        
        output$plot51 <- renderPlot({g[[5]][[1]] })
        output$plot52 <- renderPlot({g[[5]][[2]] })            
        output$plot61 <- renderPlot({g[[6]][[1]] })
        output$plot62 <- renderPlot({g[[6]][[2]] })                        
        output$plot71 <- renderPlot({g[[7]][[1]] })
        output$plot72 <- renderPlot({g[[7]][[2]] })            
        
        
        
        
        
        
})

