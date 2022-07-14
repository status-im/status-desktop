import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

StatusPopupMenu {
    id: root
    dim: false

    property var searchPopup
    property var locationModel
    readonly property int numDefaultItems: 2

    signal itemClicked(string firstLevelItemValue, string secondLevelItemValue)

    StatusMenuItem {
        text: qsTr("Anywhere")
        onTriggered: {
            searchPopup.resetSearchSelection();
            root.itemClicked("", "");
        }
    }
    StatusMenuSeparator { }
    //Dummy item to keep seperator in right position
    MenuItem { implicitHeight: 0.00001 }
    Instantiator {
        model: root.locationModel
        delegate: Loader {
            sourceComponent: (!!model.subItems && model.subItems.count > 0) ? subMenus : subMenuItemComponent
            onLoaded: {
                if (!!model.subItems && model.subItems.count > 0)  {
                    item.parentValue = model.value
                    item.title = model.title;
                    item.subItemsModel = model.subItems;
                    item.parentIconName = model.iconName;
                    item.parentImageSource = model.imageSource;
                    item.parentIdenticonColor = !!model.iconColor ? model.iconColor : Theme.palette.primaryColor1;
                    root.subMenuItemIcons.push({
                                    source: model.imageSource,
                                    icon: model.iconName,
                                    isIdenticon: model.isIdenticon,
                                    color: model.iconColor,
                                    isLetterIdenticon: !model.imageSource && !model.iconName
                                   });
                    root.insertMenu(index + numDefaultItems, item);
                } else {
                    item.value = model.value
                    item.text = model.title;
                    item.iconSettings.name = model.iconName;
                    item.iconSettings.color = model.iconColor;
                    item.iconSettings.isLetterIdenticon = !model.imageSource && !model.iconName
                    item.image.source = model.imageSource;
                    item.image.isIdenticon = model.isIdenticon;
                    root.insertItem(index + numDefaultItems, item);
                }
            }
        }
        onObjectRemoved: { root.removeItem(root.takeItem(index + numDefaultItems)); }
    }

    Component {
        id: subMenuItemComponent
        StatusSearchPopupMenuItem {
            onTriggered: {
                searchPopup.resetSearchSelection()
                searchPopup.setSearchSelection(text,
                                               "",
                                               image.source,
                                               image.isIdenticon,
                                               iconSettings.name,
                                               iconSettings.color)
                root.itemClicked(value, "")
            }
        }
    }

    Component {
        id: subMenus
        StatusPopupMenu {
            id: menu
            dim: false
            property var subItemsModel
            property string parentValue
            property string parentIconName
            property string parentImageSource
            property string parentIdenticonColor
            property string parentIsIdenticon
            Repeater {
                id: menuLoader
                model: menu.subItemsModel
                property string parentValue: menu.parentValue
                property string parentTitleText: menu.title
                property string parentIconName: menu.parentIconName
                property string parentImageSource: menu.parentImageSource
                property string parentIdenticonColor: menu.parentIdenticonColor
                property string parentIsIdenticon: menu.parentIsIdenticon
                Loader {
                    id: subMenuLoader
                    sourceComponent: StatusSearchPopupMenuItem {
                        value: model.value
                        text: model.text
                        image.source: model.imageSource
                        iconSettings.name: model.iconName
                        iconSettings.color: model.isUserIcon ? Theme.palette.userCustomizationColors[model.colorId] : model.iconColor
                        iconSettings.charactersLen: model.isUserIcon ? 2 : 1
                        ringSettings.ringSpecModel: model.colorHash
                        onTriggered: {
                            searchPopup.resetSearchSelection()
                            if (menuLoader.parentTitleText === "Chat") {
                                searchPopup.setSearchSelection(model.text,
                                                               "",
                                                               model.imageSource,
                                                               model.isIdenticon,
                                                               model.iconName,
                                                               model.iconColor,
                                                               model.isUserIcon,
                                                               model.colorId,
                                                               model.colorHash.toJson())
                            } else {
                                searchPopup.setSearchSelection(menuLoader.parentTitleText,
                                                   model.text,
                                                   menuLoader.parentImageSource,
                                                   menuLoader.parentIsIdenticon,
                                                   menuLoader.parentIconName,
                                                   menuLoader.parentIdenticonColor)
                            }
                            root.itemClicked(menuLoader.parentValue, value)
                            root.dismiss()
                        }
                    }
                }
            }
        }
    }
    onMenuItemClicked: {
        searchPopup.resetSearchSelection()
        let menuItem = root.menuAt(root.currentIndex)
        searchPopup.setSearchSelection(menuItem.title,
                           "",
                           menuItem.parentImageSource,
                           menuItem.parentIsIdenticon,
                           menuItem.parentIconName,
                           menuItem.parentIdenticonColor)
        root.itemClicked(menuItem.parentValue, "")
        //TODO fix error "QML StatusPopupMenu: cannot find any window to open popup in."
        root.dismiss()
    }
}
