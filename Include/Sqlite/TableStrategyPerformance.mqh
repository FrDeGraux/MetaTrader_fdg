//+------------------------------------------------------------------+
//|                                     TableStrategyPerformance.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Sqlite\dbClass.mqh>
#include "SqlTable.mqh"
string colNames = "(name,return)";
bool createTableOnStart = false;
class TableStrategyPerformance :  public SqlTable
  {
private:

public:
                     TableStrategyPerformance(string sStrategyName,dbClass* _db);
                    ~TableStrategyPerformance();
                    bool addPerformance(datetime start,datetime end,double _return);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TableStrategyPerformance::TableStrategyPerformance(string sName,dbClass* _db) : SqlTable("PERFORMANCE",_db,createTableOnStart,colNames)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TableStrategyPerformance::~TableStrategyPerformance()
  {
  }
//+------------------------------------------------------------------+
bool TableStrategyPerformance::addPerformance(datetime start,datetime end,double _return)
{
return 1;
}