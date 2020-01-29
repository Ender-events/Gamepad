package IO_Interface_Types is
   type IO_Interface is limited interface;
   type All_IO_Interface is access all IO_Interface;

   procedure Initialize_UART (This : in out IO_Interface) is abstract;

   procedure Write(This : in out IO_Interface;
                   Msg  : String) is abstract;
end IO_Interface_Types;
