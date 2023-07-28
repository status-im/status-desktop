# Contributing guidelines

## Generic Reusable Component Design

Define the component's purpose. Narrow down the scope as much as possible.

Avoid assumptions about its parent/owner

- See [broken behavior example](./code-examples.md#Dont-assume-parents-context-bad-example)
- See [well-behaved behavior example](./code-examples.md#Give-user-choice)

Define and make clear the interface/contract that defines requirements.

To simplify maintenance consider the following options for implementing custom controls, generic containers or views:

- Use QML2's customization mechanics in place if the change is simple: [Check docs for examples](https://doc.qt.io/qt-6/qtquickcontrols2-customize.html)
- If the control should be generic or the changes are extensive and the design maps to a QML control, use QML2's customization mechanisms in a generic QML control: [Check docs for examples](https://doc.qt.io/qt-6/qtquickcontrols2-customize.html) instead of starting from scratch.
- Use Qt controls instead of defining our own. Defining and implementing a complex control from scratch should be the last resort and there should be an excellent reason to do that.
- For keyboard input item, ensure focus properties are set; see [Qt docs](https://doc.qt.io/qt-6/qtquick-input-focus.html)

When unsure, check Qt's excellent documentation.

- For main components/controls, there is a good overview that is worth revisiting from time to time
- Functions/Properties usually have a short on-point description
- In `QtCreator` you can quickly open the doc panel using `F1` key while having a cursor on component or function/property and recheck its invariants, pre and post conditions

Consider that design follows user-friendlier principles.

- Have commonly used items at hand
- Have transition if possible
  - Use Qt's property animation for states
- Avoid often and radical size changes to items in views/layouts. Radical size change confuses users.
  - If the content is not available, consider having placeholders using the estimated size
    (delegates, dummy items)

Have the base control as the component's root. This way, control inherits all the interface and reduce the code.
If it doesn't map to an existing one, use a base control like `Item`.

- Don't use layouts or positioners as base for controls, they don't have the same behavior when used in layouts/containers
  - Layouts have `fillWidth`/`fillHeight` as true by default and they will be extended. Controls don't and they will follow implicit sizes

## QML well-behaved components checklist

### Positioning and sizing

[Positioners and Layouts In QML](https://doc.qt.io/qt-6/qtquick-usecase-layouts.html)

- Define size hints appropriately. Define implicit properties (`impicitWidth` and `implicitHeight`)

  - They are used to break polishing binding loops for adaptive control
  - All the containers use the implicit size for deriving the initial size (Layouts, Popups, Delegates, GridView, ListView ...). Size hints combined with resize adaptability are the appropriate way to have reactive controls.
  - For complex controls, look if layouts are the choice as the main position driver. [Layouts](###Layouts)

  ```qml
  Item {
    id: root
    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight
    RowLayout {	// Column, Grid
       id: mainLayout
       // ...
    }
  ```

- Adapt to the requested size if control can scale or it make sense to be extensible. For sizes bigger than content follow QML way for similar controls. e.g. Text leaves empty space around content
- If the control is not adaptable and makes sense only in its full size, define default sizes and make it work by default with positioners (`Row`, `Column`, `Grid`).
  - [Item Positioners in QML](https://doc.qt.io/qt-5/qtquick-positioning-layouts.html)
- Don't mix hints with sizes, it will create binding loops

### Quality

Pixel miss-alignment for sensitive elements like icons and images with straight and thin lines can degrade the quality perceptibly.

Dividing sizes and coordinates are the usual root cause of pixel miss-alignment. Correct subpixel division by rounding the result of the operation to a fixed value, e.g. `x: (width/2).toFixed()`

- Example of pixel miss-alignment. The right control has a position offset of `Qt.pos(0.7, 0.4)` therefore, the image interpolation generates a blurred rendering.
  - ![](https://user-images.githubusercontent.com/47554641/163448378-3a6ede2f-a922-4f35-bff7-93c6bfa840d5.png)

## Topics

### QML Coding Conventions

[Follow Qt's way if appropriate](https://doc.qt.io/qt-6/qml-codingconventions.html)

### Layouts

[Qt Quick Layouts Overview](https://doc.qt.io/qt-6/qtquicklayouts-overview.html)

Hierarchically sources hints from children. Implicit properties will have the recommended aggregated size.

Layouts as children of other layouts have `fillWidth` and `fillHeight` enabled; controls don't.

Use `Layout.preferredWidth` and `Layout.preferredHeight` attached properties to overwrite item's `implicitWidth` if they are not appropriate to the design.

### Scope

Follow [Qt's recommendations](https://doc.qt.io/qt-5/qtqml-documents-scope.html) if appropriate

- Avoid dynamic scoping in out-of-line components, see more: https://doc.qt.io/qt-5/qtqml-documents-scope.html#component-instance-hierarchy

  - Example

    ```qml
    Item {
      // Probably won't work as intended. If another `testComp` instance is defined in QML's document hierarchy model and has a `testProp` property, that will be sourced instead
      property bool booleanProp: testComp.testProp
      // Same behavior if the TestComponent is defined in a file TestComponent.qml
      component TestComponent: Item {
        id: testComp
        property bool testProp: false
      }
    }
    ```

- Component `id`s are not accessible outside the component's scope. If required, the component can expose the instance through properties binding. E.g. `readonly property ComponentType exposedComponent: privateInstanceId`

- If in doubt, explicitly use an instance variable to access properties
- If the scope is clear and there is no ambiguity, use the property directly for readability

### Popups content sizing

As stated in Qt documentation on Popup content sizing:

1. `Popup` size is as calculated internally as `contentItem.implicitSize + paddings`
2. The size of `contentItem` is managed by the popup to fit the Popup and paddings

It's important to understand that `Popup.contentItem` is an internal invisible Item. Any user items will be parented to the `contentItem`, not the `Popup` itself.

Knowing this, we make a simple rule to choose one of 2 ways for popup content sizing:

1. Replace the `contentItem` with your item, but don't explicitly anchor or bind it's sizes, because the size of `contentItem` is managed by the popup.

```qml
Popup {
  contentItem: ColumnLayout {
    // no anchoring or binding
 }
}
```

2. Don't touch the `contentItem` property, but create a single child to the popup and **anchor it to `parent`**.

```qml
Popup {
  ColumnLayout {
    anchors.fill: parent // parent is contentItem, not Popup
  }
}
```

### StatusScrollView

> A presenation on using `StatusScrollView` can be found [here](https://docs.google.com/presentation/d/1ZZeg9j2fZMV-iHreu_Wsl1u6D9POH7SlUO78ZXNj-AI).

#### Basic usage

```qml
StatusScrollView {
    anchors.fill: parent // Give the SceollView some size

    // - No need to specify  contentWidth and contentHeight. 
    // For a single child item it will be calculated automatically from implicit size of the item.
    // The item must have implicit size specified. Not width/height.

    Image {
        source: "https://placekitten.com/400/600"
    }
}
```

#### Filling width

```qml
StatusScrollView {
    id: scrollView
    anchors.fill: parent
    contentWidth: availableWidth // Bind ScrollView.contentWidth to availableWidth

    ColumnLayout {
        width: scrollView.availableWidth // Bind content width to  availableWidth
    }
}
```

#### In a popup

1. Use when `StatusScrollView` is the _only direct child_ of popup's `contentItem`.
2. If you have other items outside the scroll view, you will have to manually apply paddings to them as well.

```qml
StatusModal {
    padding: 0 // Use paddings of StatusScrollView

    StatusScrolLView {
        id: scrollView

        anchors.fill: parent
        implicitWidth: 400
        contentWidth: availableWidth
        padding: 16 // Use padding of StatusScrollView, not StatusModal

        Text {
            width: scrollView.availableWidth
            wrapMode: Text.WrapAnywhere
            text: "long text here"
        }
    }
}

```

#### Deep in a popup

1. Use when `StatusScrollView` or `StatusListView` is not a direct child of `contentItem`, or it's not the only child.
2. All popup contents are aligned to given paddings, but the scroll bar doesn't overlay the content and is positioned right inside the padding.

```qml
StatusModal {
    padding: 16 // Use popup paddings

    ColumnLayout {
        anchors.fill: parent
        
        Text {
            Layout.fillWidth: true
            text: "This header is fixed and not scrollable"
        }

        Item {
            id: scrollViewWrapper

            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: scrollView.implicitWidth
            implicitHeight: scrollView.implicitHeight

            StatusScrollView {
                id: scrollView

                anchors.fill: parent
                contentWidth: availableWidth
                padding: 0 // Use popup paddings

                // Detach scrollbar
                ScrollBar.vertical: StatusScrollBar {
                    parent: scrollViewWrapper
                    anchors.top: scrollView.top
                    anchors.bottom: scrollView.bottom
                    anchors.left: scrollView.right
                    anchors.leftMargin: 1
                }

                Text {
                    width: scrollView.availableWidth
                    wrapMode: Text.WrapAnywhere
                    text: "long scrollable text here"
                }
            }
        }
    }
}
```

## Testing

Test in isolation

- Use `qmlproject`s and `qml` for quick complex scenarios
- Use [`QtQuick.TestCase`](https://doc.qt.io/qt-5/qtquicktest-index.html)

Integration tests

- Use sandbox test app
- Use QML `qmlproject`s and `qmlscene` for quick debugging with layouts

Try scenarios

- Embed in Layouts with different properties: fixed size, min-max, not size set

  ```qml
  Window {
    width: mainLayout.implicitWidth
    heigh: mainLayout.implicitHeight

    GridLayout {
      id: mainLayout
      rows: 3
      column: 3

      anchor.fill: parent
      Label { text: "Fixed width" }
      TestControl {
        Layout.preferredWidth: 100
        Layout.preferredHeight: 100
      }
      Label { text: "Fill space" }
      TestControl {
        Layout.fillWidth: true
        Layout.fillHeight: true
      }
      Label { text: "Width range" }
      TestControl {
        Layout.minWidth: 50
        Layout.maxWidth: 150
      }
      TestControl {}
    }
  }
  ```

- Resize window to check the behavior for each case
  - Visually validate that each control is behaving as expected
- Add controls with different properties that affect control size behavior
