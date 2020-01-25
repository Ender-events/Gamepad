with Message_Buffers;            use Message_Buffers;

package body keyboard is

   procedure Initiliaze_Keyboard (kb : in out Keyboard) is
   begin
      kb.report.Key_Status.Left_Ctrl := False;
      kb.report.Key_Status.Left_Shift := False;
      kb.report.Key_Status.Left_Alt := False;
      kb.report.Key_Status.Left_GUI := False;
      kb.report.Key_Status.Right_Ctrl := False;
      kb.report.Key_Status.Right_Shift := False;
      kb.report.Key_Status.Right_Alt := False;
      kb.report.Key_Status.Right_GUI := False;
      kb.report.Keypress := (None, None, None, None, None, None);
      kb.nb_key := 0;
      kb.have_events := False;
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
      if Is_Modifier_Status_Key(key) then
         Update_Modifier_Status_Key(kb, key, False);
      else
         for I in Keypress_array_index'First .. Keypress_array_index(kb.nb_key) loop
            kb.report.Keypress(J) := kb.report.Keypress(I);
            if kb.report.Keypress(J) /= key then
               J := J + 1;
            end if;
         end loop;
         kb.report.Keypress(J) := None;
         kb.nb_key := kb.nb_key - 1;
      end if;
   end;

   function Is_Key_Press(This : in out Keyboard; key : KeyCode) return Boolean is
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
                          uart : in out Serial_Port) is
      Outgoing : aliased Message (Physical_Size => 1024);  -- arbitrary size
      data : String(1 .. 8) := (others => Character'Val(0));
      key_status : Key_Status_Type := This.report.Key_Status;
      key_status_buf : Character
        with Address => key_status'Address;
   begin
      data(1) := key_status_buf;
      for I in Keypress_array_index loop
         data(Integer(I + 2)) := Character'Val(This.report.Keypress(I)'Enum_Rep);
      end loop;
      Outgoing.Set(data);
      uart.Put(Outgoing'Unchecked_Access);
   end;

   function Is_Modifier_Status_Key (key : KeyCode) return Boolean is
   begin
      return (key = Left_Ctrl
              or else key = Left_Shift
              or else key = Left_Alt
              or else key = Left_GUI
              or else key = Right_Ctrl
              or else key = Right_Shift
              or else key = Right_Alt
              or else key = Right_GUI);
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
end keyboard;
