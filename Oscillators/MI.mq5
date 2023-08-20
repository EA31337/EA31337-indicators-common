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
 * Implements Relative Strength Index indicator.
 */

// Defines.
#define INDI_FULL_NAME "Relative Strength Index"
#define INDI_SHORT_NAME "MI"

// Indicator properties.
#ifdef __MQL__
#property copyright "2016-2023, EA31337 Ltd"
#property link "https://ea31337.github.io"
#property description INDI_FULL_NAME
//--
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 DodgerBlue
#property indicator_level1 27
#property indicator_level2 26.5
#property indicator_levelcolor DarkGray
#property version "1.000"
#endif

// Resource files.
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\MI.ex5"
#resource "\\Indicators\\Examples\\MI.ex5"
#endif

// Includes.
#include <EA31337-classes/Indicators/Indi_MassIndex.mqh>

// Input parameters.
input int InpPeriod = 9;                                    // First EMA period
input int InpPeriodSecond = 9;                              // Second EMA period
input int InpPeriodSum = 25;                                // Mass period
input int InpShift = 0;                                     // Shift
input ENUM_IDATA_SOURCE_TYPE InpSourceType = IDATA_BUILTIN; // Source type

// Global indicator buffers.
double InpExtMIBuffer[];

// Global variables.
Indi_MassIndex *indi;

/**
 * Init event handler function.
 */
void OnInit() {
  // Initialize indicator buffers.
  SetIndexBuffer(0, InpExtMIBuffer);
  // Initialize indicator.
  IndiMassIndexParams _indi_params(::InpPeriod, ::InpPeriodSecond,
                                   ::InpPeriodSum, ::InpShift);
  indi = new Indi_MassIndex(_indi_params /* , InpSourceType */);
  // Name for labels.
  // @todo: Use serialized string of _indi_params.
  string short_name = StringFormat("%s(%d,%d,%d)", indi.GetName(), ::InpPeriod,
                                   ::InpPeriodSecond, ::InpPeriodSum);
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  // Sets first bar from what index will be drawn
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN,
                      fmax3(0, ::InpPeriod, ::InpPeriodSecond));
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
  if (rates_total < fmax3(0, ::InpPeriod, ::InpPeriodSecond)) {
    return (0);
  }
  // Initialize calculations.
  start = prev_calculated == 0 ? fmax3(0, ::InpPeriod, ::InpPeriodSecond)
                               : prev_calculated - 1;
  // Main calculations.
  for (i = start; i < rates_total && !IsStopped(); i++) {
    IndicatorDataEntry _entry = indi[rates_total - i];
    if (!indi.Get<bool>(
            STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      return prev_calculated + 1;
    }
    InpExtMIBuffer[i] = _entry[0];
  }
  // Returns new prev_calculated.
  return (rates_total);
}

/**
 * Deinit event handler function.
 */
void OnDeinit(const int reason) { delete indi; }
