import QtQuick
import QtQuick.Controls

ComboBox {
    id: control

    signal valueChanged

    property string cfg_key
    property var cfg_defaultValue

    textRole: "text"
    valueRole: "value"

    Component.onCompleted: {
        if (cfg_key) {
            var value = Plasmoid.configuration[cfg_key]
            if (value === undefined) {
                value = cfg_defaultValue
            }
            for (var i = 0; i < model.length; i++) {
                if (model[i].value === value) {
                    currentIndex = i
                    break
                }
            }
        }
    }
}
