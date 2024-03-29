Some helpers to use with [hxDefold](https://github.com/hxdefold/hxdefold). This is under the equivalent of public domain, you can do whatever you want with it. 

- [Extensions](https://github.com/ixiagames/ixia-defold/tree/master/source/ixia/defold/extensions): Externs for some extensions.
- [Gui](https://github.com/ixiagames/ixia-defold/tree/master/source/ixia/defold/gui): An easy way to add interaction listeners & styling to GUI node. [ExtGuiNode](https://github.com/ixiagames/ixia-defold/blob/master/source/ixia/defold/gui/ExtGuiNode.hx) is an abstract of GuiNode to make working with them more convenient.
- [Script](https://github.com/ixiagames/ixia-defold/tree/master/source/ixia/defold/script): GUI & GO scripts with some basic macro to build methods into wrapped async version of them with callback. When those wrapped methods are called by any script, the original methods & their callbacks will be executed by the original script by receiving a message, allowing you to update GUI nodes & other properties by calling the methods outside of their script.
- [Collection](https://github.com/ixiagames/ixia-defold/tree/master/source/ixia/defold/collection): Load, unload, liveupdate make more convenient.
- [Types](https://github.com/ixiagames/ixia-defold/tree/master/source/ixia/defold/types): Mostly abstracts of Defold original types to make them more convenient & easier to read.
- [Render](https://github.com/ixiagames/ixia-defold/tree/master/source/ixia/defold/render): For RenderScript, with some basic built-in config for different types of projections.
