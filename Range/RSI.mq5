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
 * Implements Relative Strength Index indicator.
 */

// Defines.
#define INDI_FULL_NAME "Relative Strength Index"
#define INDI_SHORT_NAME "RSI"

// Indicator properties.
#property copyright "2016-2021, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 30
#property indicator_level2 70
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 DodgerBlue

// Includes.
#include <EA31337-classes/Indicators/Indi_RSI.mqh>

// Input parameters.
input int InpRSIPeriod = 14;                                // Period
input ENUM_APPLIED_PRICE InpRSIAppliedPrice = PRICE_OPEN;   // Applied price
input int InpShift = 0;                                     // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtRSIBuffer[];

// Global variables.
Indi_RSI *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtRSIBuffer, INDICATOR_DATA);
  // Initialize indicator.
  IndiRSIParams _indi_params(::InpRSIPeriod, ::InpRSIAppliedPrice, ::InpShift);
  _indi_params.SetDataSourceType(InpSourceType);
  indi = new Indi_RSI(_indi_params);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(%d)", indi.GetName(), InpRSIPeriod);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 50.0);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpRSIPeriod);
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
  if (rates_total < fmax(0, InpRSIPeriod)) {
    return (0);
  }
  // Initialize calculations.
  start =
      prev_calculated == 0 ? fmax(0, InpRSIPeriod - 1) : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      ExtRSIBuffer[i] = 50.0;
      return prev_calculated + 1;
    }
    ExtRSIBuffer[i] = _entry[0];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
