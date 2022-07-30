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
};
bool UtilTerminal::isViewerMode()
{
return false;
if(MQLInfoInteger(MQL_VISUAL_MODE))
   return true;
else
   return false;
}
