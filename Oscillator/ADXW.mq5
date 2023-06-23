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
 * Implements Average Directional Movement Index (ADX) by Welles Wilder.
 */

// Defines.
#define INDI_FULL_NAME "Average Directional Movement Index by Welles Wilder"
#define INDI_SHORT_NAME "ADXW"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots 3
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_color1 LightSeaGreen
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_DOT
#property indicator_width2 1
#property indicator_color2 YellowGreen
#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_DOT
#property indicator_width3 1
#property indicator_color3 Wheat
#property indicator_label1 "ADX Wilder"
#property indicator_label2 "+DI"
#property indicator_label3 "-DI"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_ADXW.mqh>

// Input parameters.
input int InpADXWPeriod = 14;                                 // Period
input ENUM_APPLIED_PRICE InpADXWAppliedPrice = PRICE_TYPICAL; // Applied Price
input int InpShift = 0;                                       // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN;   // Source type

// Global indicator buffers.
double InpExtADXWBuffer[];
double InpExtPDIBuffer[];
double InpExtNDIBuffer[];
double InpExtPDSBuffer[];
double InpExtNDSBuffer[];
double InpExtPDBuffer[];
double InpExtNDBuffer[];
double InpExtTRBuffer[];
double InpExtATRBuffer[];
double InpExtDXBuffer[];

// Global variables.
Indi_ADXW *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, InpExtADXWBuffer);
  SetIndexBuffer(1, InpExtPDIBuffer);
  SetIndexBuffer(2, InpExtNDIBuffer);
  SetIndexBuffer(3, InpExtPDBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(4, InpExtNDBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(5, InpExtDXBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(6, InpExtTRBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(7, InpExtATRBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(8, InpExtPDSBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(9, InpExtNDSBuffer, INDICATOR_CALCULATIONS);
  // Initialize indicator.
  IndiADXWParams _indi_params(::InpADXWPeriod, ::InpADXWAppliedPrice,
                              ::InpShift);
  indi = new Indi_ADXW(_indi_params, InpSourceType);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(%d)", indi.GetName(), InpADXWPeriod);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpADXWPeriod << 1);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpADXWPeriod);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, InpADXWPeriod);
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
  if (rates_total < fmax(0, InpADXWPeriod)) {
    return (0);
  }
  // Initialize calculations.
  start =
      prev_calculated == 0 ? fmax(0, InpADXWPeriod - 1) : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      InpExtADXWBuffer[i] = DBL_MAX;
      InpExtPDIBuffer[i] = DBL_MAX;
      InpExtNDIBuffer[i] = DBL_MAX;
      InpExtPDSBuffer[i] = DBL_MAX;
      InpExtNDSBuffer[i] = DBL_MAX;
      InpExtPDBuffer[i] = DBL_MAX;
      InpExtNDBuffer[i] = DBL_MAX;
      InpExtTRBuffer[i] = DBL_MAX;
      InpExtATRBuffer[i] = DBL_MAX;
      InpExtDXBuffer[i] = DBL_MAX;
      return prev_calculated + 1;
    }
    InpExtADXWBuffer[i] = _entry[0];
    InpExtPDIBuffer[i] = _entry[1];
    InpExtNDIBuffer[i] = _entry[2];
    InpExtPDSBuffer[i] = _entry[3];
    InpExtNDSBuffer[i] = _entry[4];
    InpExtPDBuffer[i] = _entry[5];
    InpExtNDBuffer[i] = _entry[6];
    InpExtTRBuffer[i] = _entry[7];
    InpExtATRBuffer[i] = _entry[8];
    InpExtDXBuffer[i] = _entry[9];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
