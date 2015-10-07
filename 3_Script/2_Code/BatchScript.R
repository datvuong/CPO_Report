insertRow <- function(existingDF, newrow, r) {
        require(dplyr)
        existingDF <- rbind(existingDF,newrow)
        existingDF <- existingDF[order(c(1:(nrow(existingDF)-1),r-0.5)),]
        row.names(existingDF) <- 1:nrow(existingDF)
        existingDF <- filter(existingDF, !is.na(JobName))
        return(existingDF)  
}

trackingLog <- function(trackingLogDF, jobName, runID, step, activity, description){
        newRecord <- data.frame(jobName, runID, step, activity, Sys.time(), description)
        colnames(newRecord) <- c("JobName", "RunID","Step","Activity","Timestamp","Description")
        insertRow(trackingLogDF, newRecord, 1)
}

runningStep <- function(stepSource, stepName, trackingLogDF, jobName, runID){
        trackingLogDF <- trackingLog(trackingLogDF, jobName, runID,
                                     stepName, "Start", "Step Note")
        
        tryCatch(source(file = stepSource, echo = FALSE),
                 error = function(e){
                         trackingLogDF <<- trackingLog(trackingLogDF, jobName, runID,
                                                       stepName, "Error", as.character(e))
                 },
                 warning=function(e) {
                         trackingLogDF <<- trackingLog(trackingLogDF, jobName, runID,
                                                       stepName, "Warning", as.character(e))
                 },
                 finally={
                         
                 })
        
        trackingLogDF <- trackingLog(trackingLogDF, jobName, runID,
                                     stepName, "End", "Step Note")
        
        save(trackingLogDF, file = paste0("../3_Log/",jobName,"_",runID,".RData"))
        
        trackingLogDF
}

runningAll <- function(){
        pb <- txtProgressBar(min=0,max=9, style = 3)
        
        jobName <- "CPO Correlation - Data Consolidation"
        runID <- format(Sys.time(),"%Y%m%d%H%M")
        
        trackingLogDF <- data.frame(JobName=character(),
                                    RunID=character(),
                                    Step=character(),
                                    Activity=character(),
                                    Timestamp=as.POSIXct(character()),
                                    Description=character())
        
        totalStep <- 7
        pb <- txtProgressBar(min=0, max=totalStep, style=3)
        
        getTxtProgressBar(pb)

        trackingLogDF <- runningStep(stepSource = "00_Initial.R", stepName = "00_Initial", trackingLogDF, jobName, runID)
        setTxtProgressBar(pb, 1)
        trackingLogDF <- runningStep(stepSource = "04_MergingTicketOMSData.R", stepName = "04_MergingTicketOMSData", trackingLogDF, jobName, runID)
        setTxtProgressBar(pb, 2)
        trackingLogDF <- runningStep(stepSource = "05_MergingTicketOMSData.R", stepName = "05_MergingTicketOMSData", trackingLogDF, jobName, runID)
        setTxtProgressBar(pb, 3)
        trackingLogDF <- runningStep(stepSource = "06_MergingVenturesData.R", stepName = "06_MergingVenturesData", trackingLogDF, jobName, runID)
        setTxtProgressBar(pb, 4)
        trackingLogDF <- runningStep(stepSource = "07_CalculateOrderStatusWhenTicketCreated.R", stepName = "07_CalculateOrderStatusWhenTicketCreated", trackingLogDF, jobName, runID)
        setTxtProgressBar(pb, 5)
        trackingLogDF <- runningStep(stepSource = "08_AddCalculatedFields.R", stepName = "08_AddCalculatedFields", trackingLogDF, jobName, runID)
        setTxtProgressBar(pb, 6)
        trackingLogDF <- runningStep(stepSource = "09_SelectFinalOutputFields.R", stepName = "09_SelectFinalOutputFields", trackingLogDF, jobName, runID)
        setTxtProgressBar(pb, 7)
        #trackingLogDF <- runningStep(stepSource = "10_MappingComplaintsData.R", stepName = "10_MappingComplaintsData", trackingLogDF, jobName, runID)
        #setTxtProgressBar(pb, 8)

        close(pb)
        trackingLogDF
}

runningAll()