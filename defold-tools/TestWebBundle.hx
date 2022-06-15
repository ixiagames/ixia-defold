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
        var zip:String = null;
        for (file in FileSystem.readDirectory(resourcesPath)) {
            if (file.endsWith(".zip")) {
                if (zip == null || FileSystem.stat(resourcesPath + file).mtime.getTime() > FileSystem.stat(resourcesPath + zip).mtime.getTime())
                    zip = file;
            }
        }

        if (zip != null)
            unpackResource(zip);
        else
            throw "Found no resource pack in " + resourcesPath;

        for (file in FileSystem.readDirectory(resourcesPath)) {
            if (file != zip && file.endsWith(".zip"))
                FileSystem.deleteFile(resourcesPath + file);
        }
    }

    function unpackResource(file:String):Void {
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