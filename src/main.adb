------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2015-2016, AdaCore                     --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
--  The "last chance handler" is the user-defined routine that is called when
--  an exception is propagated. We need it in the executable, therefore it
--  must be somewhere in the closure of the context clauses.

with STM32.Board;           use STM32.Board;
with HAL.Bitmap;            use HAL.Bitmap;
pragma Warnings (Off, "referenced");
with HAL.Touch_Panel;       use HAL.Touch_Panel;
with STM32.User_Button;     use STM32;
with BMP_Fonts;
with LCD_Std_Out;
with gyroscope; use gyroscope;


procedure Main
is
   BG : Bitmap_Color := (Alpha => 255, others => 0);
   Ball_Pos   : Point := (20, 280);
   Ball_Pos_X : Angle;
   Speed : Integer := 0;
   Gravity : Integer := 2;
   Is_Down : Boolean := True;
   Axes : Angles := (0, 0, 0);
begin

   --  Initialize LCD
   Display.Initialize;
   Display.Initialize_Layer (1, ARGB_8888);

   --  Initialize touch panel
   Touch_Panel.Initialize;

   --  Initialize button
   User_Button.Initialize;

   LCD_Std_Out.Set_Font (BMP_Fonts.Font8x8);
   LCD_Std_Out.Current_Background_Color := BG;

   --  Clear LCD (set background)
   Display.Hidden_Buffer (1).Set_Source (BG);
   Display.Hidden_Buffer (1).Fill;

   LCD_Std_Out.Clear_Screen;
   Display.Update_Layer (1, Copy_Back => True);

   Configure_Gyro;

   loop
      if User_Button.Has_Been_Pressed then
         BG := HAL.Bitmap.Dark_Orange;
      end if;
      Axes := Get_Raw_Angle;
      Ball_Pos_X := Angle(Ball_Pos.X) + Axes.Z / 8192;
      if Ball_Pos_X < 0 then
         Ball_Pos.X := 0;
      elsif Ball_Pos_X > 230 then
         Ball_Pos.X := 230;
      else
         Ball_Pos.X := Standard.Natural(Ball_Pos_X);
      end if;

      Display.Hidden_Buffer (1).Set_Source (BG);
      Display.Hidden_Buffer (1).Fill;

      Display.Hidden_Buffer (1).Set_Source (HAL.Bitmap.Blue);
      Display.Hidden_Buffer (1).Fill_Circle (Ball_Pos, 10);


      declare
         State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
      begin
         case State'Length is
            when 1 =>
               Ball_Pos := (State (State'First).X, State (State'First).Y);
            when others =>
               if Speed <= 0 then
                  Is_Down := True;
               end if;
               if Is_Down then
                  if Ball_Pos.Y - Speed <= 0 then
                     Is_Down := False;
                     Ball_Pos.Y := 0;
                     Speed := Speed - Gravity;
                  else
                     Ball_Pos.Y := Ball_Pos.Y - Speed;
                     Speed := Speed + Gravity;
                  end if;
               else
                  Ball_Pos.Y := Ball_Pos.Y + Speed;
                  Speed := Speed - Gravity;
               end if;

         end case;
      end;

      --  Update screen
      Display.Update_Layer (1, Copy_Back => True);

   end loop;
end Main;
