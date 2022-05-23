//+------------------------------------------------------------------+
//|                                                TableCalendar.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "dbReportingClass.mqh"
//#include "recordCalendar.mqh"
#include <Arrays\ArrayString.mqh>
bool createTableOnStart = false;
class TableReporter
  {
private:
                     string sTableName;
                     int db;
                     dbReportingClass* dbFull;
                     string sDBName;
                      bool createTable();
                      CArrayString* get_record(int rec);
public:
                     TableReporter(string sName,dbReportingClass* _db,string _dbName);
                    
                    ~TableReporter();
                   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TableReporter::TableReporter(string sName,dbReportingClass* _db,string _dbName)
  {
  sTableName = sName;
  dbFull = _db;
  sDBName = _dbName;
  if(createTableOnStart)
   {
      if( !createTable())
         Alert("TableReporter::TableReporter : Unable to create the table " + this.sTableName);
   }
      createTable();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TableReporter::~TableReporter()
  {
  }
  bool TableReporter::createTable()
  {
  string sql_request = "CREATE TABLE";
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

