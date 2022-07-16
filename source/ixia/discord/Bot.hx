package ixia.discord;

import discordjs.channel.GuildChannel;
import discordjs.client.Client;
import discordjs.guild.Guild;
import discordjs.interaction.ButtonInteraction;
import discordjs.interaction.SelectMenuInteraction;
import discordjs.message.MessageButton.ButtonStyle;
import discordjs.message.MessageButton.MessageButton;
import discordjs.message.MessageSelectMenu;
import haxe.Timer;
import ixia.discord.Logger.LogType;
import ixia.discord.command.CommandLocale;
import ixia.discord.command.slash.SlashCmd;
import ixia.discord.command.slash.SlashCmdManager;
import ixia.discord.gui.GuiManager;

class Bot {

    public var client(default, null):Client;
    public var logger(default, null):Logger;
    public var gui(default, null):GuiManager;
    public var slashCmdManager(default, null):SlashCmdManager;
    var _slashCommands:Map<String, SlashCmd<CommandLocale>>;
    final _buttonCallbacks = new Map<String, ButtonInteraction->Void>();
    final _selectMenuCallbacks = new Map<String, SelectMenuInteraction->Void>();

    public function new(options:BotOptions) {
        slashCmdManager = options.slashCmdManager;
        @:privateAccess slashCmdManager.bot = this;

        var initLogger:Void->Void = null;
        initLogger = () -> {
            client.off(READY, initLogger);
            client.guilds.fetch(options.logger.guildId).then((guild:Guild) -> {
                guild.channels.fetch(options.logger.channelId).then((channel:GuildChannel) -> {
                    if (!channel.isText())
                        throw 'The channel ("${channel.name}" in "${guild.name}") is not text based.';
                    logger = new Logger(cast channel);
                    gui = new GuiManager(this);
                    onReady(options);
                });
            });
        }
        
        client = new Client(options.client);
        client.on(READY, initLogger);
        client.on(INTERACTION_CREATE, onInteractionCreate);
        client.login(options.token);
    }

    //
    
    function onReady(options:BotOptions):Void {
        trace('Bot has started running as ${client.user.tag}!');
    }

    function onInteractionCreate(interaction:Dynamic):Void {
        try {
            if (interaction.isCommand())
                slashCmdManager.solveInteraction(interaction);
            else if (interaction.isButton()) {
                if (_buttonCallbacks.exists(interaction.customId))
                    _buttonCallbacks[interaction.customId](interaction);
                else
                    gui.onButtonInteraction(interaction);
            } else if (interaction.isSelectMenu())
                _selectMenuCallbacks[interaction.customId](interaction);
        } catch (error) logger.error(error, interaction.guild);
    }

    //

    public function createButton(name:String, groupId:String, label:String, style:ButtonStyle, minutes:Int, callback:ButtonInteraction->Void):MessageButton {
        var id = '$name-$groupId';
        if (_buttonCallbacks.exists(id))
            logger.warn('Button with name $name & groupId $groupId already existed.');
        _buttonCallbacks[id] = callback;
        if (minutes > 0)
            Timer.delay(() -> _buttonCallbacks.remove(id), minutes * 60000);
        return new MessageButton().setCustomId(id).setLabel(label).setStyle(style);
    }
    
    public function createSelectMenu(name:String, groupId:String, minutes:Int, callback:SelectMenuInteraction->Void):MessageSelectMenu {
        var id = '$name-$groupId';
        if (_selectMenuCallbacks.exists(id))
            logger.warn('Select menu with name $name & groupId $groupId already existed.');
        _selectMenuCallbacks[id] = callback;
        if (minutes > 0)
            Timer.delay(() -> _buttonCallbacks.remove(id), minutes * 60000);
        return new MessageSelectMenu().setCustomId(id);
    }
    
}

typedef BotOptions = {

    token:String,
    client:Dynamic,
    logger:LoggerOptions,
    slashCmdManager:SlashCmdManager

}

typedef LoggerOptions = {

    guildId:String,
    channelId:String,
    ?icons:Map<LogType, String>

}