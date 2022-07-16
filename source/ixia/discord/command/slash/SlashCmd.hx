package ixia.discord.command.slash;

import discordjs.command.ApplicationCommandOptionData;
import discordjs.interaction.CommandInteraction;

class SlashCmd<T_LOCALE:CommandLocale> {
    
    public var name(default, null):String;
    public var locale(default, null):T_LOCALE;
    public var commands(default, null):Map<String, SlashCmd<Dynamic>>;
    public var groups(default, null):Map<String, SlashCmdGroup>;

    public function new(
        name:String, ?locale:T_LOCALE,
        ?commands:Array<SlashCmd<Dynamic>>, ?groups:Array<SlashCmdGroup>
    ) {
        this.name = name;
        this.locale = locale;

        if (commands != null)
            this.commands = [ for (command in commands) command.name => command ];
        if (groups != null)
            this.groups = [ for (group in groups) group.name => group ];
    }

    public function options():Array<ApplicationCommandOptionData> {
        var options = new Array<ApplicationCommandOptionData>();
        if (commands != null) {
            for (command in commands) {
                options.push({
                    type: SUB_COMMAND,
                    name: command.name,
                    description: command.locale.description(),
                    options: command.options()
                });
            }
        }
        if (groups != null) {
            for (group in groups)
                options.push(group.data());
        }
        return options;
    }

    public function handle(interaction:CommandInteraction):Void {

    }

}