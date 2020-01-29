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
with Keyboard_Interface; use Keyboard_Interface;
with HID_Interface;              use HID_Interface;

with Peripherals_Nonblocking;    use Peripherals_Nonblocking;
with Serial_IO.Nonblocking;      use Serial_IO.Nonblocking;
with Message_Buffers;            use Message_Buffers;
with Ada.Real_Time; use Ada.Real_Time;
with UART_Interface;


procedure Main is
   BG : Bitmap_Color := (Alpha => 255, others => 0);
   Middle_Pos   : constant Point := (110, 150);
   Ball_Pos   : Point := Middle_Pos;
   Speed : Integer := 0;
   Gravity : Integer := 2;
   Is_Down : Boolean := True;
   Axes : Angles := (0, 0, 0);
   CR : constant Character := Character'Val(13);
   LF : constant Character := Character'Val(10);
   NL : constant String := CR & LF;
   Width : constant Angle := 300;
   Height : constant Angle := 220;
   Prev : Time := Clock;
   Cur : Time;
   Dur : Duration;
   Kbrd : Keyboard;
   UART : UART_Interface.UARTInterface;


   function Gyro_To_Keyboard (Gyro: Angles;
                              Kbrd: in out Keyboard)
                              return Boolean
   is
      Change: Boolean := False;
   begin
      if Gyro.X > 15 then
         Change := Kbrd.Checked_Key_Press (Key => Q) or Change;
      elsif Kbrd.Is_Key_Press (Key => Q) then
         Kbrd.Key_Release (Key => Q);
         Change := True;
      end if;

      if Gyro.X < -15 then
         Change := Kbrd.Checked_Key_Press (Key => D) or Change;
      elsif Kbrd.Is_Key_Press (Key => D) then
         Kbrd.Key_Release (Key => D);
         Change := True;
      end if;

      if Gyro.Y < -15 then
         Change := Kbrd.Checked_Key_Press (Key => Z) or Change;
      elsif Kbrd.Is_Key_Press (Key => Z) then
         Kbrd.Key_Release (Key => Z);
         Change := True;
      end if;

      if Gyro.Y > 15 then
         Change := Kbrd.Checked_Key_Press (Key => S) or Change;
      elsif Kbrd.Is_Key_Press (Key => S) then
         Kbrd.Key_Release (Key => S);
         Change := True;
      end if;

      -- TODO: Use radius instead ?
      if ((Gyro.X > 15 and then Gyro.X < 40) or else (Gyro.Y > 15 and then Gyro.Y < 40))
        or else ((Gyro.X < -15 and then Gyro.X > -40) or else (Gyro.Y < -15 and then Gyro.Y > -40)) then
         Change := Kbrd.Checked_Key_Press (Key => Left_Ctrl) or Change;
      elsif Kbrd.Is_Key_Press (Key => Left_Ctrl) then
         Kbrd.Key_Release (Key => Left_Ctrl);
         Change := True;
      end if;

      if Gyro.X > 65 or else Gyro.Y > 65  or else Gyro.X < -65 or else Gyro.Y < -65 then
         Change := Kbrd.Checked_Key_Press (Key => Left_Shift) or Change;
      elsif Kbrd.Is_Key_Press (Key => Left_Shift) then
         Kbrd.Key_Release (Key => Left_Shift);
         Change := True;
      end if;
      return Change;
   end;

   procedure Send (This : String) is
      Outgoing : aliased Message (Physical_Size => 1024);  -- arbitrary size
   begin
      Set (Outgoing, To => This);
      Put (COM, Outgoing'Unchecked_Access);
      -- Await_Transmission_Complete (Outgoing);
      --  We must await xmit completion because Put does not wait
   end Send;

   procedure Background_Display is
      Black : Bitmap_Color := (Alpha => 255, others => 0);
   begin
      Display.Hidden_Buffer (1).Set_Source (BG);
      Display.Hidden_Buffer (1).Fill;

      Display.Hidden_Buffer (1).Set_Source (HAL.Bitmap.Red);
      Display.Hidden_Buffer (1).Fill_Circle (Middle_Pos, 90);

      Display.Hidden_Buffer (1).Set_Source (HAL.Bitmap.Yellow);
      Display.Hidden_Buffer (1).Fill_Circle (Middle_Pos, 65);

      Display.Hidden_Buffer (1).Set_Source (HAL.Bitmap.Green);
      Display.Hidden_Buffer (1).Fill_Circle (Middle_Pos, 40);

      Display.Hidden_Buffer (1).Set_Source (HAL.Bitmap.White_Smoke);
      Display.Hidden_Buffer (1).Fill_Circle (Middle_Pos, 15);
   end;
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

   -- Initialize UART

   UART.Initialize_UART;
   -- Send ("Welcome to bouncing ball simulator." & NL);
   Kbrd.Initiliaze_Keyboard;
   -- kb.Key_Press(key => Left_Shift);
   -- kb.Key_Press(key => Right_GUI);
   -- kb.Key_Press(key => Z);
   -- kb.Key_Press(key => Q);


   loop
      if User_Button.Has_Been_Pressed then
         BG := HAL.Bitmap.Dark_Orange;
         Kbrd.Send_Report (UART);
      end if;
      Cur := Clock;
      Dur := Ada.Real_Time.To_Duration(Cur - Prev);
      Prev := Cur;
      Axes := Update_Gyro (Dur);
      -- Send(Axes.X'Image & "," & Axes.Y'Image & "," & Axes.Z'Image & NL);
      declare
         Pos_X : Angle := Angle (Middle_Pos.X) + Axes.Y;
         Pos_Y : Angle := Angle (Middle_Pos.Y) + Axes.X;
      begin
         if Pos_X < 10 then
            Pos_X := 10;
         elsif Pos_X > Width then
            Pos_X := Width;
         end if;

         if Pos_Y < 10 then
            Pos_Y := 10;
         elsif Pos_Y > Height then
            Pos_Y := Height;
         end if;

         Ball_Pos.X := Standard.Natural (Pos_X);
         Ball_Pos.Y := Standard.Natural (Pos_Y);
      end;

      Background_Display;

      declare
         State : constant TP_State := Touch_Panel.Get_All_Touch_Points;
      begin
         if State'Length = 1 then
            Ball_Pos := Middle_Pos;
            gyroscope.Reset_Gyro;
         end if;
      end;

      if Gyro_To_Keyboard (Axes, Kbrd) then
         Kbrd.Send_Report (UART);
      end if;

      Display.Hidden_Buffer (1).Set_Source (HAL.Bitmap.Blue);
      Display.Hidden_Buffer (1).Fill_Circle (Ball_Pos, 5);

      --  Update screen
      Display.Update_Layer (1, Copy_Back => True);

   end loop;
end Main;
