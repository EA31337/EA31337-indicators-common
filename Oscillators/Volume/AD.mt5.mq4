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
#property indicator_buffers 1
#property indicator_color1 LightSeaGreen
#property indicator_label1 "AD"
#endif

// Includes EA31337 framework.
#include <EA31337-classes/Indicator.enum.h>

// Includes MQL5 version of indicator.
#include <../Indicators\Examples\AD.mq5>
