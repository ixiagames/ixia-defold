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
    public var particlePred(default, null):RenderPredicate;
    public var guiPred(default, null):RenderPredicate;
    public var textPred(default, null):RenderPredicate;
    public var near:Float;
    public var far:Float;
    public var zoom:Float;
    public var clearColor:Rgba;
    public var view:Matrix4;
    public var projection:Matrix4;
    var _projectionFunc:Void->Matrix4;
    var _clearTable:RawTable<RenderBufferType, Dynamic>;

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

        enableStretchProjection();
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
            case RenderScriptMessages.clear_color:
                clearColor = message.color;

            case RenderScriptMessages.set_view_projection:
                view = message.view;
                if (message.projection != null)
                    projection = message.projection;
                else if (projection == null)
                    projection = Vmath.matrix4();

            case RenderScriptMessages.use_camera_projection:
                if (message.projection != null)
                    projection = message.projection;
                else if (projection == null)
                    projection = Vmath.matrix4();
                _projectionFunc = () -> return projection;
            
            case RenderScriptMessages.use_stretch_projection:
                enableStretchProjection(message.near, message.far);

            case RenderScriptMessages.use_fixed_fit_projection:
                enableFixedFitProjection(message.near, message.far);

            case RenderScriptMessages.use_fixed_hfit_projection:
                enableFixedHFitProjection(message.near, message.far);

            case RenderScriptMessages.use_fixed_vfit_projection:
                enableFixedVFitProjection(message.near, message.far);

            case RenderScriptMessages.use_fixed_projection:
                enableFixedProjection(message.near, message.far, message.zoom);
        }
    }

    /**
     * Projection that stretches content.
     */
    public function enableStretchProjection(?near:Float, ?far:Float):Void {
        near = near != null ? near : -1;
        far = far != null ? far : 1;
        _projectionFunc = () -> return Projection.stretch(near, far);
    }

    /**
     * Projection that centers content with maintained aspect ratio and optional zoom.
     */
    public function enableFixedProjection(?near:Float, ?far:Float, ?zoom:Float):Void {
        near = near != null ? near : -1;
        far = far != null ? far : 1;
        zoom = zoom != null ? zoom : 1;
        _projectionFunc = () -> return Projection.fixed(near, far, zoom);
    }

    /**
     * Projection that centers and fits content with maintained aspect ratio.
     */
    public function enableFixedFitProjection(?near:Float, ?far:Float):Void {
        near = near != null ? near : -1;
        far = far != null ? far : 1;
        zoom = zoom != null ? zoom : 1;
        _projectionFunc = () -> return Projection.fixedFit(near, far);
    }

    /**
     * Projection that centers and horizontally fits the content with maintained aspect ratio.
     */
    public function enableFixedHFitProjection(?near:Float, ?far:Float):Void {
        near = near != null ? near : -1;
        far = far != null ? far : 1;
        zoom = zoom != null ? zoom : 1;
        _projectionFunc = () -> return Projection.fixedHFit(near, far);
    }

    /**
     * Projection that centers and vertically fits the content with maintained aspect ratio.
     */
    public function enableFixedVFitProjection(?near:Float, ?far:Float):Void {
        near = near != null ? near : -1;
        far = far != null ? far : 1;
        zoom = zoom != null ? zoom : 1;
        _projectionFunc = () -> return Projection.fixedVFit(near, far);
    }

}

class RenderScriptMessages {
    
    public static final clear_color = new Message<{ color:Rgba }>("clear_color");
    public static final set_view_projection = new Message<{ view:Matrix4, ?projection:Matrix4 }>("set_view_projection");
    public static final use_camera_projection = new Message<{ ?projection:Matrix4 }>("use_camera_projection");
    public static final use_stretch_projection = new Message<{ ?near:Float, ?far:Float }>("use_stretch_projection");
    public static final use_fixed_fit_projection = new Message<{ ?near:Float, ?far:Float }>("use_fixed_fit_projection");
    public static final use_fixed_hfit_projection = new Message<{ ?near:Float, ?far:Float }>("use_fixed_hfit_projection");
    public static final use_fixed_vfit_projection = new Message<{ ?near:Float, ?far:Float }>("use_fixed_vfit_projection");
    public static final use_fixed_projection = new Message<{ ?near:Float, ?far:Float, ?zoom:Float }>("use_fixed_projection");

}