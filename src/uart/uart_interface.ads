with Message_Buffers;
with IO_Interface_Types;
with Serial_IO.Nonblocking; use Serial_IO.Nonblocking;

package UART_Interface is
   type UARTInterface is limited new IO_Interface_Types.IO_Interface with private;

   overriding
   procedure Initialize_UART (This : in out UARTInterface);

   overriding
   procedure Write (This : in out UARTInterface;
                    Msg  : String);

private
   type UARTInterface is limited new IO_Interface_Types.IO_Interface with record
      Initialized : Boolean := False;
   end record;

end UART_Interface;
