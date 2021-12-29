//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
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
 * Implements Moving Average indicator.
 */

#property copyright "2016-2021, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description "Moving Average"

// Indicator properties.
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 DarkBlue
#property indicator_width1 1
#property indicator_label1 "MA"
#property indicator_applied_price PRICE_CLOSE

// Input parameters.
input int InpMAPeriod = 14;                  // MA period
input int InpMAShift = 0;                    // MA shift
input ENUM_MA_METHOD InpMAMethod = MODE_SMA; // MA method (smoothing type)
input ENUM_APPLIED_PRICE InpMAAppliedPrice = PRICE_OPEN; // Applied price
input int InpShift = 0;                                  // Indicator shift

// Includes.
#include <EA31337-classes/Indicators/Indi_MA.mqh>

// Global variables.
double MABuffer[];
Indi_MA *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  SetIndexBuffer(0, MABuffer, INDICATOR_DATA);
  // Initialize indicator.
  IndiMAParams _indi_params(::InpMAPeriod, ::InpMAShift, ::InpMAMethod,
                            ::InpMAAppliedPrice, ::InpShift);
  indi = new Indi_MA(_indi_params);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(%d)", indi.GetName(), InpMAPeriod);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 2 * InpMAPeriod - 1);
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
  if (rates_total < 2 * InpMAPeriod) {
    return (0);
  }
  // Initialize calculations.
  start = prev_calculated == 0 ? 2 * InpMAPeriod - 1 : prev_calculated - 1;
  if (prev_calculated == 0) {
    for (i = 0; i <= start; i++) {
      MABuffer[i] = close[i];
    }
  }
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    bool _is_ready = indi.Get<bool>(
        STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY));
    double _value = indi[i][0];
    MABuffer[i] = _is_ready ? indi[i][0] : close[i];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
