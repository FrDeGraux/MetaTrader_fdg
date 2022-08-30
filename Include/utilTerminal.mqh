//+------------------------------------------------------------------+
//|                                                   utilString.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

class UtilTerminal
{
   public : 
      static bool isViewerMode();
      static bool isViewerModeAlt();
      static bool useCiCustomMA_Yellow_Hysteresis();
      static bool displayEquity();
      static bool displaySwap();
      static bool displayATRSLTP();
};
bool UtilTerminal::displaySwap()
{
if(!isViewerMode())
   return false;
if(Period() == PERIOD_D1)
   return true;
 return false;
}
bool UtilTerminal::displayATRSLTP()
{
return(isViewerMode());
}
bool UtilTerminal::useCiCustomMA_Yellow_Hysteresis()
{
return(isViewerMode());
}
bool UtilTerminal::isViewerModeAlt()
{
return UtilTerminal::isViewerMode();
}
bool UtilTerminal::displayEquity()
{

if(!isViewerMode())
   return false;
 return true;
}
bool UtilTerminal::isViewerMode()
{
if(MQLInfoInteger(MQL_VISUAL_MODE))
   return true;
else
   return false;
}

