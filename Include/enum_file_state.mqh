//+------------------------------------------------------------------+
//|                                              enum_file_state.mqh |
//|                                          Copyright 2019, D. Dorn |
//|                                             mailto:d.dorn@web.de |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, D. Dorn"
#property link      "mailto:d.dorn@web.de"
#property strict

#ifndef DD__ENUM__FILE__STATE__MQH
#define DD__ENUM__FILE__STATE__MQH
//+------------------------------------------------------------------+
//| Return values for the ReadLine() function if an error occured    |
//+------------------------------------------------------------------+
enum ENUM_FILE_STATE
  {
   FILE_STATE_ERROR = -1,
   FILE_STATE_EOF   = -4,
  };
//+------------------------------------------------------------------+
#endif