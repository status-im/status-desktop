import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.status 1.0

import "../helpers"

Item {
    id: root

    property var sharedKeycardModule

    signal keyPairSelected()

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Style.current.xlPadding
        anchors.bottomMargin: Style.current.halfPadding
        anchors.leftMargin: Style.current.xlPadding
        anchors.rightMargin: Style.current.xlPadding
        spacing: Style.current.padding
        clip: true

        ButtonGroup {
            id: keyPairsButtonGroup
        }

        StatusBaseText {
            id: title
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Select a key pair")
            font.pixelSize: Constants.keycard.general.fontSize1
            font.weight: Font.Bold
            color: Theme.palette.directColor1
            wrapMode: Text.WordWrap
        }

        StatusBaseText {
            id: subTitle
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Select which key pair you’d like to move to this Keycard")
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.baseColor1
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.current.halfPadding
            Layout.fillHeight: root.sharedKeycardModule.keyPairModel.count === 0
        }

        StatusBaseText {
            visible: !root.sharedKeycardModule.isProfileKeyPairMigrated()
            Layout.preferredWidth: parent.width - 2 * Style.current.padding
            Layout.leftMargin: Style.current.padding
            Layout.alignment: Qt.AlignLeft
            text: qsTr("Profile key pair")
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.baseColor1
            wrapMode: Text.WordWrap
        }

        KeyPairList {
            visible: !root.sharedKeycardModule.isProfileKeyPairMigrated()
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            Layout.fillHeight: visible && root.sharedKeycardModule.keyPairModel.count === 1
            Layout.alignment: Qt.AlignLeft
            Layout.preferredWidth: parent.width

            sharedKeycardModule: root.sharedKeycardModule
            filterProfilePair: true
            keyPairModel: root.sharedKeycardModule.keyPairModel
            buttonGroup: keyPairsButtonGroup

            onKeyPairSelected: {
                root.keyPairSelected()
            }
        }

        StatusBaseText {
            visible: root.sharedKeycardModule.isProfileKeyPairMigrated() && root.sharedKeycardModule.keyPairModel.count > 0 ||
                     !root.sharedKeycardModule.isProfileKeyPairMigrated() && root.sharedKeycardModule.keyPairModel.count > 1
            Layout.preferredWidth: parent.width - 2 * Style.current.padding
            Layout.leftMargin: Style.current.padding
            Layout.alignment: Qt.AlignLeft
            text: qsTr("Other key pairs")
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.baseColor1
            wrapMode: Text.WordWrap
        }

        KeyPairList {
            visible: root.sharedKeycardModule.isProfileKeyPairMigrated() && root.sharedKeycardModule.keyPairModel.count > 0 ||
                     !root.sharedKeycardModule.isProfileKeyPairMigrated() && root.sharedKeycardModule.keyPairModel.count > 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft
            Layout.preferredWidth: parent.width

            sharedKeycardModule: root.sharedKeycardModule
            keyPairModel: root.sharedKeycardModule.keyPairModel
            buttonGroup: keyPairsButtonGroup

            onKeyPairSelected: {
                root.keyPairSelected()
            }
        }
    }
}
