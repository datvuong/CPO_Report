# ---- 6_MergingVenturesData ----

load("../4_RData/ProcessedData.RData")
AllVentureTickets <- rbind_list(IndonesiaValidTickets,MalaysiaValidTickets)
AllVentureTickets <- rbind_list(AllVentureTickets,PhilippinesValidTickets)
AllVentureTickets <- rbind_list(AllVentureTickets,SingaporeValidTickets)
AllVentureTickets <- rbind_list(AllVentureTickets,ThailandValidTickets)
AllVentureTickets <- rbind_list(AllVentureTickets,VietnamValidTickets)
AllVentureTickets$country <- as.factor(AllVentureTickets$country)
save(AllVentureTickets,file = "../4_RData/AllVentureTickets.RData")