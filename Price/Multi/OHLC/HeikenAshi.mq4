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

// Indicator properties.
#ifdef __MQL__
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 DodgerBlue
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_LINE
#property version "1.000"
#endif

// This will allow calling MT5 functions in MT4.
#define INDICATOR_LEGACY_VERSION_MT5
#define INDICATOR_LEGACY_VERSION_LONG // OHLC-based OnCalculate().
#define INDICATOR_LEGACY_VERSION_ACQUIRE_BUFFER                                \
  ACQUIRE_BUFFER5(InpExtOBuffer, InpExtHBuffer, InpExtLBuffer, InpExtCBuffer,  \
                  InpExtColorBuffer)
#define INDICATOR_LEGACY_VERSION_RELEASE_BUFFER                                \
  RELEASE_BUFFER5(InpExtOBuffer, InpExtHBuffer, InpExtLBuffer, InpExtCBuffer,  \
                  InpExtColorBuffer)
#include <EA31337-classes/IndicatorLegacy.h>

// Includes the main code.
#include "HeikenAshi.mq5"

// Resource files.
#property tester_indicator "::HeikenAshi.mt5.ex4"
#resource "HeikenAshi.mt5.ex4"
