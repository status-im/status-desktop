import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "./components"
import "./constants.js" as ProfileConstants

ScrollView {
    property int profileCurrentIndex: ProfileConstants.PROFILE
    readonly property int btnheight: 42
    readonly property int w: 340
    property var changeProfileSection: function (sectionId) {
        profileCurrentIndex = sectionId
    }

    id: profileMenu

    Column {
        anchors.fill: parent
        spacing: 8

        Repeater {
            model: ProfileConstants.menuButtons
            delegate: MenuButton {
                menuItemId: modelData.id
                text: modelData .text
                source: "../../../img/profile/" + modelData.filename
                active: profileMenu.profileCurrentIndex === modelData.id
                Layout.fillWidth: true
                onClicked: function () {
                    profileMenu.profileCurrentIndex = modelData.id
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:340}
}
##^##*/
