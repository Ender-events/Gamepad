with IO_Interface_Types;
with Keyboard_Interface; use Keyboard_Interface;

package HID_Interface
with SPARK_Mode => On
is

   pragma Elaborate_Body;

   type KeyPress_Array_Index is range 1 .. 6;
   type KeyPress_Array is array (KeyPress_Array_Index) of KeyCode;

   type Key_Status_Type is record
      Left_Ctrl   : Boolean;
      Left_Shift  : Boolean;
      Left_Alt    : Boolean;
      Left_GUI    : Boolean;
      Right_Ctrl  : Boolean;
      Right_Shift : Boolean;
      Right_Alt   : Boolean;
      Right_GUI   : Boolean;
   end record
     with Size => 8;

   for Key_Status_Type use record
      Left_Ctrl   at 0 range 0 .. 0;
      Left_Shift  at 0 range 1 .. 1;
      Left_Alt    at 0 range 2 .. 2;
      Left_GUI    at 0 range 3 .. 3;
      Right_Ctrl  at 0 range 4 .. 4;
      Right_Shift at 0 range 5 .. 5;
      Right_Alt   at 0 range 6 .. 6;
      Right_GUI   at 0 range 7 .. 7;
   end record;

   type Report_Format is record
      Key_Status : Key_Status_Type;
      Reserved : KeyCode;
      KeyPress : KeyPress_Array;
   end record;

   type Keyboard is new Keyboard_Interface_Instance with record
      Report      : Report_Format;
      Num_Key     : Integer range 0 .. 6;
      Have_Events : Boolean;
      Initialized : Boolean := False;
   end record
     with Dynamic_Predicate =>
       ((Num_Key = 0) or else
          (for all I in KeyPress_Array'First .. KeyPress_Array_Index (Num_Key) => Report.KeyPress (I) /= None))
     and
       ((Num_Key = Integer (KeyPress_Array'Last)) or else
          (for all I in KeyPress_Array_Index (Num_Key + 1) .. KeyPress_Array'Last => Report.KeyPress (I) = None));

   overriding
   procedure Initiliaze_Keyboard (This : in out Keyboard)
     with
       Global => null, Post'Class => This.Initialized = True;

   function Is_Modifier_Status_Key (Key : KeyCode) return Boolean
     with
       Global => null,
       Post => Is_Modifier_Status_Key'Result = ((Key = Left_Ctrl
              or else Key = Left_Shift
              or else Key = Left_Alt
              or else Key = Left_GUI
              or else Key = Right_Ctrl
              or else Key = Right_Shift
              or else Key = Right_Alt
              or else Key = Right_GUI));

   overriding
   procedure Key_Press (This : in out Keyboard;
                        Key : KeyCode)
     with
       Global => null,
         Pre => This.Initialized = True and then
         Key /= None and then
         This.Num_Key < Integer (KeyPress_Array_Index'Last);

   overriding
   function Checked_Key_Press (This : in out Keyboard;
                               Key : KeyCode) return Boolean
     with
       SPARK_Mode => Off,
       Global => null,
       Pre => This.Initialized = True;

   overriding
   procedure Key_Release (This : in out Keyboard;
                          Key : KeyCode)
     with
       Global => null,
         Pre => This.Initialized = True and then
         Key /= None and then
         This.Num_Key > 0 and then This.Is_Key_Press (Key);

   overriding
   function Is_Key_Press(This : in out Keyboard;
                         Key : KeyCode) return Boolean
     with
       Global => null,
       Pre => This.Initialized = True;

   overriding
   procedure Send_Report (This : in out Keyboard;
                          UART : in out IO_Interface_Types.IO_Interface'Class)
     with
       SPARK_Mode => Off,
       Global => null,
       Pre => This.Initialized = True;

private

   procedure Update_Modifier_Status_Key (Kbrd : in out Keyboard;
                                         Key    : KeyCode;
                                         Status : Boolean)
     with
       Global => null,
         Pre'Class => Kbrd.Initialized = True and then
         Is_Modifier_Status_Key (Key);

end HID_Interface;
