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
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64a_vconv
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: Cyclone IV and Cyclone 10 LP devices
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: vh/n64a_params.vh
//
// Revision: 2.1
// Features: conversion RGB to YPbPr on demand
//           outputs 8bit vectors for ADV7125 / ADV7123
//
//////////////////////////////////////////////////////////////////////////////////

module n64a_vconv(
  VCLK,

  nEN_YPbPr,    // enables color transformation on '0'

  vdata_i,
  vdata_o
);

`include "vh/n64a_params.vh"

localparam coeff_width = 20;

input VCLK;

input nEN_YPbPr;

input  [`VDATA_O_FU_SLICE] vdata_i;
output [`VDATA_O_FU_SLICE] vdata_o;


// pre-assignments

wire                        [3:0] S_i = vdata_i[`VDATA_O_SY_SLICE];
wire unsigned [color_width_o-1:0] R_i = vdata_i[`VDATA_O_RE_SLICE];
wire unsigned [color_width_o-1:0] G_i = vdata_i[`VDATA_O_GR_SLICE];
wire unsigned [color_width_o-1:0] B_i = vdata_i[`VDATA_O_BL_SLICE];

reg                        [3:0]  S_o = 4'h0;
reg unsigned [color_width_o-1:0] V1_o = {color_width_o{1'b0}};
reg unsigned [color_width_o-1:0] V2_o = {color_width_o{1'b0}};
reg unsigned [color_width_o-1:0] V3_o = {color_width_o{1'b0}};


// start of rtl

// delay Sync along with the pipeline stages of the video conversion

reg [3:0] S[0:2];
reg [color_width_o-1:0] R[0:2], G[0:2], B[0:2];

integer i;
initial begin
  for (i = 0; i < 3; i = i+1) begin
    S[i] = 4'h0;
    R[i] = {color_width_o{1'b0}};
    G[i] = {color_width_o{1'b0}};
    B[i] = {color_width_o{1'b0}};
  end
end

always @(posedge VCLK) begin
  for (i = 1; i < 3; i = i+1) begin
    S[i] <= S[i-1];
    R[i] <= R[i-1];
    G[i] <= G[i-1];
    B[i] <= B[i-1];
  end

  S[0] <= S_i;
  R[0] <= R_i;
  G[0] <= G_i;
  B[0] <= B_i;
end


// Transformation to YPbPr
// =======================

// Transformation Rec. 601:
// Y  =  0.299    R + 0.587    G + 0.114   B
// Pb = -0.168736 R - 0.331264 G + 0.5     B + 2^9
// Pr =       0.5 R - 0.418688 G - 0.08132 B + 2^9

localparam msb_vo = color_width_o+coeff_width-1;  // position of MSB after altmult_add (Pb and Pr neg. parts are shifted to that)
localparam lsb_vo = coeff_width;                // position of LSB after altmult_add (Pb and Pr neg. parts are shifted to that)


localparam fyr = 20'd313524;
localparam fyg = 20'd615514;
localparam fyb = 20'd119538;

reg [color_width_o+coeff_width+1:0] Y_addmult;
reg [color_width_o+coeff_width-1:0] R4Y_scaled;
reg [color_width_o+coeff_width-1:0] G4Y_scaled;
reg [color_width_o+coeff_width-1:0] B4Y_scaled;

always @(posedge VCLK) begin
  Y_addmult  <= R4Y_scaled + G4Y_scaled + B4Y_scaled;
  R4Y_scaled <= fyr * (* multstyle = "dsp" *) R[0];
  G4Y_scaled <= fyg * (* multstyle = "dsp" *) G[0];
  B4Y_scaled <= fyb * (* multstyle = "dsp" *) B[0];
end


localparam fpbr = 20'd353865;
localparam fpbg = 20'd694711;

reg [color_width_o+coeff_width  :0] Pb_nPart_addmult;
reg [color_width_o+coeff_width-1:0] R4Pb_scaled;
reg [color_width_o+coeff_width-1:0] G4Pb_scaled;

always @(posedge VCLK) begin
  Pb_nPart_addmult <= R4Pb_scaled + G4Pb_scaled;
  R4Pb_scaled      <= fpbr * (* multstyle = "dsp" *) R[0];
  G4Pb_scaled      <= fpbg * (* multstyle = "dsp" *) G[0];
end


wire [color_width_o+1:0] Pb_addmult = {1'b0,B[2],1'b0}- Pb_nPart_addmult[msb_vo+1:lsb_vo-1];


localparam fprg = 20'd878052;
localparam fprb = 20'd170524;

reg [color_width_o+coeff_width  :0] Pr_nPart_addmult;
reg [color_width_o+coeff_width-1:0] G4Pr_scaled;
reg [color_width_o+coeff_width-1:0] B4Pr_scaled;

always @(posedge VCLK) begin
  Pr_nPart_addmult <= G4Pr_scaled + B4Pr_scaled;
  G4Pr_scaled      <= fprg * (* multstyle = "dsp" *) G[0];
  B4Pr_scaled      <= fprb * (* multstyle = "dsp" *) B[0];
end

wire [color_width_o+1:0] Pr_addmult = {1'b0,R[2],1'b0}- Pr_nPart_addmult[msb_vo+1:lsb_vo-1];


// get final results:

wire [color_width_o-1:0]  Y_tmp =  Y_addmult[msb_vo:lsb_vo]     +  Y_addmult[lsb_vo-1];
wire [color_width_o  :0] Pb_tmp = Pb_addmult[color_width_o+1:1] + Pb_addmult[0];
wire [color_width_o  :0] Pr_tmp = Pr_addmult[color_width_o+1:1] + Pr_addmult[0];


always @(posedge VCLK) begin
  if (!nEN_YPbPr) begin
     S_o <= S[2];
    V1_o <= {~Pr_tmp[color_width_o],Pr_tmp[color_width_o-1:1]};
    V2_o <= Y_tmp;
    V3_o <= {~Pb_tmp[color_width_o],Pb_tmp[color_width_o-1:1]};
  end else begin
     S_o <= S_i;
    V1_o <= R_i;
    V2_o <= G_i;
    V3_o <= B_i;
  end
end


// post-assignment

assign vdata_o = {S_o,V1_o,V2_o,V3_o};

endmodule 