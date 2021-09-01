import QtQuick 2.14
import QtQuick.Controls 2.14 as QC

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1


import "statusModal" as Spares

QC.Popup {
    id: statusModal

    property alias headerActionButton: headerImpl.actionButton

    property StatusModalHeaderSettings header: StatusModalHeaderSettings {}
    property alias rightButtons: footerImpl.rightButtons
    property alias leftButtons: footerImpl.leftButtons
    property bool showHeader: true
    property bool showFooter: true

    signal editButtonClicked()

    parent: QC.Overlay.overlay

    width: 480
    implicitHeight: contentItem.implicitHeight + headerImpl.implicitHeight + footerImpl.implicitHeight

    topPadding: headerImpl.implicitHeight
    bottomPadding: footerImpl.implicitHeight
    leftPadding: 0
    rightPadding: 0

    modal: true

    QC.Overlay.modal: Rectangle {
        color: Theme.palette.backdropColor
    }


    background: Rectangle {
        color: Theme.palette.statusModal.backgroundColor
        radius: 8

        Spares.StatusModalHeader {
            id: headerImpl
            anchors.top: parent.top
            width: visible ? parent.width : 0

            visible: statusModal.showHeader
            title: header.title
            titleElide: header.titleElide
            subTitle: header.subTitle
            subTitleElide: header.subTitleElide
            image: header.image
            icon: header.icon

            onEditButtonClicked: statusModal.editButtonClicked()
            onClose: statusModal.close()
        }

        Spares.StatusModalFooter {
            id: footerImpl
            anchors.bottom: parent.bottom
            width: visible ? parent.width : 0
            visible: statusModal.showFooter
        }
    }
}
