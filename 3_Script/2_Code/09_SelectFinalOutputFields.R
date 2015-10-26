# ---- 9_SelectFinalOutputFields ----

load("../4_RData/AllVentureTicketsCalculated.RData")

AllVentureTicketsShort <- AllVentureTicketsCalculated %>% 
  select(Ticket.Id,
         Concern_Issues,
         Date.Ticket.Created,
         Order_Nr,
         Via=Channel.List,
         Outbound,
         Week,
         Outbound.Inbound,
         Level.2.reason=Level.2,
         Level.3.reason=Level.3,
         country,
         retail_mp,
         crossborder,
         OMS_Status_ticket_created=TicketCreatedStatus,
         N_days_from_last_status_change,
         Status_N_days,
         N_days_from_order_creation,
         N_days_from_last_status_change_round,
         max_initial_delivery_promised_max,
         min_initial_delivery_promised_max,
         Delivered_in_SLA,
         finance_status,
         Valid_Order,
         new_customer,
         device_type,
         payment_method,
         metro,
         ContactPerOrder,
         NumberofContacts,
         UniqueOrder,
         Reopen,
         SKU,
         Merchant)

save(AllVentureTicketsShort,
     file = "../4_RData/AllVentureTicketsShort.RData")