import QtQuick
import QtMultimedia

Item {
    id: statusRoot
    anchors.fill: parent

    property int activeBgIndex: 1
    property string activeMode: "TPMS"
    property bool rightSideActive: false

    MediaPlayer {
        id: bgPlayer
        source: "qrc:/assets/backgrounds/live_bg_" + statusRoot.activeBgIndex + ".mp4"
        audioOutput: null
        loops: MediaPlayer.Infinite
        Component.onCompleted: bgPlayer.play()
    }

    VideoOutput {
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#F0030508" }
            GradientStop { position: 0.45; color: "#C006090E" }
            GradientStop { position: 1.0; color: "#F8010204" }
        }
    }

    Item {
        id: stage
        width: parent.width * 0.62
        height: parent.height
        anchors.left: parent.left

        Rectangle {
            id: platformRing
            width: parent.width * 0.88
            height: 64
            radius: width / 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 75
            color: "transparent"
            border.color: "#00F0FF"
            border.width: 2
            opacity: 0.28
        }

        Image {
            id: vehicleRender
            anchors.centerIn: stage
            anchors.verticalCenterOffset: -25
            width: parent.width * 0.84
            fillMode: Image.PreserveAspectFit
            source: {
                if (statusRoot.activeMode === "WEIGHT") {
                    return "qrc:/assets/vehicles/car_upside.png"
                }
                if (statusRoot.activeMode === "DIAGNOSTICS") {
                    return "qrc:/assets/vehicles/car_side.png"
                }
                return statusRoot.rightSideActive ? "qrc:/assets/vehicles/car_right.png" : "qrc:/assets/vehicles/car_left.png"
            }

            Behavior on opacity {
                NumberAnimation { duration: 180 }
            }
        }

        Item {
            id: tpmsLayer
            anchors.fill: vehicleRender
            visible: statusRoot.activeMode === "TPMS"

            Rectangle {
                x: statusRoot.rightSideActive ? parent.width * 0.74 : parent.width * 0.12
                y: parent.height * 0.60
                width: 114
                height: 46
                color: "#B004070D"
                border.color: "#00F0FF"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    Text {
                        text: statusRoot.rightSideActive ? "FRONT RIGHT" : "FRONT LEFT"
                        color: "#5C6E82"
                        font.pixelSize: 8
                        font.bold: true
                    }
                    Text {
                        text: "2.40 BAR"
                        color: "#00F0FF"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }
            }

            Rectangle {
                x: statusRoot.rightSideActive ? parent.width * 0.12 : parent.width * 0.74
                y: parent.height * 0.60
                width: 114
                height: 46
                color: "#B004070D"
                border.color: "#00F0FF"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    Text {
                        text: statusRoot.rightSideActive ? "REAR RIGHT" : "REAR LEFT"
                        color: "#5C6E82"
                        font.pixelSize: 8
                        font.bold: true
                    }
                    Text {
                        text: "2.35 BAR"
                        color: "#00F0FF"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }
            }
        }

        Item {
            id: weightLayer
            anchors.fill: vehicleRender
            visible: statusRoot.activeMode === "WEIGHT"

            Rectangle {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 30
                width: 150
                height: 52
                color: "#B00E0803"
                border.color: "#FF9500"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    Text {
                        text: "TRUNK LOAD STATUS"
                        color: "#8E6948"
                        font.pixelSize: 8
                        font.bold: true
                    }
                    Text {
                        text: "340 KG / 506 L"
                        color: "#FF9500"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }
            }
        }
    }

    Column {
        width: 310
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Rectangle {
            width: parent.width
            height: 68
            color: statusRoot.activeMode === "TPMS" ? "#2400F0FF" : "#8005080E"
            border.color: statusRoot.activeMode === "TPMS" ? "#00F0FF" : "#1A2536"
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onClicked: statusRoot.activeMode = "TPMS"
            }

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 2
                Text {
                    text: "TIRE MONITORING"
                    color: "#FFFFFF"
                    font.bold: true
                    font.pixelSize: 12
                }
                Text {
                    text: "LIVE TELEMETRY ACTIVE"
                    color: "#00F0FF"
                    font.pixelSize: 9
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 38
            visible: statusRoot.activeMode === "TPMS"
            color: "#8005080E"
            border.color: "#2C3E55"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: statusRoot.rightSideActive ? "AXIS VIEW: RIGHT" : "AXIS VIEW: LEFT"
                color: "#00F0FF"
                font.pixelSize: 10
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: statusRoot.rightSideActive = !statusRoot.rightSideActive
            }
        }

        Rectangle {
            width: parent.width
            height: 68
            color: statusRoot.activeMode === "WEIGHT" ? "#24FF9500" : "#8005080E"
            border.color: statusRoot.activeMode === "WEIGHT" ? "#FF9500" : "#1A2536"
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onClicked: statusRoot.activeMode = "WEIGHT"
            }

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 2
                Text {
                    text: "LOAD & TRUNK AXLE"
                    color: "#FFFFFF"
                    font.bold: true
                    font.pixelSize: 12
                }
                Text {
                    text: "DISTRIBUTION 54% R / 46% F"
                    color: "#FF9500"
                    font.pixelSize: 9
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 68
            color: statusRoot.activeMode === "DIAGNOSTICS" ? "#24FF003C" : "#8005080E"
            border.color: statusRoot.activeMode === "DIAGNOSTICS" ? "#FF003C" : "#1A2536"
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onClicked: statusRoot.activeMode = "DIAGNOSTICS"
            }

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 2
                Text {
                    text: "VEHICLE DIAGNOSTICS"
                    color: "#FFFFFF"
                    font.bold: true
                    font.pixelSize: 12
                }
                Text {
                    text: "WIREFRAME TELEMETRY LINKED"
                    color: "#FF003C"
                    font.pixelSize: 9
                }
            }
        }

        Row {
            width: parent.width
            spacing: 8

            Rectangle {
                width: (parent.width - 8) / 2
                height: 34
                color: "#8005080E"
                border.color: "#1A2536"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "PREV BG"
                    color: "#8CA0B8"
                    font.pixelSize: 9
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (statusRoot.activeBgIndex > 1) {
                            statusRoot.activeBgIndex--
                        } else {
                            statusRoot.activeBgIndex = 8
                        }
                    }
                }
            }

            Rectangle {
                width: (parent.width - 8) / 2
                height: 34
                color: "#8005080E"
                border.color: "#1A2536"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "NEXT BG"
                    color: "#8CA0B8"
                    font.pixelSize: 9
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (statusRoot.activeBgIndex < 8) {
                            statusRoot.activeBgIndex++
                        } else {
                            statusRoot.activeBgIndex = 1
                        }
                    }
                }
            }
        }
    }
}