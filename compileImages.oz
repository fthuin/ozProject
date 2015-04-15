declare
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}
BASE_PATH = "/Users/Greg/Desktop/ozProject/images/"

% Create library
Library = {QTk.newImageLibrary}

% Add sacha images
{Library newPhoto(file:BASE_PATH#"sacha/down1.gif" name:sacha_down_1)}
{Library newPhoto(file:BASE_PATH#"sacha/down2.gif" name:sacha_down_2)}
{Library newPhoto(file:BASE_PATH#"sacha/down3.gif" name:sacha_down_3)}
{Library newPhoto(file:BASE_PATH#"sacha/down4.gif" name:sacha_down_4)}

{Library newPhoto(file:BASE_PATH#"sacha/up1.gif" name:sacha_up_1)}
{Library newPhoto(file:BASE_PATH#"sacha/up2.gif" name:sacha_up_2)}
{Library newPhoto(file:BASE_PATH#"sacha/up3.gif" name:sacha_up_3)}
{Library newPhoto(file:BASE_PATH#"sacha/up4.gif" name:sacha_up_4)}

{Library newPhoto(file:BASE_PATH#"sacha/left1.gif" name:sacha_left_1)}
{Library newPhoto(file:BASE_PATH#"sacha/left2.gif" name:sacha_left_2)}
{Library newPhoto(file:BASE_PATH#"sacha/left3.gif" name:sacha_left_3)}
{Library newPhoto(file:BASE_PATH#"sacha/left4.gif" name:sacha_left_4)}

{Library newPhoto(file:BASE_PATH#"sacha/right1.gif" name:sacha_right_1)}
{Library newPhoto(file:BASE_PATH#"sacha/right2.gif" name:sacha_right_2)}
{Library newPhoto(file:BASE_PATH#"sacha/right3.gif" name:sacha_right_3)}
{Library newPhoto(file:BASE_PATH#"sacha/right4.gif" name:sacha_right_4)}

{Library newPhoto(file:BASE_PATH#"/sacha/large.gif" name:sacha_large)}

% Add textures
{Library newPhoto(file:BASE_PATH#"textures/grass.gif" name:texture_grass)}
{Library newPhoto(file:BASE_PATH#"textures/road.gif" name:texture_road)}

% Save library to file
{QTk.saveImageLibrary Library "/Users/Greg/Desktop/ozProject/ImagesLibrary.ozf"}

% Verify content
LoadedLib = {QTk.loadImageLibrary "/Users/Greg/Desktop/ozProject/ImagesLibrary.ozf"}
{Browse {LoadedLib getNames($)}}