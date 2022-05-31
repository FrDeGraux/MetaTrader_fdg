//+------------------------------------------------------------------+
//|                                                  sqlReporter.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfoCustom.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Indicators\Indicators.mqh>
 #include <Indicators\Oscilators.mqh>
 #include <Indicators\CiPosition.mqh>
#include <Indicators\CiProfit_v3stepwip.mqh>
#include <Arrays\ArrayObj.mqh>
#include <sqlReporter.mqh>
#include <CSVDebugger.mqh> 
#include <Indicators\CICustomMA.mqh>
#include <Indicators\CICustomATR.mqh>
#include <CSVDebugger.mqh> 
#include <MqlOutputMessageBase.mqh>
class CGuruEx03_Base : CArrayObj
  { 
private:
   CSVDebugger* objCSVDebug;
   double ATR_StopLossRange;
   double ATR_TPRange;
   ulong             OrderNumber;
   double            GetSize();
   double             make_ATR_SL(double price,ENUM_ORDER_TYPE type,double atr_value );
   double              make_ATR_TP(double price,ENUM_ORDER_TYPE type,double atr_value );
   void writemsgContext(string prefix,string symbol);
   CArrayObj* dealsToMessage();
   CICustomATR              *m_ATR;
   
   bool getFinalSessionDate(datetime in_dt,datetime& out_final_dt);
protected:
   int               Dig;
   double            Points;
   bool              Initialized;
   bool              Long;
   bool              InitIndicators();
   string            m_Pair;                    // Currency pair to trade
   CTrade            m_Trade;                   // Trading object
   CSymbolInfoCustom       m_Symbol;                  // Symbol info object
   // Indicators
   CIndicators       *m_Indis;                   // Indicator collection for fast recalculations
                  // Slow moving average indicator

   CIProf            *m_Profit;
  CiPosition         *m_Position;

   double            sl,tp;
   double Lots;
   sqlReporter       *objsqlReporter;
   double ticks;
   int magicNumber;
   int ATR_MAPeriod;
   
public:
                     CGuruEx03_Base();
        
                    ~CGuruEx03_Base() { Deinit(); }  // Destructor
   bool              Init(int _magicNumber,string Pair,int slippage,double lot,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange);
   void              Deinit();
   bool              Validated();
   bool             CheckEntry(bool buy_signal,bool sell_signal);
   bool              rectangleCreate();
   bool              writeTrade (MqlOutputMessageBase* msg,string extra);
   
         static int        MathRandInt(const int,const int);
  bool LookForEntry_Random();
  };
 int CGuruEx03_Base::MathRandInt(const int min, const int max)
  {
   double f   = (MathRand() / 32768.0);
   return min + (int)(f * (max - min));
  }
//+------------------------------------------------------------------+
//| Constructor                                                     |
//+------------------------------------------------------------------+.

  bool CGuruEx03_Base:: writeTrade(MqlOutputMessageBase* msg,string extra)
  {

   string type = EnumToString(msg.getType());
   string msg_out = (msg.getDT() +  ";" + msg.getSymbol() + ";" + type + ";" + DoubleToString(msg.getPrice()));
   msg_out = msg_out + ";" + extra;
   Print(" Preparing to write msg + " + msg_out);
   return(objCSVDebug.writeMsg(msg_out));
  } 
CGuruEx03_Base::CGuruEx03_Base() 
{
   m_Position = NULL;
   m_Profit = NULL;
  ticks = 0;
   m_Indis = NULL;
   Initialized = false;

}

   // File name (only if "Information output" == "The text file")
//---
int file_handle=0;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+


   double     CGuruEx03_Base::make_ATR_SL(double price,ENUM_ORDER_TYPE type,double atr_value )
   
   {
   int factor = 0;
      switch(type)
      {
      case ORDER_TYPE_BUY: factor = 1;
      case ORDER_TYPE_SELL: factor = -1;
      case ORDER_TYPE_BUY_LIMIT: factor = 1;
      case ORDER_TYPE_SELL_LIMIT: factor = -1;     
      case ORDER_TYPE_BUY_STOP: factor = 1;
      case ORDER_TYPE_SELL_STOP: factor = -1;
      case ORDER_TYPE_BUY_STOP_LIMIT: factor = 1;
      case ORDER_TYPE_SELL_STOP_LIMIT : factor = -1;

      default : Print("Exception in Typing @  CGuruEx03_Base::make_ATR_SL")  ;      
      }
    return((price-ATR_StopLossRange*factor*atr_value));

   }
   double              CGuruEx03_Base::make_ATR_TP(double price,ENUM_ORDER_TYPE type,double atr_value)
   {
   int factor = 0;
      switch(type)
      {
      case ORDER_TYPE_BUY: factor = 1;
      case ORDER_TYPE_SELL: factor = -1;
      case ORDER_TYPE_BUY_LIMIT: factor = 1;
      case ORDER_TYPE_SELL_LIMIT: factor = -1;     
      case ORDER_TYPE_BUY_STOP: factor = 1;
      case ORDER_TYPE_SELL_STOP: factor = -1;
      case ORDER_TYPE_BUY_STOP_LIMIT: factor = 1;
      case ORDER_TYPE_SELL_STOP_LIMIT : factor = -1;

      default : Print("Exception in Typing @  CGuruEx03_Base::make_ATR_TP")  ;       
      }
return((price+ATR_TPRange*factor*atr_value));
   }
//+------------------------------------------------------------------+
//| Performs system initialisation                                   |
//+------------------------------------------------------------------+

bool CGuruEx03_Base::Init(int _magicNumber,string Pair,int slippage,double lot,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange)
  {


   m_Pair = Pair;
   ATR_MAPeriod = _ATR_MAPeriod;

   ATR_StopLossRange = _ATR_StopLossRange;
   ATR_TPRange = _ATR_TPRange;
   Print("Init with pair :" + m_Pair);
   m_Symbol.Name(m_Pair);                // Symbol
   m_Trade.SetExpertMagicNumber(magicNumber);  // Magic number
   Lots = lot;
   Dig = m_Symbol.Digits();
   Points = m_Symbol.Point();
   m_Trade.SetDeviationInPoints(slippage);

   Print("Digits = ", Dig, ", Points = ", DoubleToString(Points, Dig));

   InitIndicators();

   Initialized = true;

   return(true);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void CGuruEx03_Base::Deinit()
  {
   if(m_Indis != NULL)
     {
      delete m_Indis;
    
      m_Profit = NULL;
      m_Position = NULL;
       m_Indis = NULL;

     }

if(objCSVDebug != NULL)
   delete objCSVDebug;
  }

//+------------------------------------------------------------------+
//| Initialize indicators                                            |
//+------------------------------------------------------------------+
bool CGuruEx03_Base::InitIndicators()
  {
  

   if(m_Indis == NULL)
     {
      if((m_Indis = new CIndicators) == NULL)
        {
         Print("Error creating indicators collection");
         return(false);
        }
     }

        


//wa<<<wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww<w<<<w<<<<<<
// Create Profit  and add it to collection
   if(m_Profit == NULL)
     {
      if((m_Profit = new CIProf) == NULL)
        {
         Print("Error creating m_Profit");
         return(false);
        }
     }
   if(!m_Profit.Create(m_Pair, 0))
     {
      Print("Error initializing m_Profit");
      return(false);
     }
// m_Slow.BuffSize(1);
   if(!m_Indis.Add(m_Profit))
     {
      Print("Error adding CiRAVI to indicator collection");
      return(false);
     }
   if(m_Position == NULL)
     {
      if((m_Position = new CiPosition) == NULL)
        {
         Print("Error creating m_Position");
         return(false);
        }
     }
   if(!m_Position.Create(m_Pair, 0))
     {
      Print("Error initializing m_Profit");
      return(false);
     }
// m_Slow.BuffSize(1);
   if(!m_Indis.Add(m_Position))
     {
      Print("Error adding CiPosition to indicator collection");
      return(false);
     }
 if(m_ATR== NULL)
     {
      if((m_ATR = new CICustomATR()) == NULL)
        {
         Print("Error creating m_ATR");
         return(false);
        }
     }


   if(!m_ATR.Create(m_Pair, 0,ATR_MAPeriod,ATR_StopLossRange,ATR_TPRange))
     {
      Print("Error initializing m_ATR");
      return(false);
     }
   if(!m_Indis.Add(m_ATR))
     {
      Print("Error adding m_ATR to indicator collection");
      return(false);
     }
 
   return (true);
  }



//+------------------------------------------------------------------+
//| Returns trade size based on money management system (if any!)    |
//+------------------------------------------------------------------+
double CGuruEx03_Base::GetSize()
  {
   return (Lots);
  }

//+------------------------------------------------------------------+
//| Checks if everything initialized successfully                    |
//+------------------------------------------------------------------+
bool CGuruEx03_Base::Validated()
  {
   return (Initialized);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  bool CGuruEx03_Base::LookForEntry_Random()
  {
           double   signal_rd = MathRandInt(0,1000);
           bool buy_signal = false;
           bool sell_signal = false;
           
         ticks = ticks + 1;
         if (MathCeil(signal_rd) == 1)
         {
            buy_signal = true;
         }
            if (MathCeil(signal_rd) == 2)
         {
            sell_signal = true;
         }   
          return(CheckEntry(buy_signal,sell_signal));
         
  }
//+------------------------------------------------------------------+
//| Checks for entry to a trade - Exits previous trade also          |
//+------------------------------------------------------------------+
int u = 0;
CArrayObj* CGuruEx03_Base::dealsToMessage()
{
   CArrayObj* msg_list = new CArrayObj();
            ulong ticket = m_Trade.ResultDeal();
               if(HistoryDealSelect(ticket))
               {
               
         //--- time of deal execution in milliseconds since 01.01.1970
                  long position_id = HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
                  long deal_time_msc=HistoryDealGetInteger(ticket,DEAL_TIME_MSC);
                  ENUM_DEAL_TYPE type = HistoryDealGetInteger(ticket,DEAL_TYPE);
                  ENUM_DEAL_REASON reason = HistoryDealGetInteger(ticket,DEAL_REASON);
                  datetime DateTimeOpenLastOp = HistoryDealGetInteger(ticket, DEAL_TIME);
              msg_list.Add(new MqlOutputMessageBase(position_id,DateTimeOpenLastOp,m_Symbol.Name(),type,reason,m_Trade.ResultBid()));
                         
                 }
                             else
                                 Alert("HistoryDealSelect() failed for #%d. Eror code=%d",
                                    ticket,GetLastError());
     Print("MSG SIZE IS  : "  + IntegerToString(msg_list.Total()) );                             
     return msg_list;   // returns an array of messages            
                     
}
bool CGuruEx03_Base::CheckEntry(bool buy_signal,bool sell_signal)
  {
 //  double atr_value = 0;
     //atr_value = m_ATR.Main(0);
   if(!m_Symbol.RefreshRates())
      return (false);
   double price = iOpen(m_Symbol.Name(),Period(),0);

 double equity = m_Symbol.computeSymbolEquity();
  double positioning = m_Symbol.computeNetPositioning();

    string sBalanceVarName = m_Symbol.Name() + "_balance";
    string sEquityVarName = m_Symbol.Name() + "_equity";
    string sPositioningVarName = m_Symbol.Name() + "_netPositioning";
  
    GlobalVariableSet(sEquityVarName,equity);
     GlobalVariableSet(sPositioningVarName,positioning);

 
   
  if(buy_signal)
  {

   if(OrderNumber > 0) // does an active position exist ?       
         m_Trade.PositionClose(m_Pair);  // Close previous short order
         
      if(m_Trade.PositionOpen(m_Pair, ORDER_TYPE_BUY, GetSize(), m_Symbol.Ask(),0,0))
        {
         OrderNumber = m_Trade.ResultOrder();
         Long = true;
  
         return(true);
        }
      else
         OrderNumber = 0;
        
     }
   else
      if(sell_signal)
     {
      if(OrderNumber > 0) 
            m_Trade.PositionClose(m_Pair);  // Close previous long order

         if(m_Trade.PositionOpen(m_Pair, ORDER_TYPE_SELL, GetSize(), m_Symbol.Bid(), 0,0))
           {
            OrderNumber = m_Trade.ResultOrder();

            Long = false;
            return(true);
           }
         else
            OrderNumber = 0;
           
        }
   return(false);
  
 } 
  
  
  
  

