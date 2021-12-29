import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var languageModule

    function changeLocale(locale) {
        root.languageModule.changeLocale(locale)
    }
}
