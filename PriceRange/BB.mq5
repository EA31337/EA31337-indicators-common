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
 * Implements Bollinger Bands indicator.
 */

// Defines.
#define INDI_FULL_NAME "Bollinger Bands"
#define INDI_SHORT_NAME "BB"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 3
#property indicator_type1 DRAW_LINE
#property indicator_color1 LightSeaGreen
#property indicator_type2 DRAW_LINE
#property indicator_color2 LightSeaGreen
#property indicator_type3 DRAW_LINE
#property indicator_color3 LightSeaGreen
#property indicator_label1 "Bands middle"
#property indicator_label2 "Bands upper"
#property indicator_label3 "Bands lower"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_Bands.mqh>

// Input parameters.
input int InpBandsPeriod = 20;                               // Period
input int InpBandsShift = 0;                                 // Shift
input double InpBandsDeviations = 2.0;                       // Deviation
input ENUM_APPLIED_PRICE InpBandsAppliedPrice = PRICE_CLOSE; // Applied price
input int InpShift = 0;                                      // Indicator shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN;  // Source type

// Global indicator buffers.
double ExtMLBuffer[];
double ExtTLBuffer[];
double ExtBLBuffer[];
double ExtStdDevBuffer[];

// Global variables.
Indi_Bands *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtMLBuffer);
  SetIndexBuffer(1, ExtTLBuffer);
  SetIndexBuffer(2, ExtBLBuffer);
  // Initialize indicator.
  IndiBandsParams _indi_params(::InpBandsPeriod, ::InpBandsDeviations,
                               ::InpBandsShift, ::InpBandsAppliedPrice,
                               ::InpShift);
  indi = new Indi_Bands(_indi_params, InpSourceType);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(%d, %f)", indi.GetName(),
                                   ::InpBandsPeriod, ::InpBandsDeviations);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, DBL_MAX);
  // Number of digits of indicator value.
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits + 1);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpBandsPeriod);
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
  if (rates_total < InpBandsPeriod) {
    return (0);
  }
  // Initialize calculations.
  start = prev_calculated == 0 ? InpBandsPeriod : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      // ExtMLBuffer[i] = DBL_MAX;
      return prev_calculated + 1;
    }
    ExtMLBuffer[i] = _entry[(int)BAND_BASE];
    ExtTLBuffer[i] = _entry[(int)BAND_UPPER];
    ExtBLBuffer[i] = _entry[(int)BAND_LOWER];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
