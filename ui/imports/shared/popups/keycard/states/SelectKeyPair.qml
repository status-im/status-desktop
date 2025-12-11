import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Core.Utils
import StatusQ.Components
import StatusQ.Controls

import utils
import shared.status

import SortFilterProxyModel

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

        TitleText {
            id: title
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Select a key pair")
            wrapMode: Text.WordWrap
        }

        StatusBaseText {
            id: subTitle
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Select which key pair you’d like to move to this Keycard")
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
