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
 * Implements Ichimoku Kinko Hyo indicator.
 */

// Defines.
#define INDI_FULL_NAME "Ichimoku Kinko Hyo"
#define INDI_SHORT_NAME "Ichimoku"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 4
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_FILLING
#property indicator_type4 DRAW_LINE
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 SandyBrown, Thistle
#property indicator_color4 Lime
#property indicator_label1 "Tenkan-sen"
#property indicator_label2 "Kijun-sen"
#property indicator_label3 "Senkou Span A;Senkou Span B"
#property indicator_label4 "Chikou Span"
#property version "1.000"
#endif

// Resource files.
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\Ichimoku.ex5"
#resource "\\Indicators\\Examples\\Ichimoku.ex5"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_Ichimoku.mqh>

// Input parameters.
input int InpTenkan = 9;                                    // Tenkan-sen
input int InpKijun = 26;                                    // Kijun-sen
input int InpSenkou = 52;                                   // Senkou Span B
input int InpShift = 0;                                     // Indicator shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtTenkanBuffer[];
double ExtKijunBuffer[];
double ExtSpanABuffer[];
double ExtSpanBBuffer[];
double ExtChikouBuffer[];

// Global variables.
Indi_Ichimoku *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtTenkanBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, ExtKijunBuffer, INDICATOR_DATA);
  SetIndexBuffer(2, ExtSpanABuffer, INDICATOR_DATA);
  SetIndexBuffer(3, ExtSpanBBuffer, INDICATOR_DATA);
  SetIndexBuffer(4, ExtChikouBuffer, INDICATOR_DATA);
  // Initialize indicator.
  IndiIchimokuParams _indi_params(::InpTenkan, ::InpKijun, ::InpSenkou,
                                  ::InpShift);
  indi = new Indi_Ichimoku(_indi_params /* , InpSourceType */);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(%d, %d, %d)", indi.GetName(),
                                   ::InpTenkan, ::InpKijun, ::InpSenkou);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  // Sets first bar from what index will be drawn.
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpTenkan);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpKijun);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, InpSenkou - 1);
  // Line shifts when drawing.
  PlotIndexSetInteger(2, PLOT_SHIFT, InpKijun);
  PlotIndexSetInteger(3, PLOT_SHIFT, -InpKijun);
  // Name for DataWindow.
  PlotIndexSetString(0, PLOT_LABEL, "Tenkan-sen(" + string(InpTenkan) + ")");
  PlotIndexSetString(1, PLOT_LABEL, "Kijun-sen(" + string(InpKijun) + ")");
  PlotIndexSetString(2, PLOT_LABEL,
                     "Senkou Span A;Senkou Span B(" + string(InpSenkou) + ")");
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
  if (rates_total < fmax4(0, ::InpTenkan, ::InpKijun, ::InpSenkou)) {
    return (0);
  }
  // Initialize calculations.
  start = prev_calculated == 0 ? fmax4(0, ::InpTenkan, ::InpKijun, ::InpSenkou)
                               : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      return prev_calculated + 1;
    }
    ExtTenkanBuffer[i] = _entry[(int)LINE_TENKANSEN];
    ExtKijunBuffer[i] = _entry[(int)LINE_KIJUNSEN];
    ExtSpanABuffer[i] = _entry[(int)LINE_SENKOUSPANA];
    ExtSpanBBuffer[i] = _entry[(int)LINE_SENKOUSPANB];
    ExtChikouBuffer[i] = _entry[(int)LINE_CHIKOUSPAN];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
