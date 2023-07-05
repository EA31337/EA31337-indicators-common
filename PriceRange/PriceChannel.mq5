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
 * Implements Price Channel indicator.
 */

// Defines.
#define INDI_FULL_NAME "Price Channel"
#define INDI_SHORT_NAME "PriceChannel"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_type1 DRAW_FILLING
#property indicator_type2 DRAW_LINE
#property indicator_color1 DodgerBlue,Gray
#property indicator_color2 Blue
#property indicator_label1 "Channel upper;Channel lower"
#property indicator_label2 "Channel median"
#property version "1.000"
#endif

// Resource files.
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\Price_Channel.ex5"
#resource "\\Indicators\\Examples\\Price_Channel.ex5"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_PriceChannel.mqh>

// Input parameters.
input int InpPeriod = 22;                                   // Period
input int InpShift = 0;                                     // Indicator shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double InpExtHighBuffer[];
double InpExtLowBuffer[];
double InpExtMiddBuffer[];

// Global variables.
Indi_PriceChannel *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, InpExtHighBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, InpExtLowBuffer, INDICATOR_DATA);
  SetIndexBuffer(2, InpExtMiddBuffer, INDICATOR_DATA);
  // Initialize indicator.
  IndiPriceChannelParams _indi_params(::InpPeriod, ::InpShift);
  indi = new Indi_PriceChannel(_indi_params, InpSourceType);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(%d)", indi.GetName(), ::InpPeriod);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
  PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
  // Number of digits of indicator value.
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpPeriod);
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
  start = prev_calculated == 0 ? InpPeriod : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      return prev_calculated + 1;
    }
    InpExtHighBuffer[i] = _entry[0];
    InpExtLowBuffer[i] = _entry[1];
    InpExtMiddBuffer[i] = _entry[2];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
