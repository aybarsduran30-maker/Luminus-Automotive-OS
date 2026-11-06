import QtQuick
import QtQuick.Window
import QtMultimedia

Window {
    id: appWindow
    width: 1024
    height: 600
    minimumWidth: 920
    minimumHeight: 540
    visible: true
    visibility: Window.Windowed
    title: "Luminus OS | C-Elysée"
    color: "#101214"

    property int activeTab: 0
    property int themeColorIndex: 0
    property bool languageEnglish: false
    property var themeColors: ["#C79A63", "#A7B4A8", "#B95150", "#D7D5CB"]
    readonly property color currentAccent: themeColors[themeColorIndex]

    property real kerbWeight: 1090.0
    property real currentGrossWeight: 1170.0

    property bool tripActive: false
    property real liveTripDist: 0.0
    property real liveTripFuel: 0.0
    property var savedTripLogs: []

    property string statusMode: "TPMS"
    property date currentDateTime: new Date()
    property bool splashFinished: false
    property bool sweepCompleted: false

    property real displaySpeed: 0.0
    property real displayRpm: 0.0

    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Up) {
                vehicleSim.throttleActive = true
                event.accepted = true
            } else if (event.key === Qt.Key_Down) {
                vehicleSim.brakeActive = true
                event.accepted = true
            }
        }

        Keys.onReleased: function(event) {
            if (event.key === Qt.Key_Up) {
                vehicleSim.throttleActive = false
                event.accepted = true
            } else if (event.key === Qt.Key_Down) {
                vehicleSim.brakeActive = false
                event.accepted = true
            }
        }
    }

    Timer {
        interval: 100
        running: tripActive && (vehicleSim.speed > 0.5)
        repeat: true
        onTriggered: {
            var stepDist = (vehicleSim.speed * (0.1 / 3600.0))
            liveTripDist += stepDist
            liveTripFuel += (stepDist * 0.065)
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#171A1C" }
            GradientStop { position: 0.55; color: "#101214" }
            GradientStop { position: 1.0; color: "#0B0D0F" }
        }
        z: -1
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: currentDateTime = new Date()
    }

    SequentialAnimation {
        id: gaugeSweepAnimation
        running: false

        ParallelAnimation {
            NumberAnimation { target: appWindow; property: "displaySpeed"; from: 0; to: 220; duration: 800; easing.type: Easing.OutQuart }
            NumberAnimation { target: appWindow; property: "displayRpm"; from: 0; to: 7000; duration: 800; easing.type: Easing.OutQuart }
        }
        ParallelAnimation {
            NumberAnimation { target: appWindow; property: "displaySpeed"; to: 0; duration: 600; easing.type: Easing.InOutCubic }
            NumberAnimation { target: appWindow; property: "displayRpm"; to: 850; duration: 600; easing.type: Easing.InOutCubic }
        }
        ScriptAction { script: sweepCompleted = true }
    }

    Binding {
        target: appWindow
        property: "displaySpeed"
        value: vehicleSim.speed
        when: sweepCompleted
    }

    Binding {
        target: appWindow
        property: "displayRpm"
        value: vehicleSim.rpm
        when: sweepCompleted
    }

    Item {
        id: cockpitRoot
        anchors.fill: parent
        opacity: splashFinished ? 1.0 : 0.0
        visible: opacity > 0.0
        Behavior on opacity { NumberAnimation { duration: 500 } }

        Item {
            id: topHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 58
            z: 30

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: currentAccent
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: {
                        switch(activeTab) {
                            case 0: return languageEnglish ? "HOME" : "ANA SAYFA"
                            case 1: return languageEnglish ? "VEHICLE" : "ARAÇ"
                            case 2: return languageEnglish ? "DRIVING" : "SÜRÜŞ"
                            case 3: return languageEnglish ? "MEDIA" : "MEDYA"
                            case 4: return languageEnglish ? "TRIP" : "YOLCULUK"
                            case 5: return languageEnglish ? "SETTINGS" : "AYARLAR"
                            default: return "LUMINUS OS"
                        }
                    }
                    color: "#FFFFFF"
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 1.4
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 24
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle { width: 7; height: 7; radius: 4; color: vehicleSim.hardwareConnected ? "#A7B4A8" : "#C79A63"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: vehicleSim.hardwareConnected ? (languageEnglish ? "OBD CONNECTED" : "OBD BAĞLI") : (languageEnglish ? "DEMO DATA" : "DEMO VERİ"); color: "#AEB3AF"; font.pixelSize: 9; font.bold: true; font.letterSpacing: 0.6 }
                Rectangle { width: 1; height: 14; color: "#343A3B"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: Qt.formatDate(currentDateTime, "dd.MM.yyyy"); color: "#858B89"; font.pixelSize: 10; font.bold: true }
                Text { text: Qt.formatTime(currentDateTime, "hh:mm"); color: currentAccent; font.pixelSize: 12; font.bold: true; font.family: "Consolas" }
            }
        }


        CockpitPages {
            id: redesignedPages
            anchors.top: topHeader.bottom
            anchors.bottom: dsNavRack.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 18
            z: 2
            activeTab: appWindow.activeTab
            themeColorIndex: appWindow.themeColorIndex
            english: appWindow.languageEnglish
            themeColors: appWindow.themeColors
            accent: appWindow.currentAccent
            speed: vehicleSim.speed
            rpm: vehicleSim.rpm
            coolant: vehicleSim.coolantTemp
            voltage: vehicleSim.batteryVoltage
            throttle: vehicleSim.throttlePos
            tireFL: vehicleSim.tireFL
            tireFR: vehicleSim.tireFR
            tireRL: vehicleSim.tireRL
            tireRR: vehicleSim.tireRR
            kerbWeight: appWindow.kerbWeight
            grossWeight: appWindow.currentGrossWeight
            dragTime: vehicleSim.dragTime
            bestDragTime: vehicleSim.bestDragTime
            dragArmed: vehicleSim.dragArmed
            hardwareConnected: vehicleSim.hardwareConnected
            rawPacket: vehicleSim.lastRawPacket
            vehicleSim: vehicleSim
            appWindow: appWindow
        }

        Item {
            id: dsNavRack
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 58
            z: 30

            Row {
                anchors.centerIn: parent
                spacing: 7

                component BottomTabBtn : Rectangle {
                    property string bTitle: ""
                    property int bTarget: 0

                    width: 128
                    height: 40
                    radius: 12
                    color: activeTab === bTarget
                           ? Qt.rgba(currentAccent.r, currentAccent.g, currentAccent.b, 0.16)
                           : Qt.rgba(1, 1, 1, 0.045)
                    border.color: activeTab === bTarget
                                  ? Qt.rgba(currentAccent.r, currentAccent.g, currentAccent.b, 0.62)
                                  : Qt.rgba(1, 1, 1, 0.12)
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: bTitle
                        color: activeTab === bTarget ? currentAccent : "#929795"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: activeTab = bTarget
                    }
                }

                BottomTabBtn { bTitle: languageEnglish ? "HOME" : "ANA SAYFA"; bTarget: 0 }
                BottomTabBtn { bTitle: languageEnglish ? "VEHICLE" : "ARAÇ"; bTarget: 1 }
                BottomTabBtn { bTitle: languageEnglish ? "DRIVING" : "SÜRÜŞ"; bTarget: 2 }
                BottomTabBtn { bTitle: languageEnglish ? "MEDIA" : "MEDYA"; bTarget: 3 }
                BottomTabBtn { bTitle: languageEnglish ? "TRIP" : "YOLCULUK"; bTarget: 4 }
                BottomTabBtn { bTitle: languageEnglish ? "SETTINGS" : "AYARLAR"; bTarget: 5 }
            }
        }
    }

    Item {
        id: splashOverlay
        anchors.fill: parent
        visible: !splashFinished
        z: 100

        SoundEffect {
            id: whooshAudio
            source: "qrc:/startup_whoosh.wav"
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
        }

        Image {
            id: brandSplashLogo
            anchors.centerIn: parent
            width: 260
            fillMode: Image.PreserveAspectFit
            source: "qrc:/citroen_logo.png"
            opacity: 0.0
            scale: 0.85
        }

        SequentialAnimation {
            id: splashSequence
            running: true

            ScriptAction { script: whooshAudio.play() }

            ParallelAnimation {
                NumberAnimation { target: brandSplashLogo; property: "opacity"; from: 0.0; to: 1.0; duration: 900; easing.type: Easing.OutCubic }
                NumberAnimation { target: brandSplashLogo; property: "scale"; from: 0.85; to: 1.0; duration: 1100; easing.type: Easing.OutCubic }
            }

            PauseAnimation { duration: 500 }

            ParallelAnimation {
                NumberAnimation { target: brandSplashLogo; property: "opacity"; to: 0.0; duration: 500; easing.type: Easing.InQuad }
                NumberAnimation { target: splashOverlay; property: "opacity"; to: 0.0; duration: 600 }
            }

            ScriptAction {
                script: {
                    splashFinished = true
                    splashOverlay.visible = false
                    gaugeSweepAnimation.start()
                }
            }
        }
    }
}
