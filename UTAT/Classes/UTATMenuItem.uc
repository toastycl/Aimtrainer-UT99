class UTATMenuItem extends UMenuModMenuItem;
function Execute()
{
    MenuItem.Owner.Root.CreateWindow(class'UTATWindow', 40, 40, 440, 420,,True);
}
defaultproperties
{
    MenuCaption="UT99 &Aimtrainer"
    MenuHelp="Enter the training room or set up a practice round."
}
