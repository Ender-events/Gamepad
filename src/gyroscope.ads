with L3GD20;            use L3GD20;

package Gyroscope is
   type Angle is new Long_Integer;

   type Angles is tagged record
      X : Angle;  -- pitch, per Figure 2, pg 7 of the Datasheet
      Y : Angle;  -- roll
      Z : Angle;  -- yaw
   end record;

   procedure Add_Angle (This : in out Angles;
                        Value : Angles);

   procedure Div_Factor (This : in out Angles;
                         Factor : Angle);

   function Update_Gyro (Dur: Duration) return Angles;


   type AnglesDegree is record
      X : Float;  -- pitch, per Figure 2, pg 7 of the Datasheet
      Y : Float;  -- roll
      Z : Float;  -- yaw
   end record;

   function Average_Gyro return Angles;
   procedure Configure_Gyro;
   procedure Reset_Gyro;

   Axes        : Angles       := (0, 0, 0);
   Axes_Offset : AnglesDegree := (0.0, 0.0, 0.0);
   Axes_HP     : AnglesDegree := (0.0, 0.0, 0.0);
end Gyroscope;
