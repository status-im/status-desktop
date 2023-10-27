import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.popups.keycard.helpers 1.0

import SortFilterProxyModel 0.2

ColumnLayout {
    id: root

    property var keypairSigningModel

    readonly property string title: qsTr("Prove ownership of keypairs")
    readonly property var rightButtons: [d.rightBtn]
    readonly property bool allSigned: regularKeypairs.visible == d.sharedAddressesForAllNonKeycardKeypairsSigned &&
                                      keycardKeypairs.visible == d.allKeycardKeypairsSigned

    signal joinCommunity()
    signal signSharedAddressesForAllNonKeycardKeypairs()
    signal signSharedAddressesForKeypair(string keyUid)

    function sharedAddressesForAllNonKeycardKeypairsSigned() {
        d.sharedAddressesForAllNonKeycardKeypairsSigned = true
    }

    QtObject {
        id: d

        property bool sharedAddressesForAllNonKeycardKeypairsSigned: false
        property bool allKeycardKeypairsSigned: false

        readonly property var rightBtn: StatusButton {
            enabled: root.allSigned
            text: qsTr("Share your addresses to join")
            onClicked: {
                root.joinCommunity()
            }
        }

        function reEvaluateSignedKeypairs() {
            let allKeypairsSigned = true
            for(var i = 0; i< keycardKeypairs.model.count; i++) {
                if(!keycardKeypairs.model.get(i).keyPair.ownershipVerified) {
                    allKeypairsSigned = false
                    break
                }
            }

            d.allKeycardKeypairsSigned = allKeypairsSigned
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.margins: Style.current.xlPadding

        spacing: Style.current.padding

        RowLayout {
            Layout.fillWidth: true

            visible: regularKeypairs.visible

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Keypairs we need an authentication for")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
                wrapMode: Text.WordWrap
            }

            StatusButton {
                text: d.sharedAddressesForAllNonKeycardKeypairsSigned? qsTr("Authenticated") : qsTr("Authenticate")
                enabled: !d.sharedAddressesForAllNonKeycardKeypairsSigned
                icon.name: userProfile.usingBiometricLogin? "touch-id" : "password"

                onClicked: {
                    root.signSharedAddressesForAllNonKeycardKeypairs()
                }
            }
        }

        StatusListView {
            id: regularKeypairs
            Layout.fillWidth: true
            Layout.preferredHeight: regularKeypairs.contentHeight
            visible: regularKeypairs.model.count > 0
            spacing: Style.current.padding
            model: SortFilterProxyModel {
                sourceModel: root.keypairSigningModel
                filters: ExpressionFilter {
                    expression: !model.keyPair.migratedToKeycard
                }
            }
            delegate: KeyPairItem {
                width: ListView.view.width
                sensor.hoverEnabled: false
                additionalInfoForProfileKeypair: ""

                keyPairType: model.keyPair.pairType
                keyPairKeyUid: model.keyPair.keyUid
                keyPairName: model.keyPair.name
                keyPairIcon: model.keyPair.icon
                keyPairImage: model.keyPair.image
                keyPairDerivedFrom: model.keyPair.derivedFrom
                keyPairAccounts: model.keyPair.accounts
            }
        }

        Item {
            visible: regularKeypairs.visible && keycardKeypairs.visible
            Layout.fillWidth: true
            Layout.preferredHeight: Style.current.xlPadding
        }

        StatusBaseText {
            Layout.fillWidth: true
            visible: keycardKeypairs.visible
            text: qsTr("Keypairs that need to be singed using appropriate Keycard")
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.baseColor1
            wrapMode: Text.WordWrap
        }

        StatusListView {
            id: keycardKeypairs
            Layout.fillWidth: true
            Layout.preferredHeight: keycardKeypairs.contentHeight
            visible: keycardKeypairs.model.count > 0
            spacing: Style.current.padding
            model: SortFilterProxyModel {
                sourceModel: root.keypairSigningModel
                filters: ExpressionFilter {
                    expression: model.keyPair.migratedToKeycard
                }
            }
            delegate: KeyPairItem {
                width: ListView.view.width
                sensor.hoverEnabled: !model.keyPair.ownershipVerified
                additionalInfoForProfileKeypair: ""

                keyPairType: model.keyPair.pairType
                keyPairKeyUid: model.keyPair.keyUid
                keyPairName: model.keyPair.name
                keyPairIcon: model.keyPair.icon
                keyPairImage: model.keyPair.image
                keyPairDerivedFrom: model.keyPair.derivedFrom
                keyPairAccounts: model.keyPair.accounts

                components: [
                    StatusBaseText {
                        font.weight: Font.Medium
                        font.underline: mouseArea.containsMouse
                        font.pixelSize: Theme.primaryTextFontSize
                        color: model.keyPair.ownershipVerified? Theme.palette.baseColor1 : Theme.palette.primaryColor1
                        text: model.keyPair.ownershipVerified? qsTr("Signed") : qsTr("Sign")
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            hoverEnabled: !model.keyPair.ownershipVerified
                            enabled: !model.keyPair.ownershipVerified
                            onEnabledChanged: {
                                d.reEvaluateSignedKeypairs()
                            }
                            onClicked: {
                                root.signSharedAddressesForKeypair(model.keyPair.keyUid)
                            }
                        }
                    }
                ]
            }
        }
    }
}
