package ixia.defold.render;

import defold.Render;
import defold.support.RenderScript;
import defold.types.Matrix4;
import defold.types.Message;
import defold.types.Url;
import defold.Vmath;
import ixia.defold.types.RBGA;
import ixia.lua.RawTable;
import lua.Table;

class RenderScript<T:{}> extends defold.support.RenderScript<T> {

    public var tilePred(default, null):RenderPredicate;
    public var guiPred(default, null):RenderPredicate;
    public var textPred(default, null):RenderPredicate;
    public var particlePred(default, null):RenderPredicate;
    public var near:Float;
    public var far:Float;
    public var zoom:Float;
    public var clearColor:Rgba;
    public var view:Matrix4;
    public var projection:Matrix4;
    var _projectionFunc:Void->Matrix4;
    var _clearTable:RawTable;

    override function init(self:T):Void {
        tilePred = Render.predicate(Table.create([ "tile" ]));
        guiPred = Render.predicate(Table.create([ "gui" ]));
        textPred = Render.predicate(Table.create([ "text" ]));
        particlePred = Render.predicate(Table.create([ "particle" ]));

        clearColor = Rgba.fromConfigClearColor();
        _clearTable = new RawTable();
        _clearTable[BUFFER_COLOR_BIT] = clearColor;
        _clearTable[BUFFER_DEPTH_BIT] = 1;
        _clearTable[BUFFER_STENCIL_BIT] = 0;
        
        view = Vmath.matrix4();

        // Default is stretch projection. copy from builtins and change for different projection
        // or send a message to the Render script to change projection:
        // - Msg.post("@Render:", "use_stretch_projection", { near: -1, far: 1 });
        // - Msg.post("@Render:", "use_fixed_projection", { near: -1, far: 1, zoom: 2 });
        // - Msg.post("@Render:", "use_fixed_fit_projection", { near: -1, far: 1 });
        near = -1;
        far = 1;
        _projectionFunc = stretchProjection;
    }

    override function update(self:T, dt:Float):Void {
        Render.set_depth_mask(true);
        Render.set_stencil_mask(0xFF);
        Render.clear(cast _clearTable);

        Render.set_viewport(0, 0, Render.get_window_width(), Render.get_window_height());
        Render.set_view(view);

        Render.set_depth_mask(false);
        Render.disable_state(STATE_DEPTH_TEST);
        Render.disable_state(STATE_STENCIL_TEST);
        Render.enable_state(STATE_BLEND);
        Render.set_blend_func(BLEND_SRC_ALPHA, BLEND_ONE_MINUS_SRC_ALPHA);
        Render.disable_state(STATE_CULL_FACE);

        Render.set_projection(_projectionFunc());

        Render.draw(tilePred);
        Render.draw(particlePred);
        Render.draw_debug3d();

        // Render GUI.
        Render.set_view(Vmath.matrix4());
        Render.set_projection(Vmath.matrix4_orthographic(0, Render.get_window_width(), 0, Render.get_window_height(), -1, 1));

        Render.enable_state(STATE_STENCIL_TEST);
        Render.draw(guiPred);
        Render.draw(textPred);
        Render.disable_state(STATE_STENCIL_TEST);
    }
    
    override function on_message<TMessage>(self:T, message_id:Message<TMessage>, message:TMessage, sender:Url):Void {
        switch (message_id) {
            case RenderMessages.clear_color:
                clearColor = message.color;

            case RenderMessages.set_view_projection:
                view = message.view;
                projection = (cast message:Dynamic).projection;

            case RenderScriptMessages.use_camera_projection:
                _projectionFunc = () -> return projection != null ? projection : projection = Vmath.matrix4();
            
            case RenderScriptMessages.use_stretch_projection:
                near = message.near != null ? message.near : -1;
                far = message.far != null ? message.far : 1;
                _projectionFunc = stretchProjection;

            case RenderScriptMessages.use_fixed_projection:
                near = message.near != null ? message.near : -1;
                far = message.far != null ? message.far : 1;
                zoom = message.far != null ? message.zoom : 1;
                _projectionFunc = fixedProjection;

            case RenderScriptMessages.use_fixed_fit_projection:
                near = message.near != null ? message.near : -1;
                far = message.far != null ? message.far : 1;
                _projectionFunc = fixedFitProjection;
        }
    }

    // Projection that centers content with maintained aspect ratio and optional zoom.
    function fixedProjection():Matrix4 {
        var projectedWidth = Render.get_window_width() / zoom;
        var projectedHeight = Render.get_window_height() / zoom;
        var xoffset = -(projectedWidth - Render.get_width()) / 2;
        var yoffset = -(projectedHeight - Render.get_height()) / 2;
        return Vmath.matrix4_orthographic(xoffset, xoffset + projectedWidth, yoffset, yoffset + projectedHeight, near, far);
    }
    
    
    // Projection that centers and fits content with maintained aspect ratio.
    function fixedFitProjection():Matrix4 {
        var width = Render.get_width();
        var height = Render.get_height();
        var windowWidth = Render.get_window_width();
        var windowHeight = Render.get_window_height();
        zoom = Math.min(windowWidth / width, windowHeight / height);
        return fixedProjection();
    }

    // Projection that stretches content.
    function stretchProjection():Matrix4 {
        return Vmath.matrix4_orthographic(0, Render.get_width(), 0, Render.get_height(), near, far);
    }

}

class RenderScriptMessages {
    
    public static final use_camera_projection = new Message<Void>("use_camera_projection");
    public static final use_stretch_projection = new Message<{ near:Float, far:Float }>("use_stretch_projection");
    public static final use_fixed_projection = new Message<{ near:Float, far:Float, zoom:Float }>("use_fixed_projection");
    public static final use_fixed_fit_projection = new Message<{ near:Float, far:Float }>("use_fixed_fit_projection");

}