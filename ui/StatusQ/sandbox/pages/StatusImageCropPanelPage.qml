import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQuick.Dialogs 1.3
import QtQml 2.14

import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import QtGraphicalEffects 1.14

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

Item {
    id: root

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    property var testControls: [ctrl1, ctrl2, ctrl3]

    property bool globalStylePreferRound: true
    property var testImageList: ["qrc:/demoapp/data/logo-test-image.png",
                                 "qrc:/demoapp/data/profile-image-2.jpeg",
                                 "qrc:/demoapp/data/profile-image-1.jpeg"]
    property int testImageIndex: 0
    property int testSpacing: 0
    property int testFrameMargins: 10

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        RowLayout {
            spacing: root.testSpacing

            ColumnLayout {
                spacing: root.testSpacing
                Layout.margins: root.testSpacing

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
        RowLayout {
            StatusButton {
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
                text: qsTr("Cycle spacing")
                onClicked: {
                    root.testSpacing += (root.testSpacing/2) + 1
                    if(root.testSpacing > 35)
                        root.testSpacing = 0
                }
            }
            StatusButton {
                text: qsTr("Cycle frame margins")
                onClicked: {
                    root.testFrameMargins += (root.testFrameMargins/2) + 1
                    if(root.testFrameMargins > 50)
                        root.testFrameMargins = 0
                }
            }
            StatusButton {
                text: qsTr("Load external image")
                onClicked: workflowLoader.active = true
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
            /*required*/ property string imageFileDialogTitle: ""
            /*required*/ property string title: ""
            /*required*/ property string acceptButtonText: ""
            property bool roundedImage: true

            signal imageCropped(var image, var cropRect)
            signal canceled()

            function chooseImageToCrop() {
                fileDialog.open()
            }

            FileDialog {
                id: fileDialog

                title: workflowItem.imageFileDialogTitle
                folder: workflowItem.userSelectedImage ? imageCropper.source.substr(0, imageCropper.source.lastIndexOf("/")) : shortcuts.pictures
                nameFilters: [qsTr("Supported image formats (%1)").arg("*.jpg *.jpeg *.jfif *.webp *.png *.heif")]
                onAccepted: {
                    if (fileDialog.fileUrls.length > 0) {
                        imageCropper.source = fileDialog.fileUrls[0]
                        imageCropperModal.open()
                    }
                }
                onRejected: workflowItem.canceled()
            } // FileDialog

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
}
