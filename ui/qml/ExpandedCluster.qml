import QtQuick
import QtQuick.Controls

Rectangle {
    id: clusterOverlay
    anchors.fill: parent
    color: "#07080B"
    opacity: 0.0
    visible: opacity > 0.0

    signal closeRequested()

    function openPanel() {
        clusterOverlay.opacity = 1.0
    }

    function closePanel() {
        clusterOverlay.opacity = 0.0
    }

    Behavior on opacity {
        NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 24
        width: 80
        height: 30
        radius: 5
        color: closeMouse.pressed ? "#282F3D" : "#131720"
        border.color: "#2A3142"

        Text {
            anchors.centerIn: parent
            text: "CLOSE X"
            color: "#D8C7B0"
            font.pixelSize: 10
            font.bold: true
        }

        MouseArea {
            id: closeMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: clusterOverlay.closeRequested()
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 32
        width: parent.width * 0.8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "PERFORMANCE TELEMETRY"
            color: "#D8C7B0"
            font.pixelSize: 18
            font.letterSpacing: 4
            font.bold: true
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 64

            Column {
                spacing: 8
                Text { text: "0 - 60 KM/H"; color: "#6A7282"; font.pixelSize: 12; font.letterSpacing: 2; anchors.horizontalCenter: parent.horizontalCenter }
                Text {
                    text: telemetryCore.split_0_60 > 0.0 ? telemetryCore.split_0_60.toFixed(2) + " s" : "--"
                    color: "#E2D9C8"
                    font.pixelSize: 36
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                spacing: 8
                Text { text: "0 - 100 KM/H"; color: "#6A7282"; font.pixelSize: 12; font.letterSpacing: 2; anchors.horizontalCenter: parent.horizontalCenter }
                Text {
                    text: telemetryCore.final_0_100 > 0.0 ? telemetryCore.final_0_100.toFixed(2) + " s" : "--"
                    color: "#C5A880"
                    font.pixelSize: 36
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                spacing: 8
                Text { text: "BEST RECORD"; color: "#6A7282"; font.pixelSize: 12; font.letterSpacing: 2; anchors.horizontalCenter: parent.horizontalCenter }
                Text {
                    text: telemetryCore.best_0_100 > 0.0 ? telemetryCore.best_0_100.toFixed(2) + " s" : "--"
                    color: "#3B82F6"
                    font.pixelSize: 36
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Rectangle {
                width: 140
                height: 38
                radius: 6
                color: armMouse.pressed ? "#243328" : "#132318"
                border.color: "#22C55E"

                Text {
                    anchors.centerIn: parent
                    text: "ARM DRAG TIMER"
                    color: "#22C55E"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    id: armMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: telemetryCore.arm_timer()
                }
            }

            Rectangle {
                width: 140
                height: 38
                radius: 6
                color: resetMouse.pressed ? "#331818" : "#221010"
                border.color: "#EF4444"

                Text {
                    anchors.centerIn: parent
                    text: "RESET TIMER"
                    color: "#EF4444"
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    id: resetMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: telemetryCore.reset_timer()
                }
            }
        }
    }
}
