with IO_Interface_Types;

package Keyboard_Interface is

   type Keyboard_Interface_Instance is interface;
   type All_Keyboard_Interface_Instances is access all Keyboard_Interface_Instance'Class;
   
   type KeyCode is (None,
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
                    Right_GUI)
     with Size => 8;

   for KeyCode use (None            => 16#00#,
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
                    Right_GUI       => 16#e7#);
      
   subtype CtrlKeyCode is KeyCode range Left_Ctrl .. Right_GUI;

   procedure Initiliaze_Keyboard (This : in out Keyboard_Interface_Instance) 
   is abstract;
   
   procedure Key_Release (Keybrd : in out Keyboard_Interface_Instance;
                          Key    : KeyCode) is abstract;

   function Is_Key_Press(This : in out Keyboard_Interface_Instance; 
                         Key  : KeyCode) return Boolean is abstract;

   procedure Send_Report (This : in out Keyboard_Interface_Instance;
                          UART : in out IO_Interface_Types.IO_Interface'Class)
   is abstract;
   
   procedure Key_Press (This : in out Keyboard_Interface_Instance;
                        Key : KeyCode)
   is abstract;
   
   function Checked_Key_Press (This : in out Keyboard_Interface_Instance;
                               Key : KeyCode) return Boolean
   is abstract;

end Keyboard_Interface;
