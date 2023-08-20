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
 * Implements Envelopes indicator.
 */

// Defines.
#define INDI_FULL_NAME "Envelopes"
#define INDI_SHORT_NAME "Envelopes"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_label1 "Upper band"
#property indicator_label2 "Lower band"
#property version "1.000"
#endif

// Resource files.
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\Envelopes.ex5"
#resource "\\Indicators\\Examples\\Envelopes.ex5"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_Envelopes.mqh>

// Input parameters.
input int InpMAPeriod = 14;                                 // Period
input int InpMAShift = 0;                                   // Shift
input ENUM_MA_METHOD InpMAMethod = MODE_SMA;                // Method
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE;     // Applied price
input double InpDeviation = 0.1;                            // Deviation
input int InpShift = 0;                                     // Indicator shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtUpBuffer[];
double ExtDownBuffer[];
double ExtMABuffer[];

// Global variables.
Indi_Envelopes *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtUpBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, ExtDownBuffer, INDICATOR_DATA);
  SetIndexBuffer(2, ExtMABuffer, INDICATOR_CALCULATIONS);
  // Initialize indicator.
  IndiEnvelopesParams _indi_params(::InpMAPeriod, ::InpMAShift, ::InpMAMethod,
                                   ::InpAppliedPrice, ::InpDeviation,

                                   ::InpShift);
  indi = new Indi_Envelopes(_indi_params /* , InpSourceType */);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name =
      StringFormat("%s(%d, %f)", indi.GetName(), ::InpMAPeriod, ::InpDeviation);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, DBL_MAX);
  // Number of digits of indicator value.
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 1);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpMAPeriod);
  // Sets indicator shift.
  PlotIndexSetInteger(0, PLOT_SHIFT, InpShift);
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
  if (rates_total < InpMAPeriod) {
    return (0);
  }
  // Initialize calculations.
  start = prev_calculated == 0 ? InpMAPeriod : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      // ExtMLBuffer[i] = DBL_MAX;
      return prev_calculated + 1;
    }
    ExtUpBuffer[i] = _entry[(int)LINE_UPPER];
    ExtDownBuffer[i] = _entry[(int)LINE_LOWER];
    ExtMABuffer[i] = _entry[(int)LINE_MAIN];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
