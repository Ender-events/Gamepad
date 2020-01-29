with Ahven.Framework;
package Keyboard_Tests is
   type Test is new Ahven.Framework.Test_Case with null record;

   procedure Initialize (T : in out Test);
   procedure Test_Is_Key_Press;

end Keyboard_Tests;
