# Ea-BbMaxRsi-v1

### Status
The EA represents stage 1 of completion, after, revisit and cleanup. This works well enough as a example EA; feel free to fork away, and let me know if its a winner!

## Description
The "BB-MAX-RSI" EA Version 1 for MetaTrader 5, is a cut down version of the EA I have personally developed, serving as a solid foundation for developing your own trading bot. It combines Bollinger Bands, Moving Average Crossover, and RSI strategies with customizable risk management and trading settings. This adaptable and efficient tool is designed to cater to various market scenarios and trading styles. In short, its somewhat no frills, and would require further work to become a profitable/reliable EA. Currently its designed, so you can swap out the strategies, try differing strategies in combination, the default strategies are simpler ones requiring less inputs. There is no trail stop or volatility for loss stop in this version.

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
- The external inputs...
```
// External Inputs
input string ___Ea_Settings___ = "--= EA Settings - (Settings For The Ea) =--";
input int MagicNumber = 12345; 
input double LossPercentOff = 25.0;
input string ___Timer_Settings___ = "--= Timer Settings - (Settings For Timings) =--";
input double MaxSpreadInPips = 25;
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
