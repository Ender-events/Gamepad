package body HID_Interface
with SPARK_Mode => On
is

   overriding
   procedure Initiliaze_Keyboard (This : in out Keyboard) is
   begin
      This.Num_Key := 0;
      This.Report.KeyPress := (others => None);
      This.Report.Key_Status := (others => False);
      This.Report.Reserved := None;
      This.Have_Events := False;
      This.Initialized := True;
   end Initiliaze_Keyboard;

   overriding
   function Checked_Key_Press (This : in out Keyboard;
                               Key : KeyCode) return Boolean
        with SPARK_Mode => Off -- Can't have in out in function
   is
   begin
      if False then
         return False;
      else
         This.Key_Press (Key);
         return True;
      end if;
   end Checked_Key_Press;

   procedure Key_Press (This : in out Keyboard;
                        Key : KeyCode)
   is
   begin
      if Is_Modifier_Status_Key (Key) then
         This.Update_Modifier_Status_Key (Key, True);
      else
         This.Have_Events := True;
         This.Num_Key := This.Num_Key + 1;
         This.Report.KeyPress (KeyPress_Array_Index (This.Num_Key)) := Key;
      end if;
   end Key_Press;

   overriding
   procedure Key_Release (This : in out Keyboard;
                          Key : KeyCode) is
        J : KeyPress_Array_Index := 1;
   begin
      if Is_Modifier_Status_Key (Key) then
         Update_Modifier_Status_Key (This, Key, False);
      else
         pragma Assert(for some I in KeyPress_Array'Range => This.Report.KeyPress (I) = Key);

         for I in KeyPress_Array_Index'First .. KeyPress_Array_Index (This.Num_Key) loop
            pragma Assert(((J = I and then
                            (for all K in KeyPress_Array_Index'First .. I - 1 => This.Report.KeyPress (K) /= Key)) or else
                              (J < I)) and then
                            (J /= 6 or else This.Report.KeyPress (J) = Key));

            This.Report.KeyPress (J) := This.Report.KeyPress (I);

            if This.Report.KeyPress (J) /= Key then
               J := J + 1;
            end if;
         end loop;

         This.Report.KeyPress (J) := None;
         -- TODO: find a way to say they have a unique value of the key to be remove
         This.Num_Key := This.Num_Key - 1;
      end if;
   end Key_Release;

   overriding
   function Is_Key_Press(This : in out Keyboard;
                         Key : KeyCode) return Boolean is
   begin
      case Key is
         when Left_Shift =>
            return This.Report.Key_Status.Left_Shift;
         when Left_Ctrl =>
            return This.Report.Key_Status.Left_Ctrl;
         when Left_Alt =>
            return This.Report.Key_Status.Left_Alt;
         when Left_GUI =>
            return This.Report.Key_Status.Left_GUI;
         when Right_Shift =>
            return This.Report.Key_Status.Right_Shift;
         when Right_Ctrl =>
            return This.Report.Key_Status.Right_Ctrl;
         when Right_Alt =>
            return This.Report.Key_Status.Right_Alt;
         when Right_GUI =>
            return This.Report.Key_Status.Right_GUI;
         when others =>
            for I in KeyPress_Array_Index'Range loop
               if This.Report.KeyPress (I) = Key then
                  return True;
               end if;
            end loop;

            return False;
      end case;
   end Is_Key_Press;

   overriding
   procedure Send_Report (This : in out Keyboard;
                          UART : in out IO_Interface_Types.IO_Interface'Class)
     with SPARK_Mode => Off -- Can't use spark with uart
   is
      Data : String(1 .. 8) := (others => Character'Val(0));
      Key_Status : Key_Status_Type := This.Report.Key_Status;
      Key_Status_Buf : Character
        with Address => key_status'Address;
   begin
      Data (1) := Key_Status_Buf;
      for I in KeyPress_Array_Index loop
         Data (Integer (I + 2)) := Character'Val (This.Report.KeyPress (I)'Enum_Rep);
      end loop;
      UART.Write (Data);
   end Send_Report;

   function Is_Modifier_Status_Key (Key : KeyCode) return Boolean is
   begin
      return Key in CtrlKeyCode;
   end Is_Modifier_Status_Key;


   procedure Update_Modifier_Status_Key (Kbrd : in out Keyboard;
                                         Key : KeyCode;
                                         Status : Boolean) is
   begin
      case Key is
         when Left_Shift =>
            Kbrd.Report.Key_Status.Left_Shift := Status;
         when Left_Ctrl =>
            Kbrd.Report.Key_Status.Left_Ctrl := Status;
         when Left_Alt =>
            Kbrd.Report.Key_Status.Left_Alt := Status;
         when Left_GUI =>
            Kbrd.Report.Key_Status.Left_GUI := Status;
         when Right_Shift =>
            Kbrd.Report.Key_Status.Right_Shift := Status;
         when Right_Ctrl =>
            Kbrd.Report.Key_Status.Right_Ctrl := Status;
         when Right_Alt =>
            Kbrd.Report.Key_Status.Right_Alt := Status;
         when Right_GUI =>
            Kbrd.Report.Key_Status.Right_GUI := Status;
         when others =>
            raise Program_Error with "Should not be here";
         end case;
   end Update_Modifier_Status_Key;
end HID_Interface;
