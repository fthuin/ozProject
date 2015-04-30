functor
import
   Application
   Module
   System
define
   BASE_PATH = "images/"
   [QTk]     = {Module.link ["x-oz://system/wp/QTk.ozf"]}
   Library   = {QTk.newImageLibrary}

   proc {AddPhoto Folder Name}
     {Library newPhoto(file:BASE_PATH#Folder#"/"#Name#".gif" name:{VirtualString.toAtom Folder#"_"#Name})}
   end

   % Add player images
   {AddPhoto sacha down0}
   {AddPhoto sacha down1}
   {AddPhoto sacha down2}
   {AddPhoto sacha down3}

   {AddPhoto sacha up0}
   {AddPhoto sacha up1}
   {AddPhoto sacha up2}
   {AddPhoto sacha up3}

   {AddPhoto sacha left0}
   {AddPhoto sacha left1}
   {AddPhoto sacha left2}
   {AddPhoto sacha left3}

   {AddPhoto sacha right0}
   {AddPhoto sacha right1}
   {AddPhoto sacha right2}
   {AddPhoto sacha right3}

   {AddPhoto sacha large}

   % Add textures
   {AddPhoto textures grass}
   {AddPhoto textures road}

   % Add pokemons
   {AddPhoto pokemoz bellsprout}
   {AddPhoto pokemoz bulbasoz}
   {AddPhoto pokemoz caterpie}
   {AddPhoto pokemoz charmandoz}
   {AddPhoto pokemoz lapras}
   {AddPhoto pokemoz magby}
   {AddPhoto pokemoz magikarp}
   {AddPhoto pokemoz moltres}
   {AddPhoto pokemoz nidoran}
   {AddPhoto pokemoz oddish}
   {AddPhoto pokemoz omanyte}
   {AddPhoto pokemoz oztirtle}
   {AddPhoto pokemoz poliwag}
   {AddPhoto pokemoz ponyta}
   {AddPhoto pokemoz vulpix}

   % Add characters
   {AddPhoto characters brock}
   {AddPhoto characters james}
   {AddPhoto characters may}
   {AddPhoto characters misty}
   {AddPhoto characters player}
   {AddPhoto characters wild}

   {AddPhoto characters brock_small}
   {AddPhoto characters james_small}
   {AddPhoto characters may_small}
   {AddPhoto characters misty_small}

   % Add types
   {AddPhoto types electric}
   {AddPhoto types fire}
   {AddPhoto types flying}
   {AddPhoto types grass}
   {AddPhoto types ground}
   {AddPhoto types normal}
   {AddPhoto types water}

   % Add various
   {AddPhoto various hospital}

   % Save library
   {QTk.saveImageLibrary Library "ImageLibrary.ozf"}

   % Double check execution
   LoadedLib = {QTk.loadImageLibrary "ImageLibrary.ozf"}
   {System.show {LoadedLib getNames($)}}

   {Application.exit 0}
end
