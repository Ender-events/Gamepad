with Message_Buffers;
with IO_Interface;
with Serial_IO.Nonblocking; use Serial_IO.Nonblocking;

package UART_Interface is
   type UART_InterfaceNT is limited new IO_Interface.IO_InterfaceNT with private;

   procedure Initiliaze_UART (This : out UART_InterfaceNT);

   overriding procedure Write(This: UART_InterfaceNT; msg: access Message_Buffers.Message);


private
   type UART_InterfaceNT is limited new IO_Interface.IO_InterfaceNT with record
      Initialized : Boolean := False;
   end record;

end UART_Interface;
