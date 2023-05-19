import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import shared.controls 1.0

import utils 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: loader
            anchors.margins: -1
            color: "transparent"
            border.width: 1
            border.color: "#20000000"
        }

        // globalUtilsInst mock
        QtObject {
            function getCompressedPk(publicKey) { return "zx3sh" + publicKey }
            function getColorHashAsJson(publicKey) {
                return JSON.stringify([{"segmentLength":1,"colorId":12},{"segmentLength":5,"colorId":18},
                                       {"segmentLength":3,"colorId":25},{"segmentLength":3,"colorId":23},
                                       {"segmentLength":1,"colorId":10},{"segmentLength":3,"colorId":26},
                                       {"segmentLength":2,"colorId":30},{"segmentLength":1,"colorId":18},
                                       {"segmentLength":4,"colorId":28},{"segmentLength":1,"colorId":17},
                                       {"segmentLength":2,"colorId":2}])
            }
            function isCompressedPubKey(publicKey) { return true }
            function getColorId(publicKey) { return Math.floor(Math.random() * 10) }

            Component.onCompleted: {
                Utils.globalUtilsInst = this
                root.globalUtilsReady = true
            }
            Component.onDestruction: {
                root.globalUtilsReady = false
                Utils.globalUtilsInst = {}
            }
        }

        // mainModuleInst mock
        QtObject {
            function getContactDetailsAsJson(publicKey, getVerification) {
                return JSON.stringify({
                    displayName: "ArianaP",
                    displayIcon: "",
                    publicKey: publicKey,
                    name: "",
                    alias: "",
                    localNickname: "",
                    isContact: true
                })
            }
            function isEnsVerified(publicKey) { return false }

            Component.onCompleted: {
                Utils.mainModuleInst = this
                root.mainModuleReady = true
            }
            Component.onDestruction: {
                root.mainModuleReady = false
                Utils.mainModuleInst = {}
            }
        }

        QtObject {
            id: d
            property string addressPrefixString: "eth:opt:arb:"
            property string addressName: "Ariana Pearlona"
            property bool isContact: true
            property bool showPrefix: true
            property bool showAddressName: true
        }

        Loader {
            id: loader
            anchors.centerIn: parent
            width: 400
            active: root.globalUtilsReady && root.mainModuleReady
            sourceComponent: TransactionAddress {
                width: parent.width
                address: (d.showPrefix ? d.addressPrefixString : "") + "0x29D7d1dd5B6f9C864d9db560D72a247c178aE86B"
                addressName: d.showAddressName ? d.addressName : ""
                contactPubKey: d.isContact ? "zQ3shWU7xpM5YoG19KP5JDRiSs1AdWtjpnrWEerMkxfQnYo7x" : ""
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        SplitView.fillWidth: true

        ColumnLayout {
            spacing: 5
            CheckBox {
                text: "is contact"
                checked: d.isContact
                onCheckedChanged: d.isContact = checked
            }
            Label {
                text: "Address prefix:"
            }
            RowLayout {
                TextField {
                    text: d.addressPrefixString
                    onTextChanged: d.addressPrefixString = text
                }
                CheckBox {
                    text: "Show"
                    checked: d.showPrefix
                    onCheckedChanged: d.showPrefix = checked
                }
            }
            Label {
                text: "Address name:"
            }
            RowLayout {
                TextField {
                    text: d.addressName
                    onTextChanged: d.addressName = text
                }
                CheckBox {
                    text: "use"
                    checked: d.showAddressName
                    onCheckedChanged: d.showAddressName = checked
                }
            }
        }
    }
}
