/*********************************************************************************
 *
 * This file is part of the N64 RGB/YPbPr DAC project.
 *
 * Copyright (C) 2016-2018 by Peter Bartmann <borti4938@gmx.de>
 *
 * N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *********************************************************************************
 *
 * n64.h
 *
 *  Created on: 06.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/


#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "n64.h"
#include "vd_driver.h"


#define COMMAND_HISTORY_LENGTH 1

extern char szText[];

alt_u8 use_filteraddon;

void print_ctrl_data(alt_u32* ctrl_data) {
  sprintf(szText,"Ctrl.Data: 0x%08x",(uint) *ctrl_data);
  vd_print_string(0, VD_HEIGHT-1, BACKGROUNDCOLOR_STANDARD, FONTCOLOR_NAVAJOWHITE, &szText[0]);
}

// ToDo: export function into logic to save some memory space if needed
cmd_t ctrl_data_to_cmd(alt_u32* ctrl_data)
{
  cmd_t cmd_new = CMD_NON;
  static cmd_t cmd_pre = CMD_NON;

  static alt_u8 cmd_history_cnt = COMMAND_HISTORY_LENGTH;

  switch (*ctrl_data & CTRL_GETALL_DIGITAL_MASK) {
    case BTN_OPEN_OSDMENU:
      cmd_new = CMD_OPEN_MENU;
      break;
    case BTN_CLOSE_OSDMENU:
      cmd_new = CMD_CLOSE_MENU;
      break;
    case BTN_MUTE_OSDMENU:
      cmd_new = CMD_MUTE_MENU;
      break;
    case BTN_DEBLUR_QUICK_ON:
      cmd_new = CMD_DEBLUR_QUICK_ON;
      break;
    case BTN_DEBLUR_QUICK_OFF:
      cmd_new = CMD_DEBLUR_QUICK_OFF;
      break;
    case BTN_15BIT_QUICK_ON:
      cmd_new = CMD_15BIT_QUICK_ON;
      break;
    case BTN_15BIT_QUICK_OFF:
      cmd_new = CMD_15BIT_QUICK_OFF;
      break;
    case BTN_MENU_ENTER:
      cmd_new = CMD_MENU_ENTER;
      break;
    case BTN_MENU_BACK:
      cmd_new = CMD_MENU_BACK;
      break;
    case CTRL_DU_SETMASK:
    case CTRL_CU_SETMASK:
      cmd_new = CMD_MENU_UP;
      break;
    case CTRL_DD_SETMASK:
    case CTRL_CD_SETMASK:
      cmd_new = CMD_MENU_DOWN;
      break;
    case CTRL_DL_SETMASK:
    case CTRL_CL_SETMASK:
      cmd_new = CMD_MENU_LEFT;
      break;
    case CTRL_DR_SETMASK:
    case CTRL_CR_SETMASK:
      cmd_new = CMD_MENU_RIGHT;
      break;
  };

  if (cmd_pre != cmd_new) {
    if (cmd_history_cnt == 0) {
      if (cmd_pre == CMD_MUTE_MENU && cmd_new == CMD_NON)
        cmd_new = CMD_UNMUTE_MENU;
      cmd_pre = cmd_new;
      cmd_history_cnt = COMMAND_HISTORY_LENGTH;
      return cmd_new;
    } else
      cmd_history_cnt--;
  } else
    cmd_history_cnt = cmd_new == CMD_NON ? 0 : COMMAND_HISTORY_LENGTH;

  return CMD_NON;
};
