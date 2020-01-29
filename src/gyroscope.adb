with L3GD20;            use L3GD20;
with STM32.Board;           use STM32.Board;
with Ada.Real_Time;

package body Gyroscope is

   function To_Angles(Value: L3GD20.Angle_Rates) return Angles;
   function To_AnglesDegree (Value: Angles) return AnglesDegree;
   function Convert_To_Degree (Axes : AnglesDegree) return AnglesDegree;


   procedure Add_Angle (This : in out Angles;
                        Value : Angles) is
   begin
      This.X := This.X + Value.X;
      This.Y := This.Y + Value.Y;
      This.Z := This.Z + Value.Z;
   end;

   procedure Div_Factor (This : in out Angles;
                         Factor : Angle) is
   begin
      This.X := This.X / Factor;
      This.Y := This.Y / Factor;
      This.Z := This.Z / Factor;
   end;

   function To_Angles(Value: L3GD20.Angle_Rates) return Angles is
      Res : Angles;
   begin
      Res.X := Angle (Value.X);
      Res.Y := Angle (Value.Y);
      Res.Z := Angle (Value.Z);
      return res;
   end;

   function To_AnglesDegree (Value: Angles) return AnglesDegree is
      Res : AnglesDegree;
   begin
      Res.X := Float (Value.X);
      Res.Y := Float (Value.Y);
      Res.Z := Float (Value.Z);
      return res;
   end;

   function Average_Gyro return Angles is
      Axes_Cur: L3GD20.Angle_Rates;
      Axes: Angles;
   begin
      for I in 1 .. 8 loop
         while not Gyro.Data_Status.ZYX_Available loop
            delay 0.1;
         end loop;

         Gyro.Get_Raw_Angle_Rates (Axes_Cur);
         Axes.Add_Angle (To_Angles(Axes_Cur));
      end loop;

      Axes.Div_Factor(8);
      return Axes;
   end;

   function Convert_To_Degree (Axes : AnglesDegree) return AnglesDegree is
      Res : AnglesDegree := Axes;
   begin
      Res.X := Res.X / (65.536 * 2.0);
      Res.Y := Res.Y / (65.536 * 2.0);
      Res.Z := Res.Z / (65.536 * 2.0);
      return Res;
   end;

   procedure Configure_Gyro is
   begin
      --  Init the on-board gyro SPI and GPIO. This is board-specific, not
      --  every board has a gyro. The F429 Discovery does, for example, but
      --  the F4 Discovery does not.
      STM32.Board.Initialize_Gyro_IO;

      Gyro.Reset;

      Gyro.Configure
        (Power_Mode       => L3GD20_Mode_Active,
         Output_Data_Rate => L3GD20_Output_Data_Rate_95Hz,
         Axes_Enable      => L3GD20_Axes_Enable,
         Bandwidth        => L3GD20_Bandwidth_1,
         BlockData_Update => L3GD20_BlockDataUpdate_Continous,
         Endianness       => L3GD20_Little_Endian,
         Full_Scale       => L3GD20_Fullscale_250);

      Enable_Low_Pass_Filter (Gyro);
      -- Enable_High_Pass_Filter(Gyro); -- Give weird value
      delay 2.0;
      Axes_Offset := To_AnglesDegree (Average_Gyro);
   end Configure_Gyro;

   procedure Reset_Gyro is
   begin
      Axes := (0, 0, 0);
      Axes_HP := (0.0, 0.0, 0.0);
   end;

   function Update_Gyro (Dur: Duration) return Angles is
      Axes_Cur  : L3GD20.Angle_Rates;
      Axes_fix  : AnglesDegree;
      Threshold : constant Float := 1.0;
      Dur_Float : Float          := Float (Dur);
      Alpha     : Float;
   begin
      if not Gyro.Data_Status.ZYX_Available then
         return Axes;
      end if;

      Gyro.Get_Raw_Angle_Rates (Axes_Cur);

      Axes_fix := To_AnglesDegree (To_Angles (Axes_Cur));

      Axes_fix.X := Axes_fix.X - Axes_Offset.X;
      Axes_fix.Y := Axes_fix.Y - Axes_Offset.Y;
      Axes_fix.Z := Axes_fix.Z - Axes_Offset.Z;

      Axes_fix := Convert_To_Degree (Axes_fix);
      Alpha := 0.8 / (0.8 + Dur_Float);

      Axes_HP.X := Axes_HP.X + Alpha * (Axes_fix.X - Axes_HP.X);
      Axes_HP.Y := Axes_HP.Y + Alpha * (Axes_fix.Y - Axes_HP.Y);
      Axes_HP.Z := Axes_HP.Z + Alpha * (Axes_fix.Z - Axes_HP.Z);

      if Axes_HP.X >= -Threshold and then Axes_HP.X <= Threshold then
         Axes_HP.X := 0.0;
      end if;
      if Axes_HP.Y >= -Threshold and then Axes_HP.Y <= Threshold then
         Axes_HP.Y := 0.0;
      end if;
      if Axes_HP.Z >= -Threshold and then Axes_HP.Z <= Threshold then
         Axes_HP.Z := 0.0;
      end if;
      Axes.X := Axes.X + Angle (Axes_HP.X * Dur_Float);
      Axes.Y := Axes.Y + Angle (Axes_HP.Y * Dur_Float);
      Axes.Z := Axes.Z + Angle (Axes_HP.Z * Dur_Float);
      return Axes;
   end;

end gyroscope;
