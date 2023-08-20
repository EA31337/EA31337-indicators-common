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
 * Implements Bill Williams' Aligator indicator.
 */

// Defines.
#define INDI_FULL_NAME "Bill Williams' Aligator"
#define INDI_SHORT_NAME "Aligator"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_label1 "Jaws"
#property indicator_label2 "Teeth"
#property indicator_label3 "Lips"
#property version "1.000"
#endif

// Resource files.
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\Alligator.ex5"
#resource "\\Indicators\\Examples\\Alligator.ex5"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_Alligator.mqh>

// Input parameters.
input int InpJawsPeriod = 13;                 // Jaws period
input int InpJawsShift = 8;                   // Jaws shift
input int InpTeethPeriod = 8;                 // Teeth period
input int InpTeethShift = 5;                  // Teeth shift
input int InpLipsPeriod = 5;                  // Lips period
input int InpLipsShift = 3;                   // Lips shift
input ENUM_MA_METHOD InpMAMethod = MODE_SMMA; // Moving average method
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_MEDIAN;    // Applied price
input int InpShift = 0;                                     // Indicator shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtJaws[];
double ExtTeeth[];
double ExtLips[];

// Global variables.
Indi_Alligator *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtJaws, INDICATOR_DATA);
  SetIndexBuffer(1, ExtTeeth, INDICATOR_DATA);
  SetIndexBuffer(2, ExtLips, INDICATOR_DATA);
  // Initialize indicator.
  IndiAlligatorParams _indi_params(
      ::InpJawsPeriod, ::InpJawsShift, ::InpTeethPeriod, ::InpTeethShift,
      ::InpLipsPeriod, ::InpLipsShift, ::InpMAMethod, ::InpAppliedPrice,
      ::InpShift);
  indi = new Indi_Alligator(_indi_params /* , InpSourceType */);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name =
      StringFormat("%s(%d, %d, %d)", indi.GetName(), InpJawsPeriod,
                   InpTeethPeriod, InpLipsPeriod);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  // Sets first bar from what index will be drawn.
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpJawsPeriod - 1);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpTeethPeriod - 1);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, InpLipsPeriod - 1);
  // Line shifts when drawing.
  PlotIndexSetInteger(0, PLOT_SHIFT, InpJawsShift);
  PlotIndexSetInteger(1, PLOT_SHIFT, InpTeethShift);
  PlotIndexSetInteger(2, PLOT_SHIFT, InpLipsShift);
  // Name for DataWindow.
  PlotIndexSetString(0, PLOT_LABEL, "Jaws=" + string(InpJawsPeriod));
  PlotIndexSetString(1, PLOT_LABEL, "Teeth=" + string(InpTeethPeriod));
  PlotIndexSetString(2, PLOT_LABEL, "Lips=" + string(InpLipsPeriod));
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
  if (rates_total <
      fmax4(0, ::InpJawsPeriod, ::InpTeethPeriod, ::InpLipsPeriod)) {
    return (0);
  }
  // Initialize calculations.
  start = prev_calculated == 0
              ? fmax4(0, ::InpJawsPeriod, ::InpTeethPeriod, ::InpLipsPeriod)
              : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      ExtJaws[i] = DBL_MAX;
      ExtTeeth[i] = DBL_MAX;
      ExtLips[i] = DBL_MAX;
      continue;
      // return prev_calculated + 1;
    }
    ExtJaws[i] = _entry[0];
    ExtTeeth[i] = _entry[1];
    ExtLips[i] = _entry[2];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
