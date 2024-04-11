// Script: WiseTime_-_Generic_EA <<<--- Line Number 1
#property copyright "Wise-Time"
#property link      "wisetime.rf.gd"
#property strict

// MT5 Includes
#include <Trade\Trade.mqh>
#include <Indicators\Indicators.mqh>

// Custom Enums
enum CustomBarsNumber {
  ONE_BARS = 1,
  TWO_BARS = 2,
  FOUR_BARS = 4,
  EIGHT_BARS = 8,
  SIXTEEN_BARS = 16
};
enum StrategyTimeframe {
  H1_TIME = PERIOD_H1,
  H2_TIME = PERIOD_H2,
  H3_TIME = PERIOD_H3,
  H4_TIME = PERIOD_H4,
  H6_TIME = PERIOD_H6
};
enum OrderDirections {
  BUY_ONLY,
  SELL_ONLY, 
  BUY_SELL
};
enum TradeDirection {
    DIRECTION_BUY,
    DIRECTION_SELL
};
enum Signal_Filter_Type {
  NO_FILTER,
  SMMA_FILTER
};
enum Custom_Dayfilter_Config {
  FULL_WEEK,
  NOT_MON,
  NOT_TUE,
  NOT_WED,
  NOT_THU,
  NOT_FRI,
  START_WEEK,
  MIDDLE_WEEK,
  END_WEEK,
  ODD_DAYS
};

// External Inputs
input string _EA_Settings_ = "--= EA Settings - ( EA/Backtest Settings ) =--";
input int MagicNumber = 12345; // Unique Identification of Chart
input double LossPercentOff = 20.0; // % Loss to Shutdown EA
input double DrawdownPercentOff = 33.0; // % Drawdown to Shutdown EA
input string _Trade_Restrictions_ = "--= Restrictions Section - ( Settings For Trading ) =--";
input CustomBarsNumber Min_Order_Bars = EIGHT_BARS; // Number of Bars per Order
input double MaxSpreadAvePipMulti = 2.0; // Max Spread Average Pip Multiplier
input int Trade_Slots = 2; // Maximum Orders across All Charts.
input Custom_Dayfilter_Config Dayfilter_Days = MIDDLE_WEEK; // Set the default day filter
input string _Strategy_Configuration_ = "--= Strategy Section ( Strategy Settings ) =--";
input StrategyTimeframe Strategies_Timeframe = H3_TIME; // TimeFrame for IchiMoku
input OrderDirections Order_Direction = BUY_SELL; // Direction of Orders
input double RiskRewardRatio = 1.5; // TP in Ratio to SL
input double MaxRiskPercent = 7.5; // Maximum Risk in Percent
input string _Signal_Confirmation_ = "--= Signal Restriction  ( Loss Prevention ) =--";
input Signal_Filter_Type Signal_Filter = NO_FILTER; // Choose your filter type
input int Smma_Period = 100; // Smma Period (Default = 100)

// MT5 Classes
CTrade trade;

// Global Variables
datetime currentBarTime = 0;
datetime lastTradeTime = 0;
bool tradingEnabled = true;
double highestEquity = 0;
double initialEquity = 0;
double lastEquity = 0;
double FinalTakeProfit = 0;
double FinalStopLoss = 0;
double RiskPercent = 0;
bool correctConditions = true;
bool PreviousConditions = true; 
bool IsTradeInBar = false;
bool executeBuy = false;
bool executeSell = false;
double GlobalLotSize = 0;
double GlobalSLPrice = 0;
double GlobalTPPrice = 0;
double smmaBufferCurrent;
double smmaBufferPrevious;
bool smmaTrendDirection; 
bool trendIsUp = false;
int smmaHandle;
double AverageSpread = 25.0;
double MaxSpreadPips; 

// Function OnInit
int OnInit() {
    initialEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    highestEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    lastEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    return INIT_SUCCEEDED;
}

// Function OnTick
void OnTick() {
    if(IsNewBar()) {
        CheckShutdownCriteria();
        EvaluateTradingConditions();
        UpdateSMMAValues();
        IsTradeInBar = false;
    }
    if(tradingEnabled && correctConditions && !IsTradeInBar) {        
        StrategyManager();
    }    
}

// Is a NewBar?
bool IsNewBar() {
    CheckShutdownCriteria();
    static datetime lastBarTime = 0;
    datetime newBarTime = iTime(_Symbol, _Period, 0);
    if(lastBarTime != newBarTime) {
        lastBarTime = newBarTime;
        currentBarTime = newBarTime;
        return true;
    }
    return false;
}

// Trade Restriction Functions
void EvaluateTradingConditions() {
    PreviousConditions = correctConditions;
    double currentSpread = iSpread(_Symbol, _Period, 0) * _Point;
    double spreadDifference = (currentSpread - AverageSpread) / 100.0;
    AverageSpread += spreadDifference;
    AverageSpread = MathMax(AverageSpread, 5.0); 
    MaxSpreadPips = AverageSpread * MaxSpreadAvePipMulti;
    correctConditions = true;
    if (!IsTradeDay()) {
        correctConditions = false;
    } else if (currentSpread > MaxSpreadPips) {
        correctConditions = false;
    } else {
        datetime lastBarTimeAtLastTrade = iTime(_Symbol, (ENUM_TIMEFRAMES)Strategies_Timeframe, 0);
        int barsSinceLastTrade = 0;
        while (iTime(_Symbol, (ENUM_TIMEFRAMES)Strategies_Timeframe, barsSinceLastTrade) > lastTradeTime && barsSinceLastTrade < Bars(_Symbol, (ENUM_TIMEFRAMES)Strategies_Timeframe)) {
            barsSinceLastTrade++;
        }
        if (barsSinceLastTrade < Min_Order_Bars) {
            correctConditions = false;
        } else {
            int totalOpenTrades = PositionsTotal();
            if (totalOpenTrades >= Trade_Slots) {
                correctConditions = false;
            }
        }
    }  
    if (PreviousConditions != correctConditions) {
        Print(correctConditions ? "Conditions are now CORRECT for Trading." : "Conditions are now WRONG for Trading.");
    }
}
bool IsTradeDay() {
    MqlDateTime structTime;
    TimeToStruct(TimeCurrent(), structTime);
    int dow = structTime.day_of_week;
    switch(Dayfilter_Days) {
        case FULL_WEEK:
            return (dow == 1 || dow == 2 || dow == 3 || dow == 4 || dow == 5);        
        case NOT_MON:
            return (dow != 1);
        case NOT_TUE:
            return (dow != 2);
        case NOT_WED:
            return (dow != 3);
        case NOT_THU:
            return (dow != 4);
        case NOT_FRI:
            return (dow != 5);
        case START_WEEK:
            return (dow == 1 || dow == 2 || dow == 3);
        case MIDDLE_WEEK:
            return (dow == 2 || dow == 3 || dow == 4);
        case END_WEEK:
            return (dow == 3 || dow == 4 || dow == 5);
        case ODD_DAYS:
            return (dow == 1 || dow == 3 || dow == 5);
        default:
            return false;
    }
}

// Manage Strategies
void StrategyManager() {
    // Placeholder for New Strategy Entry Conditions
    CheckEntryConditions();
    
    if(executeBuy && SignalRestrictions(DIRECTION_BUY)) {
        Print("Signal allowed. Executing BUY order...");
        ExecuteOrder(DIRECTION_BUY);
    } else if(executeSell && SignalRestrictions(DIRECTION_SELL)) {
        Print("Signal allowed. Executing SELL order...");
        ExecuteOrder(DIRECTION_SELL);
    } else {
        Print("Order denied by Signal Restrictions.");
        IsTradeInBar = true;
    }
}
// Placeholder function for checking new strategy entry conditions
void CheckEntryConditions() {
    // Placeholder for implementing the entry logic of the new strategy
    // Update executeBuy and executeSell based on the new strategy's conditions
    /* Example Placeholder Logic */
    // executeBuy = /* Condition for a buy order */;
    // executeSell = /* Condition for a sell order */;
}

// Signal Restrictions
bool SignalRestrictions(TradeDirection direction) {
    if(Signal_Filter == NO_FILTER) {
        return true;
    }
    if(Signal_Filter == SMMA_FILTER) {
        if((direction == DIRECTION_BUY && smmaTrendDirection) || (direction == DIRECTION_SELL && !smmaTrendDirection)) {
            return true;
        }
    }
    return false;
}
void UpdateSMMAValues() {
    smmaHandle = iMA(_Symbol, PERIOD_D1, 100, 0, MODE_SMMA, PRICE_CLOSE);
    double smmaValues[2];
    if(smmaHandle != INVALID_HANDLE) {
        if(CopyBuffer(smmaHandle, 0, 0, 2, smmaValues) > 0) {
            smmaBufferCurrent = smmaValues[0];
            smmaBufferPrevious = smmaValues[1];
            smmaTrendDirection = smmaBufferCurrent > smmaBufferPrevious;
        } else {
            Print("Error copying buffer: ", GetLastError());
        }
    } else {
        Print("Indicator handle not valid.");
    }
}

// Execute Trade
void ExecuteOrder(TradeDirection direction) {
    GlobalLotSize = CalculateLotSize(MaxRiskPercent, _Symbol, GlobalCloudThickness);
    double entryPrice = (direction == DIRECTION_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
    CalculateSLandTP(direction, entryPrice);
    ulong ticket = 0;
    if(direction == DIRECTION_BUY) {
        ticket = trade.Buy(GlobalLotSize, _Symbol, entryPrice, GlobalSLPrice, GlobalTPPrice, "Buy Order");
    } else if(direction == DIRECTION_SELL) {
        ticket = trade.Sell(GlobalLotSize, _Symbol, entryPrice, GlobalSLPrice, GlobalTPPrice, "Sell Order");
    }
    if(ticket > 0) {
        Print("Order executed successfully. Ticket: ", ticket);
        lastTradeTime = TimeCurrent(); 
    } else {
        PrintFormat("Order execution failed. Error code: %d", GetLastError());
    }
    IsTradeInBar = true;
}

// Calculators For ExecuteOrder
void CalculateSLandTP(TradeDirection direction, double entryPrice) {
    // Placeholder: Calculate SL and TP based on new strategy
    // Use descriptive variable names and ensure logic matches your strategy's requirements
    /* Example Placeholder Logic */
    // double slDistance = /* Logic to determine SL distance */;
    // double tpDistance = /* Logic to determine TP distance */;
    // if(direction == DIRECTION_BUY) {
    //     GlobalSLPrice = entryPrice - slDistance;
    //     GlobalTPPrice = entryPrice + tpDistance;
    // } else {
    //     GlobalSLPrice = entryPrice + slDistance;
    //     GlobalTPPrice = entryPrice - tpDistance;
    // }
    // Normalize SL and TP prices
    // GlobalSLPrice = NormalizeDouble(GlobalSLPrice, _Digits);
    // GlobalTPPrice = NormalizeDouble(GlobalTPPrice, _Digits);
}
double CalculateLotSize(double riskPercent, string symbol, double cloudThickness) {
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskMoney = accountBalance * riskPercent / 100.0;
    double stopLossPips = cloudThickness / _Point;
    double pipValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE) * 0.00010;
    if(StringFind(symbol, "JPY") > -1) pipValue *= 0.01;
    double monetaryValuePerPip = pipValue;
    double lotSize = riskMoney / (stopLossPips * monetaryValuePerPip);
    double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    lotSize = MathMax(minLot, MathMin(MathRound(lotSize / lotStep) * lotStep, maxLot));
    double takeProfitPips = stopLossPips * RiskRewardRatio;
    PrintFormat("Account Balance: %g, Risk Money: %g, Stop Loss in Pips: %g, Take Profit in Pips: %g, Monetary Value Per Pip: %g, Calculated Lot Size: %g", 
                 accountBalance, riskMoney, stopLossPips, takeProfitPips, monetaryValuePerPip, lotSize); // Added Take Profit in Pips to the print statement
    return lotSize;
}

// Loss Drawdown Shutdown
void CheckShutdownCriteria() {
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    highestEquity = MathMax(highestEquity, currentEquity);
    double drawdown = (highestEquity - currentEquity) / highestEquity * 100.0;
    double percentLoss = (initialEquity - currentBalance) / initialEquity * 100.0;
    if(drawdown >= DrawdownPercentOff) {
        Shutdown("Maximum drawdown limit exceeded");
    } else if(percentLoss >= LossPercentOff) {
        Shutdown("Loss percentage limit exceeded");
    }
}
void Shutdown(string reason) {
    Print("Shutting down due to: ", reason);
    CloseAllPositions();
    tradingEnabled = false;
    ExpertRemove();
}
void CloseAllPositions() {
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(PositionSelectByTicket(PositionGetTicket(i))) {
            trade.PositionClose(_Symbol);
        }
    }
}

// Deinitialization
void OnDeinit(const int reason) {
    PrintFormat("Deinitializing: Final AverageSpread = %g, MaxSpreadPips = %g", AverageSpread, MaxSpreadPips);
    currentBarTime = 0;
    tradingEnabled = false;
    highestEquity = 0;
    initialEquity = 0;
    lastEquity = 0;
    FinalTakeProfit = 0;
    FinalStopLoss = 0;
    RiskPercent = 0;
    correctConditions = true;
    PreviousConditions = true; 
    IsTradeInBar = false;
    executeBuy = false;
    executeSell = false;
    GlobalLotSize = 0;
    GlobalSLPrice = 0;
    GlobalTPPrice = 0;
    smmaBufferCurrent = 0.0;
    smmaBufferPrevious = 0.0;
    smmaTrendDirection = false;
    trendIsUp = false;
    AverageSpread = 0.0;
    MaxSpreadPips = 0.0;

    // Releasing the SMMA handle
    if(smmaHandle != INVALID_HANDLE)
        IndicatorRelease(smmaHandle);
    smmaHandle = INVALID_HANDLE; // Reset the handle to an invalid state

    // Log the reason for deinitialization
    Print("EA deinitialized for the reason: ", reason);
}