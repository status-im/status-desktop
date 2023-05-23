import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Dialog {
    id: root

    property string subtitle
    /*!
       \qmlproperty destroyOnClose
        This property decides whether the popup component should be destroyed when closed. Default value is true.
    */
    property bool destroyOnClose: true
    /*!
       \qmlproperty color backgroundColor
        This property decides the modal background color
    */
    property string backgroundColor: Theme.palette.statusModal.backgroundColor

    anchors.centerIn: Overlay.overlay

    padding: 16
    margins: 64
    modal: true

    standardButtons: Dialog.Cancel | Dialog.Ok

    Overlay.modal: Rectangle {
        color: Theme.palette.backdropColor
    }

    background: StatusDialogBackground {
        color: root.backgroundColor
    }

    header: StatusDialogHeader {
        visible: root.title || root.subtitle
        headline.title: root.title
        headline.subtitle: root.subtitle
        actions.closeButton.onClicked: root.close()
    }

    footer: StatusDialogFooter {
        id: footerItem

        readonly property int rejectRoleFlags: Dialog.Cancel | Dialog.Close | Dialog.Abort
        readonly property int noRoleFlags: Dialog.No | Dialog.NoToAll
        readonly property int acceptRoleFlags: Dialog.Ok | Dialog.Open | Dialog.Save | Dialog.SaveAll | Dialog.Retry | Dialog.Ignore
        readonly property int yesRoleFlags: Dialog.Yes | Dialog.YesToAll

        visible: rightButtons &&
                 root.standardButtons & (rejectRoleFlags | noRoleFlags | acceptRoleFlags | yesRoleFlags | Dialog.ApplyRole)

        rightButtons: ObjectModel {
            StatusButton {
                visible: root.standardButtons & footerItem.rejectRoleFlags
                type: StatusButton.Danger
                text: {
                    if (root.standardButtons & Dialog.Close) return qsTr("Close")
                    if (root.standardButtons & Dialog.Abort) return qsTr("Abort")
                    return qsTr("Cancel")
                }

                onClicked: root.reject()
            }

            StatusButton {
                visible: root.standardButtons & footerItem.noRoleFlags
                type: StatusButton.Danger
                text: {
                    if (root.standardButtons & Dialog.NoToAll) return qsTr("No to all")
                    return qsTr("No")
                }

                onClicked: root.reject()
            }

            StatusButton {
                visible: root.standardButtons & footerItem.acceptRoleFlags
                text: {
                    if (root.standardButtons & Dialog.Open) return qsTr("Open")
                    if (root.standardButtons & Dialog.Save) return qsTr("Save")
                    if (root.standardButtons & Dialog.SaveAll) return qsTr("Save all")
                    if (root.standardButtons & Dialog.Retry) return qsTr("Retry")
                    if (root.standardButtons & Dialog.Ignore) return qsTr("Ignore")
                    return qsTr("Ok")
                }

                onClicked: root.accept()
            }

            StatusButton {
                visible: root.standardButtons & footerItem.yesRoleFlags
                type: StatusButton.Danger
                text: {
                    if (root.standardButtons & Dialog.YesToAll) return qsTr("Yes to all")
                    return qsTr("Yes")
                }

                onClicked: root.accept()
            }

            StatusButton {
                visible: root.standardButtons & Dialog.ApplyRole
                text: qsTr("Apply")

                onClicked: root.applied()
            }
        }
    }

    onClosed: {
        if (root.destroyOnClose)
            root.destroy();
    }
}
