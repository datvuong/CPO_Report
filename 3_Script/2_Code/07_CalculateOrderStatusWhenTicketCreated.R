# ---- 7_CalculateOrderStatusWhenTicketCreated ----
load("../4_RData/AllVentureTickets.RData")
library(lubridate)
library(reshape2)
library(data.table)
TicketCreatedStatus <- select(AllVentureTickets, country, Order_Nr, Ticket.Id,Date.Ticket.Created,
                              Hour.Ticket.Created, matches("_at"))

TicketCreatedStatusMelt <- melt(TicketCreatedStatus, id.vars = c("country","Order_Nr", "Ticket.Id","Date.Ticket.Created",
                                                                 "Hour.Ticket.Created"))

TicketCreatedStatusMelt <-  TicketCreatedStatusMelt %>% 
  mutate(Hour.Ticket.Created=as.integer(Hour.Ticket.Created))
TicketCreatedStatusMelt <-  TicketCreatedStatusMelt %>% 
  mutate(DateStatus=floor_date(value, unit = "day"))
TicketCreatedStatusMelt <- data.table(TicketCreatedStatusMelt)
TicketCreatedStatusMelt[, max_status_time:=max(value,na.rm = TRUE), by=c("country","Order_Nr", "Ticket.Id","Date.Ticket.Created",
                                                                         "Hour.Ticket.Created")]
TicketCreatedStatusMelt <- TicketCreatedStatusMelt %>% 
  mutate(diffCreatedStatus = ifelse(Date.Ticket.Created>value,
                                    as.duration(Date.Ticket.Created-value)+dhours(Hour.Ticket.Created),
                                    as.duration(Date.Ticket.Created-DateStatus)))
TicketCreatedStatusMelt <- TicketCreatedStatusMelt %>% 
  mutate(diffCreatedStatus = ifelse(diffCreatedStatus!=0,diffCreatedStatus,
                                    dhours(Hour.Ticket.Created-hour(value))))

TicketCreatedStatusMeltValid <- filter(TicketCreatedStatusMelt, diffCreatedStatus>=0)

TicketCreatedStatusMeltValid <- arrange(TicketCreatedStatusMeltValid, Ticket.Id,diffCreatedStatus,
                                        desc(variable))

TicketCreatedStatusFinal <- TicketCreatedStatusMeltValid %>%
  group_by(country,Order_Nr,Ticket.Id,max_status_time) %>%
  summarize(TicketCreatedStatus=first(variable),
            N_seconds_from_last_status_change=first(diffCreatedStatus))

rm(TicketCreatedStatusMelt, TicketCreatedStatusMeltValid)

AllVentureTicketsUpdated <- left_join(AllVentureTickets,TicketCreatedStatusFinal,
                                      by=c("Ticket.Id", "Order_Nr", "country"))
save(AllVentureTicketsUpdated, file = "../4_RData/AllVentureTicketsUpdated.RData")