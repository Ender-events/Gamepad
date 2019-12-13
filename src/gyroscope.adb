with L3GD20;            use L3GD20;
with STM32.Board;           use STM32.Board;

package body gyroscope is

   Axes   : Angles := (0, 0, 0);

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
   end Configure_Gyro;

   procedure Reset_Gyro is
   begin
      Axes := (0, 0, 0);
   end;

   function Get_Raw_Angle return Angles is
      Axes_Cur: L3GD20.Angle_Rates;
      Threshold: constant L3GD20.Angle_Rate := 128;
   begin
      if not Gyro.Data_Status.ZYX_Available then
         return Axes;
      end if;

      Gyro.Get_Raw_Angle_Rates (Axes_Cur);
      if Axes_Cur.X / Threshold /= 0 then
         Axes.X := Axes.X + Angle(Axes_Cur.X);
      end if;
      if Axes_Cur.Y / Threshold /= 0 then
         Axes.Y := Axes.Y + Angle(Axes_Cur.Y);
      end if;
      if Axes_Cur.Z / Threshold /= 0 then
         Axes.Z := Axes.Z + Angle(Axes_Cur.Z);
      end if;
      return Axes;
   end;

end gyroscope;
