//+------------------------------------------------------------------+
//|                                                     Greedily ver2.0.mq4 |
//|                                    strokovalexander.fx@gmail.com |
//|                                                                  |
#include <WinUser32.mqh>
//+------------------------------------------------------------------+
extern double StartProfitTrall=100;
extern double StopLoss=50;
extern string Параметры="UseTrall= 0 (не используем), 1 (фиксированный трал), 2 (динамический трал)";
extern int UseTrall=0;
extern double TralProfit=30;
extern double ProcentTrallProfit;
extern bool DeleteStopLimitOrders=false;
extern bool CloseTerminal=false;

int k;
bool ItsTrallTime=false;
double StopTrall;
double MaxEquity;
double EquityStartTrall;
double EquityStopTrall;
string Vis;
int OnInit()
  {
   if((Digits==3)||(Digits==5)) { k=10;}
   if((Digits==4)||(Digits==2)) { k=1;}
   return(INIT_SUCCEEDED);
  }
  
  int deinit()
  {

   return(0);
  }
int start()
  {
 ObjectCreate("label_object1",OBJ_LABEL,0,0,0);
ObjectSet("label_object1",OBJPROP_CORNER,4);
ObjectSet("label_object1",OBJPROP_XDISTANCE,10);
ObjectSet("label_object1",OBJPROP_YDISTANCE,10);
ObjectSetText("label_object1","Профит Жадности="+EquityStartTrall+"; Стоп Жадности="+EquityStopTrall,12,"Arial",Red);

ObjectCreate("label_object2",OBJ_LABEL,0,0,0);
ObjectSet("label_object2",OBJPROP_CORNER,4);
ObjectSet("label_object2",OBJPROP_XDISTANCE,10);
ObjectSet("label_object2",OBJPROP_YDISTANCE,30);
ObjectSetText("label_object2","Использование трала= "+Vis+"; Профит трала="+TralProfit+"; Стоп трала="+StopTrall,12,"Arial",Red);
 
//if  (GlobalVariableGet("Greedily")==0){ 

double AE=AccountEquity();
double AB=AccountBalance();
EquityStartTrall=AB+StartProfitTrall;
EquityStopTrall=AB-StopLoss;
if (UseTrall==0){Vis="Не используем";}
if (UseTrall==1){Vis="Фиксированный";}
if (UseTrall==2){Vis="Динамический";}

if (UseTrall==0){
if ((AE)<=EquityStopTrall){  
 GlobalVariableSet("Greedily",1);    
GoGoStop();        
}  
if ((AE)>=EquityStartTrall){   

 GlobalVariableSet("Greedily",1);   
GoGoProfit();
 }
                }

if (UseTrall==1){
if ((AE)<=EquityStopTrall){  
 GlobalVariableSet("Greedily",1);    
GoGoStop();        
}  
if ((AE>=EquityStartTrall)&&(ItsTrallTime==false)){ ItsTrallTime=true;MaxEquity=AE; StopTrall=AE-TralProfit; }

if (ItsTrallTime==true){
if (AE>(MaxEquity)){MaxEquity=AE;StopTrall=AE-TralProfit; Print("StopTrall стал ",StopTrall);}
if (AE<=StopTrall){ MaxEquity=0; StopTrall=0; ItsTrallTime=false; Print("StopTral >= AccountEquity, закрываем все ордера по значению депо = ", AE);GoGoProfit();       }
}


                }
                
if (UseTrall==2){
if ((AE)<=EquityStopTrall){  
 GlobalVariableSet("Greedily",1);    
GoGoStop();        
}  
if ((AE>=EquityStartTrall)&&(ItsTrallTime==false)){ ItsTrallTime=true;MaxEquity=AE; StopTrall=AE-TralProfit; }

if (ItsTrallTime==true){
if (AE>(MaxEquity)){MaxEquity=AE;StopTrall=AE-(AE-(EquityStartTrall-StartProfitTrall))*ProcentTrallProfit/100; Print("StopTrall стал ",StopTrall);}
if (AE<=StopTrall){ MaxEquity=0; StopTrall=0; ItsTrallTime=false; Print("StopTral >= AccountEquity, закрываем все ордера по значению депо = ", AE);GoGoProfit();       }
}


                }                


//}


return(0);}


 
   
double GoGoProfit(){


          for(int it=OrdersTotal()-1; it>=0; it--)
        {
         if((OrderSelect(it,SELECT_BY_POS,MODE_TRADES))&&(OrderType()==OP_BUY)){
              if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3*k,Black)<0)
               {
               Alert("Ошибка удаления ордера № ",GetLastError());
              }  }
              if((OrderSelect(it,SELECT_BY_POS,MODE_TRADES))&&(OrderType()==OP_SELL)){
              if( OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5*k,Black)<0)
              {
               Alert("Ошибка удаления ордера № ",GetLastError());
              }
            }
        }
if (DeleteStopLimitOrders==true){
  for(int idDel=OrdersTotal()-1; idDel>=0; idDel--)
        {
         if(!OrderSelect(idDel,SELECT_BY_POS,MODE_TRADES)) break;
         if((OrderType()>1)) if(IsTradeAllowed()) 
           {
            if(OrderDelete(OrderTicket())<0)
              {
               Alert("Ошибка удаления ордера № ",GetLastError());
              }
           }
         
        }
     }   
        Alert("Получен профит, закрываем ордера");

if (CloseTerminal==true){
PostMessageA(WindowHandle(Symbol(),Period()),WM_COMMAND,33050,0);
}

return(0);
}

double GoGoStop()
{          for(int itt=OrdersTotal()-1; itt>=0; itt--)
        {
         if((OrderSelect(itt,SELECT_BY_POS,MODE_TRADES))&&(OrderType()==OP_BUY)){
              if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5*k,Black)<0)
               {
               Alert("Ошибка удаления ордера № ",GetLastError());
              }  }
              if((OrderSelect(itt,SELECT_BY_POS,MODE_TRADES))&&(OrderType()==OP_SELL)){
              if( OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5*k,Black)<0)
              {
               Alert("Ошибка удаления ордера № ",GetLastError());
              }
            }       
        }
if (DeleteStopLimitOrders==true){
  for(int iDel=OrdersTotal()-1; iDel>=0; iDel--)
        {
         if(!OrderSelect(iDel,SELECT_BY_POS,MODE_TRADES)) break;
         if((OrderType()>1)) if(IsTradeAllowed()) 
           {
            if(OrderDelete(OrderTicket())<0)
              {
               Alert("Ошибка удаления ордера № ",GetLastError());
              }
           }
        }
     }   
        Alert("Теряем слишком много, прекращаем торговлю!");
        
 if (CloseTerminal==true){
PostMessageA(WindowHandle(Symbol(),Period()),WM_COMMAND,33050,0);
}    
        
SendMail("Советник Жадность закрыл убыток(((", "Все ордера закрылись");

     return(0); }  
  