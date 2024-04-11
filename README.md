# Ea-BbMaxRsi-v1

### Status
The EA represents stage 1 of completion, after, revisit and cleanup. This works well enough as a example EA; feel free to fork away, and let me know if its a winner!

## Description
The "BB-MAX-RSI" EA Version 1 for MetaTrader 5, is a cut down version of the EA I have personally developed, serving as a solid foundation for developing your own trading bot. It combines Bollinger Bands, Moving Average Crossover, and RSI strategies with customizable risk management and trading settings. This adaptable and efficient tool is designed to cater to various market scenarios and trading styles. In short, its somewhat no frills, and would require further work to become a profitable/reliable EA. Currently its designed, so you can swap out the strategies, try differing strategies in combination, the default strategies are simpler ones requiring less inputs. After trying a few strategies, and finding the best combination, you could then hardcode the strategies, and then logically add for example, trail stop or loss stop volatility. 

### Features
- **Multiple Strategies:** Offers Bollinger Bands, Moving Average Crossover, and RSI strategies with customizable settings.
- **Trade Directionality:** Allows trend following, trend reversal, and bi-directional trades.
- **Risk Management:** Enables setting risk levels, stop loss, and take profit to protect capital.
- **Custom Time Frames:** Supports various time frames from 30 minutes to 12 hours for strategy execution.
- **Day-of-Week Control:** Permits trading on selected weekdays, optimizing trading strategy.
- **Equity Protection:** Stops trading if losses exceed a specified percentage, safeguarding account equity.
- **Signal Processing:** Combines multiple indicators for robust buy or sell decisions.
- **Spread Management:** Executes trades considering spread conditions to ensure favorable entry.
- **Magic Number Use:** Identifies trades with a unique number, distinguishing EA-managed trades.

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

## Requirements
- MetaTrader 5.
- A demo account.
- A lot of time.
- Algo-Trading Experience.

### Usage
- Do not use it, you will loose money, unless...
1. You know what you are doing.
2. You are not trading money, that you do not mind loosing.
3. You have somehow upgraded the code, to make it more effective.
4. You have done extensive backtesing on it.
5. You have done forward backtest on demo account.
- All that said...
1. Copy the Ea to your `MQL5\Experts` folder.
2. Load the `*.set` Settings file provided, ensure genetic backtest is selected.
3. Its not great, but the loss-shutdown input will produce better quality results with less losses, the idea is put it higher for backtesting, then loosen it up for live/demo trading.
4. Setup the other parts of the backtest, note its designed for between a M30-H12 timeframe.
5. Run genetic backtest. 

### Notes
- The number of bars thing, is to coordinate signals between indicators, there are 2 enums for this, long and short, same with timeframes I think.
- To avoid market manipulation you should use a TimeFrame over M5, but, I would use at least M15, to remove such randomness.
- To gain consistent results, I would advise backtesting for 4 years of data, therein, you would probably want your TimeFrame to then become M30 or H1, for speed.
- I do notice that doing a backtest for short periods of history with a high takeprofit will definately result in non-reproducable results.
- If you add more than 3 strategies, it starts to become a massive number of calculations involved, also GPT context suffers.
- GPT: "Considering the complexity and features of your EA, a base price could be in the $50 to $100 range"

## Disclaimer
This software is subject to the terms in License.Txt, covering usage, distribution, and modifications. For full details on your rights and obligations, refer to License.Txt.
