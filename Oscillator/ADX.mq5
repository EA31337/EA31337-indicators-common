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
 * Implements Average Directional Movement Index (ADX).
 */

// Defines.
#define INDI_FULL_NAME "Average Directional Movement Index"
#define INDI_SHORT_NAME "ADX"

// Indicator properties.
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots 3
#property indicator_type1 DRAW_LINE
#property indicator_color1 LightSeaGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2 DRAW_LINE
#property indicator_color2 YellowGreen
#property indicator_style2 STYLE_DOT
#property indicator_width2 1
#property indicator_type3 DRAW_LINE
#property indicator_color3 Wheat
#property indicator_style3 STYLE_DOT
#property indicator_width3 1
#property indicator_label1 "ADX"
#property indicator_label2 "+DI"
#property indicator_label3 "-DI"

// Includes.
#include <EA31337-classes/Indicators/Indi_ADX.mqh>

// Input parameters.
input int InpADXPeriod = 14;                                 // Period
input ENUM_APPLIED_PRICE InpADXAppliedPrice = PRICE_TYPICAL; // Applied Price
input int InpShift = 0;                                      // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN;  // Source type

// Global indicator buffers.
double ExtADXBuffer[];
double ExtPDIBuffer[];
double ExtNDIBuffer[];
double ExtPDBuffer[];
double ExtNDBuffer[];
double ExtTmpBuffer[];

// Global variables.
Indi_ADX *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtADXBuffer);
  SetIndexBuffer(1, ExtPDIBuffer);
  SetIndexBuffer(2, ExtNDIBuffer);
  SetIndexBuffer(3, ExtPDBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(4, ExtNDBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(5, ExtTmpBuffer, INDICATOR_CALCULATIONS);
  // Initialize indicator.
  IndiADXParams _indi_params(::InpADXPeriod, ::InpADXAppliedPrice, ::InpShift);
  indi = new Indi_ADX(_indi_params, InpSourceType);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(%d)", indi.GetName(), InpADXPeriod);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpADXPeriod << 1);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpADXPeriod);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, InpADXPeriod);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
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
  if (rates_total < fmax(0, InpADXPeriod)) {
    return (0);
  }
  // Initialize calculations.
  start =
      prev_calculated == 0 ? fmax(0, InpADXPeriod - 1) : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      ExtADXBuffer[i] = 0.0;
      return prev_calculated + 1;
    }
    ExtADXBuffer[i] = _entry[0];
    ExtPDIBuffer[i] = _entry[1];
    ExtNDIBuffer[i] = _entry[2];
    ExtPDBuffer[i] = _entry[3];
    ExtNDBuffer[i] = _entry[4];
    ExtTmpBuffer[i] = _entry[5];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
