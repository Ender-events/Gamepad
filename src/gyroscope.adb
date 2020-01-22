with L3GD20;            use L3GD20;
with STM32.Board;           use STM32.Board;
with Ada.Real_Time;

package body gyroscope is

   Axes   : Angles := (0, 0, 0);
   Axes_Offset: AnglesDegree := (0.0, 0.0, 0.0);
   Axes_HP: AnglesDegree := (0.0, 0.0, 0.0);

   procedure Add_Equal(This : in out Angles; value : Angles) is
   begin
      This.X := This.X + value.X;
      This.Y := This.Y + value.Y;
      This.Z := This.Z + value.Z;
   end;

   procedure Div_Equal(This : in out Angles; value : Angle) is
   begin
      This.X := This.X / value;
      This.Y := This.Y / value;
      This.Z := This.Z / value;
   end;

   function To_Angles(value: L3GD20.Angle_Rates) return Angles is
      res : Angles;
   begin
      res.X := Angle(value.X);
      res.Y := Angle(value.Y);
      res.Z := Angle(value.Z);
      return res;
   end;

   function To_AnglesDegree(value: Angles) return AnglesDegree is
      res : AnglesDegree;
   begin
      res.X := Float(value.X);
      res.Y := Float(value.Y);
      res.Z := Float(value.Z);
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
         Axes.Add_Equal(To_Angles(Axes_Cur));
      end loop;
      Axes.Div_Equal(8);
      return Axes;
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
      Axes_Offset := To_AnglesDegree(Average_Gyro);
   end Configure_Gyro;

   procedure Reset_Gyro is
   begin
      Axes := (0, 0, 0);
      Axes_HP := (0.0, 0.0, 0.0);
   end;

   function Update_Gyro (dt: Duration) return Angles is
      Axes_Cur: L3GD20.Angle_Rates;
      Threshold: constant Float := 128.0;
      alpha: Float;
   begin
      if not Gyro.Data_Status.ZYX_Available then
         return Axes;
      end if;

      Gyro.Get_Raw_Angle_Rates (Axes_Cur);


      alpha := 0.8 / (0.8 + Float(dt));
      Axes_HP.X := Axes_HP.X + alpha * (Float(Axes_Cur.X) - Axes_Offset.X - Axes_HP.X);
      Axes_HP.Y := Axes_HP.Y + alpha * (Float(Axes_Cur.Y) - Axes_Offset.Y - Axes_HP.Y);
      Axes_HP.Z := Axes_HP.Z + alpha * (Float(Axes_Cur.Z) - Axes_Offset.Z - Axes_HP.Z);

      if Axes_HP.X >= -Threshold and then Axes_HP.X <= Threshold then
         Axes_HP.X := 0.0;
      end if;
      if Axes_HP.Y >= -Threshold and then Axes_HP.Y <= Threshold then
         Axes_HP.Y := 0.0;
      end if;
      if Axes_HP.Z >= -Threshold and then Axes_HP.Z <= Threshold then
         Axes_HP.Z := 0.0;
      end if;
      Axes.X := Axes.X + Angle(Axes_HP.X);
      Axes.Y := Axes.Y + Angle(Axes_HP.Y);
      Axes.Z := Axes.Z + Angle(Axes_HP.Z);
      return Axes;
   end;

end gyroscope;
