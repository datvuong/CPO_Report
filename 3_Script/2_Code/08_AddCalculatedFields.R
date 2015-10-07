# ---- 8_AddCalculatedFields ----

load("../4_RData/AllVentureTicketsUpdated.RData")

AllVentureTicketsCalculated <- AllVentureTicketsUpdated %>%
    mutate(N_days_from_last_status_change=ifelse(is.na(N_seconds_from_last_status_change),NA,
                                                 N_seconds_from_last_status_change/60/60/24))
AllVentureTicketsCalculated <- AllVentureTicketsCalculated %>%
    mutate(Week=isoweek(Date.Ticket.Created))
AllVentureTicketsCalculated <- AllVentureTicketsCalculated %>%
    mutate(Outbound.Inbound="?")
AllVentureTicketsCalculated <- AllVentureTicketsCalculated %>%
    mutate(Status_N_days=paste(TicketCreatedStatus,N_days_from_last_status_change,sep="+"))
AllVentureTicketsCalculated <- AllVentureTicketsCalculated %>%
    mutate(Hour.Ticket.Created=as.numeric(Hour.Ticket.Created)) %>%
    mutate(N_days_from_order_creation=ifelse(Date.Ticket.Created>create_at,
                                             as.duration(Date.Ticket.Created-create_at)+dhours(Hour.Ticket.Created),
                                             dhours(Hour.Ticket.Created-hour(create_at)))) %>%
    mutate(N_days_from_order_creation=N_days_from_order_creation/60/60/24)
AllVentureTicketsCalculated <- AllVentureTicketsCalculated %>%
    mutate(N_days_from_last_status_change_round=ceiling(N_days_from_last_status_change))
AllVentureTicketsCalculated <- AllVentureTicketsCalculated %>%
    mutate(Delivered_in_SLA=factor(ifelse(ifelse(is.na(delivered_at),max_status_time,delivered_at)
                                          < max_initial_delivery_promised_max,"Yes","No")))
AllVentureTicketsCalculated <- AllVentureTicketsCalculated %>%
    mutate(Valid_Order=factor(ifelse(is.na(create_at),NA,
                                     ifelse(!is.na(financed_at),"Yes","No"))))
OrderCount <- AllVentureTicketsCalculated %>% group_by(country, Order_Nr) %>%
    summarize(ContactPerOrder=n_distinct(Ticket.Id))
AllVentureTicketsCalculated <- left_join(AllVentureTicketsCalculated,
                                         OrderCount)
AllVentureTicketsCalculated <- AllVentureTicketsCalculated %>%
    mutate(NumberofContacts = paste(ContactPerOrder,"contact(s)"),
           UniqueOrder=ifelse(ContactPerOrder>1,"No","Yes"))

save(AllVentureTicketsCalculated,
     file = "../4_RData/AllVentureTicketsCalculated.RData")