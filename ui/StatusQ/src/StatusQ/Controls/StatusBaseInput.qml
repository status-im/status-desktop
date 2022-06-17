import QtQuick 2.14

import QtQuick.Controls 2.14 as QC
import QtQuick.Layouts 1.14

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
      \qmltype StatusBaseInput
      \inherits Item
      \inqmlmodule StatusQ.Controls
      \since StatusQ.Controls 0.1
      \brief Displays a customized TextInput component.
      Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-item.html}{Item}.

      The \c StatusBaseInput displays an enhanced TextInput for users to type text.
      For example:

      \qml
      StatusBaseInput {
        implicitWidth: parent.width
        implicitHeight: 36
        topPadding: 8
        bottomPadding: 8
        clearable: true
        placeholderText: qsTr("Search")
        icon.name: "search"
      }
      \endqml

      \image status_base_input.png

      For a list of components available see StatusQ.
*/

Item {
    id: root

    /*!
        \qmlproperty bool StatusBaseInput::multiline
        This property indicates whether the StatusBaseInput allows multiline text. Default value is false.
    */
    property bool multiline: false

    /*!
        \qmlproperty bool StatusBaseInput::acceptReturn
        This property indicates whether the StatusBaseInput allows pressing Enter or Return.
        This is used in case multiline is false and we still want to interact using Enter or Return. Default value is false.
    */
    property bool acceptReturn: false
    /*!
        \qmlproperty bool StatusBaseInput::clearable
        This property indicates whether the StatusBaseInput allows clearing all text. Default value is false.
    */
    property bool clearable: false
    /*!
        \qmlproperty alias StatusBaseInput::inputMethodHints
        This property holds a reference to the TextEdit component's inputMethodHints property.
    */
    property alias inputMethodHints: edit.inputMethodHints
    /*!
        \qmlproperty alias StatusBaseInput::selectedText
        This property holds a reference to the TextEdit component's selectedText property.
    */
    property alias selectedText: edit.selectedText
    /*!
        \qmlproperty alias StatusBaseInput::selectedTextColor
        This property holds a reference to the TextEdit component's selectedTextColor property.
    */
    property alias selectedTextColor: edit.selectedTextColor
    /*!
        \qmlproperty alias StatusBaseInput::selectionStart
        This property holds a reference to the TextEdit component's selectionStart property.
    */
    property alias selectionStart: edit.selectionStart
    /*!
        \qmlproperty alias StatusBaseInput::selectionEnd
        This property holds a reference to the TextEdit component's selectionEnd property.
    */
    property alias selectionEnd: edit.selectionEnd
    /*!
        \qmlproperty alias StatusBaseInput::cursorPosition
        This property holds a reference to the TextEdit component's cursorPosition property.
    */
    property alias cursorPosition: edit.cursorPosition

    /*!
        \qmlproperty alias StatusBaseInput::edit
        This property holds a reference to the TextEdit component.
    */
    property alias edit: edit
    /*!
        \qmlproperty alias StatusBaseInput::text
        This property holds a reference to the TextEdit component's text property.
    */
    property alias text: edit.text
    /*!
        \qmlproperty alias StatusBaseInput::background
        This property holds a reference to the background component.
    */
    property alias background: background
    /*!
        \qmlproperty alias StatusBaseInput::color
        This property holds a reference to the TextEdit component's color property.
    */

    property alias color: edit.color
    /*!
        \qmlproperty alias StatusBaseInput::font
        This property holds a reference to the TextEdit component's font property.
    */
    property alias font: edit.font
    /*!
        \qmlproperty alias StatusBaseInput::focussed
        This property holds a reference to the TextEdit component's activeFocus property.
    */
    property alias focussed: edit.activeFocus
    /*!
        \qmlproperty alias StatusBaseInput::verticalAlignment
        This property holds a reference to the TextEdit component's verticalAlignment property.
    */
    property alias verticalAlignment: edit.verticalAlignment
    /*!
        \qmlproperty alias StatusBaseInput::horizontalAlignment
        This property holds a reference to the TextEdit component's horizontalAlignment property.
    */
    property alias horizontalAlignment: edit.horizontalAlignment
    /*!
        \qmlproperty alias StatusBaseInput::placeholder
        This property holds a reference to the placeholder component.
    */
    property alias placeholder: placeholder
    /*!
        \qmlproperty alias StatusBaseInput::placeholderText
        This property holds a reference to the placeholder component's placeholderText property.
    */
    property alias placeholderText: placeholder.text
    /*!
        \qmlproperty alias StatusBaseInput::placeholderTextColor
        This property holds a reference to the placeholder component's placeholderTextColor property.
    */
    property alias placeholderTextColor: placeholder.color
    /*!
        \qmlproperty alias StatusBaseInput::placeholderFont
        This property holds a reference to the placeholder component's font property.
    */
    property alias placeholderFont: placeholder.font

    /*!
        \qmlproperty real StatusBaseInput::leftPadding
        This property sets the leftComponentLoader's left padding.
    */
    property real leftPadding: leftComponentLoader.item ? 8 : 16
    /*!
        \qmlproperty real StatusBaseInput::rightPadding
        This property sets the right padding.
    */
    property real rightPadding: 16
    /*!
        \qmlproperty real StatusBaseInput::topPadding
        This property sets the top padding.
    */
    property real topPadding: 12
    /*!
        \qmlproperty alias StatusBaseInput::bottomPadding
        This property sets the bottom padding.
    */
    property real bottomPadding: 12
    /*!
        \qmlproperty var StatusBaseInput::tabNavItem
        This property sets the tab key navigation item.
    */
    property var tabNavItem: null

    /*!
        \qmlproperty real StatusBaseInput::minimumHeight
        This property sets the minimum height.
    */
    property real minimumHeight: 0
    /*!
        \qmlproperty alias StatusBaseInput::maximumHeight
        This property sets the maximum height.
    */
    property real maximumHeight: 0
    /*!
        \qmlproperty int StatusBaseInput::maximumLength
        This property sets the text's maximum length.
    */
    property int maximumLength: 0

    /*!
        \qmlproperty bool StatusBaseInput::valid
        This property sets the valid state. Default value is true.
    */
    property bool valid: true
    /*!
        \qmlproperty bool StatusBaseInput::pristine
        This property sets the pristine. Default value is true.
    */
    property bool pristine: true
    /*!
        \qmlproperty bool StatusBaseInput::dirty
        This property sets the dirty property. Default value is false.
    */
    property bool dirty: false
    /*!
        \qmlproperty bool StatusBaseInput::pending
        This property holds the maximum height of the component. Default value is false.
    */
    property bool pending: false
    /*!
        \qmlproperty bool StatusBaseInput::leftIcon
        This property sets the visibility of the left icon. Default value is true.
    */
    property bool leftIcon: true
    /*!
        \qmlproperty bool StatusBaseInput::isIconSelectable
        This property indicates whether icon is selectable. Default value is false.
    */
    property bool isIconSelectable: false
    /*!
        \qmlproperty bool StatusBaseInput::showBackground
        This property sets the visibility of the background. Default value is true.
    */
    property bool showBackground: true

    /*!
        \qmlproperty StatusIconSettings StatusBaseInput::icon
        This property holds a set of settings for the icon of the StatusBaseInput.
    */
    property StatusIconSettings icon: StatusIconSettings {
        width: 24
        height: 24
        name: ""
        color: Theme.palette.baseColor1
        emoji: ""
        letterSize: emoji ? 11 : 14
        background: StatusIconBackgroundSettings {
            width: 30
            height: 30
            color: Theme.palette.indirectColor1
        }
    }

    /*!
        \qmlproperty string StatusBaseInput::letterIconName
        This property holds the letter that should be displayed in the letter identicon component.
    */
    property string letterIconName: ""
    /*!
        \qmlproperty Component StatusBaseInput::leftComponent
        This property sets the left component to be displayed inside the input.
    */
    property Component leftComponent
    /*!
        \qmlproperty Component StatusBaseInput::selectedText
        This property sets the right component to be displayed inside the input.
    */
    property Component rightComponent

    /*!
        \qmlsignal
         This signal is emitted when the icon is clicked.
    */
    signal iconClicked
    /*!
        \qmlsignal
         This signal is emitted when a hard key is pressed passing as parameter the keyboard event.
    */
    signal keyPressed(var event)
    /*!
        \qmlsignal
         This signal is emitted when the text edit is clicked.
    */
    signal editClicked()

    implicitWidth: 448
    implicitHeight: multiline ? Math.min(Math.max(
                                    (edit.implicitHeight + topPadding + bottomPadding),
                                    44, root.minimumHeight), root.maximumHeight) : 44

    Rectangle {
        id: background
        width: parent.width
        height: maximumHeight != 0 ? Math.min(
                                         minimumHeight
                                         != 0 ? Math.max(
                                                    root.implicitHeight,
                                                    minimumHeight) : root.implicitHeight,
                                         maximumHeight) : parent.height
        color: root.showBackground ? Theme.palette.baseColor2
                                              : "transparent"
        radius: 8

        clip: true

        border.width: 1
        border.color: {
            if (!root.showBackground) {
                return "transparent"
            }
            if (!root.valid && root.dirty) {
                return Theme.palette.dangerColor1
            }
            if (edit.activeFocus) {
                return Theme.palette.primaryColor1
            }
            return sensor.containsMouse ? Theme.palette.primaryColor2 : "transparent"
        }

        MouseArea {
            id: sensor
            anchors.fill: parent
            enabled: edit.enabled
            hoverEnabled: enabled
            cursorShape: Qt.IBeamCursor
            onClicked: {
                if (edit.activeFocus)
                    return;
                edit.forceActiveFocus()
                root.editClicked()
            }
            RowLayout {
                spacing: 10
                anchors {
                    fill: parent
                    leftMargin: root.leftPadding ? root.leftPadding : leftComponentLoader.item ? 8 : 16
                    rightMargin: root.rightPadding
                }

                clip: true

                Loader {
                    id: leftComponentLoader
                    sourceComponent: {
                        if (root.leftComponent) return root.leftComponent
                        if (!root.leftIcon) return undefined
                        if (root.icon.emoji || root.icon.isLetterIdenticon) return identiconComponent
                        if (root.icon.name) return isIconSelectable ? identiconComponent : iconComponent
                        return undefined
                    }
                }

                Flickable {
                    id: flick

                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.topMargin: root.topPadding
                    Layout.bottomMargin: root.bottomPadding

                    contentWidth: edit.paintedWidth
                    contentHeight: edit.paintedHeight
                    boundsBehavior: Flickable.StopAtBounds
                    QC.ScrollBar.vertical: QC.ScrollBar {
                        interactive: multiline
                        enabled: multiline
                    }
                    clip: true

                    function ensureVisible(r) {
                        if (contentX >= r.x)
                            contentX = r.x
                        else if (contentX + width <= r.x + r.width)
                            contentX = r.x + r.width - width
                        if (contentY >= r.y)
                            contentY = r.y
                        else if (contentY + height <= r.y + r.height)
                            contentY = r.y + r.height - height
                    }

                    TextEdit {
                        id: edit

                        property string previousText: text
                        property var keyEvent

                        width: flick.width
                        height: flick.height
                        verticalAlignment: TextEdit.AlignVCenter
                        selectByMouse: true
                        selectionColor: Theme.palette.primaryColor2
                        selectedTextColor: color
                        focus: true
                        font.pixelSize: 15
                        font.family: Theme.palette.baseFont.name
                        color: Theme.palette.directColor1
                        wrapMode: root.multiline ? Text.WrapAtWordBoundaryOrAnywhere : TextEdit.NoWrap

                        Keys.onReturnPressed: event.accepted = !multiline && !acceptReturn
                        Keys.onEnterPressed: event.accepted = !multiline && !acceptReturn
                        Keys.forwardTo: [root]
                        KeyNavigation.priority: !!root.tabNavItem ? KeyNavigation.BeforeItem : KeyNavigation.AfterItem
                        KeyNavigation.tab: root.tabNavItem
                        Keys.onPressed: {
                            edit.keyEvent = event.key
                            root.keyPressed(event);
                        }

                        onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                        onActiveFocusChanged: if (root.pristine) root.pristine = false
                        onTextChanged: {
                            if (previousText === text) {
                                // Not sure why, but the textChanged event was triggered even if it didn't really
                                return
                            }
                            root.dirty = true
                            if (root.maximumLength > 0) {
                                if (text.length > root.maximumLength) {
                                    var cursor = cursorPosition
                                    text = previousText
                                    if (cursor > text.length) {
                                        cursorPosition = text.length
                                    } else {
                                        cursorPosition = cursor - 1
                                    }
                                }
                                previousText = text
                            }
                        }

                        cursorDelegate: Rectangle {
                            color: Theme.palette.primaryColor1
                            implicitWidth: 2
                            implicitHeight: 22
                            radius: 1
                            visible: edit.cursorVisible

                            SequentialAnimation on visible {
                                loops: Animation.Infinite
                                running: edit.cursorVisible
                                PropertyAnimation { to: false; duration: 600; }
                                PropertyAnimation { to: true; duration: 600; }
                            }
                        }

                        StatusBaseText {
                            id: placeholder
                            visible: (edit.text.length === 0)
                            anchors.fill: parent
                            verticalAlignment: parent.verticalAlignment
                            font.pixelSize: 15
                            elide: StatusBaseText.ElideRight
                            font.family: Theme.palette.baseFont.name
                            color: root.enabled ? Theme.palette.baseColor1 : Theme.palette.directColor6
                        }
                    }
                } // Flickable

                Loader {
                    sourceComponent: {
                        if (root.rightComponent) return root.rightComponent
                        if (root.clearable) return clearButton
                        if (root.leftIcon) return undefined
                        if (root.icon.emoji) return identiconComponent
                        if (root.icon.name) return isIconSelectable ? identiconComponent : iconComponent
                        return undefined
                    }
                }
            }
        }
    } // Rectangle


    Component {
        id: clearButton

        StatusFlatRoundButton {
            visible: edit.text.length != 0 && root.clearable && !root.multiline
                     && edit.activeFocus
            type: StatusFlatRoundButton.Type.Secondary
            width: 24
            height: 24
            icon.name: "clear"
            icon.width: 16
            icon.height: 16
            icon.color: Theme.palette.baseColor1
            onClicked: {
                edit.clear()
            }
        }
    }

    Component {
        id: identiconComponent

        StatusSmartIdenticon {
            id: identicon

            icon.width: 24
            icon.height: 24
            icon.background: root.icon.background
            icon.color: root.icon.color
            icon.letterSize: root.icon.letterSize
            icon.emoji: root.icon.emoji
            icon.name: !root.icon.emoji ? root.icon.name : ""
            icon.isLetterIdenticon: root.icon.isLetterIdenticon
            name: root.letterIconName

            MouseArea {
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                anchors.fill: parent
                hoverEnabled: true
                enabled: identicon.visible
                onClicked: root.iconClicked()
            }
        }
    }

    Component {
        id: iconComponent

        StatusIcon {
            id: statusIcon

            icon: root.icon.name
            width: root.icon.width
            height: root.icon.height
            color: root.icon.color
        }
    }
}
