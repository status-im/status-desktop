import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ

Pane {
    id: root

    ColumnLayout {
        anchors.centerIn: parent

        RowLayout {
            Label {
                text: "Capitalized words:"
            }

            TextField {
                validator: GenericValidator {
                    validate: {
                        const split = input.split(' ')

                        const upperCase = split.map(w =>
                                                    w.charAt(0).toUpperCase()
                                                    + w.slice(1).toLowerCase())

                        return {
                            state: GenericValidator.Acceptable,
                            output: upperCase.join(' ')
                        }
                    }
                }
            }
        }

        RowLayout {
            Label {
                text: "Decimal numbers, replacing ',' with '.':"
            }

            TextField {
                id: decimalsTextField

                validator: GenericValidator {
                    validate: {
                        if (input.length === 0)
                            return GenericValidator.Intermediate

                        const validCharSet = /^[0-9\.\,]*$/.test(input)

                        if (!validCharSet)
                            return GenericValidator.Invalid

                        const pointFixed = input.replace(",", ".")
                        const pointsCount = (pointFixed.match(/\./g) || []).length

                        const wellFormed = pointFixed.charAt(0) !== '.'
                                         && pointFixed.charAt(
                                             pointFixed.length - 1) !== '.'

                        if (pointsCount > 1)
                            return GenericValidator.Invalid

                        return {
                            state: wellFormed ? GenericValidator.Acceptable
                                              : GenericValidator.Intermediate,
                            output: pointFixed
                        }
                    }
                }
            }

            Label {
                text: `acceptable: ${decimalsTextField.acceptableInput}`
            }
        }

        RowLayout {
            Label {
                text: "Position always at 0:"
            }

            TextField {
                validator: GenericValidator {
                    validate: ({
                        state: GenericValidator.Acceptable,
                        pos: 0
                    })
                }
            }
        }

        RowLayout {
            Label {
                text: "Maximum number of characters:"
            }

            TextField {
                id: limitedTextField

                validator: GenericValidator {
                    validate: input.length <= slider.value
                }
            }

            Label {
                text: `acceptable: ${limitedTextField.acceptableInput}`
            }

            Slider {
                id: slider

                from: 3
                to: 10
                stepSize: 1
            }

            Label {
                text: `max: ${slider.value}`
            }
        }
    }
}
