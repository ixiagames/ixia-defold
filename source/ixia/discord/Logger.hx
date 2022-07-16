package ixia.discord;

import discordjs.channel.TextChannel;
import discordjs.guild.Guild;
import discordjs.message.MessageEmbed;
import haxe.PosInfos;
import js.Node.console;
import ixia.discord.common.CommonEmbedColor;

class Logger {

    public var channel(default, null):TextChannel;
    public var icons(default, null):Map<LogType, String>;
    
    public function new(channel:TextChannel, ?icons:Map<LogType, String>) {
        this.channel = channel;
        this.icons = icons;
    }

    public inline function log(description:Dynamic, type:LogType = INFO, ?guild:Guild, ?pos:PosInfos):Void {
        if (channel == null)
            throw "The log channel wasn't fetched.";
        
        var title = guild == null ? '' : 'Guild: "${guild.name}"\n';
        title += '${pos.fileName}:${pos.lineNumber}:';
        var consoleLog = title + '\n' + description;
        switch (type) {
            case INFO:  console.log(consoleLog);
            case WARN:  console.warn(consoleLog);
            case ERROR: console.error(consoleLog);
        };
        
        var embed = new MessageEmbed()
            .setTitle(title)
            .setDescription(description)
            .setColor(switch (type) {
                case INFO: COLOR_INFO;
                case WARN: COLOR_WARN;
                case ERROR: COLOR_ERROR;
            });
        if (icons != null && icons.exists(type))
            embed.setThumbnail(icons[type]);
        channel
            .send({ embeds: [ embed ] })
            .catchError(error -> this.error(error));
    }

    public inline function error(error:Dynamic, ?guild:Guild, ?pos:PosInfos):Void {
        var description = Reflect.isFunction(error.details) ? error.details() : Std.string(error);
        log(description, ERROR, guild, pos);
    }

    public inline function warn(description:Dynamic, ?guild:Guild, ?pos:PosInfos) {
        log(description, WARN, guild, pos);
    }

}

enum abstract LogType(Int) {

    var INFO;
    var WARN;
    var ERROR;
    
}