package ixia.defold.render;

import defold.Render;
import defold.types.Matrix4;
import defold.Vmath;
import lua.Table;

/**
 * Only renders GUI without clearing.
 */
class NoClearGuiOnlyRenderScript<T:{}> extends defold.support.RenderScript<T> {

    public var guiPred(default, null):RenderPredicate;
    public var textPred(default, null):RenderPredicate;
    public var view:Matrix4;

    override function init(self:T) {
        guiPred = Render.predicate(Table.create([ "gui" ]));
        textPred = Render.predicate(Table.create([ "text" ]));
        view = Vmath.matrix4();
    }
    
    override function update(self:T, dt:Float) {    
        Render.set_view(view);
        Render.set_projection(getProjection());
        Render.enable_state(STATE_BLEND);
        Render.set_blend_func(BLEND_SRC_ALPHA, BLEND_ONE_MINUS_SRC_ALPHA);
        Render.enable_state(STATE_STENCIL_TEST);
        Render.draw(guiPred);
        Render.draw(textPred);
        Render.disable_state(STATE_STENCIL_TEST);
    }

    function getProjection():Matrix4 {
        return Vmath.matrix4_orthographic(0, Render.get_window_width(), 0, Render.get_window_height(), -1, 1);
    }

}