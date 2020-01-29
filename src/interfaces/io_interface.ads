with Message_Buffers;
package IO_Interface is
   type IO_InterfaceNT is limited interface;

   procedure Write(This: IO_InterfaceNT; msg: access Message_Buffers.Message) is abstract;
end IO_Interface;
