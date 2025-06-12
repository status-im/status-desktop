import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Utils 0.1

import QtModelsToolkit 1.0
import SortFilterProxyModel 0.2

Control {
    id: root

    // [{keyUid:string, username:string, thumbnailImage:string, colorId:int, colorHash:var, order:int, keycardCreatedAccount:bool}]
    required property var model
    required property bool currentKeycardLocked

    readonly property string selectedProfileKeyId: currentEntry.value
    readonly property bool keycardCreatedAccount: currentEntry.available ? currentEntry.item.keycardCreatedAccount : false

    signal onboardingCreateProfileFlowRequested()
    signal onboardingLoginFlowRequested()

    function setSelection(keyUid: string) {
        let selection = keyUid
        if (!ModelUtils.contains(root.model, "keyUid", selection)) // get first item if not existing (or empty)
            selection = ModelUtils.get(root.model, 0, "keyUid")

        currentEntry.value = selection
    }

    QtObject {
        id: d

        readonly property int maxPopupHeight: 300
        readonly property int delegateHeight: 64
    }

    ModelEntry {
        id: currentEntry

        sourceModel: root.model
        key: "keyUid"
        value: ""
    }

    contentItem: LoginUserSelectorDelegate {
        id: userSelectorButton
        states: [
            State {
                when: currentEntry.available
                PropertyChanges {
                    target: userSelectorButton

                    label: currentEntry.item.username
                    image: currentEntry.item.thumbnailImage
                    colorHash: currentEntry.item.colorHash
                    colorId: currentEntry.item.colorId
                    keycardCreatedAccount: currentEntry.item.keycardCreatedAccount
                    keycardLocked: root.currentKeycardLocked
                }
            }
        ]
        background: Rectangle {
            color: userSelectorButton.hovered ? Theme.palette.baseColor2 : "transparent"
            border.width: 1
            border.color: Theme.palette.baseColor2
            radius: Theme.radius
        }
        rightPadding: spacing + Theme.padding + chevronIcon.width

        StatusIcon {
            id: chevronIcon
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            anchors.verticalCenter: parent.verticalCenter
            icon: "chevron-down"
            color: Theme.palette.baseColor1
        }

        onClicked: dropdown.opened ? dropdown.close() : dropdown.open()
    }

    StatusDropdown {
        id: dropdown
        objectName: "dropdown"

        closePolicy: Popup.CloseOnPressOutsideParent | Popup.CloseOnEscape

        y: parent.height + 2
        width: root.width

        verticalPadding: Theme.halfPadding
        horizontalPadding: 0

        contentItem: ColumnLayout {
            spacing: 0
            StatusListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: d.maxPopupHeight
                id: userSelectorPanel
                model: SortFilterProxyModel {
                    id: proxyModel
                    sourceModel: root.model
                    sorters: RoleSorter {
                        roleName: "order"
                    }
                    filters: ValueFilter { // don't show the currently selected item
                        roleName: "keyUid"
                        value: root.selectedProfileKeyId
                        inverted: true
                    }
                }
                implicitHeight: contentHeight
                spacing: 0
                delegate: LoginUserSelectorDelegate {
                    width: ListView.view.width
                    height: d.delegateHeight
                    label: model.username
                    image: model.thumbnailImage
                    colorId: model.colorId
                    colorHash: model.colorHash
                    keycardCreatedAccount: model.keycardCreatedAccount
                    onClicked: {
                        dropdown.close()
                        root.setSelection(model.keyUid)
                    }
                }
            }
            StatusMenuSeparator {
                Layout.fillWidth: true
                visible: proxyModel.count > 0
            }
            LoginUserSelectorDelegate {
                Layout.fillWidth: true
                Layout.preferredHeight: d.delegateHeight
                objectName: "createProfileDelegate"
                label: qsTr("Create profile")
                image: "add"
                isAction: true
                onClicked: {
                    dropdown.close()
                    root.onboardingCreateProfileFlowRequested()
                }
            }
            LoginUserSelectorDelegate {
                Layout.fillWidth: true
                Layout.preferredHeight: d.delegateHeight
                objectName: "logInDelegate"
                label: qsTr("Log in")
                image: "profile"
                isAction: true
                onClicked: {
                    dropdown.close()
                    root.onboardingLoginFlowRequested()
                }
            }
        }
    }
}
