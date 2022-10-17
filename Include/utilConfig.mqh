//+------------------------------------------------------------------+
//|                                                   utilString.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include <Arrays\ArrayString.mqh>
#include "utilTerminal.mqh"
#define NROWS_SWAP 5217
#define NCOLS_SWAP  4

#define NROWS_FIXED_HYSTERESIS 81
#define NCOLS_FIXED_HYSTERESIS 4
#include <fxsaber\MultiTester\MTTester.mqh>
class UtilConfig
  {
private: 
  static string getTesterConfig();
public :
   static datetime   getEndDateTester();
   static string getPeriodTester();
  };
datetime UtilConfig::getEndDateTester()
{

if(!UtilTerminal::isTesterMode())
   return(TimeCurrent());


string cfg = getTesterConfig();
int findPeriod = StringFind(cfg,"Period");
int findOptimization = StringFind(cfg,"Optimization");

if(findPeriod < 0 || findOptimization < 0)
   return "";
   int startExtract  = findPeriod+7;
   int endExtract = findOptimization-1;
 string res = StringSubstr(cfg,findPeriod+7,endExtract-startExtract-1);

  return res;
} 
string UtilConfig::getTesterConfig()
{
string Str;
  if (MQLInfoInteger(MQL_TESTER) && MTTESTER::GetSettings(Str))
    return Str;
   return "OOH";
 
}
string UtilConfig::getPeriodTester()
{

if(!UtilTerminal::isTesterMode())
   return("H1");


string cfg = getTesterConfig();
Alert("CFG : " + cfg);
int findPeriod = StringFind(cfg,"Period");
int findOptimization = StringFind(cfg,"Optimization");

if(findPeriod < 0 || findOptimization < 0)
   return "";
   int startExtract  = findPeriod+7;
   int endExtract = findOptimization-1;
 string res = StringSubstr(cfg,findPeriod+7,endExtract-startExtract-1);

  return res;
}