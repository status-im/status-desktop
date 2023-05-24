import QtQuick 2.15
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "./private/dateInput"

/*!
   \qmltype StatusDateInput
   \inherits Control
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief It allows entering a date string in dd/mm/yyyy format

   Example of how to use it:

   \qml
        StatusDateInput {
            datePlaceholderText: qsTr("dd")
            monthPlaceholderText: qsTr("mm")
            yearPlaceholderText: qsTr("yyyy")
            presetTimestamp: fromTimestamp
        }
   \endqml

   For a list of components available see StatusQ.
*/

Control {
    id: root

    /*!
        \qmlproperty string StatusDateInput::datePlaceholderText
        This property sets the placeholder text for the date input
    */
    property string datePlaceholderText
    /*!
        \qmlproperty string StatusDateInput::monthPlaceholderText
        This property sets the placeholder text for the month input
    */
    property string monthPlaceholderText
    /*!
        \qmlproperty string StatusDateInput::yearPlaceholderText
        This property sets the placeholder text for the year input
    */
    property string yearPlaceholderText

    /*!
        \qmlproperty string StatusDateInput::nowText
        This property holds the now text to be shown on the widget
    */
    property string nowText
    /*!
        \qmlproperty double StatusDateInput::presetTimestamp
        This property holds the timestamp chosen before entering the popup
    */
    property double presetTimestamp: Date.now()
    /*!
        \qmlproperty bool StatusDateInput::isEditMode
        This property can turn and off the edit mode for the input
    */
    property bool isEditMode: false
    /*!
        \qmlproperty bool StatusDateInput::showBackground
        This property helps turning of the background of the input
    */
    property bool showBackground: true
    /*!
        \qmlproperty var StatusDateInput::newDate
        Represents the newly set date in the input
    */
    property var newDate
    /*!
        \qmlproperty string StatusDateInput::errorMessage
        This property to assign errorMessage for the date input
    */
    property string errorMessage
    /*!
        \qmlproperty bool StatusDateInput::valid
        This property exposes if the input has a valid date
    */
    readonly property bool valid: inputLoader1.item.acceptableInput && inputLoader2.item.acceptableInput && inputLoader3.item.acceptableInput
    /*!
        \qmlproperty bool StatusDateInput::hasChange
        This property exposes if the input has been modified by user
    */
    readonly property bool hasChange: d.presetDate.valueOf() !== newDate.valueOf()
    /*!
        \qmlproperty bool StatusDateInput::supportedStartYear
        This property helps set the sypported start year for the input
    */
    property int supportedStartYear: 0

    /*!
        \qmlmethod
        This function resets the input's text
    */
    function reset() {
        d.presetDate = d.getDateWithoutTime(presetTimestamp)
    }
    /*!
        \qmlmethod
        This function sets the active focus to edit date
    */
    function forceActiveFocus() {
        inputLoader1.item.forceActiveFocus()
        inputLoader1.item.cursorPosition = 0
    }

    QtObject {
        id: d
        readonly property string separator: "/"
        readonly property string space: " "
        readonly property string dateId: "d"
        readonly property string monthId: "m"
        readonly property string yearId: "y"
        readonly property bool hasActiveFocus: inputLoader1.item.activeFocus || inputLoader2.item.activeFocus || inputLoader3.item.activeFocus
        readonly property bool isCurrentTimestamp: getDateWithoutTime(Date.now().valueOf()).valueOf() === newDate.valueOf()
        property var presetDate: d.getDateWithoutTime(presetTimestamp)
        readonly property bool showError: (!inputLoader1.item.acceptableInput && !!inputLoader1.item.text) || (!inputLoader2.item.acceptableInput && !!inputLoader2.item.text) || (!inputLoader3.item.acceptableInput && !!inputLoader3.item.text)
        readonly property var dateTimeFormat: Qt.locale().dateTimeFormat(Locale.ShortFormat).split(space)[0].toLowerCase().split(separator)

        function setNewDate() {
            if (!!inputLoader1.item &&  !!inputLoader2.item &&  !!inputLoader3.item) {
                newDate = new Date(getDateString(yearId), getDateString(monthId), getDateString(dateId))
            }
        }

        function getDateWithoutTime(timeStamp) {
            let d = new Date(timeStamp)
            d.setHours(0, 0, 0, 0)
            return d
        }

        function clearAll() {
            if(!!inputLoader1.item.selectedText)
                inputLoader1.item.clear()
            if(!!inputLoader2.item.selectedText)
                inputLoader2.item.clear()
            if(!!inputLoader3.item.selectedText)
                inputLoader3.item.clear()
        }

        function selectAll() {
            inputLoader1.item.selectAll()
            inputLoader2.item.selectAll()
            inputLoader3.item.selectAll()
        }


        function getComponent(itemPos) {
            return d.dateTimeFormat[(itemPos)].startsWith(yearId) ? editYear : d.dateTimeFormat[(itemPos)].startsWith(monthId) ? editMonth: editDate
        }

        function getDateString(identifier) {
            return dateTimeFormat[0].startsWith(identifier) ? inputLoader1.item.text : dateTimeFormat[1].startsWith(identifier) ? inputLoader2.item.text: inputLoader3.item.text
        }
    }

    implicitHeight: 44
    implicitWidth: 135
    leftPadding: 12
    rightPadding: 12

    background: Rectangle {
        color: root.showBackground ? Theme.palette.baseColor2: Theme.palette.transparent
        radius: 8
        clip: true
        border.width: 1
        border.color: {
            if (!root.showBackground) {
                return Theme.palette.transparent
            }
            if (d.showError) {
                return Theme.palette.dangerColor1
            }
            if (d.hasActiveFocus) {
                return Theme.palette.primaryColor1
            }
            return hoverHandler.hovered ? Theme.palette.primaryColor2 : Theme.palette.transparent
        }
        HoverHandler { id: hoverHandler }
    }

    contentItem: ColumnLayout {
        id: mainLayout
        spacing: 11
        RowLayout {
            spacing: 3
            StatusBaseText {
                id: nowInput
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                font.pixelSize: 15
                text: nowText
                visible: d.isCurrentTimestamp && !isEditMode && !!nowInput.text
            }
            Loader {
                id: inputLoader1
                Layout.preferredWidth: Math.max(item.contentWidth, item.placeholder.contentWidth)
                Layout.preferredHeight: root.height
                sourceComponent: d.getComponent(0)
                onLoaded: {
                    d.setNewDate()
                    item.tabNavItem = inputLoader2.item
                }
            }
            StatusBaseText {
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                lineHeightMode: Text.FixedHeight
                lineHeight: 22
                text: d.separator
                visible: !nowInput.visible
            }
            Loader {
                id: inputLoader2
                Layout.preferredWidth: Math.max(item.contentWidth, item.placeholder.contentWidth)
                Layout.preferredHeight: root.height
                sourceComponent: d.getComponent(1)
                onLoaded: {
                    d.setNewDate()
                    item.tabNavItem = inputLoader3.item
                }
            }
            StatusBaseText {
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                lineHeightMode: Text.FixedHeight
                lineHeight: 22
                text: d.separator
                visible: !nowInput.visible
            }
            Loader {
                id: inputLoader3
                Layout.preferredWidth: Math.max(item.contentWidth, item.placeholder.contentWidth)
                Layout.preferredHeight: root.height
                sourceComponent: d.getComponent(2)
                onLoaded: {
                    d.setNewDate()
                    item.tabNavItem = inputLoader1.item
                }
            }
        }
        StatusBaseText {
            Layout.maximumWidth: root.width
            Layout.rightMargin: -root.rightPadding
            Layout.alignment: Qt.AlignRight
            font.pixelSize: 12
            color: Theme.palette.dangerColor1
            lineHeightMode: Text.FixedHeight
            lineHeight: 16
            elide: Text.ElideRight
            text: errorMessage
            visible: d.showError
        }
    }

    Component {
        id: editDate
        StatusBaseDateInput {
            maximumLength: 2
            placeholderText: root.datePlaceholderText
            text: ('0' + d.presetDate.getDate()).slice(-2)
            onTextChanged: d.setNewDate()
            visible: !nowInput.visible

            validator: IntValidator { bottom: 1; top: {
                    let tempDate = newDate
                    tempDate.setDate(0)
                    return tempDate.getDate() }
            }

            onTrippleTap: d.selectAll()
            onClearEvent: d.clearAll()
        }
    }

    Component {
        id: editMonth
        StatusBaseDateInput {
            maximumLength: 2
            placeholderText: root.monthPlaceholderText
            text: ('0' + d.presetDate.getMonth()).slice(-2)
            onTextChanged: d.setNewDate()
            visible: !nowInput.visible

            validator: IntValidator { bottom: 1; top: 12 }

            onTrippleTap: d.selectAll()
            onClearEvent: d.clearAll()
        }
    }

    Component {
        id: editYear
        StatusBaseDateInput {
            maximumLength: 4
            placeholderText: root.yearPlaceholderText
            text: d.presetDate.getFullYear()
            onTextChanged: d.setNewDate()
            visible: !nowInput.visible

            validator: IntValidator { bottom: supportedStartYear; top: new Date().getFullYear() }

            onTrippleTap: d.selectAll()
            onClearEvent: d.clearAll()
        }
    }
}
