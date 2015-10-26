# ---- 10_MappingComplaintsData ----
load("../4_RData/AllVentureTicketsShort.RData")

wb <- loadWorkbook(file.path(runningFolder,"Manual CS Data/Consilidate_compalins.xlsx"))
ID <- readWorksheet(wb, 1, colTypes = c("integer","character","character","character",
                                        "character","character","character","character"))
MY <- readWorksheet(wb, 2, colTypes = c("integer","character","character","character",
                                        "character","character","character","character"))
PH <- readWorksheet(wb, 3, colTypes = c("integer","character","character","character",
                                        "character","character","character","character"))
SG <- readWorksheet(wb, 4, colTypes = c("integer","character","character","character",
                                        "character","character","character","character"))
TH <- readWorksheet(wb, 5, colTypes = c("integer","character","character","character",
                                        "character","character","character","character"))
VN <- readWorksheet(wb, 6, colTypes = c("integer","character","character","character",
                                        "character","character","character","character"))

TicketComplains <- rbind_list(ID, MY, PH, SG, TH , VN)

TicketComplains <- TicketComplains %>%
    mutate(Zendesk.Ticket=gsub("#","",Zendesk.Ticket)) %>%
    mutate(Zendesk.Ticket=gsub("https://lazadaphilippines.zendesk.com/agent/tickets/","",Zendesk.Ticket))

AllVentureTicketsShortFinal <- left_join(AllVentureTicketsShort, TicketComplains,
                                         by=c("Ticket.Id"="Zendesk.Ticket",
                                              "country"="Venture"))

AllVentureTicketsShortFinal <- AllVentureTicketsShortFinal %>%
    mutate(OrderMapped=ifelse(is.na(Valid_Order),"No","Yes"))

AllVentureTicketsShortFinal <- AllVentureTicketsShortFinal %>%
    filter(!duplicated(AllVentureTicketsShortFinal$Ticket.Id)) %>%
    mutate(OMS_Status_ticket_created_1=gsub("_at","",OMS_Status_ticket_created)) %>%
    mutate(N_days_from_last_status_change_1=ifelse(OMS_Status_ticket_created_1 %in% c("shipped","delivered"),
                                                   ifelse(N_days_from_last_status_change>10,">10",
                                                          floor(N_days_from_last_status_change)),
                                                   ifelse(N_days_from_last_status_change>5,">5",
                                                          floor(N_days_from_last_status_change)))) %>%
    mutate(N_days_from_order_creation_1=ifelse(N_days_from_order_creation>=45,">45",
                                               ifelse(N_days_from_order_creation<0,0,
                                                      floor(N_days_from_order_creation)))) %>%
    mutate(NumberOfContacts=ifelse(ContactPerOrder>=3,"3 contacts & above",
                                   ifelse(ContactPerOrder>0, paste0(ContactPerOrder," contact(s)"),
                                          "No order contacts")))

Unique_Order <- AllVentureTicketsShortFinal%>%
    group_by(Order_Nr) %>% summarize(Unique_Order=1/n()) %>%
    mutate(Unique_Order=ifelse(is.na(Order_Nr),0,Unique_Order))

AllVentureTicketsShortFinal <- left_join(AllVentureTicketsShortFinal, Unique_Order)
AllVentureTicketsShortFinal <- AllVentureTicketsShortFinal %>%
    mutate(Complaint=ifelse(is.na(Brief.Description.of.Complaint),"No","Yes"))

AllVentureTicketsShortFinal <- select(AllVentureTicketsShortFinal, -(Week.y))

save(AllVentureTicketsShortFinal, file = "../4_RData/FinalCSData.RData")

write.csv(AllVentureTicketsShortFinal, file = file.path("../../2_Output",runningFolderName,"data.csv"),
          row.names = FALSE)

