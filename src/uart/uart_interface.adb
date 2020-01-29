with Peripherals_Nonblocking;    use Peripherals_Nonblocking;
with Serial_IO.Nonblocking;      use Serial_IO.Nonblocking;
with Message_Buffers;            use Message_Buffers;
package body UART_Interface is

   overriding
   procedure Initialize_UART (This : in out UARTInterface) is
   begin
      Initialize (COM);
      Configure (COM, Baud_Rate => 115_200);
      This.Initialized := True;
   end;

   overriding
   procedure Write(This : in out UARTInterface;
                   Msg  : String)
   is
      Outgoing : aliased Message (Physical_Size => 1024);  -- arbitrary size
   begin
      Outgoing.Set (Msg);
      Put (COM, Outgoing'Unchecked_Access);
   end Write;
end UART_Interface;
