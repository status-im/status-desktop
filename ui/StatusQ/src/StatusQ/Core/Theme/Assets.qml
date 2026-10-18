pragma Singleton

import QtQml

QtObject {
    readonly property string assetPath: Qt.resolvedUrl("../../../assets/")

    function png(name) {
        return assetPath + "png/" + name + ".png"
    }
    function svg(name) {
        return assetPath + "img/icons/" + name + ".svg"
    }
    function svgImg(name) {
        return assetPath + "img/" + name + ".svg"
    }
}
