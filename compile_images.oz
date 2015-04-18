functor
import
   Application
   Module
   System
define
   BASE_PATH = "images/"
   [QTk]     = {Module.link ["x-oz://system/wp/QTk.ozf"]}
   Library   = {QTk.newImageLibrary}

   % Add player images
   {Library newPhoto(file:BASE_PATH#"sacha/down0.gif" name:sacha_down_0)}
   {Library newPhoto(file:BASE_PATH#"sacha/down1.gif" name:sacha_down_1)}
   {Library newPhoto(file:BASE_PATH#"sacha/down2.gif" name:sacha_down_2)}
   {Library newPhoto(file:BASE_PATH#"sacha/down3.gif" name:sacha_down_3)}

   {Library newPhoto(file:BASE_PATH#"sacha/up0.gif" name:sacha_up_0)}
   {Library newPhoto(file:BASE_PATH#"sacha/up1.gif" name:sacha_up_1)}
   {Library newPhoto(file:BASE_PATH#"sacha/up2.gif" name:sacha_up_2)}
   {Library newPhoto(file:BASE_PATH#"sacha/up3.gif" name:sacha_up_3)}

   {Library newPhoto(file:BASE_PATH#"sacha/left0.gif" name:sacha_left_0)}
   {Library newPhoto(file:BASE_PATH#"sacha/left1.gif" name:sacha_left_1)}
   {Library newPhoto(file:BASE_PATH#"sacha/left2.gif" name:sacha_left_2)}
   {Library newPhoto(file:BASE_PATH#"sacha/left3.gif" name:sacha_left_3)}

   {Library newPhoto(file:BASE_PATH#"sacha/right0.gif" name:sacha_right_0)}
   {Library newPhoto(file:BASE_PATH#"sacha/right1.gif" name:sacha_right_1)}
   {Library newPhoto(file:BASE_PATH#"sacha/right2.gif" name:sacha_right_2)}
   {Library newPhoto(file:BASE_PATH#"sacha/right3.gif" name:sacha_right_3)}

   {Library newPhoto(file:BASE_PATH#"/sacha/large.gif" name:sacha_large)}

   % Add textures
   {Library newPhoto(file:BASE_PATH#"textures/grass.gif" name:texture_grass)}
   {Library newPhoto(file:BASE_PATH#"textures/road.gif"  name:texture_road)}

   % Add pokemons
   {Library newPhoto(file:BASE_PATH#"pokemoz/bellsprout.gif" name:pokemoz_bellsprout)}
   {Library newPhoto(file:BASE_PATH#"pokemoz/bulbasaur.gif"  name:pokemoz_bulbasaur)}
   {Library newPhoto(file:BASE_PATH#"pokemoz/caterpie.gif"   name:pokemoz_caterpie)}
   {Library newPhoto(file:BASE_PATH#"pokemoz/charmander.gif" name:pokemoz_charmander)}
   {Library newPhoto(file:BASE_PATH#"pokemoz/nidoran.gif"    name:pokemoz_nidoran)}
   {Library newPhoto(file:BASE_PATH#"pokemoz/oddish.gif"     name:pokemoz_oddish)}
   {Library newPhoto(file:BASE_PATH#"pokemoz/poliwag.gif"    name:pokemoz_poliwag)}
   {Library newPhoto(file:BASE_PATH#"pokemoz/ponyta.gif"     name:pokemoz_ponyta)}
   {Library newPhoto(file:BASE_PATH#"pokemoz/squirtle.gif"   name:pokemoz_squirtle)}
   {Library newPhoto(file:BASE_PATH#"pokemoz/vulpix.gif"     name:pokemoz_vulpix)}

   % Save library
   {QTk.saveImageLibrary Library "ImageLibrary.ozf"}

   % Double check execution
   LoadedLib = {QTk.loadImageLibrary "ImageLibrary.ozf"}
   {System.show {LoadedLib getNames($)}}

   {Application.exit 0}
end
