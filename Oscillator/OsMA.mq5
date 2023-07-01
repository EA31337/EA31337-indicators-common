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
 * Implements Moving Averages Convergence/Divergence indicator.
 */

// Defines.
#define INDI_FULL_NAME "Moving Averages Convergence/Divergence"
#define INDI_SHORT_NAME "OsMA"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots 1
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_color1 Silver
#property indicator_width1 2
#property indicator_label1 INDI_SHORT_NAME
#property version "1.000"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_OsMA.mqh>

// Input parameters.
input int InpFastEMAPeriod = 12;                            // Fast EMA period
input int InpSlowEMAPeriod = 26;                            // Slow EMA period
input int InpSignalSMAPeriod = 9;                           // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE;     // Applied price
input int InpShift = 0;                                     // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtOsMABuffer[];

// Global variables.
Indi_OsMA *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtOsMABuffer, INDICATOR_DATA);
  // Initialize indicator.
  IndiOsMAParams _indi_params(::InpFastEMAPeriod, ::InpSlowEMAPeriod,
                              ::InpSignalSMAPeriod, ::InpAppliedPrice,
                              ::InpShift);
  indi = new Indi_OsMA(_indi_params, InpSourceType);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name =
      StringFormat("%s(%d,%d,%d)", indi.GetName(), ::InpFastEMAPeriod,
                   ::InpSlowEMAPeriod, ::InpSignalSMAPeriod);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, DBL_MAX);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN,
                      fmax(InpFastEMAPeriod, InpSlowEMAPeriod) - 1);
  // Sets indicator shift.
  PlotIndexSetInteger(0, PLOT_SHIFT, InpShift);
  // Drawing settings (MQL4).
  SetIndexStyle(0, DRAW_HISTOGRAM);
  SetIndexStyle(1, DRAW_LINE);
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
  start = prev_calculated == 0 ? fmax4(0, ::InpFastEMAPeriod,
                                       ::InpSlowEMAPeriod, ::InpSignalSMAPeriod)
                               : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      return prev_calculated + 1;
    }
    ExtOsMABuffer[i] = _entry[0];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
