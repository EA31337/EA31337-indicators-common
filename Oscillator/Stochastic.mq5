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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Implements Stochastic indicator.
 */

// Defines.
#define INDI_FULL_NAME "Stochastic"
#define INDI_SHORT_NAME "Stoch"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 2
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_color1 LightSeaGreen
#property indicator_color2 Red
#property indicator_style2 STYLE_DOT
#property indicator_label1 "K period"
#property indicator_label2 "D period"
#property indicator_label2 "Slowing"
#property version "1.000"
#endif

// Resource files.
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\Stochastic.ex5"
#resource "\\Indicators\\Examples\\Stochastic.ex5"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_Stochastic.mqh>

// Input parameters.
input int InpKPeriod = 5;                    // K period
input int InpDPeriod = 3;                    // D period
input int InpSlowing = 3;                    // Slowing
input ENUM_MA_METHOD InpMaMethod = MODE_SMA; // MA Method
input ENUM_STO_PRICE InpPriceField =
    STO_LOWHIGH;        // Stochastic calculation method
input int InpShift = 0; // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtMainBuffer[];
double ExtSignalBuffer[];
double ExtHighesBuffer[];
double ExtLowesBuffer[];

// Global variables.
Indi_Stochastic *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtMainBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, ExtSignalBuffer, INDICATOR_DATA);
  SetIndexBuffer(2, ExtHighesBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(3, ExtLowesBuffer, INDICATOR_CALCULATIONS);
  // Initialize indicator.
  IndiStochParams _indi_params(::InpKPeriod, ::InpDPeriod, ::InpSlowing,
                               ::InpMaMethod, ::InpPriceField, ::InpShift);
  indi = new Indi_Stochastic(_indi_params, InpSourceType);
  // Name for DataWindow and indicator subwindow label.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(%d,%d,%d)", indi.GetName(), ::InpKPeriod,
                                   ::InpDPeriod, ::InpSlowing);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);

  // Set accuracy.
  IndicatorSetInteger(INDICATOR_DIGITS, 2);
  // Set levels.
  IndicatorSetInteger(INDICATOR_LEVELS, 2);
  IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 20);
  IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, 80);
  // Set maximum and minimum for subwindow.
  IndicatorSetDouble(INDICATOR_MINIMUM, 0);
  IndicatorSetDouble(INDICATOR_MAXIMUM, 100);
  PlotIndexSetString(0, PLOT_LABEL, "Main");
  PlotIndexSetString(1, PLOT_LABEL, "Signal");
  // Sets first bar from what index will be drawn.
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpKPeriod + InpSlowing - 2);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpKPeriod + InpDPeriod);

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
  if (rates_total < fmax4(0, ::InpKPeriod, ::InpDPeriod, ::InpSlowing)) {
    return (0);
  }
  // Initialize calculations.
  start = prev_calculated == 0
              ? fmax4(0, ::InpKPeriod, ::InpDPeriod, ::InpSlowing)
              : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      ExtMainBuffer[i] = DBL_MAX;
      ExtSignalBuffer[i] = DBL_MAX;
      ExtHighesBuffer[i] = DBL_MAX;
      ExtLowesBuffer[i] = DBL_MAX;
      return prev_calculated + 1;
    }
    ExtMainBuffer[i] = _entry[(int)LINE_MAIN];
    ExtSignalBuffer[i] = _entry[(int)LINE_SIGNAL];
    // ExtHighesBuffer
    // ExtLowesBuffer
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
