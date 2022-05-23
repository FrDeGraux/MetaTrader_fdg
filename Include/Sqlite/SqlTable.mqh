//+------------------------------------------------------------------+
//|                                                     SqlTable.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include "dbClass.mqh"
#property version   "1.00"

class SqlTable
  {
private:
          
                  
          
                      bool createTable(string colNames);
protected :
               dbClass* dbFull;        
                  string sTableName;      
                          
                     int db;              
public:
                     SqlTable(string _sTableName,dbClass* _db,bool createTableOnStart,string colNames );
                  
                    ~SqlTable();
                   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SqlTable::SqlTable(string _sTableName,dbClass* _db,bool createTableOnStart = false,string colNames = "" )
  {
  //   sTableName = sStrategyName + "_TRADES";
  sTableName = sTableName;
  dbFull = _db;
  
  if(createTableOnStart)
   {
      if( !createTable(colNames))
         Alert("TableTradeReporter::TableTradeReporter : Unable to create the table " + this.sTableName);
   }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SqlTable::~SqlTable()
  {
  }
  bool SqlTable::createTable(string colNames)
  {
  //string sql_request = "CREATE TABLE " + sTableName + "(dt,symbol,type,mode,volume,sl,tp,comment)";
  string sql_request = "CREATE TABLE " + sTableName + colNames;
     if(!DatabaseExecute(this.dbFull.getDB(),sql_request))
     {
      int error_code=GetLastError();
      PrintFormat("Error code=%d",error_code);
      //---
      DatabaseClose(db);
      return(false);
     }
     return true;
  }