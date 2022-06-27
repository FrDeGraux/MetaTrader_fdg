//+------------------------------------------------------------------+
//|                                                   SVDEbugger.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <utilDateTime.mqh>
class CSVDebugger
  {
private:

public:
                     CSVDebugger(string ctx);
                     CSVDebugger();
                    ~CSVDebugger();
                    void init(string ctx);
                    bool writeMsg(string msg);
private : 
                     string filename;
                     int handleFile;
                     bool isUsed;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string buildFileName()
{
string sTime = TimeToString(utilDateTime::GetTimeLocal(),TIME_DATE|TIME_SECONDS);
StringReplace(sTime,".","_");
StringReplace(sTime,":","_");

return sTime;
}
void CSVDebugger::init(string ctx)
{
   this.filename = ctx + "_" + buildFileName() + ".csv" ; 
   this.handleFile = FileOpen(this.filename,FILE_CSV|FILE_READ|FILE_WRITE, ',');
   isUsed = false;
   if(this.handleFile > 0)
       Print("File " + this.filename + " is opened");
}
CSVDebugger::CSVDebugger()
{

}
CSVDebugger::CSVDebugger(string ctx)
{
init(ctx);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSVDebugger::~CSVDebugger()
  {
   FileClose(this.handleFile);
      Print("File " + this.filename + " is closed");
   if(isUsed == true)
      return;
     
   bool bDeleteSuccess = FileDelete(filename);
   if(!bDeleteSuccess)
      Print("CSVDebugger::~CSVDebugger() Error");
  }
//+------------------------------------------------------------------+
bool CSVDebugger::writeMsg(string msg)
{
      isUsed = true;

      return(FileWrite(this.handleFile,msg) > 0);
    
}