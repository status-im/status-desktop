import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "../stores"

Column {
    id: root

    property AddAccountStore store

    padding: Style.current.padding
    state: {
        if (root.store.editMode) {
            return d.expandedState
        }

        root.store.addAccountModule.actionAuthenticated? d.expandedState : d.collapsedState
    }

    QtObject {
        id: d

        readonly property string expandedState: "expanded"
        readonly property string collapsedState: "collapsed"
    }

    RowLayout {
        width: parent.width - 2 * root.padding
        height: 64
        visible: !root.store.editMode

        StatusBaseText {
            font.pixelSize: Constants.addAccountPopup.labelFontSize1
            textFormat: Text.RichText
            text: {
                let t = qsTr("Derivation path")
                let t1 = qsTr("(advanced)")
                return `%1 <font color="${Theme.palette.baseColor1}">%2</font>`.arg(t).arg(t1)
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
        }

        StatusButton {
            objectName: "AddAccountPopup-EditDerivationPath"
            visible: !root.store.addAccountModule.actionAuthenticated
            text: qsTr("Edit")

            icon.name: {
                if (root.store.selectedOrigin.keyUid === root.store.userProfileKeyUid &&
                        root.store.userProfileUsingBiometricLogin) {
                    return "touch-id"
                }

                if (root.store.selectedOrigin.migratedToKeycard || root.store.userProfileIsKeycardUser) {
                    return "keycard"
                }

                return "password"
            }

            onClicked: {
                root.store.authenticateForEditingDerivationPath()
            }
        }

        StatusIcon {
            id: expandImage
            visible: root.store.addAccountModule.actionAuthenticated
            color: Theme.palette.baseColor1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.state === d.expandedState) {
                        root.state = d.collapsedState
                        return
                    }
                    root.state = d.expandedState

                    root.state = Qt.binding(function(){ return root.store.addAccountModule.actionAuthenticated? d.expandedState : d.collapsedState })
                }
            }
        }
    }

    DerivationPath {
        id: derivationPathContent
        visible: !root.store.editMode
        width: parent.width - 2 * root.padding

        store: root.store
    }

    Loader {
        active: root.store.editMode
        sourceComponent: DerivationPathDisplay {
            width: parent.width - 2 * root.padding
            store: root.store
        }
    }

    states: [
        State {
            name: d.expandedState
            PropertyChanges {target: expandImage; icon: "chevron-up"}
            PropertyChanges {target: derivationPathContent; visible: !root.store.editMode}
        },
        State {
            name: d.collapsedState
            PropertyChanges {target: expandImage; icon: "chevron-down"}
            PropertyChanges {target: derivationPathContent; visible: false}
        }
    ]

    transitions: [
        Transition {
            from: d.collapsedState
            to: d.expandedState
            NumberAnimation { properties: "height"; duration: 200;}
        },
        Transition {
            from: d.expandedState
            to: d.collapsedState
            NumberAnimation { properties: "height"; duration: 200;}
        }
    ]
}
