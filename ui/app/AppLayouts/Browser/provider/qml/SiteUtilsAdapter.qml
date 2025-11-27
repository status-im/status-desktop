import QtQuick
import QtWebChannel

QtObject {
    id: root

    signal clearSiteDataAndReloadRequested()

    function clearSiteDataAndReload() {
        clearSiteDataAndReloadRequested()
    }
}
