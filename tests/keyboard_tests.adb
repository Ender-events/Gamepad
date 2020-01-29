with Ahven;
use Ahven;
with keyboard;

package body Keyboard_Tests is

   procedure Initialize (T : in out Test) is
      begin
         Set_Name (T, "My tests");

         Framework.Add_Test_Routine
           (T, Test_Is_Key_Press'Access, "My first test");
   end Initialize;

   procedure Test_Is_Key_Press is
   begin
      Assert(true, "bite");
   end Test_Is_Key_Press;

end Keyboard_Tests;
