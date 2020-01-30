with HID_Interface; use HID_Interface;
with Gyroscope;     use Gyroscope;
with HAL.Bitmap;              use HAL.Bitmap;


package Utils is
   Middle_Pos   : constant Point := (110, 150);

   function Gyro_To_Keyboard (Gyro: Angles;
                              Kbrd: in out Keyboard)
                              return Boolean;
   
   procedure Send (This : String);
   
   procedure Background_Display (BG : Bitmap_Color);

end Utils;
