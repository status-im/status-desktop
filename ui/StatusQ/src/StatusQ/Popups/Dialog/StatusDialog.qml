import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Dialog {
    id: root

    property string subtitle

    /*!
       \qmlproperty bool destroyOnClose
        This property decides whether the popup component should be destroyed when closed. Default value is false.
    */
    property bool destroyOnClose: false

    /*!
       \qmlproperty color backgroundColor
        This property decides the modal background color
    */
    property color backgroundColor: Theme.palette.statusModal.backgroundColor

    /*!
       \qmlproperty var closeHandler
        This property decides the action to be performed when the close button is clicked. It allows to define
        a custom function to be called when the popup is closed by the user.
    */
    property var closeHandler: root.close

    /*!
       \qmlproperty string okButtonText
        This property decides what text to use for an "OK" button
    */
    property string okButtonText: qsTr("OK")

    readonly property bool bottomSheet: d.windowHeight
                                        > d.windowWidth
                                        && d.windowWidth
                                        <= Theme.portraitBreakpoint.width // The max width of a phone in portrait mode

    readonly property real desiredY: root.bottomSheet ? root.contentItem.Window.height - root.height : ((root.Overlay.overlay.height - root.height) / 2)

    QtObject {
        id: d

        readonly property int windowWidth: root.contentItem.Window ? root.contentItem.Window.width: Screen.width
        readonly property int windowHeight: root.contentItem.Window? root.contentItem.Window.height : Screen.height
    }

    enter: Transition {
        id: enterTransition
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 150
            }
            NumberAnimation {
                property: "y"
                from: root.parent.height
                to: root.desiredY
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    enabled: opened

    Binding on width {
        when: root.bottomSheet
        restoreMode: Binding.RestoreBindingOrValue
        value: d.windowWidth
    }
    Binding on height {
        when: root.bottomSheet && !enterTransition.running
        restoreMode: Binding.RestoreBindingOrValue
        value: Math.min(root.implicitHeight, d.windowHeight * 0.9)
    }
    Binding on y {
        when: root.bottomSheet && !enterTransition.running
        restoreMode: Binding.RestoreBindingOrValue
        value: root.desiredY
    }

    Binding on y {
        when: !root.bottomSheet && !enterTransition.running
        restoreMode: Binding.RestoreBindingOrValue
        value: (d.windowHeight - root.height) / 2
    }

    Binding on x {
        when: !root.bottomSheet
        restoreMode: Binding.RestoreBindingOrValue
        value: (d.windowWidth - root.width) / 2
    }

    Binding on x {
        when: root.bottomSheet
        restoreMode: Binding.RestoreBindingOrValue
        value: 0
    }

    parent: Overlay.overlay

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
        actions.closeButton.onClicked: root.closeHandler()
    }

    footer: StatusDialogFooter {
        id: footerItem

        readonly property int rejectRoleFlags: Dialog.Cancel | Dialog.Close | Dialog.Abort
        readonly property int noRoleFlags: Dialog.No | Dialog.NoToAll
        readonly property int acceptRoleFlags: Dialog.Ok | Dialog.Open | Dialog.Save
                                               | Dialog.SaveAll | Dialog.Retry | Dialog.Ignore
        readonly property int yesRoleFlags: Dialog.Yes | Dialog.YesToAll

        visible: rightButtons
                 && root.standardButtons & (rejectRoleFlags | noRoleFlags | acceptRoleFlags
                                            | yesRoleFlags | Dialog.ApplyRole)

        rightButtons: ObjectModel {
            StatusButton {
                visible: root.standardButtons & footerItem.rejectRoleFlags
                type: StatusButton.Danger
                text: {
                    if (root.standardButtons & Dialog.Close)
                        return qsTr("Close")
                    if (root.standardButtons & Dialog.Abort)
                        return qsTr("Abort")
                    return qsTr("Cancel")
                }

                onClicked: root.reject()
            }

            StatusButton {
                visible: root.standardButtons & footerItem.noRoleFlags
                type: StatusButton.Danger
                text: {
                    if (root.standardButtons & Dialog.NoToAll)
                        return qsTr("No to all")
                    return qsTr("No")
                }

                onClicked: root.reject()
            }

            StatusButton {
                visible: root.standardButtons & footerItem.acceptRoleFlags
                text: {
                    if (root.standardButtons & Dialog.Open)
                        return qsTr("Open")
                    if (root.standardButtons & Dialog.Save)
                        return qsTr("Save")
                    if (root.standardButtons & Dialog.SaveAll)
                        return qsTr("Save all")
                    if (root.standardButtons & Dialog.Retry)
                        return qsTr("Retry")
                    if (root.standardButtons & Dialog.Ignore)
                        return qsTr("Ignore")
                    return root.okButtonText
                }

                onClicked: root.accept()
            }

            StatusButton {
                visible: root.standardButtons & footerItem.yesRoleFlags
                type: StatusButton.Danger
                text: {
                    if (root.standardButtons & Dialog.YesToAll)
                        return qsTr("Yes to all")
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
        if (root.destroyOnClose) {
            root.destroy()
        }
    }
}
