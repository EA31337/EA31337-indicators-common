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
 * Implements Awesome Oscillator indicator.
 */

// Defines.
#define INDI_FULL_NAME "Awesome Oscillator"
#define INDI_SHORT_NAME "AO"
// Indicator defines.
#define FAST_PERIOD 5
#define SLOW_PERIOD 34

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 1
#property indicator_type1 DRAW_COLOR_HISTOGRAM
#property indicator_color1 Green, Red
#property indicator_width1 1
#property indicator_label1 INDI_SHORT_NAME
#property version "1.000"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_AO.mqh>

// Input parameters.
input int InpShift = 0;                                     // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtAOBuffer[];
double ExtColorBuffer[];
double ExtFastBuffer[];
double ExtSlowBuffer[];

// Global variables.
Indi_AO *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtAOBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, ExtColorBuffer, INDICATOR_COLOR_INDEX);
  SetIndexBuffer(2, ExtFastBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(3, ExtSlowBuffer, INDICATOR_CALCULATIONS);
  // Initialize indicator.
  IndiAOParams _indi_params(::InpShift);
  indi = new Indi_AO(_indi_params, InpSourceType);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s", indi.GetName());
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, DBL_MAX);
  PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, DBL_MAX);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);
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
  if (rates_total < fmax3(0, FAST_PERIOD, SLOW_PERIOD)) {
    return (0);
  }
  // Initialize calculations.
  int max_modes =
      indi.Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES));
  start = prev_calculated == 0 ? fmax3(0, FAST_PERIOD, SLOW_PERIOD)
                               : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      ExtAOBuffer[i] = DBL_MAX;
      ExtColorBuffer[i] = DBL_MAX;
      return prev_calculated + 1;
    }
    ExtAOBuffer[i] = _entry[0];
    ExtColorBuffer[i] = max_modes > 1 ? _entry[1] : DBL_MAX;
    ExtFastBuffer[i] = max_modes > 2 ? _entry[2] : DBL_MAX;
    ExtSlowBuffer[i] = max_modes > 3 ? _entry[3] : DBL_MAX;
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
