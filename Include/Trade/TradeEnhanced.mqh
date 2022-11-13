//+------------------------------------------------------------------+
//|                                                TradeEnhanced.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Trade\Trade.mqh>
#include <utilString.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTradeEnhanced : public CTrade
  {
public :
   bool              PositionClose(const string symbol,const ulong deviation);
   bool              PositionCloseEnhanced(const string symbol,const ulong deviation,string comment);
   bool              PositionOpen(const string symbol,const ENUM_ORDER_TYPE order_type,const double volume,
                                  const double price,const double sl,const double tp,string comment);
   bool              SelectPosition(const string symbol);

   void              setExcursions(string symbol);
 private : 
   datetime          startTime;
   datetime          endTime;
   string            s_close_commment;
   double            best_excursion;
   double            worst_excursion;  
   
  };

void CTradeEnhanced::setExcursions(string symbol)
{
int nBars =  Bars(this.RequestSymbol(),PERIOD_CURRENT,this.startTime,this.endTime);   // symbol name
int bar_lowest = iLowest(this.RequestSymbol(),PERIOD_CURRENT,MODE_LOW,nBars,0);
int bar_highest = iHighest(this.RequestSymbol(),PERIOD_CURRENT,MODE_HIGH,nBars,0);

double highest_val = iHigh(this.RequestSymbol(),PERIOD_CURRENT,bar_highest);
double lowest_val = iLow(this.RequestSymbol(),PERIOD_CURRENT,bar_lowest);

if(this.RequestType() == ORDER_TYPE_BUY)
   {
   best_excursion = highest_val -  this.RequestPrice();
   worst_excursion = this.RequestPrice() - lowest_val;
   }
else if(this.RequestType() == ORDER_TYPE_SELL)
{
   worst_excursion = highest_val -  this.RequestPrice();
   best_excursion = this.RequestPrice() - lowest_val;
}
else
   Print("CTradeEnhanced::setExcursions"  + " wrong order type");
worst_excursion = worst_excursion*RequestVolume()*100000;
best_excursion = best_excursion*RequestVolume()*100000;

//this.s_close_commment =   DoubleToString(best_excursion,UtilString::nDigitsFormatSymbol(symbol)) + "_"+ DoubleToString(worst_excursion,UtilString::nDigitsFormatSymbol(symbol)) + "_" + s_close_commment;
this.s_close_commment =   DoubleToString(best_excursion,UtilString::nDigitsFormatSymbol(symbol)-4) + "_"+ DoubleToString(worst_excursion,UtilString::nDigitsFormatSymbol(symbol)-4) + "_" + s_close_commment;


   return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTradeEnhanced::PositionOpen(const string symbol,const ENUM_ORDER_TYPE order_type,const double volume,
                                  const double price,const double sl,const double tp,string comment)
  {
  this.s_close_commment = "";
  this.best_excursion = 0;
  this.worst_excursion = 0;
  comment = comment + "_" + "0"; // for swap corrected
  this.startTime = TimeCurrent();
  bool res = (CTrade::PositionOpen(symbol,order_type,volume,price,sl,tp,comment));
  return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTradeEnhanced::SelectPosition(const string symbol)
  {
   bool res=false;
//---
   if(IsHedging())
     {
      uint total=PositionsTotal();
      for(uint i=0; i<total; i++)
        {
         string position_symbol=PositionGetSymbol(i);
         if(position_symbol==symbol && m_magic==PositionGetInteger(POSITION_MAGIC))
           {
            res=true;
            break;
           }
        }
     }
   else
      res=PositionSelect(symbol);
//---
   return(res);
  }
  bool CTradeEnhanced::PositionCloseEnhanced(const string symbol,const ulong deviation,string comment)
 
  {
  this.s_close_commment = comment;
  this.endTime = TimeCurrent();
     this.setExcursions(symbol);
   return(PositionClose(symbol,deviation));
  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTradeEnhanced::PositionClose(const string symbol,const ulong deviation)
  {

  this.endTime = TimeCurrent();
   bool partial_close=false;
   int  retry_count  =10;
   uint retcode      =TRADE_RETCODE_REJECT;
//--- check stopped
   if(IsStopped(__FUNCTION__))
      return(false);
//--- clean
   ClearStructures();
//--- check filling
   if(!FillingCheck(symbol))
      return(false);
   do
     {
      //--- check
      if(SelectPosition(symbol))
        {
         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            //--- prepare request for close BUY position
            m_request.type =ORDER_TYPE_SELL;
            m_request.price=SymbolInfoDouble(symbol,SYMBOL_BID);
           }
         else
           {
            //--- prepare request for close SELL position
            m_request.type =ORDER_TYPE_BUY;
            m_request.price=SymbolInfoDouble(symbol,SYMBOL_ASK);
           }
        }
      else
        {
         //--- position not found
         m_result.retcode=retcode;
         return(false);
        }
      //--- setting request
     // m_request.comment ="1.12048154_1.12070020_0.00027308_1.12075462";
m_request.comment = this.s_close_commment;
      m_request.action   =TRADE_ACTION_DEAL;
      m_request.symbol   =symbol;
      m_request.volume   =PositionGetDouble(POSITION_VOLUME);
      m_request.magic    =m_magic;
      m_request.deviation=(deviation==ULONG_MAX) ? m_deviation : deviation;
      //--- check volume
      double max_volume=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
      if(m_request.volume>max_volume)
        {
         m_request.volume=max_volume;
         partial_close=true;
        }
      else
         partial_close=false;
      //--- hedging? just send order
      if(IsHedging())
        {
         m_request.position=PositionGetInteger(POSITION_TICKET);
         bool res = OrderSend(m_request,m_result);
    
         return(res);
        }
      //--- order send
      if(!OrderSend(m_request,m_result))
        {
         if(--retry_count!=0)
            continue;
         if(retcode==TRADE_RETCODE_DONE_PARTIAL)
            m_result.retcode=retcode;
         return(false);
        }
      //--- WARNING. If position volume exceeds the maximum volume allowed for deal,
      //--- and when the asynchronous trade mode is on, for safety reasons, position is closed not completely,
      //--- but partially. It is decreased by the maximum volume allowed for deal.
      if(m_async_mode)
         break;
      retcode=TRADE_RETCODE_DONE_PARTIAL;
      if(partial_close)
         Sleep(1000);
     }
   while(partial_close);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
