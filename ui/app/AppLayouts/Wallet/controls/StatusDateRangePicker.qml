import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQml.Models 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    property double fromTimestamp: Date.now()
    property double toTimestamp: Date.now()
    property int supportedStartYear

    signal newRangeSet(double fromTimestamp, double toTimestamp)

    onOpened: fromInput.forceActiveFocus()

    topPadding: 0
    title: qsTr("Filter activity by period")

    contentItem: RowLayout {
        spacing: 20

        // From Date
        ColumnLayout {
            spacing: 8
            StatusBaseText {
                height: visible ? contentHeight : 0
                elide: Text.ElideRight
                text: qsTr("From")
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }
            StatusDateInput {
                id: fromInput
                datePlaceholderText: qsTr("dd")
                monthPlaceholderText: qsTr("mm")
                yearPlaceholderText: qsTr("yyyy")
                presetTimestamp: fromTimestamp
                errorMessage: qsTr("Invalid range")
                supportedStartYear: root.supportedStartYear
            }
        }

        // To Date
        ColumnLayout {
            Layout.preferredWidth: toInput.width
            spacing: 8
            RowLayout {
                Layout.preferredWidth: parent.width
                StatusBaseText {
                    Layout.alignment: Qt.AlignLeft
                    height: visible ? contentHeight : 0
                    elide: Text.ElideRight
                    text: qsTr("To")
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                }
                StatusButton {
                    Layout.alignment: Qt.AlignRight
                    horizontalPadding: 0
                    verticalPadding: 0
                    spacing: 0
                    normalColor: Theme.palette.transparent
                    hoverColor: Theme.palette.transparent
                    font.weight: Font.Normal
                    text: toInput.isEditMode ? qsTr("Now") : qsTr("Edit")
                    onClicked: {
                        if(toInput.isEditMode)
                            root.toTimestamp = Date.now()
                        toInput.isEditMode = !toInput.isEditMode
                    }
                }
            }
            StatusDateInput {
                id: toInput
                datePlaceholderText: qsTr("dd")
                monthPlaceholderText: qsTr("mm")
                yearPlaceholderText: qsTr("yyyy")
                presetTimestamp: toTimestamp
                nowText: qsTr("Now")
                errorMessage: qsTr("Invalid range")
                supportedStartYear: root.supportedStartYear
            }
        }

        StatusButton {
            Layout.preferredHeight: fromInput.height
            Layout.alignment: Qt.AlignVCenter
            Layout.topMargin: 28
            text: qsTr("Reset")
            enabled: fromInput.hasChange || toInput.hasChange
            normalColor: Theme.palette.transparent
            borderColor: Theme.palette.baseColor2
            hoverColor: Theme.palette.primaryColor3
            onClicked: {
                toInput.isEditMode = false
                fromInput.reset()
                toInput.reset()
            }
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Apply")
                enabled: fromInput.valid && toInput.valid && (fromInput.hasChange || toInput.hasChange)
                onClicked: {
                    root.newRangeSet(fromInput.newDate.valueOf(), toInput.newDate.valueOf())
                    root.close()
                }
            }
        }
    }
}
