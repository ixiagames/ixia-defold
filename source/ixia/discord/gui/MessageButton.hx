package ixia.discord.gui;

import discordjs.message.MessageButton.ButtonStyle;

@:forward
abstract MessageButton(discordjs.message.MessageButton) from discordjs.message.MessageButton to discordjs.message.MessageButton {

    public static inline function blank():MessageButton {
        return new discordjs.message.MessageButton();
    }

    public function new(handlerName:String, ?args:Array<String>, label:String, style:ButtonStyle) {
        var id = handlerName;
        if (args != null) {
            for (arg in args)
                id += GuiManager.ARG_SEPARATOR + arg;
        }
        this = new discordjs.message.MessageButton()
            .setCustomId(id)
            .setLabel(label)
            .setStyle(style);
    }

    public inline function setStyle(style:ButtonStyle):Void {
        this.setStyle(style);
    }
    
}