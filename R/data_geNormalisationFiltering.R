#' Interface to normalise and filter gene expression
#' 
#' @param ns Namespace function
#' 
#' @importFrom shiny numericInput div column fluidRow tags helpText 
#' selectizeInput
#' @importFrom shinyjs hidden
#' 
#' @return HTML elements
geNormalisationFilteringInterface <- function(ns) {
    filters <- div(
        id=ns("filteringInterface"),
        fluidRow(
            column(6, numericInput(ns("minMean"), "Min mean >",
                                   min=-1, max=100, value=0, width="100%")),
            column(6, numericInput(ns("maxMean"), "Max mean <", 
                                   min=-1, max=100, value=100, width="100%"))),
        fluidRow(
            column(6, numericInput(ns("minVar"), "Min variance >", 
                                   min=-1, max=100, value=0, width="100%")),
            column(6, numericInput(ns("maxVar"), "Max variance <", 
                                   min=-1, max=100, value=100, width="100%"))),
        fluidRow(
            column(6, numericInput(ns("minCounts"), "At least X counts...", 
                                   min=0, max=100, value=10, width="100%")),
            column(6, numericInput(ns("minSamples"), "...in \u2265 N samples", 
                                   min=0, max=100, value=10, width="100%"))),
        helpText(textOutput(ns("filteredGenes"))))
    
    filteringAssistant <- NULL
    # filteringAssistant <- div(
    #     id=ns("assistantInterface"),
    #     hr(), h4("Filtering assistant"), 
    #     selectizeInput(ns("assistantPlot"), "Plot type", width="100%",
    #                    c("Boxplot of the mean expression"="mean", 
    #                      "Boxplot of the variance expression"="var")),
    #     highchartOutput(ns("filteringAssistant"), height="150px")
    # )
    
    options <- div(
        id=ns("options"),
        selectizeInput(ns("geneExpr"), "Gene expression dataset", width="100%",
                       choices=NULL),
        bsCollapse(
            bsCollapsePanel(
                tagList(icon("filter"), "Gene filtering"), value="Filtering",
                checkboxInput(ns("enableFiltering"), value=TRUE, width="100%",
                              "Enable gene-wise filtering"),
                filters, filteringAssistant),
            bsCollapsePanel(
                tagList(icon("balance-scale"), "Normalisation"), 
                value="Normalisation",
                helpText("Calculate normalisation factors to scale the raw",
                         "library sizes using the function", 
                         tags$code("edgeR::calcNormFactors")),
                selectizeInput(
                    ns("normalisation"), "Normalisation method", width="100%",
                    c("Weighted trimmed mean of M-values (TMM)"="TMM",
                      "Relative log expression (RLE)"="RLE",
                      "Upper-quartile normalisation"="upperquartile",
                      "No normalisation"="none"),
                    options = list(render = I(
                        '{ option: function(item, escape) {
                            var description;
                            switch(item.value) {
                                case "TMM":
                                    description = "This method is recommended" +
                                        " for most RNAseq data where more " +
                                        "than half of the genes are believed " +
                                        "not differentially expressed " + 
                                        "between any pair of the samples.";
                                    break;
                                case "RLE":
                                    description = "The median library is " +
                                        "calculated from the geometric mean " +
                                        "of all columns and the median ratio " +
                                        "of each sample to the median library" +
                                        " is taken as the scale factor.";
                                    break;
                                case "upperquartile":
                                    description = "The scale factors are " +
                                        "calculated from a given quantile of " +
                                        "the counts for each library, after " +
                                        "removing genes with zero counts in " +
                                        "all libraries.";
                                    break;
                                case "none":
                                    description = "";
                                    break;
                            }
                            return "<div><span class=\'label label-default\'>" +
                                   escape(item.label) + 
                                   "</span></br>" + "<small>" + description + 
                                   "</small></div>"; } }'))),
                conditionalPanel(
                    sprintf("input[id='%s'] == '%s'", ns("normalisation"),
                            "upperquartile"),
                    sliderInput(ns("upperquartilePercentile"), width="100%",
                                paste("Percentile of the counts used to",
                                      "calculate scale factors"),
                                min=0, max=1, value=0.75, step=0.01))),
            bsCollapsePanel(
                tagList(icon("retweet"), "Compute CPM and log-transform"), 
                value="Log-transformation",
                helpText("Compute counts per million (CPM) and log2-transform",
                         "values using", tags$code("edgeR::cpm")),
                checkboxInput(
                    ns("log2transformation"), value=TRUE, width="100%",
                    paste("Perform log2 transformation")),
                numericInput(
                    ns("priorCount"), value=0.25, width="100%",
                    paste("Average count to add to each observation to avoid",
                          "zeroes after log-transformation")))))
    
    tagList(
        uiOutput(ns("modal")),
        errorDialog("No gene expression data is loaded.",
                    id=ns("missingData"), style="margin: 10px;"),
        hidden(options),
        actionButton(ns("loadGeneExpr"), "Load from file..."),
        disabled(processButton(ns("processGeneExpr"), 
                               "Filter and normalise gene expression")))
}

#' @rdname appUI
geNormalisationFilteringUI <- function(id, panel) {
    ns <- NS(id)
    title <- "Gene expression filtering and normalisation"
    panel(style="success", title=tagList(icon("cogs"), title),
          value=title, geNormalisationFilteringInterface(ns))
}

#' Filter and normalise gene expression
#' 
#' @param geneExpr Matrix or data frame: gene expression
#' @param geneFilter Boolean: filtered genes
#' @inheritParams edgeR::calcNormFactors
#' @param log2transform Boolean: perform log2-transformation?
#' @param priorCount Average count to add to each observation to avoid zeroes 
#' after log-transformation
#' 
#' @importFrom edgeR DGEList calcNormFactors cpm
#' 
#' @return Gene expression filtered and normalised
#' @export
#' 
#' @examples 
#' geneExpr <- readFile("ex_gene_expression.RDS")
#' normaliseGeneExpression(geneExpr)
normaliseGeneExpression <- function(geneExpr, geneFilter=NULL, method="TMM", 
                                    p=0.75, log2transform=TRUE, 
                                    priorCount=0.25) {
    updateProgress("Processing gene expression", divisions=3)
    
    updateProgress("Filtering gene expression")
    if (is.null(geneFilter)) geneFilter <- TRUE
    else if (!any(geneFilter)) return(NULL)
    geneExprNorm <- DGEList(geneExpr[geneFilter, , drop=FALSE])
    
    updateProgress("Normalising gene expression")
    geneExprNorm <- calcNormFactors(geneExprNorm, method=method, p=p)
    geneExprNorm <- cpm(geneExprNorm, log=log2transform, 
                        prior.count=priorCount)
    
    updateProgress("Preparing gene expression data")
    geneExprNorm <- data.frame(geneExprNorm)
    colnames(geneExprNorm) <- colnames(geneExpr)
    
    # Pass attributes from original gene expression table (except for names)
    notNames <- !names(attributes(geneExpr)) %in% 
        c(names(attributes(geneExprNorm)), "names", "row.names", "class")
    attributes(geneExprNorm) <- c(attributes(geneExprNorm),
                                  attributes(geneExpr)[notNames])
    return(geneExprNorm)
}

#' Set of functions to load splicing quantification
#' 
#' @importFrom shiny tags
#' @importFrom shinyBS bsPopover
#' @inherit geNormalisationFilteringServer
loadGeneExpressionSet <- function(session, input, output) {
    ns <- session$ns
    
    # Show modal for loading gene expression data
    observeEvent(input$loadGeneExpr, {
        infoModal(
            session, "Load gene expression data",
            geneExprFileInput(ns("customGeneExpr")),
            uiOutput(ns("alertGeneExpr")),
            footer=processButton(ns("loadCustomGE"), "Load quantification"))
    })
    
    observeEvent(input$loadGeneExpr, {
        prepareFileBrowser(session, input, "customGeneExpr")
    }, once=TRUE)
    
    observeEvent(input$loadCustomGE, loadGeneExpression())
    
    # Load alternative splicing quantification
    loadGeneExpression <- reactive({
        time <- startProcess("loadGeneExpr")
        
        updateProgress("Wait a moment", divisions=2)
        updateProgress("Loading gene expression")
        
        allFormats <- loadFileFormats()
        formats <- allFormats[sapply(allFormats, "[[", 
                                     "dataType") == "Gene expression"]
        
        geneExpr <- tryCatch(parseValidFile(input$customGeneExpr, formats),
                             warning=return, error=return)
        if (is(geneExpr, "error")) {
            if (geneExpr$message == paste("'file' must be a character string",
                                          "or connection"))
                errorAlert(session, title="Error", "No file was provided",
                           alertId="alertGeneExpr")
            else
                errorAlert(session, title="Error", 
                           geneExpr$message, alertId="alertGeneExpr")
        } else if (is(geneExpr, "warning")) {
            warningAlert(session, title="Warning", 
                         geneExpr$message, alertId="alertGeneExpr")
        } else {
            removeAlert(output, "alertGeneExpr")
            
            if ( is.null(getData()) ) {
                name <- file_path_sans_ext( basename(input$customGeneExpr) )
                name <- gsub(" Gene expression.*$", "", name)
                if (name == "") name <- "Unnamed"
                
                data <- setNames(list(list("Gene expression"=geneExpr)), name)
                data <- processDatasetNames(data)
                setData(data)
                setCategory(name)
                
                samples <- colnames(geneExpr)
                parsed <- parseTcgaSampleInfo(samples) 
                if ( !is.null(parsed) ) setSampleInfo(parsed)
            } else {
                name <- renameDuplicated("Gene expression",
                                         names(getCategoryData()))
                setDataTable(name, geneExpr)
            }
            removeModal()
        }
        endProcess("loadGeneExpr", time)
    })
}

#' @rdname appServer
#' 
#' @importFrom shiny reactive observeEvent helpText removeModal
#' updateNumericInput
#' @importFrom tools file_path_sans_ext
#' @importFrom shinyjs enable disable hide show
#' @importFrom data.table fread
#' @importFrom highcharter hcboxplot hc_plotOptions hc_xAxis hc_chart
geNormalisationFilteringServer <- function(input, output, session) {
    ns <- session$ns
    observeEvent(input$missing, missingDataGuide("Gene expression"))
    
    # Warn user if gene expression is not loaded
    observe({
        if (is.null(getGeneExpression())) {
            hide("options")
            disable("processGeneExpr")
            show("missingData")
        } else {
            show("options")
            enable("processGeneExpr")
            hide("missingData")
        }
    })
    
    # Update available gene expression data according to loaded files
    observe({
        geneExpr <- getGeneExpression()
        if (!is.null(geneExpr)) {
            updateSelectizeInput(session, "geneExpr",
                                 choices=c(names(geneExpr),
                                           "Select gene expression data"=""))
        } else {
            updateSelectizeInput(
                session, "geneExpr",
                choices=c("No gene expression data loaded"=""))
        }
    })
    
    # Update label of numeric input according to input itself (more intuitive)
    observeEvent(input$minCounts, {
        label <- sprintf("At least %s counts...", input$minCounts)
        updateNumericInput(session, "minCounts", label=label)
    })
    
    observeEvent(input$minSamples, {
        label <- sprintf("...in \u2265 %s samples", input$minSamples)
        updateNumericInput(session, "minSamples", label=label)
    })
    
    getFilter <- reactive({
        geneExpr <- isolate(input$geneExpr)
        if (is.null(geneExpr) || geneExpr == "") return(NULL)
        geneExpr <- isolate(getGeneExpression()[[geneExpr]])
        
        minMean    <- input$minMean
        maxMean    <- input$maxMean
        minVar     <- input$minVar
        maxVar     <- input$maxVar
        minCounts  <- input$minCounts
        minSamples <- input$minSamples
        
        if (is.na(minMean) || is.na(maxMean) || 
            is.na(minVar) || is.na(maxVar) || 
            is.na(minCounts) || is.na(minSamples)) {
            return(NULL)
        }
        
        # Check if min. counts are available in at least N samples
        checkCounts <- rowSums(geneExpr >= minCounts) >= minSamples
        
        geneExprMean <- rowMeans(geneExpr)
        geneExprVar  <- rowVars(geneExpr)
        filter <- geneExprMean > minMean & geneExprMean < maxMean &
            geneExprVar > minVar & geneExprVar < maxVar & checkCounts
        return(filter)
    })
    
    output$filteredGenes <- renderText({
        geneExpr <- input$geneExpr
        if (is.null(geneExpr) || geneExpr == "") return(NULL)
        geneExpr <- isolate(getGeneExpression()[[geneExpr]])
        
        filter <- sum(getFilter())
        total  <- nrow(geneExpr)
        ratio  <- filter/total * 100
        
        if (input$enableFiltering) {
            msg <- sprintf("Selecting %s genes (%s%%) out of %s.", 
                           filter, round(ratio), total)
        } else {
            msg <- sprintf("Selecting all %s genes.", total)
        }
        return(msg)
    })
    
    # Update filtering options based on selected gene expression data
    observeEvent(input$geneExpr, {
        geneExpr <- isolate(input$geneExpr)
        if (is.null(geneExpr) || geneExpr == "") return(NULL)
        geneExpr     <- isolate(getGeneExpression()[[geneExpr]])
        
        # Update mean range
        geneExprMean <- rowMeans(geneExpr)
        maxMean      <- ceiling( max(geneExprMean, na.rm=TRUE) )
        updateNumericInput(session, "minMean", max=maxMean)
        updateNumericInput(session, "maxMean", max=maxMean, value=maxMean)
        
        # Update variance range
        geneExprVar <- rowVars(geneExpr)
        maxVar      <- ceiling( max(geneExprVar, na.rm=TRUE) )
        updateNumericInput(session, "minVar", max=maxVar)
        updateNumericInput(session, "maxVar", max=maxVar, value=maxVar)
        
        # Update minimum samples based on available samples
        updateNumericInput(session, "minSamples", 
                           value=min(ncol(geneExpr)/2, 10))
        
        # output$filteringAssistant <- renderHighchart({
        #     type <- input$assistantPlot
        #     if (type == "") return(NULL)
        #     
        #     filter <- getFilter()
        #     if (type == "mean") {
        #         arg <- geneExprMean[filter]
        #         description <- "Mean per gene"
        #     } else if (type == "var") {
        #         arg <- geneExprVar[filter]
        #         description <- "Variance per gene"
        #     }
        #     
        #     hc <- tryCatch({
        #         hcboxplot(arg)  %>%
        #             hc_chart(zoomType="y") %>%
        #             hc_tooltip(valueDecimals=2, followPointer=TRUE) %>%
        #             hc_xAxis(visible=FALSE) %>%
        #             hc_yAxis(title=list(text=description)) %>%
        #             hc_plotOptions(series=list(animation=FALSE))
        #     }, error=return, warning=return)
        #     
        #     if (is(hc, "error") || is(hc, "warning"))
        #         return(NULL)
        #     else
        #         return(hc)
        # })
    })
    
    # Disable interface for gene filtering
    observeEvent(input$enableFiltering, {
        filter <- input$enableFiltering
        if (filter) {
            enable("filteringInterface")
            # show("assistantInterface", anim=TRUE)
        } else {
            disable("filteringInterface")
            # hide("assistantInterface", anim=TRUE)
        }
    })
    
    # Disable option to add counts to observations if not log2-transforming
    observe({
        filter <- input$log2transformation
        if (filter) {
            enable("priorCount")
            # show("assistantInterface", anim=TRUE)
        } else {
            disable("priorCount")
            # hide("assistantInterface", anim=TRUE)
        }
    })
    
    # Filter and normalise gene expression
    observeEvent(input$processGeneExpr, {
        time <- startProcess("processGeneExpr")
        
        isolate({
            geneExpr      <- getGeneExpression()[[input$geneExpr]]
            method        <- input$normalisation
            percentile    <- input$upperquartilePercentile
            filter        <- input$enableFiltering
            log2transform <- input$log2transformation
            priorCount    <- input$priorCount
            
            minMean    <- input$minMean
            maxMean    <- input$maxMean
            minVar     <- input$minVar
            maxVar     <- input$maxVar
            minCounts  <- input$minCounts
            minSamples <- input$minSamples
        })
        
        if (filter)
            geneFilter <- getFilter()
        else
            geneFilter <- NULL
        
        geneExprNorm <- normaliseGeneExpression(
            geneExpr, geneFilter, method, percentile, log2transform, priorCount)
        
        attr(geneExprNorm, "filename") <- NULL
        if (filter) {
            geneFilterSettings <- c(
                "Gene filtering"="Enabled",
                "Minimum mean >"=minMean, "Maximum mean <"=maxMean,
                "Minimum variance >"=minVar, "Maximum variance <"=maxVar,
                "At least X counts..."=paste("X =", minCounts),
                "...in >= Y samples"=paste("Y = ", minSamples))
        } else {
            geneFilterSettings <- c("Gene filtering"="Disabled")
        }
        
        settings <- c(list(
            "Original gene expression (file)"=attr(geneExpr, "filename"),
            "Original gene expression (label)"=isolate(input$geneExpr)
        ), geneFilterSettings, list(
            "Normalisation method"=method,
            "Perform log2 transformation"=if (log2transform) "Yes" else "No",
            "Average count to add per observation"=priorCount))
        attr(geneExprNorm, "settings") <- settings
        
        setNormalisedGeneExpression(geneExprNorm)
        endProcess("processGeneExpr", time=time)
    })
    loadGeneExpressionSet(session, input, output)
}

attr(geNormalisationFilteringUI, "loader") <- "data"
attr(geNormalisationFilteringServer, "loader") <- "data"