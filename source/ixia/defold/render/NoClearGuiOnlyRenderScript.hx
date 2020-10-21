package ixia.defold.render;

import defold.Render;
import defold.Vmath;
import lua.Table;

/**
 * Only render GUI without clearing.
 */
class NoClearGuiOnlyRenderScript<T:{}> extends RenderScript<T> {

    override function init(self:T) {
        guiPred = Render.predicate(Table.create([ "gui" ]));
        textPred = Render.predicate(Table.create([ "text" ]));
        view = Vmath.matrix4();
        projection = Vmath.matrix4_orthographic(0, Render.get_window_width(), 0, Render.get_window_height(), -1, 1);
    }
    
    override function update(self:T, dt:Float) {    
        Render.set_view(view);
        Render.set_projection(projection);
        Render.enable_state(STATE_BLEND);
        Render.set_blend_func(BLEND_SRC_ALPHA, BLEND_ONE_MINUS_SRC_ALPHA);
        Render.enable_state(STATE_STENCIL_TEST);
        Render.draw(guiPred);
        Render.draw(textPred);
        Render.disable_state(STATE_STENCIL_TEST);
    }

}