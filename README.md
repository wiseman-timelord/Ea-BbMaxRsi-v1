# Mql5EaGenericPlus-v2

### Status
- Under ongoing development. Currently awaiting re-creation, as uploaded wrong one, and then couldnt get back to original, and am now making a EA from a somewhat near original script. Will re-upload later.
- Feel free to download this project, and if it makes a great trader, then also feel free to, fork and upload.

## Description
The "Mql5EaGenericPlus-v2" EA Version 2 for MetaTrader 5, is a cut down version of the Latest EA I have personally developed, serving as a solid foundation for developing your own trading bot. It has placeholder parts in in, "Strategy Manager" and "Execute Order", as well as a dummy function representing calculations required for main strategy. Gpt4 with my GPT Personality "Mt5Mql5EaMakerPro" can be instructed to inspect the script, and then implement any combinations of main trading strategy, then fix the leftover issues. 

### Features
- **Descriptive Placeholder Parts:** Implement your own choice of strategy with customizable settings.
- **All other required code:** The script is complete otherwise.
- **Custom Enums**: Custom Enums for impressive reduction in calculations required during backtesting.  
- **Reduced Calculations**: Use of NewBar enables less intensive calculations not be done every tick. 
- **Order Confirmations**: Toggle a "Smma 100 D1" indicator, allowing effective recuperating of losses. 

### Preview
- The Descriptive Overview of the Script...
```
// Script: BaseStrategy_Template
#property copyright "Your Copyright"
#property link      "https://www.mql5.com"
#property strict

// MT5 Includes
#include <Trade\Trade.mqh>
#include <Indicators\Indicators.mqh>

// Custom Enums
enum CustomBarsNumber { /* Your enums here */ };
enum StrategyTimeframe { /* Your enums here */ };
enum OrderDirections { /* Your enums here */ };
enum TradeDirection { /* Your enums here */ };
enum Signal_Filter_Type { /* Your enums here */ };
enum Custom_Dayfilter_Config { /* Your enums here */ };

// External Inputs
input string _EA_Settings_ = "--= EA Settings =--";
// Define your EA settings here...

// MT5 Classes
CTrade trade;

// Global Variables
// Define your global variables here...

// Function OnInit
int OnInit() {
    // Initialization code here...
    return INIT_SUCCEEDED;
}

// Function OnTick
void OnTick() {
    // Main trading logic here...
}

// Placeholder Strategy Manager Function
void StrategyManager() {
    // Define your strategy management logic here...
    // For example, evaluate conditions for a trading signal:
    bool signalBuy = false;
    bool signalSell = false;

    // Dummy conditions for buy or sell signals
    if (/* condition for a buy signal */) {
        signalBuy = true;
    } 
    if (/* condition for a sell signal */) {
        signalSell = true;
    }

    // Execute trade based on the evaluated signal
    if(signalBuy) {
        ExecuteOrder(DIRECTION_BUY);
    } else if(signalSell) {
        ExecuteOrder(DIRECTION_SELL);
    }
}

// Function to Update Strategy Indicators or Conditions
void UpdateStrategyConditions() {
    // Update any conditions or indicators needed for your strategy
}

// Function ExecuteOrder
void ExecuteOrder(TradeDirection direction) {
    // Execution logic here...
}

// Other Utility Functions as needed...
// For example, CalculateSLandTP, CheckShutdownCriteria, etc.

// Function OnDeinit
void OnDeinit(const int reason) {
    // Cleanup code here...
}
```
- External Inputs...
```
string _EA_Settings_ = "--= EA Settings - ( EA/Backtest Settings ) =--";
int MagicNumber = 12345; // Unique Identification of Chart
double LossPercentOff = 20.0; // % Loss to Shutdown EA
double DrawdownPercentOff = 33.0; // % Drawdown to Shutdown EA
string _Trade_Restrictions_ = "--= Restrictions Section - ( Settings For Trading ) =--";
CustomBarsNumber Min_Order_Bars = EIGHT_BARS; // Number of Bars per Order
double MaxSpreadAvePipMulti = 2.0; // Max Spread Average Pip Multiplier
int Trade_Slots = 2; // Maximum Orders across All Charts.
Custom_Dayfilter_Config Dayfilter_Days = MIDDLE_WEEK; // Set the default day filter
string _Strategy_Configuration_ = "--= Strategy Section ( Strategy Settings ) =--";
StrategyTimeframe Strategies_Timeframe = H3_TIME; // TimeFrame for IchiMoku
OrderDirections Order_Direction = BUY_SELL; // Direction of Orders
double RiskRewardRatio = 1.5; // TP in Ratio to SL
double MaxRiskPercent = 7.5; // Maximum Risk in Percent
string _Signal_Confirmation_ = "--= Signal Restriction  ( Loss Prevention ) =--";
Signal_Filter_Type Signal_Filter = NO_FILTER; // Choose your filter type
int Smma_Period = 100; // Smma Period (Default = 100)
```

## Requirements
- MetaTrader 5.
- A demo account.
- A lot of time.
- Algo-Trading Experience.

### Usage
- Here is a (Mt5Mql5EaMakerPro demonstration)[https://chat.openai.com/g/g-UULzpPpmc-mt5mql5eamakerpro].
- Its not possible to use this script directly as an EA, you need to implement the main strategy, but otherwise.
- Enable Min_Order_Barsbetween, EIGHT_BARS and SIXTEEN_BARS, to avoid random, spam timing and max orders exceeded, related profit results.


### Notes
- Long Running issue with MaxOrders, cant get it to do number of orders on the specific chart, max orders is global, both would be better.
- It uses H1 to H6, this produces better reproducable results, leading to lower drawdowns.

## Disclaimer
This software is subject to the terms in License.Txt, covering usage, distribution, and modifications. For full details on your rights and obligations, refer to License.Txt.
