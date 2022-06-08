package;

import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

using StringTools;

class TestWebBundle {

    static function main() {
        new TestWebBundle();
    }

    //

    var bundlePath:String;
    var resourcesPath:String;
    var serverProcess:Process;

    public function new() {
        var args = Sys.args();
        bundlePath = args[0];
        resourcesPath = args[1];

        extractResources();
        createHTAccess();
        startWebServer();
        openPage();

        while (true) serverProcess.exitCode();
    }

    function extractResources():Void {
        for (file in FileSystem.readDirectory(resourcesPath)) {
            if (file.endsWith(".zip")) {
                unzip(file);
                break;
            }
        }
    }

    function unzip(file:String):Void {
        Sys.command('unzip -o -qq $resourcesPath/$file -d $bundlePath/resources');
    }

    function createHTAccess():Void {
        File.saveContent('$bundlePath/resources/.htaccess', "AddType application/octet-stream .");
    }

    function startWebServer():Void {
        serverProcess = new Process('nekotools server -d $bundlePath');
    }

    function openPage():Void {
        Sys.command("open http://localhost:2000");
    }

    function exit():Void {
        
    }

}