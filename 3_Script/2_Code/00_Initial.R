options( java.parameters = "-Xmx4g" )
suppressMessages(library(XLConnect))
suppressMessages(library(dplyr))
suppressMessages(library(lubridate))

# Variables used in script that suppose to be parameter if possible
pmpurl <- "http://10.50.50.97/" #PMP IP for extracts download directly
dateReport <- as.POSIXct('2015-09-01', tz = 'Asia/Bangkok')

# variables generated from parameter
dateFolderName <- format(dateReport,'%Y%m%d')
dateReportText <- format(dateReport, '%Y-%m-%d')

runningFolderName <- "August"
runningFolder <- file.path("../../1_Input",runningFolderName)
