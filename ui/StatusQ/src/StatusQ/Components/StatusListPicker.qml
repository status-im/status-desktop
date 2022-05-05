import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

/*!
   \qmltype StatusListPicker
   \inherits Item
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief It is a combination of StatusPickerButton and a drop-down list component that provides a way of presenting a list of selectable options to the user. Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-item.html}{Item}.

   The \c StatusListPicker is populated with a data model. The data model is commonly a JavaScript array or a ListModel object.

   StatusListPicker can be made as a single or multiple options picker by setting its StatusListPicker::multiSelection property properly or will be auto-set if the model contains / provides more than one selected items.
   The StatusPickerButton text holds the text of the current item selected in the list picker. If there is more than one item selected, a string composed will be displayed.
   The drop-down list incorporates a searcher by the following model roles: `name` or / and `shortName`.

   NOTE: Make sure to set the appropriate z-index when instantiating the component in order to place it on top of your view in order to display the drop-down data properly.
   Make sure to position the component inside its parent also when it is spanned in order to achieve a better user experience.

   Example of how the component looks like:
   \image status_list_picker.png
   Example of how to use it:
   \qml
        StatusListPicker {
            id: currencyPicker
            inputList: Models.currencyPickerModel
            searchText: qsTr("Search Language")
            multiSelection: true
            printSymbol: true
        }
   \endqml
   For a list of components available see StatusQ.
*/
Item {
    id: root

    /*!
       \qmlproperty string StatusListPicker::inputList
       This property holds the data that will be populated in the list picker.

       NOTE: This model property should not change so it is an in / out property where the selected role will be dynamically changed according to user actions.

       Here an example of the model roles expected:
       \qml
            inputList: ListModel {
            ListElement {
                key: 0
                name: "United States Dollar"
                shortName: "USD"
                symbol: "$"
                imageSource: "../../assets/twemoji/26x26/1f4b4.png"
                category: "fiat"
                selected: true
            }
            ListElement {
                key: 1
                name: "British Pound"
                shortName: "GBP"
                symbol: "£"
                imageSource: "../../assets/twemoji/26x26/1f4b5.png"
                category: "fiat"
                selected: false
            }
        }
       \endqml
    */
    property ListModel inputList: ListModel { }

    /*!
       \qmlproperty string StatusListPicker::searchText
       This property holds the search text the searcher input displays by default.
    */
    property string searchText: ""

    /*!
       \qmlproperty string StatusListPicker::placeholderSearchText
       This property holds the placeholder text the searcher input displays by default.
    */
    property string placeholderSearchText: qsTr("Search")

    /*!
       \qmlproperty string StatusListPicker::multiSelection
       This property holds whether the list picker is a single or a multiple picker option by displaying a StatusRadioButton or StatusCheckBox instead.
    */
    property bool multiSelection: false

    /*!
       \qmlproperty string StatusListPicker::printSymbol
       This property holds whether the selected items will display a composition of the role `symbol` in the StatusPickerButton text or just only the role `shortName`.
    */
    property bool printSymbol: false

    /*!
       \qmlproperty string StatusListPicker::maxPickerHeight
       This property holds the maximum drop-down list height allowed. The drop-down list height will be set as the minimum value between the list content height and the maxPickerHeight property.
    */
    property int maxPickerHeight: 718

    /*!
       \qmlproperty string StatusListPicker::enableSelectableItem
       This property holds if the item in the list will be highlighted when hovering and clickable in its complete area or just not highlighted and able to be selected by clicking only the checbox or radiobutton area.
    */
    property bool enableSelectableItem: true

    /*!
       \qmlproperty string StatusListPicker::menuAlignment
       This property holds the allignment of the menu in terms of the button
    */
    property int menuAlignment: StatusListPicker.MenuAlignment.Right

    /*!
       \qmlproperty enum StatusListPicker::MenuAlignment
       This property holds the allignment of the menu in terms of the button
       values can be Left, Right or Center
    */
    enum MenuAlignment {
        Left,
        Right,
        Center
    }

    /*
        \qmlmethod StatusListPicker::close()
        It can be used to force to close the drop-down picker list whenever the consumer needs it. For example by adding an outside MouseArea to close the picker when user clicks outsite the component:
       \qml
            // Outsite area
            MouseArea {
                height: root.height
                width: root.width
                onClicked: { currencyPicker.close() }
            }
       \endqml
    */
    function close() {
        picker.visible = false

        // Reset searcher:
        root.searchText = ""
    }

    /*!
        \qmlsignal StatusListPicker::itemPickerChanged(string key, bool selected)
        This signal is emitted when an item changes its selected value.
    */
    signal itemPickerChanged(string key, bool selected)

    QtObject {
        id: d
        property var filteredModel: ListModel { }

        // Used to set up component and the needed private properties
        function initialize() {
            if(filteredModel.count === 0) {
                // It is necessary to load the model, not loaded yet!
                var selected = 0
                var selectionText = ""
                for(var i = 0; i < root.inputList.count; i++) {
                    var item = root.inputList.get(i)
                    d.filteredModel.append(item)
                    if(item.selected) selected++;
                }

                // If the given model has more than one selected elements, the behaviour of the list picker will be as a multiple selector with checkboxes although it is
                // set in the radiobutton mode. Radiobutton mode is only for mutial-exclusion.
                if(selected > 1)
                    multiSelection = true

                // Update selected items text:
                d.getSelectedItemsText()
            }
        }

        // Used to update model elements given a specific text by filtering them for its `name` and / or `shortName`.
        function applyFilter(text) {
            const input = text.toLowerCase()
            filteredModel.clear()
            for(var i = 0; i < root.inputList.count; i++) {
                let item = root.inputList.get(i)
                if(item.name.toLowerCase().includes(input) || item.shortName.toLowerCase().includes(input))
                    filteredModel.append(item)
            }
        }        

        function formatSymbolShortNameText(symbol, shortName) {
            var formattedText = ""
            if(root.printSymbol && symbol)
                formattedText = symbol + shortName
            else
                formattedText = shortName
            return formattedText
        }

        function getSelectedItemsText() {
            var res = ""
            for(var i = 0; i < root.inputList.count; i++) {
                var item = root.inputList.get(i)
                if(item.selected) {
                    if(res != "")
                        res += ", "
                    res += d.formatSymbolShortNameText(item.symbol, item.shortName)
                }
            }
            return res
        }

        // Used to update the base input list model with the new selected property
        function updateInputListModel(key, selected, isSingleSelection) {
            // If it is a single selection we must ensure that when a new key is selected  others are cleared.
            // It must be done manually because as there is the option of filterning, the model visualized changes
            // and it could be possible to have a filtered list without an element selected (but in the base model
            // it is) so, the binding to not selected will not be executed, as in the current filtered model
            // there are no changes to update, just only the selected one.
            for(var i = 0; i < root.inputList.count; i++) {
                if(root.inputList.get(i).key === key) {
                    root.inputList.get(i).selected = selected
                }
                else if(isSingleSelection && selected) {
                     // Clear all the list
                    root.inputList.get(i).selected = false
                }
            }
        }
    }

    width: 110
    height: 38

    Component.onCompleted: d.initialize()

    StatusPickerButton {
        id: btn
        anchors.fill: parent
        bgColor: Theme.palette.primaryColor3
        contentColor: Theme.palette.primaryColor1
        text: picker.selectedItemsText
        textPixelSize: 13
        type: StatusPickerButton.Type.Down

        onClicked: {
            picker.visible = !picker.visible

            // Restart list position:
            content.positionViewAtBeginning()
            content.forceActiveFocus()
        }
    }

    Rectangle {
        id: picker

        property string selectedItemsText: ""

        width: content.itemWidth
        height: Math.min(content.contentHeight + content.anchors.topMargin + content.anchors.bottomMargin, root.maxPickerHeight)
        anchors.left: root.menuAlignment === StatusListPicker.MenuAlignment.Left ? btn.left : undefined
        anchors.right: root.menuAlignment === StatusListPicker.MenuAlignment.Right ? btn.right : undefined
        anchors.horizontalCenter: root.menuAlignment === StatusListPicker.MenuAlignment.Center ? btn.horizontalCenter : undefined
        anchors.top: btn.bottom
        anchors.topMargin: 4
        visible: false
        color: Theme.palette.statusPopupMenu.backgroundColor
        radius: 8
        layer.enabled: true
        layer.effect: DropShadow {
            source: picker
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 25
            spread: 0.2
            color: Theme.palette.dropShadow
        }

        ListView {
            id: content            

            property int itemHeight: 40
            property int itemWidth: 360

            model: d.filteredModel
            width: itemWidth
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            currentIndex: -1
            clip: true
            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                id: header
                width: content.itemWidth
                height: searchInput.height + 24
                color: Theme.palette.statusPopupMenu.backgroundColor
                z: 3 // Above delegate (z=1) and above section.delegate (z = 2)

                StatusBaseInput {
                    id: searchInput
                    implicitHeight: 36
                    width: content.itemWidth - 2 * 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    topPadding: 0
                    bottomPadding: 0
                    placeholderText: root.placeholderSearchText
                    text: root.searchText
                    icon.name: "search"

                    onTextChanged: {
                        d.applyFilter(text)
                        root.searchText = text
                    }
                }
            }// End of search input item
            delegate: StatusItemPicker {
                width: content.itemWidth
                height: content.itemHeight
                color: mouseArea.containsMouse ? Theme.palette.baseColor4 : "transparent"
                image: StatusImageSettings {
                    source: model.imageSource ? model.imageSource : ""
                    width: 15
                    height: 15
                    isIdenticon: false
                }
                name: model.name
                shortName: model.shortName
                selectorType: root.multiSelection ? StatusItemPicker.SelectorType.CheckBox : StatusItemPicker.SelectorType.RadioButton
                selected: model.selected
                radioGroup: radioBtnGroup

                onCheckedChanged: {
                    d.updateInputListModel(model.key, checked, selectorType === StatusItemPicker.SelectorType.RadioButton)
                    if(selectorType === StatusItemPicker.SelectorType.RadioButton && checked) {
                        // Update selected item text
                        picker.selectedItemsText = d.formatSymbolShortNameText(model.symbol, model.shortName)
                    }
                    else {
                        // Update selected items text (multiple selection, text chain).
                        picker.selectedItemsText = d.getSelectedItemsText()
                    }

                    // Used to notify selected property changes in the specific item picker.
                    itemPickerChanged(model.key, checked)
                }

                MouseArea {
                    id: mouseArea
                    enabled: root.enableSelectableItem
                    anchors.fill: parent
                    cursorShape: root.enableSelectableItem ? Qt.PointingHandCursor : Qt.ArrowCursor
                    hoverEnabled: true
                    onClicked: {
                        if(selectorType === StatusItemPicker.SelectorType.RadioButton) {
                            // Just only allow to select, not unselect in case of single selection (radiobutton)
                             if(!selected) selected = !selected
                        }
                        else
                            // In case of multiple selections you can both select and unselect.
                            selected = !selected
                    }
                }
            }
            section.property: "category"
            section.criteria: ViewSection.FullString
            section.delegate: Item {
                width: content.itemWidth
                height: content.itemHeight

                StatusBaseText {
                    anchors.leftMargin: 18
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: section
                    color: Theme.palette.baseColor1
                    font.pixelSize: 15
                    elide: Text.ElideRight
                }
            }// End of Category item

            onActiveFocusChanged: { if(!activeFocus) root.close() }

            // Not visual element to control mutual-exclusion of radiobuttons that are not sharing the same parent (inside list view)
            ButtonGroup {
                id: radioBtnGroup
            }           
        }// End of Content        
    }// End of Rectangle picker
}
