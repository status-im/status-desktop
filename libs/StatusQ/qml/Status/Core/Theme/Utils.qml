pragma Singleton

import QtQuick

/*!
  Helper functions for colors and sizes transformations

  \note Consider moving some heavy used functions to C++ for type optimizations.
  \note Consider that Qt6 transpile QML files in C++ which are then optimized by compiler;
        however, types like \c QVariant is providing limited options compared to native types
 */
QtObject {
    function addAlphaTo(baseColor, alpha) {
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alpha)
    }
}
