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

// Indicator properties.
#ifdef __MQL__
#property indicator_separate_window
#property indicator_buffers 6

#property indicator_type1 DRAW_LINE
#property indicator_color1 LightSeaGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label1 "ADXW"

#property indicator_type2 DRAW_LINE
#property indicator_color2 YellowGreen
#property indicator_style2 STYLE_DOT
#property indicator_width2 1
#property indicator_label2 "+DI"

#property indicator_type3 DRAW_LINE
#property indicator_color3 Wheat
#property indicator_style3 STYLE_DOT
#property indicator_width3 1
#property indicator_label3 "-DI"
#property version "1.000"
#endif

// Includes the main code.
#include "ADXW.mq5"

// Resource files.
#property tester_indicator "::ADXW.mt5.ex4"
#resource "ADXW.mt5.ex4"
