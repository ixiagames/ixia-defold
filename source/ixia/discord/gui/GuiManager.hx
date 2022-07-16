package ixia.discord.gui;

import discordjs.interaction.ButtonInteraction;
import discordjs.message.Message;
import js.lib.Promise;

using StringTools;

class GuiManager {

    public static inline var ARG_SEPARATOR = ',';

    //

    public var bot(default, null):Bot;
    public var missingButtonHandler:(interaction:ButtonInteraction, handlerName:String, args:Array<String>)->Void;
    final _buttonHandlers:Map<String, (interaction:ButtonInteraction, args:Array<String>)->Void> = [];
    
    public function new(bot:Bot) {
        this.bot = bot;
    }

    public inline function setButtonHandler(name:String, handler:(interaction:ButtonInteraction, args:Array<String>)->Void):Void {
        #if debug
        if (name.indexOf(ARG_SEPARATOR) > -1)
            bot.logger.error("Button handlers aren't allowed to have '" + ARG_SEPARATOR + "' in their names.");
        #end

        _buttonHandlers[name] = handler;
    }

    public function onButtonInteraction(interaction:ButtonInteraction):Void {
        var args = interaction.customId.split(ARG_SEPARATOR);
        var handlerName = args.shift();
        if (_buttonHandlers.exists(handlerName))
            _buttonHandlers[handlerName](interaction, args);
        else if (missingButtonHandler != null)
            missingButtonHandler(interaction, handlerName, args);
    }

    public function removeComponents(message:Message):Promise<Message> {
        return new Promise((resolve, reject) -> {
            if (!message.editable) {
                reject("The message is not editable.");
                return;
            }

            message.components = [];
            message.edit(message).then(resolve).catchError(reject);
        });
    }

}