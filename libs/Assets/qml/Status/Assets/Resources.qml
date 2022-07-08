pragma Singleton

import QtQml

QtObject {
    readonly property string assetPath: "qrc:/Status/UiAssets"

    function svg(name) {
        return assetPath + "/icons/" + name + ".svg";
    }
    function lottie(name) {
        return assetPath + "/lottie/" + name + ".json";
    }
    function gif(name) {
        return assetPath + "/gif/" + name + ".gif";
    }
    function png(name) {
        return assetPath + "/png/" + name + ".png";
    }
}
