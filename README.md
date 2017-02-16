# NatureEditor

This editor uses the prefabs built in my prefabEditor package and allows the user to insert them into the game scene.

## Current Version Notes

[Feb 16, 2017]
In this updated I added the background layers and applied a vertical parralax effect.  Next update should apply the same effect in the x axis.

There is a video clip of the current version here:
https://youtu.be/tUDvs-MFW4g


[Feb 14, 2017]
In the latest update I added a water shader which will reflect all the placed prefabs in the scene (anything rendered above the water line which is configurable will be reflected + distorted).

This distortion filter will also be used to implement the rising hot air columns which give the player's glider extra lift.

## Controls

Right-Click and drag to pan the camera.

### Layers

Layer 1 is intended for solid body (stationary) objects which are rendered behind the player (and AI) objects.

Layer 2 is where the entity objects (dynamic) are rendered (in front of the solid body objects).

Layer 3 is intended for objects that should appear in front of the player (IE: Clouds) and will be rendered with a parallax effect, moving faster than the player as it scrolls by.

The engine does support rendering solids and entities on each layer, however for the purpose of this game we only need the entities on layer 2.  This will also conserve fps and make searching for objects by uid much faster.

If you add a solid object to layer 2 or an entity object to layers 1 or 3 you will not be able to select them again in the editor.  This will be fixed (TODO).

## Loading/Saving

Not yet functional (TODO).

## Properties

The "> Level" menu at the bottom left of the screen gives access to the properties dialog where general level settings can be configured like background paralax layers.


