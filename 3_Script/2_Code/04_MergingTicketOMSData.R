# ---- 4_MergingTicketOMSData ----

# Initial load library needed and datatype conversions
setClass('myDate')
setAs("character","myDate", function(from) as.POSIXct(from, format =  "%m/%d/%Y", tz = "Asia/Bangkok"))
setClass('myDateTime')
setAs("character","myDateTime", function(from) as.POSIXct(from, format =  "%Y-%m-%d %H:%M:%S", tz = "Asia/Bangkok"))
orderCountdate <- as.POSIXct("2015-08-16 00:00:00", tz = "Asia/Bangkok", format="%Y-%m-%d %H:%M:%S")
for (iventure in c("Malaysia", "Philippines", "Thailand", "Vietnam")) {
  
  iventureShort = switch (iventure,
                          "Malaysia" = "MY",
                          "Philippines" = "PH",
                          "Thailand" = "TH",
                          "Vietnam" = "VN"
  )
  
  # Load Zendesk Ticket Data
  Tickets <- read.csv(file.path(runningFolder,"Manual CS Data",paste0(iventure,"_Tickets.csv")),
                      col.names = c("Ticket.Id","Channel.List","Outbound",
                                    "Hour.Ticket.Created","Date.Ticket.Created","Ticket.Tag"),
                      colClasses = c("character","character","character",
                                     "character","myDate","character"))
  # Load Zendesk Ticket with Order Number Data
  TicketsOrder <- read.csv(file.path(runningFolder,"Manual CS Data",paste0(iventure,"_Tickets_Orders.csv")),
                           colClasses = c("character","character"),
                           col.names = c("Ticket.Id","Order_Nr"))
  TicketsOrder <- mutate(TicketsOrder, Order_Nr=as.integer(substr(Order_Nr,1,9)))
  
  # Merging Tickets Data with Ticket Order Number Data - using left_join due to the Tickets data is bigger data sets.
  Tickets <- left_join(Tickets, TicketsOrder, by=c("Ticket.Id"="Ticket.Id"))
  
  # Loading Ticket.Tags information and merging Tags data with Tickets Data and filter only tickets tagged as order related.
  TagsData <- read.csv(file.path(runningFolder,"Manual CS Data/CS_Tags_Details.csv"))
  validTicket <- inner_join(Tickets, TagsData, by = c("Ticket.Tag"="Tag"))
  # Loading OMS Order Data
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
  validTicket <- left_join(validTicket, OMS, by = c("Order_Nr"="order_number"))
  validTicket <- validTicket %>%
          mutate(country=iventure)
  
  ordersCount <- nrow(filter(OMS, create_at>=orderCountdate))
  # Assign the result for eachventure into variables that used later
  assign(paste(iventure,"OrdersCount",sep=""), ordersCount)
  assign(paste(iventure,"CPO",sep=""), nrow(validTicket)/ordersCount)
  assign(paste(iventure,"ValidTickets",sep = ""),validTicket)
}