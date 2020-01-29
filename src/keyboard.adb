package body keyboard
with SPARK_Mode => On
is

   procedure Initiliaze_Keyboard (This : out Keyboard) is
   begin
      This.nb_key := 0;
      This.report.Keypress := (others => None);
      This.report.Key_Status := (others => False);
      This.report.Reserved := None;
      This.have_events := False;
      This.Initialized := True;
   end;

   function Checked_Key_Press (This : in out keyboard; key : KeyCode) return Boolean
        with SPARK_Mode => Off -- Can't have in out in function
   is
   begin
      if This.Is_Key_Press(key) then
         return False;
      else
         This.Key_Press(key);
         return True;
      end if;
   end;

   procedure Key_Press (kb : in out keyboard; key : KeyCode) is
   begin
      if Is_Modifier_Status_Key(key) then
         Update_Modifier_Status_Key(kb, key, True);
      else
         kb.have_events := True;
         kb.nb_key := kb.nb_key + 1;
         kb.report.Keypress(Keypress_array_index(kb.nb_key)) := key;
      end if;
   end;

   procedure Key_Release (kb : in out keyboard; key : KeyCode) is
      J : Keypress_array_index := 1;
   begin
      pragma Assert(kb.Is_Key_Press(key));
      if Is_Modifier_Status_Key(key) then
         Update_Modifier_Status_Key(kb, key, False);
      else
         pragma Assert(for some I in Keypress_array'Range => kb.report.Keypress(I) = key);
         for I in Keypress_array_index'First .. Keypress_array_index(kb.nb_key) loop
            pragma Assert(((J = I and then (for all K in Keypress_array_index'First .. I - 1 => kb.report.Keypress(K) /= key)) or else (J < I))
                                  and then (J /= 6 or else kb.report.Keypress(J) = key));
            kb.report.Keypress(J) := kb.report.Keypress(I);
            if kb.report.Keypress(J) /= key then
               J := J + 1;
            end if;
         end loop;
         kb.report.Keypress(J) := None;
         -- TODO: find a way to say they have a unique value of the key to be remove
         kb.nb_key := kb.nb_key - 1;
      end if;
   end;

   function Is_Key_Press(This : in Keyboard; key : KeyCode) return Boolean is
   begin
      case key is
         when Left_Shift => return This.report.Key_Status.Left_Shift;
         when Left_Ctrl => return This.report.Key_Status.Left_Ctrl;
         when Left_Alt => return This.report.Key_Status.Left_Alt;
         when Left_GUI => return This.report.Key_Status.Left_GUI;
         when Right_Shift => return This.report.Key_Status.Right_Shift;
         when Right_Ctrl => return This.report.Key_Status.Right_Ctrl;
         when Right_Alt => return This.report.Key_Status.Right_Alt;
         when Right_GUI => return This.report.Key_Status.Right_GUI;
         when others =>
            for I in Keypress_array_index'Range loop
               if This.report.Keypress(I) = key then
                  return True;
               end if;
            end loop;
            return False;
      end case;
   end;

   procedure Send_Report (This : in out Keyboard;
                          uart : in out IO_Interface.IO_InterfaceNT'Class)
     with SPARK_Mode => Off -- Can't use spark with uart
   is
      data : String(1 .. 8) := (others => Character'Val(0));
      key_status : Key_Status_Type := This.report.Key_Status;
      key_status_buf : Character
        with Address => key_status'Address;
   begin
      data(1) := key_status_buf;
      for I in Keypress_array_index loop
         data(Integer(I + 2)) := Character'Val(This.report.Keypress(I)'Enum_Rep);
      end loop;
      uart.Write(data);
   end;

   function Is_Modifier_Status_Key (key : KeyCode) return Boolean is
   begin
      return key in CtrlKeyCode;
   end;


   procedure Update_Modifier_Status_Key (kb : in out keyboard;
                                         key : KeyCode;
                                         status : Boolean) is
   begin
      case key is
         when Left_Shift => kb.report.Key_Status.Left_Shift := status;
         when Left_Ctrl => kb.report.Key_Status.Left_Ctrl := status;
         when Left_Alt => kb.report.Key_Status.Left_Alt := status;
         when Left_GUI => kb.report.Key_Status.Left_GUI := status;
         when Right_Shift => kb.report.Key_Status.Right_Shift := status;
         when Right_Ctrl => kb.report.Key_Status.Right_Ctrl := status;
         when Right_Alt => kb.report.Key_Status.Right_Alt := status;
         when Right_GUI => kb.report.Key_Status.Right_GUI := status;
         when others => raise Program_Error with "Should not be here";
         end case;
   end;


   function Nb_Key_Test(This : Keyboard) return Integer
   is
      (This.nb_key);
end keyboard;
