with Ahven;
use Ahven;
with keyboard;

package body Keyboard_Tests is

   procedure Initialize (T : in out Test) is
   begin
      Set_Name (T, "Test KeyBoard");

      Framework.Add_Test_Routine
        (T, Test_Is_Key_Press'Access, "Test Is_Key_Press");
      Framework.Add_Test_Routine
        (T, Test_Is_Modifier_Status_Key'Access, "Test Is_Modifier_Status_Key");
   end Initialize;

   procedure Test_Is_Key_Press is
      K: keyboard.Keyboard;
   begin
      K.Initiliaze_Keyboard;

      Assert(true, "test");
   end Test_Is_Key_Press;

   procedure Test_Is_Modifier_Status_Key is
      K: keyboard.Keyboard;
   begin
      K.Initiliaze_Keyboard;
      assert(not Keyboard.Is_Modifier_Status_Key(keyboard.D), "D is not a modifier");
      assert(not Keyboard.Is_Modifier_Status_Key(keyboard.Q), "Q is not a modifier");
      assert(not Keyboard.Is_Modifier_Status_Key(keyboard.S), "S is not a modifier");
      assert(not Keyboard.Is_Modifier_Status_Key(keyboard.Z), "Z is not a modifier");
      assert(not Keyboard.Is_Modifier_Status_Key(keyboard.Space), "Space is not a modifier");
      assert(Keyboard.Is_Modifier_Status_Key(keyboard.Left_Ctrl), "Left_Ctrl is a modifier");
      assert(Keyboard.Is_Modifier_Status_Key(keyboard.Left_Shift), "Left_Shift is a modifier");
      assert(Keyboard.Is_Modifier_Status_Key(keyboard.Left_Alt), "Left_Alt is a modifier");
      assert(Keyboard.Is_Modifier_Status_Key(keyboard.Left_GUI), "Left_GUI is a modifier");
      assert(Keyboard.Is_Modifier_Status_Key(keyboard.Right_Ctrl), "Right_Ctrl is a modifier");
      assert(Keyboard.Is_Modifier_Status_Key(keyboard.Right_Shift), "Right_Shift is a modifier");
      assert(Keyboard.Is_Modifier_Status_Key(keyboard.Right_Alt), "Right_Alt is a modifier");
      assert(Keyboard.Is_Modifier_Status_Key(keyboard.Right_GUI), "Right_GUI is a modifier");
   end Test_Is_Modifier_Status_Key;

end Keyboard_Tests;
