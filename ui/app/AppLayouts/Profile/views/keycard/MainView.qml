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

    signal displayKeycardsForKeypair(string keyUid, string keypairName)

    spacing: Constants.settingsSection.itemSpacing

    QtObject {
        id: d

        readonly property bool noKeycardsSet: root.keycardStore.keycardModule.keycardModel.count === 0
    }

    Image {
        visible: d.noKeycardsSet
        Layout.alignment: Qt.AlignCenter
        Layout.preferredHeight: 240
        Layout.preferredWidth: 350
        fillMode: Image.PreserveAspectFit
        antialiasing: true
        source: Style.png("keycard/keycard-security")
        mipmap: true
        cache: false
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

    StatusListView {
        visible: !d.noKeycardsSet
        Layout.fillWidth: true
        Layout.preferredHeight: 250
        spacing: Style.current.padding
        model: root.keycardStore.keycardModule.keycardModel

        delegate: KeycardItem {
            width: ListView.view.width

            keycardName: model.keycard.name
            keycardLocked: model.keycard.locked
            keyPairType: model.keycard.pairType
            keyPairIcon: model.keycard.icon
            keyPairImage: model.keycard.image
            keyPairAccounts: model.keycard.accounts

            onKeycardSelected: {
                root.displayKeycardsForKeypair(model.keycard.keyUid, model.keycard.name)
            }
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: d.noKeycardsSet? qsTr("Setup a new Keycard with an existing account")
                              : qsTr("Migrate an existing account from Status Desktop to Keycard")
        objectName: "setupFromExistingKeycardAccount"
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runSetupKeycardPopup("")
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
        title: qsTr("Create a new Keycard account with a new seed phrase")
        objectName: "createNewKeycardAccount"
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runCreateNewKeycardWithNewSeedPhrasePopup()
        }
    }

    StatusListItem {
        Layout.fillWidth: true
        title: qsTr("Import or restore via a seed phrase")
        objectName: "importRestoreKeycard"
        components: [
            StatusIcon {
                icon: "next"
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
        objectName: "importFromKeycard"
        components: [
            StatusIcon {
                icon: "next"
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
        objectName: "checkWhatsNewKeycard"
        components: [
            StatusIcon {
                icon: "next"
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
        objectName: "factoryResetKeycard"
        components: [
            StatusIcon {
                icon: "next"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            root.keycardStore.runFactoryResetPopup()
        }
    }
}
