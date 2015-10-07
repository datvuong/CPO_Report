library(dplyr)
library(ggplot2)
library(reshape2)

load("../4_RData/FinalCSData.RData")
Final <- AllVentureTicketsShortFinal
Final <- Final %>% mutate(Weeks=isoweek(Date.Ticket.Created))

missingOder <- function(iventure){
        
    missingOrder <- filter(Final, country==iventure,
                           is.na(Order_Nr))
    summaryMissing <- missingOrder %>% group_by(Level.2.reason) %>%
        summarize(TicketCount=n())
    
    write.csv(missingOrder, file.path("../../2_Output/August/TicketMissingOrderNumber",paste0(iventure,"_TicketMissingOrder.csv")),
              row.names = FALSE)

    png(filename = paste0("../../2_Output/August/TicketMissingOrderNumber/",iventure,'_TicketMissingOrder.png'),
             width = 804, height = 554, units = "px", pointsize = 12)
    
    print(ggplot(summaryMissing, aes(Level.2.reason, TicketCount)) +
        geom_bar(stat = "identity", fill="#ff9494") + coord_flip() +
        ylab("Tickets Count") + xlab("Level 2 Reasons") +
        ggtitle(paste(iventure, "Ticket Missing Order Number")) +
        theme(panel.background = element_blank()))
    
    
    dev.off()
}
missingOder("Indonesia")
missingOder("Malaysia")
missingOder("Philippines")
missingOder("Singapore")
missingOder("Thailand")
missingOder("Vietnam")

