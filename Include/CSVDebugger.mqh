//+------------------------------------------------------------------+
//|                                                   SVDEbugger.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
class CSVDebugger
  {
private:

public:
                     CSVDebugger(string ctx);
                    ~CSVDebugger();
                    void writeMsg(string msg);
private : 
                     int handleFile;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string buildFileName()
{
string sTime = TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES );
StringReplace(sTime,".",'_');
StringReplace(sTime,":",'_');

return sTime;
}
CSVDebugger::CSVDebugger(string ctx)
  {
  string filename = buildFileName() + ".csv" ; 
   this.handleFile = FileOpen(filename,FILE_CSV|FILE_READ|FILE_WRITE, ',');
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSVDebugger::~CSVDebugger()
  {
   FileClose(this.handleFile);
  }
//+------------------------------------------------------------------+
void CSVDebugger::writeMsg(string msg)
{
      FileWrite(this.handleFile,msg);
    
}