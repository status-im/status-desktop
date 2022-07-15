import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.Wallet

import Status.Onboarding

import Status.Containers

Item {
    id: root

    /// WalletController
    required property WalletController controller

    ColumnLayout {
        anchors.left: leftLine.right
        anchors.top: parent.top
        anchors.right: rightLine.left
        anchors.bottom: parent.bottom

        Label {
            text: qsTr("Wallet")
        }
        Label {
            id: totalValueLabel
            text: "" // TODO: Aggregate or API!?
        }
        Label {
            text: qsTr("Total value")
        }

        LayoutSpacer {
            Layout.fillHeight: false
            Layout.preferredHeight: 10
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: controller.accountsModel

            onCurrentIndexChanged: controller.setCurrentAccountIndex(currentIndex)

            clip: true

            delegate: ItemDelegate {
                highlighted: ListView.isCurrentItem

                width: ListView.view.width

                onClicked: ListView.view.currentIndex = index

                contentItem: ColumnLayout {
                    spacing: 2

                    RowLayout {
                        Rectangle {
                            Layout.preferredWidth: 15
                            Layout.preferredHeight: Layout.preferredWidth
                            Layout.leftMargin: 5
                            Layout.alignment: Qt.AlignVCenter

                            radius: width/2
                            color: account.color
                        }
                        Label {
                            Layout.leftMargin: 10
                            Layout.topMargin: 5
                            Layout.rightMargin: 10
                            Layout.alignment: Qt.AlignVCenter

                            text: account.name

                            verticalAlignment: Qt.AlignVCenter

                            elide: Label.ElideRight
                        }
                    }
                    Label {
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.bottomMargin: 5

                        text: "$"
                        color: "grey"

                        verticalAlignment: Qt.AlignVCenter

                        elide: Label.ElideRight
                    }
                }
            }
        }

        LayoutSpacer {
            Layout.fillHeight: false
            Layout.preferredHeight: 20
        }

        Button {
            text: "+"

            Layout.fillWidth: true
            visible: !(newAccountLoader.active || errorLayout.visible)

            onClicked: newAccountLoader.active = true
        }

        Loader {
            id: newAccountLoader

            Layout.fillWidth: true

            visible: !errorLayout.visible && active
            active: false

            sourceComponent: Component {
                NewWalletAccountView {
                    controller: root.controller.createNewWalletAccountController()

                    onCancel: newAccountLoader.active = false
                    onAccountCreated: newAccountLoader.active = false

                    Connections {
                        target: controller
                        function onAccountCreatedStatus(createdSuccessfully) {
                            if(createdSuccessfully)
                                newAccountLoader.active = false
                            else
                                errorLayout.visible = true
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: errorLayout

            visible: false

            Label {
                text: qsTr("Account creation failed!")
                color: "red"
                Layout.margins: 5
            }
            Button {
                text: qsTr("OK")
                Layout.margins: 5
                onClicked: errorLayout.visible = false
            }
        }
    }

    SideLine { id: leftLine; anchors.left: parent.left }
    SideLine { id: rightLine; anchors.right: parent.right }

    component SideLine: Rectangle {
        color: "black"
        width: 1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
}
