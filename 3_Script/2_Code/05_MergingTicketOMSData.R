# ---- 5_MergingTicketOMSData ----

for (iventure in c("Indonesia", "Singapore")) {
  
  iventureShort = switch (iventure,
                          "Indonesia" = "ID",
                          "Singapore" = "SG"
  )
  
  # Load Zendesk Ticket Data, as noted, for Singapore and Indonesa, the only one CSV files downloaded from GoodData already
  # contain full information needed for tickets
  Tickets <- read.csv(file.path(runningFolder,"Manual CS Data",paste0(iventureShort,"_CPO_Monthly_Report_Data.csv")),
                      col.names = c("Ticket.Id","Channel.List","Outbound",
                                    "Hour.Ticket.Created","Order_Nr",
                                    "Date.Ticket.Created","Ticket.Tag"),
                      colClasses = c("character","character","character",
                                     "character","character","myDate","character"))
  Tickets <- Tickets %>% mutate(Order_Nr=as.integer(gsub('"','',Order_Nr)))
  
  
  TicketsReopen <- read.csv(file.path(runningFolder,"Manual CS Data",paste0(iventureShort,"_Tickets_reopens.csv")),
                            colClasses = c("character","character",
                                           "character","character"),
                            col.names = c("Ticket.Id","Merchant",
                                          "SKU","Reopen"))
  TicketsReopen <- mutate(TicketsReopen, Reopen=as.integer(Reopen))
  
  Tickets <- left_join(Tickets, TicketsReopen, by=c("Ticket.Id"="Ticket.Id"))
  
  # Loading Ticket.Tags information and merging Tags data with Tickets Data and filter only tickets tagged as order related.
  TagsData <- read.csv(file.path(runningFolder,"Manual CS Data/CS_Tags_Details.csv"),
                       stringsAsFactors = FALSE)
  validTicket <- inner_join(Tickets, TagsData, by = c("Ticket.Tag"="Tag"))
  
  # Mapping OMS order Data with Ticket Data - Note that the due to the form of Order_Nr of data extract from GoodData,
  # some transformation was applied.
  OMS <- read.csv(file.path(runningFolder,"OMS Data",
                            paste0("CPO - Correlation - Leadtime_",iventure,".csv")),
                  colClasses = c("integer","character","factor","character","myDateTime",
                                 "myDateTime","myDateTime","myDateTime","myDateTime","myDateTime",
                                 "myDateTime","myDateTime","myDateTime","myDateTime","myDateTime",
                                 "myDateTime","myDateTime","myDateTime","myDateTime","myDateTime",
                                 "myDateTime","myDateTime","myDateTime","myDateTime","myDateTime",
                                 "factor","factor","character","factor","character"))
  # Mapping OMS order Data with Ticket Data - Note that the due to the form of Order_Nr of data extract from GoodData,
  # some transformation was applied.
  validTicket <- left_join(validTicket, OMS,by = c("Order_Nr"="order_number"))
  validTicket$country <- iventure
  
  ordersCount <- nrow(filter(OMS, create_at>=orderCountdate))
  # Assign the result for eachventure into variables that used later
  assign(paste(iventure,"OrdersCount",sep=""), ordersCount)
  assign(paste(iventure,"CPO",sep=""), nrow(validTicket)/ordersCount)
  assign(paste(iventure,"ValidTickets",sep = ""),validTicket)
}

# Save processed data in to RData file for later process
save(IndonesiaOrdersCount,MalaysiaOrdersCount,PhilippinesOrdersCount,
     SingaporeOrdersCount,ThailandOrdersCount,VietnamOrdersCount,
     IndonesiaCPO,IndonesiaValidTickets,MalaysiaCPO,MalaysiaValidTickets,
     PhilippinesCPO,PhilippinesValidTickets,SingaporeCPO,SingaporeValidTickets,
     ThailandCPO,ThailandValidTickets,VietnamCPO,VietnamValidTickets,
     file = "../4_RData/ProcessedData.RData")