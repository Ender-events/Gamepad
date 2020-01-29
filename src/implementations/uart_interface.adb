with Peripherals_Nonblocking;    use Peripherals_Nonblocking;
with Serial_IO.Nonblocking;      use Serial_IO.Nonblocking;
package body UART_Interface is

   procedure Initiliaze_UART (This : out UART_InterfaceNT) is
   begin
      Initialize(COM);
      Configure(COM, Baud_Rate => 115_200);
      This.Initialized := True;
   end;

   overriding procedure Write(This: UART_InterfaceNT; msg: access Message_Buffers.Message) is
   begin
      Put(COM, msg);
   end Write;


end UART_Interface;
