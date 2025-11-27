import QtQuick
import QtWebChannel

QtObject {
    id: root

    signal clearSiteDataRequested()

    function clearSiteData() {
        clearSiteDataRequested()
    }
}
