import QtQuick 2.14
import QtQuick.Controls 2.14 as QC

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import "statusModal" as Spares

/*!
   \qmltype StatusModal
   \inherits Popup
   \inqmlmodule StatusQ.Popups
   \since StatusQ.Popups 0.1
   \brief The StatusModal provides a template for creating Modals.

   Example of how to use it:

   \qml
        StatusModal {
            anchors.centerIn: parent
            header.title: "Some Title"
            header.subTitle: "Subtitle"
            headerActionButton: StatusFlatRoundButton {
                type: StatusFlatRoundButton.Type.Secondary
                width: 32
                height: 32

                icon.width: 20
                icon.height: 20
                icon.name: "info"
            }

            leftButtons: [
                StatusRoundButton {
                    icon.name: "arrow-right"
                    rotation: 180
                }
            ]
            rightButtons: [
                StatusButton {
                    text: qsTr("Button")
                },
                StatusButton {
                    text: qsTr("Button")
                }
            ]
        }
   \endqml

   For a list of components available see StatusQ.
*/
QC.Popup {
    id: statusModal

    /*!
       \qmlproperty advancedHeader
        This property represents the item loaded in header loader.
        Can be used to read values from the component assigned to the loader.
        \endqml
    */
    property alias advancedHeader: advancedHeader.item
    /*!
       \qmlproperty advancedHeader
        This property represents the item loaded in footer loader.
        Can be used to read values from the component assigned to the loader.
        \endqml
    */
    property alias advancedFooter: advancedFooter.item
    /*!
       \qmlproperty advancedHeader
        This property can be used to assign a Component to the advanced loader.
        This was introduced to give more control to user on the Modal Header

        example usage below

        \qml
            StatusModal {
                id: advancedHeaderFooterModal
                anchors.centerIn: parent
                showHeader: false
                showAdvancedHeader: true
                advancedHeaderComponent: Rectangle {
                    width: parent.width
                    height: 50
                    color: Theme.palette.baseColor1
                    border.width: 1
                    StatusBaseText {
                        anchors.centerIn: parent
                        text: qsTr("Add any header here")
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                    }
                }
        \endqml
    */
    property alias advancedHeaderComponent: advancedHeader.sourceComponent
    /*!
       \qmlproperty advancedHeader
        This property can be used to assign a Component to the advanced loader.
        This was introduced to give more control to user on the Modal Footer.

        example usage below

        \qml
            StatusModal {
                id: advancedHeaderFooterModal
                anchors.centerIn: parent
                showFooter: false
                showAdvancedFooter: true
                advancedFooterComponent: Rectangle {
                    width: parent.width
                    height: 50
                    color: Theme.palette.baseColor1
                    border.width: 1
                    StatusBaseText {
                        anchors.centerIn: parent
                        text: qsTr("Add any footer here")
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
                    }
                }
        \endqml
    */
    property alias advancedFooterComponent: advancedFooter.sourceComponent
    /*!
       \qmlproperty headerActionButton
        This property lets the user add a button to the header of the Modal.
        This does not apply to the advanced header!
        \endqml
    */
    property alias headerActionButton: headerImpl.actionButton

    /*!
       \qmlproperty header
        type: StatusModalHeaderSettings
        This property exposes the different properties of the standard header.
        \endqml
    */
    property StatusModalHeaderSettings header: StatusModalHeaderSettings {}
    /*!
       \qmlproperty rightButtons
        This property helps user assign the right buttons on the footer.
        This doesn't not apply to the advanced footer!
        \endqml
    */
    property alias rightButtons: footerImpl.rightButtons
    /*!
       \qmlproperty rightButtons
        This property helps user assign the left buttons on the footer.
        This doesn't not apply to the advanced footer!
        \endqml
    */
    property alias leftButtons: footerImpl.leftButtons
    /*!
       \qmlproperty showHeader
        This property to decides whether the standard header is shown.
        default value is true
        \endqml
    */
    property bool showHeader: true
    /*!
       \qmlproperty showHeader
        This property to decides whether the standard footer is shown.
        default value is true
        \endqml
    */
    property bool showFooter: true
    /*!
       \qmlproperty showAdvancedHeader
        This property to decides whether the advanced header is shown.
        default value is false.
        \endqml
    */
    property bool showAdvancedHeader: false
    /*!
       \qmlproperty showAdvancedFooter
        This property decides whether the advanced footer is shown.
        default value is false.
        \endqml
    */
    property bool showAdvancedFooter: false
    /*!
       \qmlproperty hasCloseButton
        This property decides whether the standard header has a close button.s
        \endqml
    */
    property alias hasCloseButton: headerImpl.hasCloseButton
    /*!
       \qmlproperty hasFloatingButtons
        This property decides whether the advanced header has floating buttons on top of the Modal
        \endqml
    */
    property bool hasFloatingButtons: false

    signal editButtonClicked()
    signal headerImageClicked()

    parent: QC.Overlay.overlay

    width: 480
    // implicitHeight: headerImpl.implicitHeight + contentItem.implicitHeight + footerImpl.implicitHeight

    padding: 0
    topPadding: padding + headerImpl.implicitHeight
    bottomPadding: padding + footerImpl.implicitHeight
    leftPadding: padding
    rightPadding: padding

    margins: 64

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
            popupMenu: header.popupMenu
            headerImageEditable: header.headerImageEditable
            editable: header.editable

            onEditButtonClicked: statusModal.editButtonClicked()
            onHeaderImageClicked: statusModal.headerImageClicked()
            onClose: statusModal.close()
        }

        Loader {
            id: advancedHeader
            anchors.top: parent.top
            anchors.topMargin: hasFloatingButtons ? -18 - height : 0
            width: visible ? parent.width : 0
            active: statusModal.showAdvancedHeader
        }

        Spares.StatusModalFooter {
            id: footerImpl
            anchors.bottom: parent.bottom
            width: visible ? parent.width : 0
            showFooter: statusModal.showFooter
        }

        Loader {
            id: advancedFooter
            anchors.bottom: parent.bottom
            width: visible ? parent.width : 0
            active: statusModal.showAdvancedFooter
        }
    }
}
