with L3GD20;            use L3GD20;
package gyroscope is


   type Angle is new Long_Integer;

   type Angles is record
      X : Angle;  -- pitch, per Figure 2, pg 7 of the Datasheet
      Y : Angle;  -- roll
      Z : Angle;  -- yaw
   end record;

   procedure Configure_Gyro;
   function Get_Raw_Angle return Angles;

end gyroscope;
