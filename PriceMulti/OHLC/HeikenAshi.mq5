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
 * Implements Heiken Ashi indicator.
 */

// Defines.
#define INDI_FULL_NAME "HeikenAshi"
#define INDI_SHORT_NAME "HA"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 1
#property indicator_type1 DRAW_COLOR_CANDLES
#property indicator_color1 DodgerBlue, Red
#property indicator_label1 INDI_SHORT_NAME
#property version "1.000"
#endif

// Resource files.
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\Heiken_Ashi.ex5"
#resource "\\Indicators\\Examples\\Heiken_Ashi.ex5"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_HeikenAshi.mqh>

// Input parameters.
input int InpShift = 0;                                     // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double InpExtOBuffer[];
double InpExtHBuffer[];
double InpExtLBuffer[];
double InpExtCBuffer[];
double InpExtColorBuffer[];

// Global variables.
Indi_HeikenAshi *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, InpExtOBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, InpExtHBuffer, INDICATOR_DATA);
  SetIndexBuffer(2, InpExtLBuffer, INDICATOR_DATA);
  SetIndexBuffer(3, InpExtCBuffer, INDICATOR_DATA);
  SetIndexBuffer(4, InpExtColorBuffer, INDICATOR_COLOR_INDEX);
  // Initialize indicator.
  IndiHeikenAshiParams _indi_params(::InpShift);
  indi = new Indi_HeikenAshi(_indi_params, InpSourceType);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s", indi.GetName());
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  // Use DBL_MAX for empty values.
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);
  // Sets indicator shift.
  PlotIndexSetInteger(0, PLOT_SHIFT, ::InpShift);
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
  // Initialize calculations.
  start = prev_calculated == 0 ? 0 : prev_calculated - 1;
  if (prev_calculated == 0) {
    for (i = 0; i <= start; i++) {
      InpExtLBuffer[0] = low[0];
      InpExtHBuffer[0] = high[0];
      InpExtOBuffer[0] = open[0];
      InpExtCBuffer[0] = close[0];
    }
  }
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      return prev_calculated + 1;
    }
    InpExtLBuffer[i] = _entry[(int)HA_LOW];
    InpExtHBuffer[i] = _entry[(int)HA_HIGH];
    InpExtOBuffer[i] = _entry[(int)HA_OPEN];
    InpExtCBuffer[i] = _entry[(int)HA_CLOSE];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
