//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://www.mql5.com"
#property description "Range Action Verification Index (RAVI) with inverse Fisher transform"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "balance"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed






//--- buffers declarations
double data_to_plot[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,data_to_plot,INDICATOR_DATA);
  
 
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Profit");
//---

   return (INIT_SUCCEEDED);
  }
//#include "ProfitIndicator.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
      Print("sending chart Event !");
     EventChartCustom(0,eventID,eventID,100,"de");
     eventID++;
 return(rates_total);
  }
  
  int eventID = 0;   
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
void  OnChartEvent(
   const int       id,       // event ID 
   const long&     lparam,   // long type event parameter
   const double&   dparam,   // double type event parameter
   const string&   sparam)
    
    {
    Print("Chart event !!");
        data_to_plot[eventID] = 100;
   // data_to_plot[lparam] = dparam;
    }
    
    

