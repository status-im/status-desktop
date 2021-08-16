import QtQuick 2.12
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

StatusPopupMenu {
    id: root

    property var searchPopup
    property var locationModel

    signal subMenuClicked()
    signal subMenuItemClicked()
    signal anywhereItemClicked()
    signal menuItemNoSubMenuClicked()

    StatusMenuItem {
        text: "Anywhere"
        onTriggered: {
            searchPopup.resetSelectionBadge();
            searchPopup.searchSelectionButton.primaryText = text;
            root.anywhereItemClicked();
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
                    item.parentIsIdenticon = model.isIdenticon;
                    root.subMenuItemIcons.push({
                                    source: model.imageSource,
                                    icon: model.iconName,
                                    isIdenticon: model.isIdenticon,
                                    color: model.iconColor,
                                    isLetterIdenticon: !model.imageSource && !model.iconName
                                   });
                    root.insertMenu(index+2, item);
                } else {
                    item.value = model.value
                    item.text = model.title;
                    item.iconSettings.name = model.iconName;
                    item.iconSettings.color = model.iconColor;
                    item.iconSettings.isLetterIdenticon = !model.imageSource && !model.iconName
                    item.image.source = model.imageSource;
                    item.image.isIdenticon = model.isIdenticon;
                    root.insertItem(index+2, item);
                }
            }
        }
        onObjectRemoved: { root.removeItem(root.takeItem(index+2)); }
    }

    Component {
        id: subMenuItemComponent
        StatusSearchPopupMenuItem {
            onClicked: {
                searchPopup.resetSelectionBadge()
                searchPopup.searchSelectionButton.primaryText = text;
                searchPopup.searchSelectionButton.image.source = image.source;
                searchPopup.searchSelectionButton.image.isIdenticon = image.isIdenticon;
                searchPopup.searchSelectionButton.iconSettings.name = iconSettings.name;
                searchPopup.searchSelectionButton.iconSettings.color = !!iconSettings.color ? iconSettings.color : Theme.palette.primaryColor1
                searchPopup.searchSelectionButton.iconSettings.isLetterIdenticon = !iconSettings.name && !image.source
                root.menuItemNoSubMenuClicked();
            }
        }
    }

    Component {
        id: subMenus
        StatusPopupMenu {
            id: menu
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
                        iconSettings.color: model.iconColor
                        image.isIdenticon: model.isIdenticon
                        onTriggered: {
                            searchPopup.resetSelectionBadge();
                            if (menuLoader.parentTitleText === "Chat") {
                                searchPopup.searchSelectionButton.primaryText = model.text;
                                searchPopup.searchSelectionButton.image.source = model.imageSource;
                                searchPopup.searchSelectionButton.image.isIdenticon = model.isIdenticon;
                                searchPopup.searchSelectionButton.iconSettings.name = model.iconName;
                                searchPopup.searchSelectionButton.iconSettings.color = !!model.iconColor ? model.iconColor : Theme.palette.primaryColor1;
                                searchPopup.searchSelectionButton.iconSettings.isLetterIdenticon = !model.iconName && !model.imageSource
                            } else {
                                searchPopup.searchSelectionButton.primaryText = menuLoader.parentTitleText;
                                searchPopup.searchSelectionButton.secondaryText = model.text;
                                searchPopup.searchSelectionButton.image.source = menuLoader.parentImageSource;
                                searchPopup.searchSelectionButton.image.isIdenticon = menuLoader.parentIsIdenticon;
                                searchPopup.searchSelectionButton.iconSettings.name = menuLoader.parentIconName;
                                searchPopup.searchSelectionButton.iconSettings.color = !!menuLoader.parentIdenticonColor ? menuLoader.parentIdenticonColor : Theme.palette.primaryColor1;
                                searchPopup.searchSelectionButton.iconSettings.isLetterIdenticon = !menuLoader.parentIconName && !menuLoader.parentImageSource
                            }
                            root.subMenuItemClicked();
                            root.dismiss();
                        }
                    }
                }
            }
        }
    }
    onMenuItemClicked: {
        searchPopup.resetSelectionBadge();
        let menuItem = root.menuAt(root.currentIndex)
        searchPopup.searchSelectionButton.primaryText = menuItem.title;
        searchPopup.searchSelectionButton.image.source = menuItem.parentImageSource;
        searchPopup.searchSelectionButton.image.isIdenticon = menuItem.parentIsIdenticon;
        searchPopup.searchSelectionButton.iconSettings.name = menuItem.parentIconName;
        searchPopup.searchSelectionButton.iconSettings.color = menuItem.parentIdenticonColor;
        searchPopup.searchSelectionButton.iconSettings.isLetterIdenticon = !menuItem.parentIconName && !menuItem.parentImageSource
        root.subMenuClicked();
        //TODO fix error "QML StatusPopupMenu: cannot find any window to open popup in."
        root.dismiss();
    }
}
