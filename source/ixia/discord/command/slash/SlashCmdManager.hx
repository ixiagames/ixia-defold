package ixia.discord.command.slash;

import discordjs.Collection;
import discordjs.command.ApplicationCommand;
import discordjs.command.ApplicationCommandData;
import discordjs.interaction.CommandInteraction;
import js.lib.Promise;

class SlashCmdManager {

    public var commands(default, null):Map<String, SlashCmd<Dynamic>>;
    public var bot(default, null):Bot;

    public function new() { }

    public inline function setCommands(commands:Array<SlashCmd<Dynamic>>):Void {
        this.commands = [ for (command in commands) command.name => command ];
    }

    public function solveInteraction(interaction:CommandInteraction):Void {
        try {
            if (interaction.options.getSubcommandGroup(false) != null) {
                commands[interaction.commandName]
                    .groups[interaction.options.getSubcommandGroup()]
                    .commands[interaction.options.getSubcommand()].handle(interaction);
    
            } else if (interaction.options.getSubcommand(false) != null) {
                commands[interaction.commandName]
                    .commands[interaction.options.getSubcommand()].handle(interaction);
    
            } else {
                commands[interaction.commandName].handle(interaction);
            }
        } catch (error) {
            bot.logger.error('Command name: ${interaction.commandName}\nOptions: ${interaction.options}\nError: $error', interaction.guild);
        }
    }

    public function deployCommand(name:String, ?guildId:String):Promise<ApplicationCommand> {
        return new Promise((resolve, reject) -> {
            bot.client.application.commands
                .create({
                    name: commands[name].name,
                    description: commands[name].locale != null ? commands[name].locale.description() : commands[name].name,
                    options: commands[name].options()
                }, guildId)
                .then(appCmd -> resolve(appCmd))
                .catchError(error -> {
                    bot.client.guilds.fetch(guildId).then(guild -> bot.logger.error(error, guild));
                    reject(error);
                });
        });
    }

    public function deployCommands(?guildId:String):Promise<Collection<String, ApplicationCommand>> {
        return new Promise((resolve, reject) -> {
            var numCmdLeft = 0;
            for (_ in commands.keys())
                numCmdLeft++;

            if (numCmdLeft == 0) {
                reject("Has no command.");
                return;
            }
    
            var deployedCommands = new Collection<String, ApplicationCommand>();
            for (cmdName in commands.keys()) {
                deployCommand(cmdName, guildId)
                    .then(appCmd -> {
                        deployedCommands.set(appCmd.name, appCmd);
                        numCmdLeft--;
                        if (numCmdLeft == 0)
                            resolve(deployedCommands);
                    })
                    .catchError(error -> reject(error));
            }
        });
    }

    public inline function removeCommands(?guildId:String):Promise<Collection<String, ApplicationCommand>> {
        return bot.client.application.commands.set([], guildId);
    }
    
}