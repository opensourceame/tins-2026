This game implements a quick save / quick load mechanism.

When the quick save button "S" is pressed, all current settings are stored to a file on disk in JSON format.

Settings include: the state of the game, state of the Spica, positions of elements in the game, saved species, solar systems etc.

When the quick load button "L" is pressed, a popover screen is displayed with a list of the 5 most recent quick saves.
The player can choose one of the options, and then the game is resumed from that state.

The quick load screen is located in screens/quick_load.tscn
