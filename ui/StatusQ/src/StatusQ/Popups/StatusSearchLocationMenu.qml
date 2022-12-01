import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14

import Qt.labs.qmlmodels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

StatusMenu {
    id: root

    property var locationModel
    readonly property int numDefaultItems: 2

    signal itemClicked(string firstLevelItemValue, string secondLevelItemValue)

    signal resetSearchSelection()

    signal setSearchSelection(string text,
                              string secondaryText,
                              string imageSource,
                              string isIdenticon,
                              string iconName,
                              string iconColor,
                              var isUserIcon,
                              int colorId,
                              string colorHash)

    function processTriggeredMenuItem(title,
                                      parentImageSource,
                                      parentIsIdenticon,
                                      parentIconName,
                                      parentIdenticonColoe) {
        root.resetSearchSelection()
        let menuItem = root.menuAt(root.currentIndex)

        root.setSearchSelection(menuItem.title,
                           "",
                           menuItem.parentImageSource,
                           menuItem.parentIsIdenticon,
                           menuItem.parentIconName,
                           menuItem.parentIdenticonColor)

        //TODO fix error "QML StatusMenu: cannot find any window to open popup in."
        root.dismiss()
    }

    StatusAction {
        text: qsTr("Anywhere")
        onTriggered: {
            root.resetSearchSelection();
            root.itemClicked("", "");
        }
    }

    StatusMenuSeparator { }

    StatusMenuInstantiator {
        model: root.locationModel
        menu: root

        delegate: DelegateChooser {
            role: "hasSubItems"

            DelegateChoice {
                roleValue: false
                delegate: StatusSearchPopupMenuItem {
                    text: model.title
                    assetSettings.name: !!model.imageSource ? !!model.imageSource : model.iconName
                    assetSettings.isImage: !!model.imageSource
                    assetSettings.isLetterIdenticon: !model.imageSource && !model.iconName
                    assetSettings.imgIsIdenticon: model.isIdenticon
                    onTriggered: {
                        root.resetSearchSelection()
                        root.setSearchSelection(text,
                                                "",
                                                "",
                                                assetSettings.isIdenticon,
                                                assetSettings.name,
                                                assetSettings.color)
                        root.itemClicked(model.value, "")
                    }
                }
            }

            DelegateChoice {
                roleValue: true
                delegate: StatusMenu {
                    id: subMenuDelegate

                    readonly property var subItemsModel: model.subItems
                    readonly property string parentValue: model.value
                    readonly property string parentIconName: model.iconName
                    readonly property string parentImageSource: model.imageSource
                    readonly property string parentIdenticonColor: !!model.iconColor ? model.iconColor : defaultIconColor
                    readonly property bool parentIsIdenticon: model.isIdenticon

                    title: model.title
                    assetSettings.name: !!model.iconName ? model.iconName : model.imageSource
                    assetSettings.color: !!model.iconColor ? model.iconColor : defaultIconColor
                    assetSettings.isImage: !!model.imageSource
                    assetSettings.imgIsIdenticon: model.isIdenticon
                    assetSettings.isLetterIdenticon: !model.imageSource && !model.iconName

                    StatusMenuInstantiator {
                        id: menuLoader

                        readonly property string parentValue: subMenuDelegate.parentValue
                        readonly property string parentTitleText: subMenuDelegate.title
                        readonly property string parentIconName: subMenuDelegate.parentIconName
                        readonly property string parentImageSource: subMenuDelegate.parentImageSource
                        readonly property string parentIdenticonColor: subMenuDelegate.parentIdenticonColor
                        readonly property string parentIsIdenticon: subMenuDelegate.parentIsIdenticon

                        menu: subMenuDelegate
                        model: subMenuDelegate.subItemsModel

                        delegate: StatusSearchPopupMenuItem {
                            value: model.value
                            text: model.text
                            assetSettings.isImage: !!model.imageSource
                            assetSettings.name: !!StatusQUtils.Emoji.iconSource(model.imageSource) ?
                                                  StatusQUtils.Emoji.iconSource(model.imageSource) : model.imageSource
                            assetSettings.color: model.isUserIcon ? Theme.palette.userCustomizationColors[model.colorId] : model.iconColor
                            assetSettings.bgColor: model.iconColor
                            assetSettings.charactersLen: model.isUserIcon ? 2 : 1
                            ringSettings.ringSpecModel: model.colorHash
                            onTriggered: {
                                root.resetSearchSelection()
                                if (menuLoader.parentTitleText === "Chat") {
                                    root.setSearchSelection(model.text,
                                                            "",
                                                            model.imageSource,
                                                            model.isIdenticon,
                                                            model.iconName,
                                                            model.iconColor,
                                                            model.isUserIcon,
                                                            model.colorId,
                                                            model.colorHash.toJson())
                                } else {
                                    root.setSearchSelection(menuLoader.parentTitleText,
                                                            model.text,
                                                            menuLoader.parentImageSource,
                                                            menuLoader.parentIsIdenticon,
                                                            menuLoader.parentIconName,
                                                            menuLoader.parentIdenticonColor,
                                                            "",
                                                            -1,
                                                            "")
                                }
                                root.itemClicked(subMenuDelegate.parentValue, value)
                                root.dismiss()
                            }
                        }
                    }
                }
            }
        }
    }

}
