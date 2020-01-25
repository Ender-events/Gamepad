with L3GD20;            use L3GD20;
package gyroscope is


   type Angle is new Long_Integer;

   type Angles is tagged record
      X : Angle;  -- pitch, per Figure 2, pg 7 of the Datasheet
      Y : Angle;  -- roll
      Z : Angle;  -- yaw
   end record;

   procedure Add_Equal(This : in out Angles; value : Angles);

   type AnglesDegree is record
      X : Float;  -- pitch, per Figure 2, pg 7 of the Datasheet
      Y : Float;  -- roll
      Z : Float;  -- yaw
   end record;

   procedure Configure_Gyro;
   procedure Reset_Gyro;
   function Update_Gyro (dt: Duration) return Angles;

end gyroscope;
