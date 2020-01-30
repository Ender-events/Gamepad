with Keyboard_Interface;      use Keyboard_Interface;
with Message_Buffers;         use Message_Buffers;
with HAL.Bitmap;              use HAL.Bitmap;
with Serial_IO.Nonblocking;   use Serial_IO.Nonblocking;
with Peripherals_Nonblocking; use Peripherals_Nonblocking;
with STM32.Board;             use STM32.Board;

package body Utils is

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

   procedure Background_Display (BG : Bitmap_Color) is
      Black : HAL.Bitmap.Bitmap_Color := (Alpha => 255, others => 0);
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

end Utils;
