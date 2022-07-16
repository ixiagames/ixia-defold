package ixia.discord.command.slash;

import discordjs.command.ApplicationCommandOptionData;

class SlashCmdGroup {

    public var name(default, null):String;
    public var commands(default, null):Map<String, SlashCmd<CommandLocale>>;

    public function new(name:String, commands:Array<SlashCmd<CommandLocale>>) {
        this.name = name;
        this.commands = [ for (command in commands) command.name => command ];
    }

    public function data():ApplicationCommandOptionData {
        return {
            type: SUB_COMMAND_GROUP,
            name: name,
            description: name,
            options: [
                for (command in commands) {
                    type: SUB_COMMAND,
                    name: command.name,
                    description: command.locale.description(),
                    options: command.options()
                }
            ]
        }
    }
    
}