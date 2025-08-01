import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import Qt5Compat.GraphicalEffects

import Storybook
import Models

import StatusQ.Components
import StatusQ.Controls
import StatusQ.Popups
import StatusQ.Popups.Dialog
import StatusQ.Core.Theme

SplitView {
    id: root

    property var testControls: [ctrl1, ctrl2, ctrl3]

    property bool globalStylePreferRound: true
    property var testImageList: [ModelsData.banners.dragonereum,
        ModelsData.banners.superRare,
        ModelsData.banners.socks]
    property int testImageIndex: 0
    property int testSpacing: 0
    property int testFrameMargins: 10

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    Logs { id: logs }

    SplitView {
        orientation: Qt.Horizontal
        SplitView.fillWidth: true
        SplitView.fillHeight: true


        RowLayout {
            id: mainLayout

            anchors.fill: parent
            spacing: root.testSpacing

            ColumnLayout {
                spacing: root.testSpacing

                Layout.margins: root.testSpacing
                Layout.fillWidth: true

                Text {
                    text: `AR: ${ctrl1.aspectRatio.toFixed(2)}`
                }

                StatusImageCropPanel {
                    id: ctrl1

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    source: root.testImageList[root.testImageIndex]
                    windowStyle: globalStylePreferRound ? StatusImageCrop.WindowStyle.Rounded : StatusImageCrop.WindowStyle.Rectangular
                    margins: root.testFrameMargins
                }

                Text {
                    text: `AR: ${ctrl2.aspectRatio.toFixed(2)}`
                }

                StatusImageCropPanel {
                    id: ctrl2

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    source: root.testImageList[root.testImageIndex]
                    windowStyle: globalStylePreferRound ? StatusImageCrop.WindowStyle.Rectangular : StatusImageCrop.WindowStyle.Rounded
                    aspectRatio: 16/9
                    enableCheckers: true
                    margins: root.testFrameMargins + 2
                }
            }

            ColumnLayout {
                Layout.margins: root.testSpacing
                Layout.fillWidth: true

                Text {
                    text: `AR: ${ctrl3.aspectRatio.toFixed(2)}`
                }

                StatusImageCropPanel {
                    id: ctrl3

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    source: root.testImageList[root.testImageIndex]
                    windowStyle: globalStylePreferRound ? StatusImageCrop.WindowStyle.Rounded : StatusImageCrop.WindowStyle.Rectangular
                    aspectRatio: 0.8

                    margins: root.testFrameMargins + 5.3
                }
            }
        }

        Loader {
            id: workflowLoader

            sourceComponent: workflowComponent
            active: false
            onStatusChanged: {
                if(status === Loader.Ready) {
                    item.imageFileDialogTitle = qsTr("Test Title")
                    item.title = "Test popup"
                    item.acceptButtonText = "Load Custom Image"
                    item.chooseImageToCrop()
                }
            }

            Connections {
                target: workflowLoader.item
                function onImageCropped(image, cropRect) {
                    ctrl1.source = image
                    ctrl2.source = image
                    ctrl3.source = image
                }
                function onCanceled() {
                    workflowLoader.active = false
                }
            }
        }

        Component {
            id: workflowComponent

            Item {
                id: workflowItem

                property alias aspectRatio: imageCropper.aspectRatio
                property alias windowStyle: imageCropper.windowStyle
                property string imageFileDialogTitle: ""
                property string title: ""
                property string acceptButtonText: ""
                property bool roundedImage: true

                signal imageCropped(var image, var cropRect)
                signal canceled()

                function chooseImageToCrop() {
                    fileDialog.open()
                }

                StatusFileDialog {
                    id: fileDialog

                    title: workflowItem.imageFileDialogTitle
                    currentFolder: workflowItem.userSelectedImage ? imageCropper.source.substr(0, imageCropper.source.lastIndexOf("/")) : picturesShortcut
                    nameFilters: [qsTr("Supported image formats (%1)").arg("*.jpg *.jpeg *.jfif *.webp *.png *.heif")]
                    onAccepted: {
                        if (fileDialog.selectedFiles.length > 0) {
                            imageCropper.source = fileDialog.selectedFiles[0]
                            imageCropperModal.open()
                        }
                    }
                    onRejected: workflowItem.canceled()
                } // StatusFileDialog

                StatusModal {
                    id: imageCropperModal

                    headerSettings.title: workflowItem.title

                    anchors.centerIn: Overlay.overlay

                    width: workflowItem.roundedImage ? 480 : 580

                    onClosed: workflowItem.canceled()

                    StatusImageCropPanel {
                        id: imageCropper

                        implicitHeight: workflowItem.roundedImage ? 350 : 370

                        anchors {
                            fill: parent
                            leftMargin: 10 * 2
                            rightMargin: 10 * 2
                            topMargin: 15
                            bottomMargin: 15
                        }

                        margins: workflowItem.roundedImage ? 10 : 20
                        windowStyle: workflowItem.roundedImage ? StatusImageCrop.WindowStyle.Rounded : StatusImageCrop.WindowStyle.Rectangular
                        enableCheckers: true
                    }

                    rightButtons: [
                        StatusButton {
                            text: workflowItem.acceptButtonText

                            enabled: imageCropper.sourceSize.width > 0 && imageCropper.sourceSize.height > 0

                            onClicked: {
                                workflowItem.imageCropped(imageCropper.source, imageCropper.cropRect)
                                imageCropperModal.close()
                            }
                        }
                    ]
                } // StatusModal
            } // Item
        }

        Shortcut {
            sequence: StandardKey.ZoomIn
            onActivated: {
                for(let i in testControls) {
                    const c = testControls[i]
                    c.setCropRect(ctrl1.inflateRectBy(c.cropRect, -0.05))
                }
            }
        }

        Shortcut {
            sequence: StandardKey.ZoomOut
            onActivated: {
                for(let i in testControls) {
                    const c = testControls[i]
                    c.setCropRect(ctrl1.inflateRectBy(c.cropRect, 0.05))
                }
            }
        }

        Shortcut {
            sequences: ["Ctrl+W"]
            onActivated: globalStylePreferRound = !globalStylePreferRound
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: Theme.additionalTextSize

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16

            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Cycle image")
                onClicked: {
                    let newIndex = root.testImageIndex
                    newIndex++
                    if(newIndex >= root.testImageList.length)
                        newIndex = 0
                    root.testImageIndex = newIndex
                }
            }

            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Cycle spacing")
                onClicked: {
                    root.testSpacing += (root.testSpacing/2) + 1
                    if(root.testSpacing > 35)
                        root.testSpacing = 0
                }
            }

            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Cycle frame margins")
                onClicked: {
                    root.testFrameMargins += (root.testFrameMargins/2) + 1
                    if(root.testFrameMargins > 50)
                        root.testFrameMargins = 0
                }
            }

            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Load external image")
                onClicked: workflowLoader.active = true
            }
        }
    }
}

// category: Components
