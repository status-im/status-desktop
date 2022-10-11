import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.panels 1.0
import shared.controls 1.0
import shared.status 1.0
import shared.popups.keycard.helpers 1.0

import "../../stores"

ColumnLayout {
    id: root

    property KeycardStore keycardStore

    signal displayKeycardDetails(string keycardUid, string keycardName)

    spacing: Constants.settingsSection.itemSpacing

    QtObject {
        id: d

        readonly property bool noKeycardsSet: root.keycardStore.keycardModule.keycardModel.count === 0
    }

    Image {
        visible: d.noKeycardsSet
        Layout.alignment: Qt.AlignCenter
        Layout.preferredHeight: sourceSize.height
        Layout.preferredWidth: sourceSize.width
        fillMode: Image.PreserveAspectFit
        antialiasing: true
        source: Style.png("keycard/security-keycard@2x")
        mipmap: true
    }

    Item {
        visible: d.noKeycardsSet
        Layout.fillWidth: true
        Layout.preferredHeight: Style.current.halfPadding
    }

    StyledText {
        visible: d.noKeycardsSet
        Layout.alignment: Qt.AlignCenter
        font.pixelSize: Constants.settingsSection.importantInfoFontSize
        color: Theme.palette.directColor1
        text: qsTr("Secure your funds. Keep your profile safe.")
    }

    Item {
        visible: d.noKeycardsSet
        Layout.fillWidth: true
        Layout.preferredHeight: Style.current.halfPadding
    }

    StatusSectionHeadline {
        visible: !d.noKeycardsSet
        Layout.fillWidth: true
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.padding
        text: qsTr("Your Keycard(s)")
    }

    ListView {
        visible: !d.noKeycardsSet
        Layout.fillWidth: true
        Layout.preferredHeight: 200
        spacing: Style.current.padding
        model: root.keycardStore.keycardModule.keycardModel

        delegate: KeycardItem {
            width: ListView.view.width

            keycardName: model.name
            keycardLocked: model.locked
            keyPairType: model.pairType
            keyPairIcon: model.icon
            keyPairImage: model.image
            keyPairAccounts: model.accounts

            onKeycardSelected: {
                root.displayKeycardDetails(model.keycardUid, model.name)
            }
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: d.noKeycardsSet? qsTr("Setup a new Keycard with an existing account")
                              : qsTr("Migrate an existing account from Status Desktop to Keycard")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runSetupKeycardPopup()
        }
    }

    StatusSectionHeadline {
        Layout.fillWidth: true
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.padding
        text: qsTr("Create, import or restore a Keycard account")
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Generate a seed phrase")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runGenerateSeedPhrasePopup()
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Import or restore via a seed phrase")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runImportOrRestoreViaSeedPhrasePopup()
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Import from Keycard to Status Desktop")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runImportFromKeycardToAppPopup()
        }
    }

    StatusSectionHeadline {
        Layout.fillWidth: true
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.padding
        text: qsTr("Other")
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Check what’s on a Keycard")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runDisplayKeycardContentPopup()
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Factory reset a Keycard")
        components: [
            StatusIcon {
                icon: "tiny/chevron-right"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runFactoryResetPopup()
        }
    }
}
