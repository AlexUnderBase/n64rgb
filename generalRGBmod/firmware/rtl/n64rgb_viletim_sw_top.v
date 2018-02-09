//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2018 by Peter Bartmann <borti4938@gmx.de>
//
// N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//////////////////////////////////////////////////////////////////////////////////
//
// Company: Circuit-Board.de
// Engineer: borti4938
// (initial design file by Ikari_01)
//
// Module Name:    n64rgb_viletim_sw_top
// Project Name:   N64 RGB DAC Mod
// Target Devices: MaxII: EPM240T100C5
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: rtl/n64_vinfo_ext.v  (Rev. 1.0)
//               rtl/n64_deblur.v     (Rev. 1.1)
//               rtl/n64_vdemux.v     (Rev. 1.0)
//               vh/n64rgb_params.vh
//
// Revision: 1.5
// Features: BUFFERED version (no color shifting around edges)
//           de-blur with heuristic estimation (auto)
//           15bit color mode (5bit for each color) if wanted
//
//////////////////////////////////////////////////////////////////////////////////

module n64rgb_viletim_sw_top (
  // N64 Video Input
  nCLK,
  nDSYNC,
  D_i,

  nAutoDeBlur,
  nForceDeBlur_i1,  // feature to enable de-blur (0 = feature on, 1 = feature off)
  nForceDeBlur_i99, // (pin can be left unconnected for always on; weak pull-up assigned)
  n15bit_mode,      // 15bit color mode if input set to GND (weak pull-up assigned)

  // Video output
  nHSYNC,
  nVSYNC,
  nCSYNC,
  nCLAMP,

  R_o,     // red data vector
  G_o,     // green data vector
  B_o      // blue data vector
);

`include "vh/n64rgb_params.vh"

input                   nCLK;
input                   nDSYNC;
input [color_width-1:0] D_i;

input nAutoDeBlur;
input nForceDeBlur_i1;
input nForceDeBlur_i99;
input n15bit_mode;

output reg nHSYNC;
output reg nVSYNC;
output reg nCSYNC;
output reg nCLAMP;

output reg [color_width-1:0] R_o; // red data vector
output reg [color_width-1:0] G_o; // green data vector
output reg [color_width-1:0] B_o; // blue data vector


// start of rtl

// Part 1: connect switches
// ========================

reg nForceDeBlur, nDeBlurMan;

always @(negedge nCLK) begin
  nForceDeBlur <= &{~nAutoDeBlur,nForceDeBlur_i1,nForceDeBlur_i99};
  nDeBlurMan   <= nForceDeBlur_i1 & nForceDeBlur_i99;
end


// Part 2 - 4: RGB Demux with De-Blur Add-On
// =========================================
//
// short description of N64s RGB and sync data demux
// -------------------------------------------------
//
// pulse shapes and their realtion to each other:
// nCLK (~50MHz, Numbers representing negedge count)
// ---. 3 .---. 0 .---. 1 .---. 2 .---. 3 .---
//    |___|   |___|   |___|   |___|   |___|
// nDSYNC (~12.5MHz)                           .....
// -------.       .-------------------.
//        |_______|                   |_______
//
// more info: http://members.optusnet.com.au/eviltim/n64rgb/n64rgb.html
//

// Part 2: get all of the vinfo needed for further processing
// ==========================================================

wire [3:0] vinfo_pass;

n64_vinfo_ext get_vinfo(
  .nCLK(nCLK),
  .nDSYNC(nDSYNC),
  .Sync_pre(vdata_r[1][`VDATA_SY_SLICE]),
  .Sync_cur(vdata_r[0][`VDATA_SY_SLICE]),
  .vinfo_o(vinfo_pass)
);


// Part 3: DeBlur Management (incl. heuristic)
// ===========================================

wire ndo_deblur;

n64_deblur deblur_management(
  .nCLK(nCLK),
  .nDSYNC(nDSYNC),
  .nRST(1'b1),
  .vdata_pre(vdata_r[1]),
  .vdata_cur(vdata_r[0]),
  .deblurparams_i({vinfo_pass,nForceDeBlur,nDeBlurMan}),
  .ndo_deblur(ndo_deblur)
);


// Part 4: data demux
// ==================

wire [`VDATA_FU_SLICE] vdata_r[0:1];

n64_vdemux video_demux(
  .nCLK(nCLK),
  .nDSYNC(nDSYNC),
  .D_i(D_i),
  .demuxparams_i({vinfo_pass,ndo_deblur,n15bit_mode}),
  .vdata_r_0(vdata_r[0]),
  .vdata_r_1(vdata_r[1])
);


// assign final outputs
// --------------------

always @(posedge nDSYNC)
  {nVSYNC,nCLAMP,nHSYNC,nCSYNC,R_o,G_o,B_o} <= vdata_r[1];


endmodule
