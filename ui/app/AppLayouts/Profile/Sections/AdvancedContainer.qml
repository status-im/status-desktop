import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
    id: advancedContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: title
        //% "Advanced settings"
        text: qsTrId("advanced-settings")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    RowLayout {
        id: walletTabSettings
        anchors.top: title.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24

        StyledText {
            //% "Wallet Tab"
            text: qsTrId("wallet-tab")
        }
        StatusSwitch {
            checked: appSettings.walletEnabled
            onCheckedChanged: function(value) {
                appSettings.walletEnabled = this.checked
            }
        }
        StyledText {
            //% "NOT RECOMMENDED - Use at your own risk"
            text: qsTrId("not-recommended---use-at-your-own-risk")
        }
    }

    RowLayout {
        id: browserTabSettings
        anchors.top: walletTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Browser Tab"
            text: qsTrId("browser-tab")
        }
        StatusSwitch {
            checked: appSettings.browserEnabled
            onCheckedChanged: function(value) {
                appSettings.browserEnabled = this.checked
            }
        }
        StyledText {
            //% "experimental (web3 not supported yet)"
            text: qsTrId("experimental-(web3-not-supported-yet)")
        }
    }

    RowLayout {
        id: nodeTabSettings
        anchors.top: browserTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        StyledText {
            //% "Node Management Tab"
            text: qsTrId("node-management-tab")
        }
        StatusSwitch {
            checked: nodeBtn.enabled
            onCheckedChanged: function(value) {
                nodeBtn.enabled = this.checked
            }
        }
        StyledText {
            //% "under development"
            text: qsTrId("under-development")
        }
    }

    Item {
        id: networkTabSettings
        anchors.top: nodeTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        width: parent.width - 20
        height: networkText.height

        StyledText {
            id: networkText
            text: qsTr("Network")
            font.pixelSize: 15
        }
        
        StyledText {
            text: qsTrId(profileModel.network)
            font.pixelSize: 15
            anchors.right: caret3.left
            anchors.rightMargin: Style.current.padding
        }

        SVGImage {
            id: caret3
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.verticalCenter: networkText.verticalCenter
            source: "../../../img/caret.svg"
            width: 13
            height: 7
            rotation: -90
        }
        
        ColorOverlay {
            anchors.fill: caret3
            source: caret2
            color: Style.current.darkGrey
            rotation: -90
        }

        NetworksModal {
            id: networksModal
        }

        MouseArea {
            anchors.fill: parent
            onClicked: networksModal.open()
            cursorShape: Qt.PointingHandCursor
        }
    }

    Item {
        id: fleetSetting
        anchors.top: networkTabSettings.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        width: parent.width - 20
        height: fleetText.height

        StyledText {
            id: fleetText
            text: qsTr("Fleet")
            font.pixelSize: 15
        }

        StyledText {
            text: profileModel.fleets.fleet
            font.pixelSize: 15
            anchors.right: caret2.left
            anchors.rightMargin: Style.current.padding
        }

        SVGImage {
            id: caret2
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.verticalCenter: fleetText.verticalCenter
            source: "../../../img/caret.svg"
            width: 13
            height: 7
            rotation: -90
        }
        
        ColorOverlay {
            anchors.fill: caret2
            source: caret2
            color: Style.current.darkGrey
            rotation: -90
        }

        FleetsModal {
            id: fleetModal
        }

        MouseArea {
            anchors.fill: parent
            onClicked: fleetModal.open()
            cursorShape: Qt.PointingHandCursor
        }
    }

    RowLayout {
        id: uiCatalog
        anchors.top: fleetSetting.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 24
        Component.onCompleted: {
            uiComponentBtn.enabled = false
        }

        StyledText {
            //% "UI Components"
            text: qsTrId("ui-components")
        }

        StatusSwitch {
            checked: uiComponentBtn.enabled
            onCheckedChanged: function(value) {
                uiComponentBtn.enabled = this.checked
            }
        }
        StyledText {
            //% "Developer setting"
            text: qsTrId("developer-setting")
        }
    }
}

/*##^##
Designer {
    D{i:0;height:400;width:700}
}
##^##*/
