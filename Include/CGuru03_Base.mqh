//+------------------------------------------------------------------+
//|                                                  sqlReporter.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfoCustom.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Indicators\Indicators.mqh>
#include <Arrays\ArrayObj.mqh>

#include <CSVDebugger.mqh>
 #include <Indicators\CiPosition.mqh>
#include <Indicators\CiProfit.mqh>
#include <utilTerminal.mqh>
#include <Trade\TradeEnhanced.mqh>
#include <Indicators\CICustomATR.mqh>
class CGuruEx03_Base : CArrayObj
  {
private: 
   double            ATR_StopLossRange;
   double            ATR_TPRange;
   double            ATR_MAPeriod;
   CTradeEnhanced    m_Trade;
   CSVDebugger*      objCSVDebug;

   ulong             OrderNumber;
   double            GetSize();

   bool              useStopTP;
   double computeATRThresHold(ENUM_ORDER_TYPE in_direction,ENUM_ORDER_REASON in_reason);

double computeATRThresHold_OnTheFly(ENUM_ORDER_TYPE in_direction,ENUM_ORDER_REASON in_reason);
protected:
   int               Dig;
   double            Points;
   bool              Initialized;
   bool              Long;
   bool              Short;
   bool              InitIndicators();
   string            m_Pair;                    // Currency pair to trade
   // Trading object
   CSymbolInfoCustom       m_Symbol;                  // Symbol info object
   // Indicators
   CIndicators       *m_Indis;                   // Indicator collection for fast recalculations
   // Slow moving average indicator

   CICustomATR              *m_ATR;
   
      CiProfit            *m_Profit;
  CiPosition         *m_Position;
  
  
   CSVDebugger*      debugger;

   double            Lots;

   double            ticks;
   int               magicNumber;


public:
                     CGuruEx03_Base();

                    ~CGuruEx03_Base() { Deinit(); }  // Destructor
   bool              Init(int _magicNumber,string Pair,int slippage,double lot,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange,bool useStopTP,CSVDebugger* _debugger);
   // bool              Init(int _magicNumber,string Pair,int slippage,double lot,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange,bool useStopTP,CSVDebugger* _debugger);
   void              Deinit();
   bool              Validated();
   bool              CheckEntry(bool buy_signal,bool sell_signal,string msg = "");


   static int        MathRandInt(const int,const int);
   bool              LookForEntry_Random();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CGuruEx03_Base::MathRandInt(const int min, const int max)
  {
   double f   = (MathRand() / 32768.0);
   return min + (int)(f * (max - min));
  }
//+------------------------------------------------------------------+
//| Constructor                                                     |
//+------------------------------------------------------------------+.

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGuruEx03_Base::computeATRThresHold_OnTheFly(ENUM_ORDER_TYPE in_direction,ENUM_ORDER_REASON in_reason)
{

  ENUM_SYMBOL_INFO_DOUBLE offer;
   if(in_direction == ORDER_TYPE_BUY)
      offer = SYMBOL_BID;
   else
   {
      if(in_direction == ORDER_TYPE_SELL)
         offer = SYMBOL_ASK;
      else
        {

         Print("Unable to map in_direction " + EnumToString(in_direction));
         return 0;
        }
   }


   double    atr_buffer[];
   ArrayResize(atr_buffer,1);
   int atr_handle=iATR(m_Symbol.Name(),0,ATR_MAPeriod);

   if(CopyBuffer(atr_handle,0,0,1,atr_buffer) <= 0)
     {
      Print("CGuruEx03_Base::computeATRThresHold() :: error");
      return 0;
     }
   double atr_value = atr_buffer[0];
   double current_close = SymbolInfoDouble(m_Symbol.Name(), offer);
   
   double multiplier = 0;
   if(in_reason == ORDER_REASON_SL)
         multiplier = ATR_StopLossRange;
   else if(in_reason == ORDER_REASON_TP)
         multiplier = ATR_TPRange;
   else
         Print("CGuruEx03_Base::computeATRThresHold() :: error in in_reason");
       
   double res =  current_close + multiplier*atr_value;

   return(res);
}
double CGuruEx03_Base::computeATRThresHold(ENUM_ORDER_TYPE in_direction,ENUM_ORDER_REASON in_reason)
  {
  
  
  if(!UtilTerminal::isViewerMode())
       return(computeATRThresHold_OnTheFly(in_direction,in_reason));
  if( m_ATR == NULL)
  {
    Print("CGuruEx03_Base::computeATRThresHold :: m_ATR not initialized");
  return 0;
  }
  if(in_direction == ORDER_TYPE_BUY && in_reason == ORDER_REASON_SL)
   return m_ATR.Main(1);
  if(in_direction == ORDER_TYPE_BUY && in_reason == ORDER_REASON_TP)
   return m_ATR.Main(2);
  if(in_direction == ORDER_TYPE_SELL && in_reason == ORDER_REASON_SL)
  return m_ATR.Main(0);
  if(in_direction == ORDER_TYPE_SELL && in_reason == ORDER_REASON_TP)
  return m_ATR.Main(3);
  
  Print("CGuruEx03_Base::computeATRThresHold :: uncomputable");
  return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGuruEx03_Base::CGuruEx03_Base()
  {

   ticks = 0;
   m_Indis = NULL;
   Initialized = false;
   Short = false;
   Long = false;
  }

// File name (only if "Information output" == "The text file")
//---
int file_handle=0;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+


//| Performs system initialisation                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGuruEx03_Base::Init(int _magicNumber,string Pair,int slippage,double lot,int _ATR_MAPeriod,int _ATR_StopLossRange,int _ATR_TPRange,bool _useStopTP,CSVDebugger* _debugger)
  {
   OrderNumber = 0;
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


   StringReplace(name,":"," ");

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
         Print("CGuruEx03_Base::Error creating indicators collection");
         return(false);
        }
     }
   if(!UtilTerminal::isViewerMode())
        return true;
     if(m_Profit == NULL)
     {
      if((m_Profit = new CiProfit) == NULL)
        {
         Print("CGuruEx03_Base::Error creating m_Profit");
         return(false);
        }
     }
   if(!m_Profit.Create(m_Pair, 0))
     {
      Print("CGuruEx03_Base::Error initializing m_Profit");
      return(false);
     }
// m_Slow.BuffSize(1);
   if(!m_Indis.Add(m_Profit))
     {
      Print("CGuruEx03_Base::Error adding Profit to indicator collection");
      return(false);
     }
   if(m_Position == NULL)
     {
      if((m_Position = new CiPosition) == NULL)
        {
         Print("CGuruEx03_Base::Error creating m_Position");
         return(false);
        }
     }
   if(!m_Position.Create(m_Pair, 0))
     {
      Print("CGuruEx03_Base::Error initializing m_Profit");
      return(false);
     }
   if(!m_Indis.Add(m_Position))
     {
      Print("CGuruEx03_Base::Error adding CiPosition to indicator collection");
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
   double   signal_rd = MathRandInt(0,15000);
   bool buy_signal = false;
   bool sell_signal = false;

   ticks = ticks + 1;
   if(MathCeil(signal_rd) == 1)
     {
      buy_signal = true;
     }
   if(MathCeil(signal_rd) == 2)
     {
      sell_signal = true;
     }

   string msg = "1.12048154_1.12070020_0.00027308_1.12075462";

   return(CheckEntry(buy_signal,sell_signal,msg));

  }

//+------------------------------------------------------------------+
//| Checks for entry to a trade - Exits previous trade also          |
//+------------------------------------------------------------------+
int u = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGuruEx03_Base::CheckEntry(bool buy_signal,bool sell_signal,string msg)
  {
   if(!m_Symbol.RefreshRates())
      return (false);
   if(UtilTerminal::isViewerMode())
   {
        double equity = m_Symbol.computeSymbolEquity();
        double positioning = m_Symbol.computeNetPositioning();
      
          string sBalanceVarName = m_Symbol.Name() + "_balance";
          string sEquityVarName = m_Symbol.Name() + "_equity";
          string sPositioningVarName = m_Symbol.Name() + "_netPositioning";
        
          GlobalVariableSet(sEquityVarName,equity);
          GlobalVariableSet(sPositioningVarName,positioning);
  } 
   double sl = 0;
   double tp = 0;
   if(buy_signal)
     {

      if(OrderNumber > 0) // does an active position exist ?
        {
         //         this.writeDebugMsg(" Closing order " + StringToInteger(OrderNumber));
         m_Trade.PositionClose(m_Pair,ULONG_MAX,msg);  // Close previous short order
         Short = false;
                  Print("Closing deal :  Long is now " + IntegerToString(Long) + " short is now false ");
         Print(" Used Memory is " + IntegerToString(MQLInfoInteger(MQL_MEMORY_USED)));
         Print(" Max Memory is " + IntegerToString(MQLInfoInteger(MQL_MEMORY_LIMIT)));
           
        }
      if(useStopTP)
        {

         sl=   m_ATR.Main(1);
         tp =    m_ATR.Main(2);
        }




      if(m_Trade.PositionOpen(m_Pair, ORDER_TYPE_BUY, GetSize(), m_Symbol.Ask(),sl,tp,msg))
        {
         double price = m_Trade.ResultPrice();
         Print(" Used Memory is " + IntegerToString(MQLInfoInteger(MQL_MEMORY_USED)));
         Print(" Max Memory is " + IntegerToString(MQLInfoInteger(MQL_MEMORY_LIMIT)));
         OrderNumber = m_Trade.ResultOrder();
         Long = true;
         Short = false;
         Print(" Long is now true, short is now false ");
         return(true);
        }
      else
        {
         OrderNumber = 0;
         Long = false;
           Print(" Long is now false due to failure");
        }

     }

   else
      if(sell_signal)
        {
         if(OrderNumber > 0)
           {
            m_Trade.PositionClose(m_Pair,ULONG_MAX,msg);  // Close previous long order
            Print(" Used Memory is " + IntegerToString(MQLInfoInteger(MQL_MEMORY_USED)));
            Print(" Max Memory is " + IntegerToString(MQLInfoInteger(MQL_MEMORY_LIMIT)));
            int y = 1;
            Long = false; // i'm not long anymore
           Print("Closing deal :  Long is now " + IntegerToString(Long) + " short is now " + IntegerToString(Short) );
           }
         if(useStopTP)
           {

            sl=   m_ATR.Main(0);
            tp =    m_ATR.Main(3);

           }

         if(m_Trade.PositionOpen(m_Pair, ORDER_TYPE_SELL, GetSize(), m_Symbol.Bid(), sl,tp,msg))
           {
            OrderNumber = m_Trade.ResultOrder();

          
               Short = true;
                          Print("Closing deal :  Long is now " + IntegerToString(Long) + " short is now " + IntegerToString(Short) );
            Print(" Used Memory is " + IntegerToString(MQLInfoInteger(MQL_MEMORY_USED)));
            Print(" Max Memory is " + IntegerToString(MQLInfoInteger(MQL_MEMORY_LIMIT)));
            return(true);
           }
         else
           {
            Short = false;
                       Print(" Long is now false due to failure");
            OrderNumber = 0;
           }
        }
   return(false);
  }






//+------------------------------------------------------------------+
