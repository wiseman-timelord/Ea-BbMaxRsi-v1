// Script: Wisetime_BB-MAX-RSI-CE  <<<--- Line Number 1
#property copyright "See Accompanying Licence"
#property link      "https://github.com/wiseman-timelord"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

// custom ENUMs
enum StrategySelection {
  MAX_RSI_STRATEGY,
  BB_MAX_STRATEGY,
  BB_RSI_STRATEGY,
  BB_RSI_MAX_STRATEGY
};
enum Signal_Bars_Valid_Short {
  ZERO_BARS = 0,
  ONE_BAR = 1,
  TWO_BARS = 2
};
enum Signal_Bars_Valid_Long {
  FOUR__BARS = 4,
  EIGHT__BARS = 8,
  SIXTEEN__BARS = 16
};
enum Trade_Direction {
  FOLLOW_TREND,
  REVERSE_TREND
};
enum CustomTimeFramesStrategy {
  M30_TIME = PERIOD_M30,
  H1_TIME = PERIOD_H1,
  H2_TIME = PERIOD_H2,
  H4_TIME = PERIOD_H4,
  H8_TIME = PERIOD_H8,
  H12_TIME = PERIOD_H12
};
enum OrderDirections {
  BUY_ONLY,
  SELL_ONLY, 
  BUY_SELL
 };

// External Inputs
input string ___Ea_Settings___ = "--= EA Settings - (Settings For The Ea) =--";
input int MagicNumber = 12345; 
input double LossPercentOff = 25.0;
input string ___Timer_Settings___ = "--= Timer Settings - (Settings For Timings) =--";
input double MaxSpreadInPips = 25.0;
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

// Structures
struct SignalInfo {
  bool isValid;
  datetime time;
  StrategySelection strategy;
};
struct TradeState {
  ulong ticket;
  bool isActive;
};

// Important Stuff
int handleRSI;
int handleBBUpper;
int handleBBLower;
int handleFastMA;
int handleSlowMA;
CTrade trade;
datetime currentBarTime = 0;
double initialEquity = 0;
double spreadThreshold;
bool tradingEnabled = true;
bool finalBuySignal = false;
bool finalSellSignal = false;
SignalInfo buySignal, sellSignal;
TradeState tradeStates[];
void OpenBuyTrade();
void OpenSellTrade();
bool IsNewBar();
double lastUpperBand[];
double lastLowerBand[];
double lastFastMAValues[];
double lastSlowMAValues[];
double lastRSIValues[];
static int lossCloseCounter = 0;

// Function OnInit
int OnInit() {
    initialEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    ENUM_TIMEFRAMES rsiTimeFrameConverted = (ENUM_TIMEFRAMES)RSI_TimeFrame;
    ENUM_TIMEFRAMES bbTimeFrameConverted = (ENUM_TIMEFRAMES)BB_TimeFrame;
    int bbDeviationInt = (int)MathRound(BB_Deviation);
    handleRSI = iRSI(_Symbol, rsiTimeFrameConverted, RSI_Period, PRICE_CLOSE);
    handleBBUpper = iBands(_Symbol, bbTimeFrameConverted, BB_Period, bbDeviationInt, 0, PRICE_CLOSE);
    handleBBLower = iBands(_Symbol, bbTimeFrameConverted, BB_Period, bbDeviationInt, 0, PRICE_CLOSE);
    handleFastMA = iMA(_Symbol, (ENUM_TIMEFRAMES)MAX_TimeFrame, FastMA_Period, 0, MODE_EMA, PRICE_CLOSE);
    handleSlowMA = iMA(_Symbol, (ENUM_TIMEFRAMES)MAX_TimeFrame, SlowMA_Period, 0, MODE_EMA, PRICE_CLOSE);
    ArraySetAsSeries(lastUpperBand, true);
    ArraySetAsSeries(lastLowerBand, true);
    ArraySetAsSeries(lastFastMAValues, true);
    ArraySetAsSeries(lastSlowMAValues, true);
    ArraySetAsSeries(lastRSIValues, true);
    CopyBuffer(handleBBUpper, 0, 0, 1, lastUpperBand);
    CopyBuffer(handleBBLower, 0, 0, 1, lastLowerBand);
    CopyBuffer(handleFastMA, 0, 0, 1, lastFastMAValues);
    CopyBuffer(handleSlowMA, 0, 0, 1, lastSlowMAValues);
    CopyBuffer(handleRSI, 0, 0, 1, lastRSIValues);
    return(INIT_SUCCEEDED);
}

// Function OnTick
void OnTick() {
    TradeManager();
}

// Updated IsTradeTimeDay function
bool IsTradeDay() {
    MqlDateTime structTime;
    TimeToStruct(TimeCurrent(), structTime);
    switch(structTime.day_of_week) {
        case 1: return TradeOnMonday;
        case 2: return TradeOnTuesday;
        case 3: return TradeOnWednesday;
        case 4: return TradeOnThursday;
        case 5: return TradeOnFriday;
        default: return false; // For Saturday and Sunday
    }
}


// IsNewBar
bool IsNewBar() {
    static datetime lastBarTime = 0;
    datetime newBarTime = iTime(_Symbol, _Period, 0);
    if(lastBarTime != newBarTime) {
        lastBarTime = newBarTime;
        currentBarTime = newBarTime;
        return true;
    }
    return false;
}

// Close State Check
int GetTradeStateIndex(ulong ticket) {
    for(int i = 0; i < ArraySize(tradeStates); i++) {
        if(tradeStates[i].ticket == ticket) return i;
    }
    return -1;
}

// Manage Trades
void TradeManager() {
    if(!IsTradeDay()) {
        Print("Not trading today based on day restrictions.");
        return;
    }
	 double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
	 double equityLossPercent = ((initialEquity - currentEquity) / initialEquity) * 100.0;
	 if(equityLossPercent >= LossPercentOff && LossPercentOff < 100) {
		 Print("Equity loss threshold reached. Trading disabled.");
		 tradingEnabled = false;
	 	 return;
	 }
    if(!IsNewBar()) return;
    bool bbBuySignal = false, bbSellSignal = false;
    CheckBBSignal(bbBuySignal, bbSellSignal);
    bool rsiBuySignal = false, rsiSellSignal = false;
    CheckRSISignal(rsiBuySignal, rsiSellSignal);
    bool maBuySignal = false, maSellSignal = false;
    CheckMACrossoverSignal(maBuySignal, maSellSignal);
    switch(StrategyUsed) {
        case BB_RSI_STRATEGY:
            finalBuySignal = rsiBuySignal && bbBuySignal;
            finalSellSignal = rsiSellSignal && bbSellSignal;
            break;
        case MAX_RSI_STRATEGY:
            finalBuySignal = maBuySignal && rsiBuySignal;
            finalSellSignal = maSellSignal && rsiSellSignal;
            break;
        case BB_MAX_STRATEGY:
            finalBuySignal = maBuySignal && bbBuySignal;
            finalSellSignal = maSellSignal && bbSellSignal;
            break;
        case BB_RSI_MAX_STRATEGY:
            finalBuySignal = maBuySignal && rsiBuySignal && bbBuySignal;
            finalSellSignal = maSellSignal && rsiSellSignal && bbSellSignal;
            break;
    }
    Print("Final Buy Signal: ", finalBuySignal, ", Final Sell Signal: ", finalSellSignal);
    if(finalBuySignal) ExecuteTrade(true);
    else if(finalSellSignal) ExecuteTrade(false);
}

// Bollinger Bands Strategy
void CheckBBSignal(bool& bbBuySignal, bool& bbSellSignal) {
    bbBuySignal = false;
    bbSellSignal = false;
    double upperBand[], lowerBand[];
    ArraySetAsSeries(upperBand, true);
    ArraySetAsSeries(lowerBand, true);
    if(CopyBuffer(handleBBUpper, 0, 0, BB_BarsValid, upperBand) <= 0 ||
       CopyBuffer(handleBBLower, 0, 0, BB_BarsValid, lowerBand) <= 0) return;
    for(int i = 0; i < BB_BarsValid; i++) {
        double closePrice = iClose(_Symbol, (ENUM_TIMEFRAMES)BB_TimeFrame, i);
        if(closePrice > upperBand[i] && BB_Direction == FOLLOW_TREND) {
            bbSellSignal = true;
            break;
        } else if(closePrice < lowerBand[i] && BB_Direction == REVERSE_TREND) {
            bbBuySignal = true;
            break;
        }
    }
}

// MAX Strategy
void CheckMACrossoverSignal(bool& maBuySignal, bool& maSellSignal) {
    maBuySignal = false;
    maSellSignal = false;
    double fastMAValues[], slowMAValues[];
    ArraySetAsSeries(fastMAValues, true);
    ArraySetAsSeries(slowMAValues, true);
    if(CopyBuffer(handleFastMA, 0, 0, MAX_BarsValid, fastMAValues) <= 0 ||
       CopyBuffer(handleSlowMA, 0, 0, MAX_BarsValid, slowMAValues) <= 0) return;
    for(int i = 1; i < MAX_BarsValid; i++) {
        if(fastMAValues[i-1] < slowMAValues[i-1] && fastMAValues[i] > slowMAValues[i]) {
            maBuySignal = true;
            break;
        } else if(fastMAValues[i-1] > slowMAValues[i-1] && fastMAValues[i] < slowMAValues[i]) {
            maSellSignal = true;
            break;
        }
    }
}

// RSI Strategy
void CheckRSISignal(bool& rsiBuySignal, bool& rsiSellSignal) {
    rsiBuySignal = false;
    rsiSellSignal = false;
    double rsiValues[];
    if(CopyBuffer(handleRSI, 0, 0, RSI_BarsValid, rsiValues) <= 0) return;
    for(int i = 0; i < RSI_BarsValid; i++) {
        if((rsiValues[i] < RSI_Buy_Level && RSI_Direction == FOLLOW_TREND) ||
           (rsiValues[i] > RSI_Sell_Level && RSI_Direction == REVERSE_TREND)) {
            rsiBuySignal = RSI_Direction == FOLLOW_TREND;
            rsiSellSignal = RSI_Direction == REVERSE_TREND;
            break;
        }
    }
}

// Execute Trade
void ExecuteTrade(bool isBuy) {
    if((isBuy && Order_Direction == SELL_ONLY) || (!isBuy && Order_Direction == BUY_ONLY)) {
        Print("Trade direction not allowed by settings.");
        return;
    }
    int openPositions = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol) {
            openPositions++;
        }
    }
    if(openPositions >= Trade_Slots) {
        Print("Maximum number of trade slots reached.");
        return;
    }
    MqlTick lastTick;
    if(!SymbolInfoTick(_Symbol, lastTick)) {
        Print("Failed to retrieve tick data for ", _Symbol);
        return;
    }
    double spread = lastTick.ask - lastTick.bid;
    double spreadInPips = spread / _Point;
    double spreadThresholdInPips = MaxSpreadInPips;
    if(spreadInPips > spreadThresholdInPips) {
        Print("Current spread (", spreadInPips, " pips) is higher than allowed (", MaxSpreadInPips, " pips). Trade not executed.");
        return;
    }
    double price = isBuy ? lastTick.ask : lastTick.bid;
    double adjustedSL = isBuy ? price - StopLoss * _Point : price + StopLoss * _Point;
    double adjustedTP = isBuy ? price + TakeProfit * _Point : price - TakeProfit * _Point;
    double volume = NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY) * RiskPercent / 100.0 / 10000, 2);
    volume = MathMax(volume, 0.01);
    volume = NormalizeDouble(volume, 2);
    string tradeType = isBuy ? "Buy" : "Sell";
    string tradeComment = "Trade Order MN: " + IntegerToString(MagicNumber);
    if((isBuy && trade.Buy(volume, _Symbol, price, adjustedSL, adjustedTP, tradeComment)) ||
       (!isBuy && trade.Sell(volume, _Symbol, price, adjustedSL, adjustedTP, tradeComment))) {
        Print(tradeType + " order placed successfully with Magic Number in comment.");
    } else {
        Print("Failed to place " + tradeType + " order: Error ", GetLastError());
    }
}

// Deinitialization
void OnDeinit(const int reason)
{
    IndicatorRelease(handleRSI);
    IndicatorRelease(handleBBUpper);
    IndicatorRelease(handleBBLower);
    IndicatorRelease(handleFastMA);
    IndicatorRelease(handleSlowMA);
    currentBarTime = 0;
    tradingEnabled = true;
    initialEquity = 0;
    spreadThreshold = 0;
    finalBuySignal = false;
    finalSellSignal = false;
    lossCloseCounter = 0;
    ArrayFree(lastUpperBand);
    ArrayFree(lastLowerBand);
    ArrayFree(lastFastMAValues);
    ArrayFree(lastSlowMAValues);
    ArrayFree(lastRSIValues);
    ArrayResize(tradeStates, 0);
    Print("EA deinitialized for the reason: ", reason);
}
