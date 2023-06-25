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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Implements MGator Oscillator indicator.
 *
 * Based on 3 non-shifted moving averages.
 */

// Defines.
#define INDI_FULL_NAME "Gator Oscillator"
#define INDI_SHORT_NAME "Gator"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots 2
#property indicator_type1 DRAW_COLOR_HISTOGRAM
#property indicator_type2 DRAW_COLOR_HISTOGRAM
#property indicator_color1 Green, Red
#property indicator_color2 Green, Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_label1 "Gator Upper"
#property indicator_label2 "Gator Lower"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_Gator.mqh>

// Input parameters.
input int InpJawsPeriod = 13;                 // Jaws period
input int InpJawsShift = 8;                   // Jaws shift
input int InpTeethPeriod = 8;                 // Teeth period
input int InpTeethShift = 5;                  // Teeth shift
input int InpLipsPeriod = 5;                  // Lips period
input int InpLipsShift = 3;                   // Lips shift
input ENUM_MA_METHOD InpMAMethod = MODE_SMMA; // Moving average method
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_MEDIAN;    // Applied price
input int InpShift = 0;                                     // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double ExtUpperBuffer[];
double ExtUpColorsBuffer[];
double ExtLowerBuffer[];
double ExtLoColorsBuffer[];

// Global variables.
Indi_Gator *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, ExtUpperBuffer, INDICATOR_DATA);
  SetIndexBuffer(1, ExtUpColorsBuffer, INDICATOR_COLOR_INDEX);
  SetIndexBuffer(2, ExtLowerBuffer, INDICATOR_DATA);
  SetIndexBuffer(3, ExtLoColorsBuffer, INDICATOR_COLOR_INDEX);
  // Initialize indicator.
  IndiGatorParams _indi_params(::InpJawsPeriod, ::InpJawsShift,
                               ::InpTeethPeriod, ::InpTeethShift,
                               ::InpLipsPeriod, ::InpLipsShift, ::InpMAMethod,
                               ::InpAppliedPrice, ::InpShift);
  indi = new Indi_Gator(_indi_params, InpSourceType);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name =
      StringFormat("%s(%d,%d,%d)", indi.GetName(), ::InpJawsPeriod,
                   ::InpTeethPeriod, ::InpLipsPeriod);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
  PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
  // Sets first bar from what index will be drawn.
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpTeethShift + InpTeethPeriod);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpLipsShift + InpLipsPeriod);
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
      return prev_calculated + 1;
    }
    ExtUpperBuffer[i] = _entry[0];
    ExtUpColorsBuffer[i] = _entry[1];
    ExtLowerBuffer[i] = _entry[2];
    ExtLoColorsBuffer[i] = _entry[3];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
