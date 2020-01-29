package IO_Interface is
   type IO_InterfaceNT is limited interface;

   procedure Write(This: IO_InterfaceNT; msg: String) is abstract;
end IO_Interface;
