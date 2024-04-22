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
 * Implements Fractals indicator.
 */

// Defines.
#define INDI_FULL_NAME "Fractals"
#define INDI_SHORT_NAME "Fractals"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_type1 DRAW_ARROW
#property indicator_type2 DRAW_ARROW
#property indicator_color1 Gray
#property indicator_color2 Gray
#property indicator_label1 "Fractal Up"
#property indicator_label2 "Fractal Down"
#property version "1.000"
#endif

// Resource files.
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\Fractals.ex5"
#resource "\\Indicators\\Examples\\Fractals.ex5"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_Fractals.mqh>

// Input parameters.
input int InpShift = 0;                                     // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtUpperBuffer[];
double ExtLowerBuffer[];

// Global variables.
Indi_Fractals *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtUpperBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, ExtLowerBuffer, INDICATOR_DATA);
  // Initialize indicator.
  IndiFractalsParams _indi_params(::InpShift);
  indi = new Indi_Fractals(_indi_params /* , InpSourceType */);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(", indi.GetName());
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  // Use DBL_MAX for empty values.
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 5);
  // Sets indicator shift.
  PlotIndexSetInteger(0, PLOT_SHIFT, 0);
  PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 0);
  PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 0);
  // Sets first bar from what index will be drawn.
  PlotIndexSetInteger(0, PLOT_ARROW, 217);
  PlotIndexSetInteger(1, PLOT_ARROW, 218);
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
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      ExtUpperBuffer[i] = EMPTY_VALUE;
      ExtLowerBuffer[i] = EMPTY_VALUE;
      return prev_calculated + 1;
    }
    ExtUpperBuffer[i] = _entry[(int)LINE_UPPER];
    ExtLowerBuffer[i] = _entry[(int)LINE_LOWER];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
