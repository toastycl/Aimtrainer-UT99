class UTATMenuItem extends UMenuModMenuItem;
function Execute()
{
    MenuItem.Owner.Root.CreateWindow(class'UTATWindow', 40, 40, 420, 350);
}
defaultproperties
{
    MenuCaption="Unreal Arena &Aimtrainer"
    MenuHelp="Open the local CTF aim training panel."
}
