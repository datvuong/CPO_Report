# ---- 2_downloadPMPExtracts ----

# Extracts to be downloaded from PMP
pmpExtractsList <- c("CPO - Correlation - Leadtime")

# List venture to download extracts
ventureList <- c("Indonesia", "Malaysia", "Philippines",
                 "Singapore", "Thailand", "Vietnam")

destination <- file.path("../1_Raw_Extracts/",dateFolderName)
if (!dir.exists(destination))
  dir.create(destination)

# Download file from File Sercers & Save to Working Directory
for (iventure in ventureList) {
  for (itable in pmpExtractsList) {
    iurl <- paste(pmpurl,itable,"_",iventure,"_",dateReportText,".zip",sep = "")
    idest <- file.path(destination,iventure,paste(itable,".zip",sep = ""))
    if(!dir.exists(file.path(destination,iventure))){
      dir.create(file.path(destination,iventure))
    }
    if(!file.exists(idest) | file.size(idest)<=1){
      download.file(iurl,idest)
    }
    unzip(zipfile = idest,exdir = file.path(destination,iventure))
  }
}