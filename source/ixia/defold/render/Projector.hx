package ixia.defold.render;

import defold.Render;
import defold.types.Matrix4;
import defold.Vmath;

class Projector {
    
    /**
     * Projection that stretches content.
     */
    public static inline function stretch(near:Float = -1, far:Float = 1):Matrix4 {
        return Vmath.matrix4_orthographic(0, Render.get_width(), 0, Render.get_height(), near, far);
    }

    /**
     * Projection that centers content with maintained aspect ratio and optional zoom.
     */
    public static inline function fixed(near:Float = -1, far:Float = 1, zoom:Float = 1):Matrix4 {
        var w = Render.get_window_width() / zoom;
        var h = Render.get_window_height() / zoom;
        var x = -(w - Render.get_width()) / 2;
        var y = -(h - Render.get_height()) / 2;
        return Vmath.matrix4_orthographic(x, x + w, y, y + h, near, far);
    }

    /**
     * Projection that centers and fits content with maintained aspect ratio.
     */
    public static inline function fixedFit(near:Float = -1, far:Float = 1):Matrix4 {
        return fixed(
            near, far,
            Math.min(
                Render.get_window_width() / Render.get_width(),
                Render.get_window_height() / Render.get_height()
            )
        );
    }

    /**
     * Projection that centers and horizontally fits the content with maintained aspect ratio.
     */
    public static inline function fixedHFit(near:Float = -1, far:Float = 1):Matrix4 {
        return fixed(near, far, Render.get_window_width() / Render.get_width());
    }

    /**
     * Projection that centers and vertically fits the content with maintained aspect ratio.
     */
    public static inline function fixedVFit(near:Float = -1, far:Float = 1):Matrix4 {
        return fixed(near, far, Render.get_window_height() / Render.get_height());
    }

}