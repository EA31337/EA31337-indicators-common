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
 * Implements Adaptive Moving Average indicator.
 */

// Defines.
#define INDI_FULL_NAME "Adaptive Moving Average"
#define INDI_SHORT_NAME "AMA"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_label1 "AMA"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Red
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_applied_price PRICE_OPEN
#property version "1.000"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_AMA.mqh>

// Input parameters.
input int InpPeriod = 10;                                   // AMA period
input int InpFastPeriod = 2;                                // Fast EMA period
input int InpSlowPeriod = 30;                               // Slow EMA period
input int InpAMAShift = 0;                                  // AMA shift
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_OPEN;      // Applied price
input int InpShift = 0;                                     // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double InpExtAMABuffer[];

// Global variables.
Indi_AMA *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, InpExtAMABuffer, INDICATOR_DATA);
  // Initialize indicator.
  IndiAMAParams _indi_params(::InpPeriod, ::InpFastPeriod, ::InpSlowPeriod,
                             ::InpAMAShift, ::InpAppliedPrice, ::InpShift);
  indi = new Indi_AMA(_indi_params, InpSourceType);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name =
      StringFormat("%s(%d, %d, %d)", indi.GetName(), ::InpPeriod,
                   ::InpFastPeriod, ::InpSlowPeriod);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  // Use DBL_MAX for empty values.
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, DBL_MAX);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, ::InpPeriod);
  // Sets indicator shift.
  PlotIndexSetInteger(0, PLOT_SHIFT, ::InpPeriod);
  // Set accuracy.
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 1);
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
      InpExtAMABuffer[i] = close[i];
    }
  }
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      InpExtAMABuffer[i] = DBL_MAX;
      return prev_calculated + 1;
    }
    InpExtAMABuffer[i] = _entry[0];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
