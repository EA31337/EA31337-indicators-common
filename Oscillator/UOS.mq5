//+------------------------------------------------------------------+
//|                                               EA31337 indicators |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Implements Ultimate Oscillator (UOS) indicator.
 */

// Defines.
#define INDI_FULL_NAME "Ultimate Oscillator"
#define INDI_SHORT_NAME "UOS"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 DodgerBlue
#property indicator_label1 INDI_SHORT_NAME
#property version "1.000"
#endif

// Resource files.
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\Ultimate_Oscillator.ex5"
#resource "\\Indicators\\Examples\\Ultimate_Oscillator.ex5"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_UltimateOscillator.mqh>

// Input parameters.
input int InpFastPeriod_ = 7;                               // Fast ATR period
input int InpMiddlePeriod_ = 14;                            // Middle ATR period
input int InpSlowPeriod_ = 28;                              // Slow ATR period
input int InpFastK_ = 4;                                    // Fast K
input int InpMiddleK_ = 2;                                  // Middle K
input int InpSlowK_ = 1;                                    // Slow K
input int InpShift_ = 0;                                    // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtBuffer[];

// Global variables.
Indi_UltimateOscillator *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtBuffer, INDICATOR_DATA);
  // Initialize indicator.
  IndiUltimateOscillatorParams _indi_params(
      ::InpFastPeriod_, ::InpMiddlePeriod_, ::InpSlowPeriod_, ::InpFastK_,
      ::InpMiddleK_, ::InpSlowK_, ::InpShift_);
  indi = new Indi_UltimateOscillator(_indi_params /* , InpSourceType */);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name =
      StringFormat("%s(%d,%d,%d)", INDI_SHORT_NAME, ::InpFastPeriod_,
                   ::InpMiddlePeriod_, ::InpSlowPeriod_);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  // Set accuracy.
  IndicatorSetInteger(INDICATOR_DIGITS, 2);
  // Set levels.
  IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 30);
  IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, 70);
  // Set maximum and minimum for subwindow.
  IndicatorSetDouble(INDICATOR_MINIMUM, 0);
  IndicatorSetDouble(INDICATOR_MAXIMUM, 100);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
  PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
  // Sets first bar from what index will be drawn.
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, ::InpSlowPeriod_ - 1);
}

/**
 * Calculate event handler function.
 */
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  int i, start;
  // Initialize calculations.
  start = prev_calculated == 0
              ? fmax4(0, ::InpFastPeriod_, ::InpMiddlePeriod_, ::InpSlowPeriod_)
              : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      return prev_calculated + 1;
    }
    ExtBuffer[i] = _entry[0];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
