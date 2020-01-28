with Serial_IO.Nonblocking;      use Serial_IO.Nonblocking;

package keyboard
with SPARK_Mode => On
is

   type KeyCode is
     (
      None,
      D,
      Q,
      S,
      Z,
      Space,
      Left_Ctrl,
      Left_Shift,
      Left_Alt,
      Left_GUI,
      Right_Ctrl,
      Right_Shift,
      Right_Alt,
      Right_GUI
     )
     with Size => 8;

   for KeyCode use
     (
      None            => 16#00#,
      D               => 16#07#,
      Q               => 16#14#,
      S               => 16#16#,
      Z               => 16#1d#,
      Space           => 16#2c#,
      Left_Ctrl       => 16#e0#,
      Left_Shift      => 16#e1#,
      Left_Alt        => 16#e2#,
      Left_GUI        => 16#e3#,
      Right_Ctrl      => 16#e4#,
      Right_Shift     => 16#e5#,
      Right_Alt       => 16#e6#,
      Right_GUI       => 16#e7#
     );

   subtype CtrlKeyCode is KeyCode range Left_Ctrl .. Right_GUI;

   type Keypress_array_index is range 1 .. 6;
   type Keypress_array is array (Keypress_array_index) of KeyCode;

   type Key_Status_Type is record
      Left_Ctrl : Boolean;
      Left_Shift : Boolean;
      Left_Alt : Boolean;
      Left_GUI : Boolean;
      Right_Ctrl : Boolean;
      Right_Shift : Boolean;
      Right_Alt : Boolean;
      Right_GUI : Boolean;
   end record
     with Size => 8;

   for Key_Status_Type use record
      Left_Ctrl at 0 range 0 .. 0;
      Left_Shift at 0 range 1 .. 1;
      Left_Alt at 0 range 2 .. 2;
      Left_GUI at 0 range 3 .. 3;
      Right_Ctrl at 0 range 4 .. 4;
      Right_Shift at 0 range 5 .. 5;
      Right_Alt at 0 range 6 .. 6;
      Right_GUI at 0 range 7 .. 7;
   end record;

   type Report_Format is record
      Key_Status : Key_Status_Type;
      Reserved : KeyCode;
      Keypress : Keypress_array;
   end record;

   type Keyboard is tagged limited record
      report : Report_Format;
      nb_key : Integer range 0 .. 6;
      have_events : Boolean;
      Initialized : Boolean := False;
   end record
     with Dynamic_Predicate =>
       ((nb_key = 0) or else (for all I in Keypress_array'First .. Keypress_array_index(nb_key) => report.Keypress(I) /= None)) and
       ((nb_key = Integer(Keypress_array'Last)) or else
          (for all I in Keypress_array_index(nb_key + 1) .. Keypress_array'Last => report.Keypress(I) = None));

   function Nb_Key_Test(This : Keyboard) return Integer with Ghost;

   procedure Initiliaze_Keyboard (This : out Keyboard)
     with
       Global => null,
       Post'Class => This.Initialized = True;
   function Is_Modifier_Status_Key (key : KeyCode) return Boolean
     with
       Global => null,
       Post => Is_Modifier_Status_Key'Result = ((key = Left_Ctrl
              or else key = Left_Shift
              or else key = Left_Alt
              or else key = Left_GUI
              or else key = Right_Ctrl
              or else key = Right_Shift
              or else key = Right_Alt
              or else key = Right_GUI));

   procedure Key_Press (kb : in out keyboard; key : KeyCode)
     with
       Global => null,
       Pre'Class => kb.Initialized = True and then key /= None and then kb.Nb_Key_Test < Integer(Keypress_array_index'Last);
   function Checked_Key_Press (This : in out keyboard; key : KeyCode) return Boolean
     with
       SPARK_Mode => Off,
       Global => null,
       Pre'Class => This.Initialized = True;

   procedure Key_Release (kb : in out keyboard; key : KeyCode)
     with
       Global => null,
       Pre'Class => kb.Initialized = True and then key /= None and then kb.Nb_Key_Test > 0 and then kb.Is_Key_Press(key);

   function Is_Key_Press(This : in Keyboard; key : KeyCode) return Boolean
     with
       Global => null,
       Pre'Class => This.Initialized = True;

   procedure Send_Report (This : in out Keyboard;
                          uart : in out Serial_Port)
     with
       SPARK_Mode => Off,
       Global => null,
       Pre'Class => This.Initialized = True;

private

   procedure Update_Modifier_Status_Key (kb : in out keyboard;
                                         key : KeyCode;
                                         status : Boolean)
     with
       Global => null,
       Pre'Class => kb.Initialized = True and then Is_Modifier_Status_Key(key);

end keyboard;
