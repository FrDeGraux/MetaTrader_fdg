//+------------------------------------------------------------------+
//|                                                   utilString.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

class UtilChart
{
   public : 
      static bool setColors();
   private : 
          static bool ChartUpColorSet(const long chart_ID);
      static bool ChartDownColorSet(const long chart_ID);
      static const color clrUp;
      static const color clrDown;
      
};
const color UtilChart::clrUp = clrLimeGreen;
const color UtilChart::clrDown = clrRed;
bool UtilChart::setColors()
{
//long chartID=ChartFirst();
long chartID = ChartOpen("GBPUSD",PERIOD_D1);
while(chartID >= 0)
  {
   if(!ChartUpColorSet(chartID))
      return false;
   if(!ChartDownColorSet(chartID))
      return false;
   chartID = ChartNext(chartID);
  }
  return true;

}
bool UtilChart::ChartUpColorSet(const long chart_ID)
  {
  
//--- reset the error value
   ResetLastError();
//--- set the color of up bar, its shadow and border of body of a bullish candlestick
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CHART_UP,UtilChart::clrUp))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
 //--- reset the error value
   ResetLastError();
//--- set the color of up bar, its shadow and border of body of a bullish candlestick
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BULL,UtilChart::clrUp))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }    
//--- successful execution
   return(true);
  }
  
  bool UtilChart::ChartDownColorSet(const long chart_ID)
  {
//--- reset the error value
   ResetLastError();
//--- set the color of up bar, its shadow and border of body of a bullish candlestick
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CHART_DOWN,UtilChart::clrDown))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
     
        ResetLastError();
//--- set the color of up bar, its shadow and border of body of a bullish candlestick
   if(!ChartSetInteger(chart_ID,CHART_COLOR_CANDLE_BEAR,UtilChart::clrDown))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }   
//--- successful execution
   return(true);
  }