import QtQuick 2.14
import QtQuick.Controls 2.14 as QC

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1


import "statusModal" as Spares

QC.Popup {
    id: statusModal

    property Component content

    property alias headerActionButton: headerImpl.actionButton

    property StatusModalHeaderSettings header: StatusModalHeaderSettings {}
    property alias contentComponent: contentLoader.item
    property alias rightButtons: footerImpl.rightButtons
    property alias leftButtons: footerImpl.leftButtons
    property bool showHeader: true
    property bool showFooter: true

    signal editButtonClicked()

    parent: QC.Overlay.overlay

    width: 480
    height: contentItem.implicitHeight

    margins: 0
    padding: 0

    modal: true

    QC.Overlay.modal: Rectangle {
        color: Theme.palette.backdropColor
    }


    background: Rectangle {
        color: Theme.palette.statusModal.backgroundColor
        radius: 8
    }

    contentItem: Column {
        width: parent.width
        Spares.StatusModalHeader {
            id: headerImpl
            width: visible ? parent.width : 0

            visible: statusModal.showHeader
            title: header.title
            subTitle: header.subTitle
            image: header.image
            icon: header.icon

            onEditButtonClicked: statusModal.editButtonClicked()
            onClose: statusModal.close()
        }

        Loader {
            id: contentLoader
            width: parent.width
            active: true
            sourceComponent: statusModal.content
        }

        Spares.StatusModalFooter {
            id: footerImpl
            width: visible ? parent.width : 0
            visible: statusModal.showFooter
        }
    }
}
