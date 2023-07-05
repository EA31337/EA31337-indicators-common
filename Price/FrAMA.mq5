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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Implements Fractal Adaptive Moving Average (FrAMA) indicator.
 */

// Defines.
#define INDI_FULL_NAME "Fractal Adaptive Moving Average"
#define INDI_SHORT_NAME "FrAMA"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 DarkBlue
#property indicator_width1 1
#property indicator_applied_price PRICE_CLOSE
#property indicator_label1 INDI_SHORT_NAME
#property version "1.000"
#endif

// Resource files.
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\FrAMA.ex5"
#resource "\\Indicators\\Examples\\FrAMA.ex5"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_FractalAdaptiveMA.mqh>

// Input parameters.
input int InpPeriod = 10;                                   // FrAMA period
input ENUM_APPLIED_PRICE InpFrAMAAppliedPrice = PRICE_OPEN; // Applied price
input int InpShift_ = 0;                                    // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double InpExtFrAMABuffer[];

// Global variables.
Indi_FrAMA *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, InpExtFrAMABuffer, INDICATOR_DATA);
  // Initialize indicator.
  IndiFrAIndiMAParams _indi_params(::InpPeriod, ::InpShift_);
  indi = new Indi_FrAMA(_indi_params, InpSourceType);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(%d)", indi.GetName(), ::InpPeriod);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  // Use DBL_MAX for empty values.
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, DBL_MAX);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, ::InpPeriod);
  // Sets indicator shift.
  PlotIndexSetInteger(0, PLOT_SHIFT, ::InpPeriod);
  // Set accuracy.
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
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
  if (rates_total < 2 * InpPeriod) {
    return (0);
  }
  // Initialize calculations.
  start = prev_calculated == 0 ? 2 * InpPeriod - 1 : prev_calculated - 1;
  if (prev_calculated == 0) {
    for (i = 0; i <= start; i++) {
      InpExtFrAMABuffer[i] = close[i];
    }
  }
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      InpExtFrAMABuffer[i] = DBL_MAX;
      return prev_calculated + 1;
    }
    InpExtFrAMABuffer[i] = _entry[0];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
