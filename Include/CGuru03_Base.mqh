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
#include "TradeEnhanced.mqh"
#include <MqlOutputMessageBase.mqh>
class CGuruEx03_Base : CArrayObj
  { 
private:

   CTradeEnhanced  m_Trade;  
   CSVDebugger* objCSVDebug;
   double ATR_StopLossRange;
   double ATR_TPRange;
   ulong             OrderNumber;
   double            GetSize();
   double             make_ATR_SL(double price,ENUM_ORDER_TYPE type,double atr_value );
   double              make_ATR_TP(double price,ENUM_ORDER_TYPE type,double atr_value );
   bool useStopTP;
   CSVDebugger* debugger;

   double getATR();
   bool getFinalSessionDate(datetime in_dt,datetime& out_final_dt);
protected:
   int               Dig;
   double            Points;
   bool              Initialized;
   bool              Long;
   bool              InitIndicators();
   string            m_Pair;                    // Currency pair to trade
                  // Trading object
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
   void writeDebugMsg(string msg);
   
public:
                     CGuruEx03_Base();
                  
                    ~CGuruEx03_Base() { Deinit(); }  // Destructor
   bool              Init(int _magicNumber,string Pair,int slippage,double lot,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange,bool useStopTP,CSVDebugger* _debugger);
   void              Deinit();
   bool              Validated();
   bool             CheckEntry(bool buy_signal,bool sell_signal);
   bool              rectangleCreate();
   bool              writeTrade (MqlOutputMessageBase* msg,string extra);
      CICustomATR              *m_ATR;
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

void CGuruEx03_Base::writeDebugMsg(string msg)
{
   debugger.writeMsg(m_Symbol.Name() + ";" + msg);
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

bool CGuruEx03_Base::Init(int _magicNumber,string Pair,int slippage,double lot,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange,bool _useStopTP,CSVDebugger* _debugger)
  {

   debugger = _debugger;
   useStopTP = _useStopTP;
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
   #define        WIDTH  800     // Image width to call ChartScreenShot()
#define        HEIGHT 600     // Image height to call ChartScreenShot()
   string name=_Symbol+TimeToString(TimeCurrent())+".PNG"; 
   Print("File Name is ",name);

   StringReplace(name,":"," ");

   if(!ChartScreenShot(0,name,800,600))
      Print("ScreenShot failed ");
   return(true);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void CGuruEx03_Base::Deinit()
  {
    if(debugger != NULL)
      delete debugger;
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
            m_Indis.Refresh();
           double   signal_rd = MathRandInt(0,3);
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
   
   double sl = 0;
   double tp = 0;
   //double ATR = iATR(NULL, 0, ATR_MAPeriod);
  if(buy_signal)
  {

   if(OrderNumber > 0) // does an active position exist ?   
      {
   //         this.writeDebugMsg(" Closing order " + StringToInteger(OrderNumber));
            m_Trade.PositionClose(m_Pair);  // Close previous short order
      }  
      if(useStopTP)
      {
          sl=   m_ATR.Main(1);
          tp =    m_ATR.Main(2);
      }
      
      
  
        
      if(m_Trade.PositionOpen(m_Pair, ORDER_TYPE_BUY, GetSize(), m_Symbol.Ask(),sl,tp))
        {
         double price = m_Trade.ResultPrice();
         
         OrderNumber = m_Trade.ResultOrder();
     //       this.writeDebugMsg(" Opening order " + StringToInteger(OrderNumber));
         Long = true;
  
         return(true);
        }
      else
      {
   //      this.writeDebugMsg(" Failed to open order");
         OrderNumber = 0;
      } 
     
   }
   else
      if(sell_signal)
     {
      if(OrderNumber > 0) 
         {
      //   this.writeDebugMsg(" Closing order " + StringToInteger(OrderNumber));
          m_Trade.PositionClose(m_Pair);  // Close previous long order
         }
       if(useStopTP)
      {
          sl=   m_ATR.Main(0);
          tp =    m_ATR.Main(3);
      }  

         if(m_Trade.PositionOpen(m_Pair, ORDER_TYPE_SELL, GetSize(), m_Symbol.Bid(), sl,tp))
           {
            OrderNumber = m_Trade.ResultOrder();
            // this.writeDebugMsg(" Opening order " + StringToInteger(OrderNumber));
            Long = false;
            return(true);
           }
         else
         {
            this.writeDebugMsg("Failed to open order");
            OrderNumber = 0;
          } 
        }
   return(false);
  
 } 
  
  
  
  

