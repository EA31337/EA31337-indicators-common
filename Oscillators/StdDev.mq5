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
 * Implements Standard Deviation (StdDev) indicator.
 */

// Defines.
#define INDI_FULL_NAME "Standard Deviation"
#define INDI_SHORT_NAME "StdDev"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 MediumSeaGreen
#property indicator_style1 STYLE_SOLID
#property indicator_label1 INDI_SHORT_NAME
#property version "1.000"
#endif

// Resource files.
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\StdDev.ex5"
#resource "\\Indicators\\Examples\\StdDev.ex5"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_StdDev.mqh>

// Input parameters.
input int InpStdDevPeriod = 20;                             // Period
input int InpStdDevShift = 0;                               // Shift
input ENUM_MA_METHOD InpMAMethod = MODE_SMA;                // Method
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_MEDIAN;    // Applied price
input int InpShift = 0;                                     // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtStdDevBuffer[];

// Global variables.
Indi_StdDev *indi;

/**
 * Init event handler function.
 */
int OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtStdDevBuffer);
  // Initialize indicator.
  IndiStdDevParams _indi_params(::InpStdDevPeriod, ::InpStdDevShift,
                                ::InpMAMethod, ::InpAppliedPrice, ::InpShift);
  indi = new Indi_StdDev(_indi_params /* , InpSourceType */);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(%d)", indi.GetName(), ::InpStdDevPeriod);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, DBL_MAX);
  return INIT_SUCCEEDED;
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
  start = prev_calculated == 0 ? InpStdDevPeriod - 1 : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      return prev_calculated + 1;
    }
    ExtStdDevBuffer[i] = _entry[0];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
