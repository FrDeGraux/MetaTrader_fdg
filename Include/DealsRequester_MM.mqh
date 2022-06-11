//+------------------------------------------------------------------+
//|                                            DealsRequester_MM.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "DealsRequester.mqh"
class DealsRequester_MM : public DealsRequester
  {
private:

public:
                     DealsRequester_MM();
                     DealsRequester_MM(datetime _from_date,datetime _to_date,string ctx = "");
                     void writeHeaders(string cmt = "");
                    ~DealsRequester_MM();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DealsRequester_MM::DealsRequester_MM(datetime _from_date,datetime _to_date,string ctx) : DealsRequester(_from_date,_to_date,ctx)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
DealsRequester_MM::~DealsRequester_MM()
  {
  }
void DealsRequester_MM::writeHeaders(string cmt)
{
DealsRequester::writeHeaders("FastMA_MediumMA_SlowMA");
}
//+------------------------------------------------------------------+
