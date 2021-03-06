## TODO(NunoA): should default columns be a perfect match or just a partial
## match? If only a partial match... that would be better for certain situations

## TODO(NunoA): render UI for each data table instead of rendering UI for all
## so there's no refresh

#' Get data types available from Firebrowse
#' 
#' @importFrom R.utils capitalize
#' 
#' @return Named character vector
#' @export
#' 
#' @examples
#' getFirebrowseDataTypes()
getFirebrowseDataTypes <- function() {
    choices <- list("RNA sequencing"=c(
        "junction_quantification", "exon_quantification", 
        "exon_expression", "junction_expression",
        "RSEM_genes", "RSEM_genes_normalized", "RSEM_isoforms", "Preprocess"))
    names(choices[[1]]) <- capitalize(gsub("_", " ", choices[[1]], fixed=TRUE))
    return(choices)
}

#' @rdname getFirebrowseDataTypes
getFirehoseDataTypes <- getFirebrowseDataTypes

#' Set attributes to an object
#' 
#' @param object Object
#' @param ... Named parameters to convert to attributes
#' 
#' @return Object with attributes set
#' 
#' @examples 
#' ll <- list(a="hey", b="there")
#' psichomics:::addObjectAttrs(ll, "words"=2, "language"="English")
addObjectAttrs <- function (object, ...) {
    args <- as.list(match.call())[-c(1:2)]
    for (k in seq(args)) attr(object, names(args[k])) <- args[[k]]
    return(object)
}

#' Parse sample information from TCGA samples
#' 
#' @param samples Character: sample identifiers
#' @param match Integer: match between samples and patients (NULL by default;
#' performs the match)
#' 
#' @return Data frame containing metadata associated with each TCGA sample
#' @export
#' 
#' @examples
#' samples <- c("TCGA-3C-AAAU-01A-11R-A41B-07", "TCGA-3C-AALI-01A-11R-A41B-07",
#'              "TCGA-3C-AALJ-01A-31R-A41B-07", "TCGA-3C-AALK-01A-11R-A41B-07", 
#'              "TCGA-4H-AAAK-01A-12R-A41B-07", "TCGA-5L-AAT0-01A-12R-A41B-07")
#' 
#' parseTcgaSampleInfo(samples)
parseTcgaSampleInfo <- function (samples, match=NULL) {
    parsed <- parseSampleGroups(samples)
    if ( all(is.na(parsed)) ) return(NULL)
    
    info <- data.frame(parsed)
    colnames(info) <- "Sample types"
    rownames(info) <- samples
    
    if (is.null(match)) match <- getPatientFromSample(samples)
    info <- cbind(info, "Patient ID"=match)
    
    # Metadata
    attr(info, "rowNames")    <- TRUE
    attr(info, "description") <- "Metadata for TCGA samples"
    attr(info, "dataType")    <- "Sample metadata"
    attr(info, "tablename")   <- "Sample metadata"
    attr(info, "rows")        <- "samples"
    attr(info, "columns")     <- "attributes"
    return(info)
}

#' @rdname parseTcgaSampleInfo
parseTCGAsampleInfo <- parseTcgaSampleInfo

#' Prepare TCGA sample metadata from loaded datasets
#' 
#' If no TCGA datasets apply, the input is returned
#' 
#' @param data List of list of data frames
#' 
#' @return List of list of data frames
loadTCGAsampleMetadata <- function(data) {
    for (i in seq(data)) {
        # Retrieve sample metadata from junction quantification
        match <- sapply(data[[i]], attr, "dataType") ==
            "Junction quantification"
        junctionQuantSamples <- NULL
        if (any(match)) {
            junctionQuant <- data[[i]][match]
            if (!is.null(junctionQuant)) {
                samples <- unique(unlist(lapply(junctionQuant, colnames)))
                if (any(grepl("^TCGA", samples))) {
                    junctionQuantSamples <- samples
                    data[[i]]$"Sample metadata" <- parseTcgaSampleInfo(samples)
                }
            }
        }
        
        # Retrieve sample metadata from gene expression
        match <- sapply(data[[i]], attr, "dataType") == "Gene expression"
        if (any(match)) {
            geneExpr <- data[[i]][match]
            if (!is.null(geneExpr)) {
                samples <- unique(unlist(lapply(geneExpr, colnames)))
                samples <- samples[!samples %in% junctionQuantSamples]
                if (any(grepl("^TCGA", samples))) {
                    data[[i]]$"Sample metadata" <- parseTcgaSampleInfo(samples)
                }
            }
        }
    }
    return(data)
}

#' Create a modal warning the user of already loaded data
#' @param modalId Character: identifier of the modal
#' @param replaceButtonId Character: identifier of the button to replace data
#' @param keepButtonId Character: identifier of the button to append data
#' @param session Shiny session
#' @return HTML elements for a warning modal reminding data is loaded
loadedDataModal <- function(session, modalId, replaceButtonId, keepButtonId) {
    ns <- session$ns
    warningModal(session, "Data already loaded",
                 "Would you like to", tags$b("replace"), "the loaded data or",
                 tags$b("keep"), "both the previous and new data?",
                 footer = tagList(
                     actionButton(ns(keepButtonId), "data-dismiss"="modal",
                                  label="Keep both"),
                     actionButton(ns(replaceButtonId), class="btn-warning",
                                  "data-dismiss"="modal", label="Replace")),
                 modalId=modalId)
}

#' Process dataset names
#' 
#' @details Avoid duplicated names and append the technology used for junction
#' quantification
#' 
#' @param data List of lists of data frames
#' 
#' @return Processed list of lists of data frames
processDatasetNames <- function(data) {
    newData <- data
    # Avoid duplicate names in categories
    names(newData) <- renameDuplicated(names(data), 
                                       names(data)[duplicated(names(data))])
    
    ns <- lapply(newData, names)
    for (each in names(ns)) {
        nse <- names(newData[[each]])
        
        # For read quantification, add the respective sequencing technology
        index <- nse %in% c("Junction quantification", "Gene expression")
        for (k in seq_along(nse)) {
            if (index[[k]]) {
                file <- attr(newData[[each]][[k]], "filename")
                if (is.null(file)) next
                
                if (grepl("illuminahiseq", file, fixed=TRUE))
                    names(newData[[each]])[[k]] <- paste(
                        names(newData[[each]])[[k]], "(Illumina HiSeq)")
                else if (grepl("illuminaga", file, fixed=TRUE)) 
                    names(newData[[each]])[[k]] <- paste(
                        names(newData[[each]])[[k]], "(Illumina GA)")
            }
        }
        
        # Avoid duplicate names in datasets from the same category
        nse <- names(newData[[each]])
        names(newData[[each]]) <- renameDuplicated(nse, nse[duplicated(nse)])
    }
    return(newData)
}

#' File input for gene expression
#' 
#' @param geneExprFileId Character: identifier for gene expression input
#' 
#' @return HTML elements
geneExprFileInput <- function(geneExprFileId) {
    fileBrowserInput(
        geneExprFileId,
        "File with gene expression",
        placeholder="No file selected",
        info=TRUE, infoFUN=bsPopover, infoTitle=paste(
            "File containing the read counts of each gene (rows) per",
            "sample (columns)."),
        infoContent=paste(
            "The first column must contain gene symbols and be named", 
            tags$kbd("Gene ID"), tags$hr(), helpText("Example:"), tags$table(
                class="table table-condensed",
                tags$thead(
                    tableRow("Gene ID", "SMP-18", "SMP-03", "SMP-54", 
                             th=TRUE)),
                tags$tbody(
                    tableRow("AMP1", "24", "10", "43"),
                    tableRow("BRCA1", "38", "46", "32"),
                    tableRow("BRCA2", "43", "65", "21")))))
}

#' File input for alternative splicing quantification
#' 
#' @param ASquantFileId Character: identifier for alternative splicing 
#' quantification input
#' @param speciesId Character: identifier for species selection input
#' @param assemblyId Character: identifier for genome assembly selection input
#' 
#' @return HTML elements
ASquantFileInput <- function(ASquantFileId, speciesId, assemblyId){
    tagList(
        fileBrowserInput(
            ASquantFileId, "File with alternative splicing quantification",
            placeholder="No file selected",
            info=TRUE, infoFUN=bsPopover, infoTitle=paste(
                "File containing the PSI value of each alternative splicing",
                "event (rows) per sample (columns)."),
            infoContent=paste(
                tags$ul(
                    class="popover-list",
                    tags$li(
                        "The first column must contain alternative splicing",
                        "event identifiers and should be named",
                        tags$kbd("AS Event ID")),
                    tags$li(
                        "An alternative splicing event must be represented by:",
                        tags$kbd(
                            paste0("EventType_Chromosome_Strand_Coordinate1_",
                                   "Coordinate2_..._Gene"))),
                    tags$li(
                        "PSI values may be handed between 0 and 1 or between 0",
                        "and 100. If the later, PSI values are then scaled",
                        "betwen 0 and 1.")))),
        selectizeInput(speciesId, "Species", choices="Human", width = "100%",
                       options=list(create=TRUE)),
        selectizeInput(assemblyId, "Assembly", choices=c("hg19", "hg38"),
                       width = "100%", options=list(create=TRUE)))
}

#' @rdname appUI
#' @importFrom shinyjs hidden
dataUI <- function(id, tab) {
    ns <- NS(id)
    uiList <- getUiFunctions(
        ns, "data", bsCollapsePanel,
        priority=paste0(c("localData", "firebrowse", "gtexData", "recountData",
                          "inclusionLevels", "geNormalisationFiltering"), "UI"))
    
    tcga <- tags$abbr(title="The Cancer Genome Atlas", "TCGA")
    gtex <- tags$abbr(title="Genotype-Tissue Expression project", "GTEx")
    sra  <- tags$abbr(title="Sequence Read Archive", "SRA")
    
    analysesDescription <- tagList(
        fluidRow(
            column(3, style="padding: 5px !important;",
                   h4("Dimensionality reduction"),
                   "Explore alternative splicing quantification and gene",
                   "expression through principal component analysis (PCA) and",
                   "independent component analysis (ICA) using groups based on",
                   "clinical and sample attributes."),
            column(3, style="padding: 5px !important;",
                   h4("Differential splicing and expression analysis"),
                   "Analyse alternative splicing quantification (based on",
                   "variance and median statistical tests) and gene expression",
                   "data. The groups available for differential analyses",
                   "comprise sample types (e.g. normal versus tumour) and",
                   "clinical attributes of patients (e.g. tumour stage)."),
            column(3, style="padding: 5px !important;",
                   h4("Survival analysis"),
                   "Analyse survival based on clinical attributes (e.g. tumour",
                   "stage, gender and race). Additionally, study the impact of",
                   "of a single alternative splicing event or gene on patient",
                   "survivability."),
            column(3, style="padding: 5px !important;",
                   h4("Gene, transcript and protein information"),
                   "For a given splicing event, examine its gene's annotation",
                   "and corresponding transcripts and proteins. Related",
                   "research articles are also available.")))
    
    welcome <- div(
        id=ns("welcome"),
        linkToArticle(),
        h1("Welcome"), HTML(paste0(
            "Perform integrative analyses of alternative splicing and gene ",
            "expression based on transcriptomic and sample-associated data ",
            "from The Cancer Genome Atlas (", tcga, "), the Genotype-Tissue ",
            "Expression (", gtex, ") project, Sequence Read Archive (", sra, 
            ") or user-provided data.")),
        tags$br(), tags$br(), tags$ol(
            id="list",
            tags$li(HTML(paste0(
                "Load gene expression values, alternative splicing ",
                "junction quantification and/or sample-associated data ",
                "from ", tcga, ", ", gtex, ", ", sra, " or user-provided data.",
                tags$br(), tags$small(
                    style="color: gray;",
                    "More data types will soon be supported.")))),
            tags$li("Quantify alternative splicing events based on the",
                    "values from the percent spliced-in (PSI) metric.",
                    # "The following event types are available:",
                    # "skipped exon (SE), mutually exclusive exon",
                    # "(MXE), alternative 3' and 5' splice site (A3SS",
                    # "and A5SS) and alternative first and last exon",
                    # "(AFE and ALE).", tags$br(),
                    tags$br(), tags$small(
                        style="color: gray;",
                        "Note: as", tcga, "does not include exon-intron",
                        "junction quantification, intron retention",
                        "events are not measurable.")),
            tags$li("Explore statistically significant events or",
                    "individual events of interest through the",
                    "following analyses:")), 
        analysesDescription, br(), br(),
        p(style="text-align:right",
          tags$a(href="http://imm.medicina.ulisboa.pt/group/distrans/",
                 target="_blank", "Disease Transcriptomics Lab, iMM"), 
          "(", tags$a(href="mailto:nunodanielagostinho@gmail.com", 
                      "Nuno Saraiva-Agostinho", icon("envelope-o")),
          ", 2015-2018)", 
          br(), "Special thanks to my lab colleagues for their work-related",
          br(), "support and supporting chatter."))
    
    tab(title="Data", icon="table",
        sidebarLayout(
            sidebar( do.call(bsCollapse, c(id=ns("accordion"), uiList)) ),
            mainPanel( welcome, uiOutput(ns("tablesOrAbout")) ) ))
}

#' Creates a \code{tabPanel} template for a \code{datatable} with a title and
#' description
#'
#' @param ns Namespace function
#' @param title Character: tab title
#' @param tableId Character: id of the \code{datatable}
#' @param description Character: description of the table (optional)
#' @param columns Character: column names of the \code{datatable}
#' @param visCols Boolean: visible columns
#' @param data Data frame: dataset of interest
#'
#' @importFrom shinyBS bsTooltip bsCollapse bsCollapsePanel
#' @importFrom DT dataTableOutput
#' @importFrom shiny hr br tabPanel selectizeInput column fluidRow p mainPanel
#' downloadButton
#'
#' @return HTML elements
tabDataset <- function(ns, title, tableId, columns, visCols, data,
                       description=NULL) {
    tablename <- ns(paste("table", tableId, sep="-"))
    
    downloadId <- paste(tablename, "download", sep="-")
    download <- downloadButton(downloadId, "Save table",
                               class="pull-right btn-info")
    
    if(!is.null(description)) {
        description <- p(tags$strong("Table description:"), description)
        download <- fluidRow(column(10, description), column(2, download))
    }
    
    # Get class of each column
    colType <- sapply(1:ncol(data), function(i) class(data[[i]]))
    colType[colType == "character"] <- "string"
    
    # Show class of each column
    choices <- columns
    names(choices) <- sprintf("%s (%s class)", columns, colType)
    
    visColsId <- paste(tablename, "columns", sep="-")
    visibleColumns <- selectizeInput(
        visColsId, label="Visible columns",  choices=choices, selected=visCols, 
        multiple=TRUE, width="auto", 
        options=list(plugins=list('remove_button', 'drag_drop'), render=I(
            "{ item: function(item, escape) {
            return '<div>' + escape(item.value) + '</div>'; } }")))
    
    # Add a common HTML container to allow for multiple Highcharts plots
    multiPlotId        <- paste(tablename, "multiPlot", sep="-")
    loadingMultiPlotId <- paste(tablename, "loadingMultiPlot", sep="-")
    multiHighchartsPlots <- fluidRow(column(12, uiOutput(multiPlotId)))
    # div(id=loadingMultiPlotId, class="progress",
    #     div(class="progress-bar progress-bar-striped active",
    #         role="progressbar", style="width:100%",
    #         "Loading summary plots")))
    
    tabPanel(title, br(), download, br(),
             bsCollapse(
                 open="Summary",
                 bsCollapsePanel(
                     tagList(icon("table"), "Data table"), value="Data table",
                     visibleColumns, hr(), dataTableOutput(tablename)),
                 bsCollapsePanel(
                     tagList(icon("pie-chart"), "Summary"), value="Summary",
                     multiHighchartsPlots)))
    }

#' Render a specific data tab (including data table and related interface)
#' 
#' @param index Integer: index of the data to load
#' @param data Data frame: data with everything to load
#' @param name Character: name of the dataset
#' @param session Shiny session
#' @param input Shiny session input
#' @param output Shiny session output
#' 
#' @importFrom shiny tags HTML
#' @importFrom DT renderDataTable
#' @importFrom shiny downloadHandler br
#' @importFrom utils write.table
#' @importFrom shinyjs show hide
#' 
#' @return NULL (this function is used to modify the Shiny session's state)
createDataTab <- function(index, data, name, session, input, output) {
    tablename <- paste("table", name, index, sep="-")
    
    table <- data[[index]]
    # Only show default columns if they are defined (don't cause problems)
    subsetToShow <- table
    
    visCols <- input[[paste(tablename, "columns", sep="-")]]
    if (!is.null(visCols)) {
        match <- visCols %in% colnames(table)
        subsetToShow <- subset(table, select=visCols[match])
    }
    
    output[[tablename]] <- renderDataTable(
        subsetToShow, style="bootstrap", selection='none', filter="top",
        options=list(pageLength=10))
    
    downloadId <- paste(tablename, "download", sep="-")
    output[[downloadId]] <- downloadHandler(
        filename = paste(name, attr(table, "tablename")),
        content = function(file) {
            res <- cbind(rownames(table), table)
            names(res)[1] <- attr(table, "dataType")
            write.table(res, file, quote=FALSE, row.names=FALSE, sep="\t")
        })
    
    multiPlotId        <- paste(tablename, "multiPlot", sep="-")
    loadingMultiPlotId <- paste(tablename, "loadingMultiPlot", sep="-")
    output[[multiPlotId]] <- renderUI({
        # gethc <- function(dfname = "cars") {
        #     # function to return the chart in a column div
        #     df <- get(dfname)
        #     hc <- highchart(height=100) %>%
        #         hc_title(text = dfname) %>%
        #         hc_xAxis(title = list(text = names(df)[1])) %>%
        #         hc_yAxis(title = list(text = names(df)[2])) %>%
        #         highcharter::hc_add_series_scatter(df[ , 1], df[ , 2])
        #     column(width=3, hc)
        # }
        # 
        # data <- c("cars", "mtcars", "iris", "Puromycin", "ChickWeight")
        # charts <- suppressWarnings(lapply(rep(data, 3), gethc))
        # do.call(tagList, charts)
        
        rows <- attr(table, "rows")
        rows <- ifelse(!is.null(rows), rows, "rows")
        cols <- attr(table, "columns")
        cols <- ifelse(!is.null(cols), cols, "columns")
        
        filename <- attr(table, "filename")
        if (!is.null(filename)) {
            filename <- prepareWordBreak(filename)
            filename <- tags$small(tags$b("Loaded based on file:"),
                                   tags$var(filename))
        }
        
        settings <- attr(table, "settings")
        if (!is.null(settings)) {
            settingsDf <- data.frame(names(settings), sapply(
                settings, function(item) 
                    prepareWordBreak(paste(item, collapse=", "))))
            colnames(settingsDf) <- c("Attribute", "Item")
            settings <- table2html(
                settingsDf, rownames=FALSE, thead=TRUE, 
                class="table table-condensed table-striped")
            settings <- tags$small(tagList(tags$b("Dataset settings"), 
                                           settings))
            settings <- gsub("&lt;", "<", settings, fixed=TRUE)
            settings <- gsub("&gt;", ">", settings, fixed=TRUE)
            settings <- HTML(settings)
        }
        
        extra <- NULL
        if ( !is.null(filename) || !is.null(settings) ) {
            extra <- tagList(
                tags$hr(), filename, 
                if (!is.null(filename) && !is.null(settings)) 
                    tagList(tags$br(), tags$br()), 
                settings)
        }
        
        tags$div(tags$h4(paste(ncol(table), cols)), 
                 tags$h4(paste(nrow(table), rows)),
                 extra)
    })
}

#' @rdname appServer
#'
#' @importFrom shiny selectInput tabsetPanel tags h1 h2 HTML fluidRow column
#' tagList
#' @importFrom shinyjs show hide
dataServer <- function(input, output, session) {
    ns <- session$ns
    
    # Show welcome screen when there's no data loaded
    output$tablesOrAbout <- renderUI({
        if(is.null(getData())) {
            show("welcome", anim=TRUE, animType="fade")
        } else {
            hide("welcome", anim=TRUE, animType="fade")
            uiOutput(ns("datatabs"))
        }
    })
    
    # Render tables when data changes
    observe({
        data <- getData()
        if (!is.null(data)) {
            for (category in names(data)) {
                categoryData <- data[[category]]
                # Create data tab for each dataset in a data category
                lapply(seq_along(categoryData), createDataTab,
                       data=categoryData, category, session, input, output)
            }
        }
    })
    
    # Render tabs with data tables
    output$datatabs <- renderUI({
        categoryData <- getCategoryData()
        category <- getCategory()
        
        dataTablesUI <- lapply(
            seq_along(categoryData),
            function(i) {
                data <- categoryData[[i]]
                tabDataset(ns, names(categoryData)[i], 
                           paste(category, i, sep="-"), names(data),
                           attr(data, "show"), data,
                           description=attr(data, "description"))
            })
        do.call(tabsetPanel, c(id=ns("datasetTab"), dataTablesUI))
    })
    
    # Change the active dataset
    observe( setActiveDataset(input$datasetTab) )
    
    # Match clinical data with sample information
    observe({
        patients   <- getPatientId()
        samples    <- getSampleId()
        sampleInfo <- getSampleInfo()
        if ( !is.null(patients) && !is.null(samples) ) {
            startProgress("Matching subjects to their samples...", 1)
            match <- getSubjectFromSample(samples, patients, 
                                          sampleInfo=sampleInfo)
            setClinicalMatchFrom("Inclusion levels", match)
            closeProgress("Matching process concluded")
        }
    })
    
    # Run server logic from the scripts
    getServerFunctions("data", priority=paste0(
        c("localData", "firebrowse", "gtexData",
          "inclusionLevels", "geNormalisationFiltering"), "Server"))
}

attr(dataUI, "loader") <- "app"
attr(dataServer, "loader") <- "app"