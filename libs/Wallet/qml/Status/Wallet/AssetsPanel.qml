import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

import Status.Wallet

import Status.Onboarding

import Status.Containers

Item {
    id: root

    /// WalletController
    required property WalletController controller
    readonly property AccountAssetsController currentAssetController: listView.currentItem ? listView.currentItem.assetController : null

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
            // TODO: source it from the last total cached value of balance service,
            text: "-"
        }
        Label {
            text: qsTr("Total value")
        }

        LayoutSpacer {
            Layout.fillHeight: false
            Layout.preferredHeight: 10
        }

        ListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: controller.accountsModel

            onCurrentIndexChanged: controller.setCurrentAccountIndex(currentIndex)

            clip: true

            delegate: ItemDelegate {
                required property int index
                // Enabling type generates 'Writing to "account" broke the binding to the underlying model'
                required property var/*WalletAccount*/ account

                readonly property AccountAssetsController assetController: account && WalletController.createAccountAssetsController(account)

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

                    RowLayout {
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.bottomMargin: 5

                        Label {
                            text: assetController.assetsReady ? assetController.totalValue : "-"
                        }
                        Label {
                            text: "$"
                            color: "grey"
                        }
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

        ColumnLayout {
            visible: !errorLayout.visible && newAccountLoader.active

            Rectangle {
                color: "blue"

                Layout.fillWidth: true
                Layout.preferredHeight: 2
                Layout.margins: 5
            }

            ComboBox {
                id: accountTypeComboBox

                textRole: "title"
                valueRole: "sourceComponent"

                Layout.fillWidth: true

                component NewAccountEntry: ItemDelegate {
                    required property string title
                    required property Component sourceComponent

                    text: title
                    width: accountTypeComboBox.width
                }
                model: ObjectModel {
                    NewAccountEntry {
                        title: qsTr("New Account")
                        sourceComponent: NewWalletAccountView {
                            controller: root.controller.createNewWalletAccountController()
                        }
                    }
                    NewAccountEntry {
                        title: qsTr("Watch Only Account")
                        sourceComponent: AddWatchOnlyAccountView {
                            controller: root.controller.createNewWalletAccountController()
                        }
                    }
                }
            }

            Loader {
                id: newAccountLoader

                Layout.fillWidth: true

                active: false

                sourceComponent: accountTypeComboBox.currentValue
            }

            Connections {
                target: newAccountLoader.item ? newAccountLoader.item.controller : null
                function onAccountCreatedStatus(createdSuccessfully) {
                    if(createdSuccessfully)
                        newAccountLoader.active = false
                    else
                        errorLayout.visible = true
                }
            }
            Connections {
                target: newAccountLoader.item
                function onCancel() { newAccountLoader.active = false }
                function onAccountCreated() { newAccountLoader.active = false }
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
