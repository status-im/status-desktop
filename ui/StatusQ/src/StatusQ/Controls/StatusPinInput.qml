import QtQuick 2.0
import StatusQ.Core.Theme 0.1
import StatusQ.Controls.Validators 0.1

/*!
   \qmltype StatusPinInput
   \inherits Item
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief It allows entering an N pin length.

   The \c StatusPinInput displays N visual circles corresponging with the pin length to introduce.

   It runs a blinking animation when the control is focused and ready to introduce the pin, as well as, an hovering feedback when user is in the MouseArea where is able to click into the control.

   This pin input control allows introducing validators.

   Example of how the control looks like:
   \image status_pin_input.png

   Example of how to use it:

   \qml
        StatusPinInput {
            id: regexPinInput
            validator:  StatusRegularExpressionValidator { regularExpression: /[0-9A-Za-z@]+/ }
            circleDiameter: 22
            circleSpacing: 22
            pinLen: 7
        }
   \endqml

   For a list of components available see StatusQ.
*/
Item {
    id: root

    /*!
       \qmlproperty string StatusPinInput::pinInput
       This property holds the introduced user pin.
    */
    property alias pinInput: inputText.text

    /*!
       \qmlproperty Validator StatusPinInput::validator
        This property allows you to set a validator on the StatusPinInput. When a validator is set the StatusPinInput will only accept
        input which leaves the pinInput property in an acceptable state.

        Currently supported validators are qml StatusIntValidator and StatusRegularExpressionValidator.

        An example of using validators is shown below, which allows input of integers between 0 and 999999 into the pin input

        \qml
            StatusPinInput {
                id: numbersPinInput
                validator: StatusIntValidator{bottom: 0; top: 999999;}
            }
        \endqml
    */
    property alias validator: d.statusValidator

    /*!
       \qmlproperty int StatusPinInput::pinLen
       This property allows you to set a specific pin input length. The default value is 6.
    */
    property int pinLen: 6

    /*!
       \qmlproperty int StatusPinInput::circleSpacing
       This property allows you to customize spacing between pin circles. The default value is 16 pixels.
    */
    property int circleSpacing: 16

    /*!
       \qmlproperty int StatusPinInput::circleDiameter
       This property allows you to customize pin circle diameter. The default value is 16 pixels.
    */
    property int circleDiameter: 16

    QtObject {
        id: d
        property int currentPinIndex: 0

        property StatusValidator statusValidator

        function activateBlink () {
            const currItem = repeater.itemAt(d.currentPinIndex)
            if(currItem) {
                if((currItem.innerState === "NEXT") && (!currItem.blinkingAnimation.running)) {
                    currItem.blinkingAnimation.start()
                }
            }
        }

        function deactivateBlink () {
            const currItem = repeater.itemAt(d.currentPinIndex)
            if(currItem) {
                if((currItem.innerState === "NEXT") && (currItem.blinkingAnimation.running)) {
                    currItem.blinkingAnimation.stop()

                    // To ensure that the opacity does not remain in an intermediate state when forcing the animation to stop
                    currItem.innerOpacity = 1
                }
            }
        }
    }

    /*
        \qmlmethod StatusPinInput::statesInitialization()

        Initializes pin input bringing it to its initial state.

        It is directly called in Component.onCompleted slot and can be called whenever you need resetting it.
    */
    function statesInitialization() {
        d.currentPinIndex = 0
        repeater.itemAt(d.currentPinIndex).innerState = "NEXT"
        for (var i = 1; i < root.pinLen; i++) {
            repeater.itemAt(i).innerState = "EMPTY"
        }
    }

    width: (root.circleDiameter + root.circleSpacing) * root.pinLen
    height: root.circleDiameter

    Component.onCompleted: { statesInitialization() }

    // Pin input data management object:
    TextInput {
        id: inputText
        visible: false
        focus: true
        maximumLength: root.pinLen
        validator: d.statusValidator.validatorObj
        onTextChanged: {
            // Modify state of current introduced character position:
            if(text.length >= (d.currentPinIndex + 1)) {
                repeater.itemAt(d.currentPinIndex).innerState = "FILLED"

                // Update next:
                d.currentPinIndex++
                if(d.currentPinIndex < root.pinLen)
                    repeater.itemAt(d.currentPinIndex).innerState = "NEXT"

            }
            // Modify state of current removed character position:
            else if (text.length <= (d.currentPinIndex + 1)) {
                if(d.currentPinIndex < root.pinLen)
                    repeater.itemAt(d.currentPinIndex).innerState = "EMPTY"
                d.currentPinIndex--
                repeater.itemAt(d.currentPinIndex).innerState = "NEXT"
            }

            // Some component validations:
            if(text.length !== d.currentPinIndex)
                console.error("StatusPinInput input management error. Current pin length must be "+ text.length + "and is " + d.currentPinIndex)
        }
        onFocusChanged: { if(!focus) { d.deactivateBlink () } }
    }

    // Pin input visual objects:
    Row {
        spacing: root.circleSpacing

        Repeater {
            id: repeater
            model: root.pinLen

            Rectangle {
                id: background
                property string innerState: "EMPTY"
                property alias blinkingAnimation: blinkingAnimation
                property alias innerOpacity: inner.opacity

                 width: root.circleDiameter
                 height: width
                 color: Theme.palette.primaryColor2
                 radius: 0.5 * width

                 Rectangle {
                     id: inner
                     state: background.innerState
                     anchors.centerIn: parent
                     height: width
                     color: Theme.palette.primaryColor1
                     radius: 0.5 * width
                     states: [
                         State {
                             name: "NEXT"
                             StateChangeScript { script: { if(inputText.focus) blinkingAnimation.start() } }
                             PropertyChanges {target: inner; width: root.circleDiameter / 2}                             
                         },
                         State {
                             name: "FILLED"                             
                             StateChangeScript { script: if(blinkingAnimation.running) blinkingAnimation.stop() }
                             PropertyChanges {target: inner; width: root.circleDiameter}
                             PropertyChanges {target: inner; opacity: 1}
                         },
                         State {
                             name: "EMPTY"
                             StateChangeScript { script: if(blinkingAnimation.running) blinkingAnimation.stop() }
                             PropertyChanges {target: inner; width: 0}
                             PropertyChanges {target: inner; opacity: 1}
                         }
                     ]

                     // Animation on transitions
                     Behavior on width { NumberAnimation { duration: 200 } }

                     // Animation on "cursor" blinking
                     SequentialAnimation {
                         id: blinkingAnimation
                         loops: Animation.Infinite
                         running: visible
                         NumberAnimation { target: inner; property: "opacity"; to: 0; duration: 800; running: visible }
                         NumberAnimation { target: inner; property: "opacity"; to: 1; duration: 800; running: visible }
                     }
                 }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        // MouseArea behavior:
        onClicked:  {
            inputText.forceActiveFocus()
            d.activateBlink ()
        }
        onContainsMouseChanged: { if(containsMouse) { cursorShape = Qt.PointingHandCursor } }
    }
}
