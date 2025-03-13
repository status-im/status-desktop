import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Popups.Dialog 0.1

import Models 1.0
import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Logs { id: logs }

    Rectangle {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        color: "lightgray"

        Button {
            anchors.centerIn: parent
            text: "Reopen"
            onClicked: dlg.open()
        }

        StatusMessageDialog {
            id: dlg
            visible: true
            modal: false
            closePolicy: Popup.NoAutoClose
            anchors.centerIn: parent
            text: ctrlText.text
            standardButtons: sampleModel.count > 0 ? sampleModel.get(ctrlCombo.currentIndex).buttons : Dialog.Ok
            informativeText: ctrlInfoText.text
            detailedText: ctrlDetailedText.text
            icon: ctrlCombo.currentValue
            onAccepted: console.info("accepted")
            onRejected: console.info("rejected")
            onApplied: console.info("applied")
            onDiscarded: console.info("discarded")
            onReset: console.info("reset")
            onHelpRequested: console.info("helpRequested")

            Binding on title {
                value: ctrlTitle.text
                when: ctrlTitle.text !== ""
                restoreMode: Binding.RestoreBindingOrValue
            }
        }
    }

    ListModel {
        id: sampleModel
        Component.onCompleted: append(data)
        readonly property var data: [
            { title: "NoIcon", value: StatusMessageDialog.StandardIcon.NoIcon, buttons: Dialog.Yes | Dialog.No | Dialog.Help },
            { title: "Question", value: StatusMessageDialog.StandardIcon.Question, buttons: Dialog.Yes | Dialog.YesToAll | Dialog.No | Dialog.NoToAll },
            { title: "Information", value: StatusMessageDialog.StandardIcon.Information, buttons:  Dialog.Ok | Dialog.Apply | Dialog.Cancel },
            { title: "Warning", value: StatusMessageDialog.StandardIcon.Warning, buttons: Dialog.Abort | Dialog.Ignore | Dialog.Discard },
            { title: "Critical", value: StatusMessageDialog.StandardIcon.Critical, buttons: Dialog.Reset | Dialog.Close | Dialog.Ok }
        ]
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 300
        SplitView.preferredHeight: 300

        logsView.logText: logs.logText

        ColumnLayout {
            width: parent.width

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Type:\t"
                }
                ComboBox {
                    Layout.preferredWidth: 300
                    id: ctrlCombo
                    model: sampleModel
                    textRole: "title"
                    valueRole: "value"
                    currentIndex: 0
                    onCurrentIndexChanged: if (!dlg.visible) dlg.open()
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Title:\t"
                }
                TextField {
                    Layout.preferredWidth: 300
                    id: ctrlTitle
                    placeholderText: "Empty == default title"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Text:\t"
                }
                TextField {
                    Layout.preferredWidth: 300
                    id: ctrlText
                    placeholderText: "Empty == default title"
                    text: "Do you want to proceed?"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Info text:\t"
                }
                TextField {
                    Layout.preferredWidth: 300
                    id: ctrlInfoText
                    placeholderText: "Empty == default title"
                    text: "If you click Yes, the file will be deleted"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Detailed text:\t"
                }
                TextField {
                    Layout.preferredWidth: 300
                    id: ctrlDetailedText
                    placeholderText: "Empty == default title"
                    text: "This is an optional detailed text"
                }
            }
        }
    }
}

// category: Dialogs
// status: good
