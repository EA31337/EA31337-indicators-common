//+------------------------------------------------------------------+
//|                                               EA31337 indicators |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Implements Accelerator/Decelerator indicator.
 */

// Defines.
#define INDI_FULL_NAME "Accelerator/Decelerator"
#define INDI_SHORT_NAME "AC"

// Indicator properties.
#property copyright "2016-2021, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots 1
#property indicator_type1 DRAW_COLOR_HISTOGRAM
#property indicator_color1 Green, Red
#property indicator_width1 2
#property indicator_label1 INDI_SHORT_NAME

// Includes.
#include <EA31337-classes/Indicators/Indi_AC.mqh>

// Input parameters.
input int InpShift = 0;                                     // Indicator shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtACBuffer[];

// Global variables.
Indi_AC *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtACBuffer, INDICATOR_DATA);
  // Set accuracy.
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 2);
  // Initialize indicator.
  IndiACParams _indi_params(::InpShift);
  _indi_params.SetDataSourceType(InpSourceType);
  indi = new Indi_AC(_indi_params);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s", indi.GetName());
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);
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
  // Initialize calculations.
  start = prev_calculated;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    bool _is_ready = indi.Get<bool>(
        STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY));
    ExtACBuffer[i] = _is_ready ? _entry[0] : 0;
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
