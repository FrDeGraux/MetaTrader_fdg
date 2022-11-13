//+------------------------------------------------------------------+
//|                                               DealsRequester.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <CSVDebugger.mqh>
#include <utilString.mqh>
class DealsRequester : public CSVDebugger
{
public : 
DealsRequester(datetime _from_date,datetime _to_date,string ctx = "");
void init(string);
void writeTradeHistory();
private : 
void writeHeaders();
datetime from_date;
datetime to_date;
};

DealsRequester::DealsRequester(datetime _from_date,datetime _to_date,string ctx) : CSVDebugger(ctx)
{
from_date = _from_date;
to_date= _to_date;
writeHeaders();
}
void DealsRequester::writeHeaders()
{
         string text;
         text=StringFormat("%-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s",
                           " Ticket"," ;Order"," ;Time"," ;Time msc"," ;Type"," ;Entry"," ;Reason"," ;Position ID");
 

        
         text=text + StringFormat("%-20s %-20s %-20s %-20s %-20s %-20s %-20s %-20s",
                           ";Volume",";Price",";Commission",";Swap",";Swap_corrected"";Profit",";Symbol",";Comment");
 
         
              text += StringFormat("%-20s %-20s %-20s %-20s %-20s %-20s %-20s",
                             ";Ticket",";Time setup",";Type",";State",";Time expiration",
                              ";Time done","Type filling");

            text += StringFormat("%-20s %-20s %-20s %-20s",
                              ";Type time",";Reason",";Position id",";Position by id");
         



   


            text+=StringFormat("%-20s %-20s %-20s %-20s %-20s %-20s %-20s",
                              ";Volume initial",";Volume current",";Open price",";sl",";tp",";Price current",";Price stoplimit");



           text+=StringFormat("%-20s %-41s %-20s",";Symbol",";Comment",";Extarnal id");
            writeMsg(text);
         
         
         
}

void DealsRequester::writeTradeHistory()
  {
//--- request trade history 
   HistorySelect(from_date,to_date);
   uint total_deals=HistoryDealsTotal();
   ulong ticket_history_deal=0;
//--- for all deals 
   for(uint i=0;i<total_deals;i++)
     {
     
      //--- try to get deals ticket_history_deal 
      if((ticket_history_deal=HistoryDealGetTicket(i))>0)
        {
         long     deal_ticket       =HistoryDealGetInteger(ticket_history_deal,DEAL_TICKET);
         long     deal_order        =HistoryDealGetInteger(ticket_history_deal,DEAL_ORDER);
         long     deal_time         =HistoryDealGetInteger(ticket_history_deal,DEAL_TIME);
         long     deal_time_msc     =HistoryDealGetInteger(ticket_history_deal,DEAL_TIME_MSC);
         long     deal_type         =HistoryDealGetInteger(ticket_history_deal,DEAL_TYPE);
         long     deal_entry        =HistoryDealGetInteger(ticket_history_deal,DEAL_ENTRY);
         long     deal_magic        =HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
         long     deal_reason       =HistoryDealGetInteger(ticket_history_deal,DEAL_REASON);
         long     deal_position_id  =HistoryDealGetInteger(ticket_history_deal,DEAL_POSITION_ID);

         double   deal_volume       =HistoryDealGetDouble(ticket_history_deal,DEAL_VOLUME);
         double   deal_price        =HistoryDealGetDouble(ticket_history_deal,DEAL_PRICE);
         double   deal_commission   =HistoryDealGetDouble(ticket_history_deal,DEAL_COMMISSION);
         double   deal_swap         =HistoryDealGetDouble(ticket_history_deal,DEAL_SWAP);
         double   deal_profit       =HistoryDealGetDouble(ticket_history_deal,DEAL_PROFIT);

         string   deal_symbol       =HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL);
         string   deal_comment      =HistoryDealGetString(ticket_history_deal,DEAL_COMMENT);
         string   deal_external_id  =HistoryDealGetString(ticket_history_deal,DEAL_EXTERNAL_ID);

         string time=TimeToString((datetime)deal_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
         string type=EnumToString((ENUM_DEAL_TYPE)deal_type);
         string entry=EnumToString((ENUM_DEAL_ENTRY)deal_entry);
         string str_deal_reason=EnumToString((ENUM_DEAL_REASON)deal_reason);
         long digits=5;
         if(deal_symbol!="" && deal_symbol!=NULL)
           {
            if(SymbolSelect(deal_symbol,true))
               digits=SymbolInfoInteger(deal_symbol,SYMBOL_DIGITS);
           }
         //---
         string text="";
      
         if(deal_type == DEAL_TYPE_BALANCE)
            continue;


   
         //--- try to get oeders ticket_history_order 
         if(HistoryOrderSelect(deal_order))
           {
            long     o_ticket          =HistoryOrderGetInteger(deal_order,ORDER_TICKET);
            long     o_time_setup      =HistoryOrderGetInteger(deal_order,ORDER_TIME_SETUP);
            long     o_type            =HistoryOrderGetInteger(deal_order,ORDER_TYPE);
            long     o_state           =HistoryOrderGetInteger(deal_order,ORDER_STATE);
            long     o_time_expiration =HistoryOrderGetInteger(deal_order,ORDER_TIME_EXPIRATION);
            long     o_time_done       =HistoryOrderGetInteger(deal_order,ORDER_TIME_DONE);
            long     o_time_setup_msc  =HistoryOrderGetInteger(deal_order,ORDER_TIME_SETUP_MSC);
            long     o_time_done_msc   =HistoryOrderGetInteger(deal_order,ORDER_TIME_DONE_MSC);
            long     o_type_filling    =HistoryOrderGetInteger(deal_order,ORDER_TYPE_FILLING);
            long     o_type_time       =HistoryOrderGetInteger(deal_order,ORDER_TYPE_TIME);
            long     o_magic           =HistoryOrderGetInteger(deal_order,ORDER_MAGIC);
            long     o_reason          =HistoryOrderGetInteger(deal_order,ORDER_REASON);
            long     o_position_id     =HistoryOrderGetInteger(deal_order,ORDER_POSITION_ID);
            long     o_position_by_id  =HistoryOrderGetInteger(deal_order,ORDER_POSITION_BY_ID);

            double   o_volume_initial  =HistoryOrderGetDouble(deal_order,ORDER_VOLUME_INITIAL);
            double   o_volume_current  =HistoryOrderGetDouble(deal_order,ORDER_VOLUME_CURRENT);
            double   o_open_price      =HistoryOrderGetDouble(deal_order,ORDER_PRICE_OPEN);
            double   o_sl              =HistoryOrderGetDouble(deal_order,ORDER_SL);
            double   o_tp              =HistoryOrderGetDouble(deal_order,ORDER_TP);
            double   o_price_current   =HistoryOrderGetDouble(deal_order,ORDER_PRICE_CURRENT);
            double   o_price_stoplimit =HistoryOrderGetDouble(deal_order,ORDER_PRICE_STOPLIMIT);

            string   o_symbol          =HistoryOrderGetString(deal_order,ORDER_SYMBOL);
            string   o_comment         =HistoryOrderGetString(deal_order,ORDER_COMMENT);
            string   str_swap_corrected = UtilString::fromCommentToSwapRate(o_comment);
            double deal_swap_corrected = StringToDouble(str_swap_corrected);
            string   o_extarnal_id     =HistoryOrderGetString(deal_order,ORDER_EXTERNAL_ID);

            string str_o_time_setup       =TimeToString((datetime)o_time_setup,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
            string str_o_type             =EnumToString((ENUM_ORDER_TYPE)o_type);
            string str_o_state            =EnumToString((ENUM_ORDER_STATE)o_state);
            string str_o_time_expiration  =TimeToString((datetime)o_time_expiration,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
            string str_o_time_done        =TimeToString((datetime)o_time_done,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
            string str_o_type_filling     =EnumToString((ENUM_ORDER_TYPE_FILLING)o_type_filling);
            string str_o_type_time        =TimeToString((datetime)o_type_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
            string str_o_reason           =EnumToString((ENUM_ORDER_REASON)o_reason);

 text+=StringFormat("%-19d ;%-19d ;%-19s ;%-19I64d ;%-19s ;%-19s  ;%-19s ;%-19d"
                           ,deal_ticket,deal_order,time,deal_time_msc,type,entry,str_deal_reason,deal_position_id);
 

      
         text+=StringFormat(";%-19.2f ;%-19."+IntegerToString(digits)+"f ;%-19.2f ;%-19.2f ;%-19.2f ;%-19.2f ;%-19s ;%-40s",
                           deal_volume,deal_price,deal_commission,deal_swap,deal_swap_corrected,deal_profit,deal_symbol,deal_comment);

            text+=StringFormat(";%-19d ;%-19s ;%-19s ;%-19s ;%-19s ;%-19s ;%-19s",
                              o_ticket,str_o_time_setup,str_o_type,str_o_state,str_o_time_expiration,str_o_time_done
                              ,str_o_type_filling);
       

       
            text+=StringFormat(";%-19s ;%-19d ;%-19d",
                              str_o_reason,o_position_id,o_position_by_id);
  
            
         
            text+=StringFormat(";%-19.2f ;%-19.2f ;%-19."+IntegerToString(digits)+"f ;%-19."+IntegerToString(digits)+
                              "f ;%-19."+IntegerToString(digits)+"f ;%-19."+IntegerToString(digits)+
                              "f ;%-19."+IntegerToString(digits)+"f",
                              o_volume_initial,o_volume_current,o_open_price,o_sl,o_tp,o_price_current,o_price_stoplimit);
   
      
       
            text+=StringFormat(";%-19s ;%-80s ;%-19s",o_symbol,o_comment,o_extarnal_id);

    

            int d=0;
           }
         else
           {
            text+= "Order "+IntegerToString(deal_order)+" is not found in the trade history between the dates "+
                 TimeToString(from_date,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+" and "+
                 TimeToString(to_date,TIME_DATE|TIME_MINUTES|TIME_SECONDS);
     
           }
     
         writeMsg(text);

         int d=0;
        }
     }
   }
//---

     
  
