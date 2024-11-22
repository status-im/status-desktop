import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.status 1.0

import SortFilterProxyModel 0.2

import "../helpers"

Item {
    id: root

    property var sharedKeycardModule

    signal keyPairSelected()

    QtObject {
        id: d
        readonly property int profilePairTypeValue: Constants.keycard.keyPairType.profile
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: Theme.xlPadding
        anchors.bottomMargin: Theme.halfPadding
        anchors.leftMargin: Theme.xlPadding
        anchors.rightMargin: Theme.xlPadding
        spacing: Theme.padding
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
            Layout.preferredHeight: Theme.halfPadding
            Layout.fillHeight: root.sharedKeycardModule.keyPairModel.count === 0
        }

        StatusBaseText {
            visible: !userProfile.isKeycardUser
            Layout.preferredWidth: parent.width - 2 * Theme.padding
            Layout.leftMargin: Theme.padding
            Layout.alignment: Qt.AlignLeft
            text: qsTr("Profile key pair")
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.baseColor1
            wrapMode: Text.WordWrap
        }

        KeyPairList {
            visible: !userProfile.isKeycardUser
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            Layout.fillHeight: visible && root.sharedKeycardModule.keyPairModel.count === 1
            Layout.alignment: Qt.AlignLeft
            Layout.preferredWidth: parent.width

            modelFilters: ExpressionFilter {
                expression: model.keyPair.pairType === d.profilePairTypeValue
            }
            keyPairModel: root.sharedKeycardModule.keyPairModel
            buttonGroup: keyPairsButtonGroup

            onKeyPairSelected: {
                root.sharedKeycardModule.setSelectedKeyPair(keyUid)
                root.keyPairSelected()
            }
        }

        StatusBaseText {
            visible: userProfile.isKeycardUser && root.sharedKeycardModule.keyPairModel.count > 0 ||
                     !userProfile.isKeycardUser && root.sharedKeycardModule.keyPairModel.count > 1
            Layout.preferredWidth: parent.width - 2 * Theme.padding
            Layout.leftMargin: Theme.padding
            Layout.alignment: Qt.AlignLeft
            text: qsTr("Other key pairs")
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.baseColor1
            wrapMode: Text.WordWrap
        }

        KeyPairList {
            visible: userProfile.isKeycardUser && root.sharedKeycardModule.keyPairModel.count > 0 ||
                     !userProfile.isKeycardUser && root.sharedKeycardModule.keyPairModel.count > 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft
            Layout.preferredWidth: parent.width

            modelFilters: ExpressionFilter {
                expression: model.keyPair.pairType === d.profilePairTypeValue
                inverted: true
            }
            keyPairModel: root.sharedKeycardModule.keyPairModel
            buttonGroup: keyPairsButtonGroup

            onKeyPairSelected: {
                root.sharedKeycardModule.setSelectedKeyPair(keyUid)
                root.keyPairSelected()
            }
        }
    }
}
