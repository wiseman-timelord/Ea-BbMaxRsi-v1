# Ea-BbMaxRsi-v1
A cut down version of my EA, a good base for developing your own EA.




### Preview
- The external inputs...
```
// External Inputs
input string ___Ea_Settings___ = "--= EA Settings - (Settings For The Ea) =--";
input int MagicNumber = 12345; 
input double LossPercentOff = 25.0;
input string ___Timer_Settings___ = "--= Timer Settings - (Settings For Timings) =--";
input double SpreadPercent = 10.0;
input bool TradeOnMonday = true;
input bool TradeOnTuesday = true;
input bool TradeOnWednesday = true;
input bool TradeOnThursday = true;
input bool TradeOnFriday = true;
input string ___General_Strategy___ = "--= General Strategy (Strategy Switches) =--";
input StrategySelection StrategyUsed = BB_RSI_MAX_STRATEGY;
input OrderDirections Order_Direction = BUY_SELL;
input int Trade_Slots = 2;
input double RiskPercent = 2.0;
input double TakeProfit = 50;
input double StopLoss = 50;
input string ___Bollinger_Bands___ = "--= Bollinger Bands (Strategy One) =--";
input Signal_Bars_Valid_Long BB_BarsValid = EIGHT__BARS;
input CustomTimeFramesStrategy BB_TimeFrame = H1_TIME;
input Trade_Direction BB_Direction = FOLLOW_TREND;
input double BB_Deviation = 2.0;
input int BB_Period = 20;
input string ___Moving_Average_Crossover___ = "--= Moving Average Crossover (Strategy Two) =--";
input Signal_Bars_Valid_Long MAX_BarsValid = EIGHT__BARS;
input CustomTimeFramesStrategy MAX_TimeFrame = H1_TIME;
input Trade_Direction MAX_TrendFollowing = FOLLOW_TREND; 
input int FastMA_Period = 9;
input int SlowMA_Period = 21;
input string ___Relative_Strength_Index___ = "--= Relative Strength Index (Strategy Three) =--";
input Signal_Bars_Valid_Short RSI_BarsValid = ONE_BAR;
input CustomTimeFramesStrategy RSI_TimeFrame = H1_TIME;
input Trade_Direction RSI_Direction = FOLLOW_TREND;
input int RSI_Period = 14;
input double RSI_Buy_Level = 30.0;
input double RSI_Sell_Level = 70.0;
```
