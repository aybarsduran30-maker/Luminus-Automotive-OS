import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia

Window {
    id: appWindow
    width: 1024
    height: 600
    minimumWidth: 920
    minimumHeight: 540
    visible: true
    visibility: Window.Windowed
    title: "Luminus OS // Hyper-Cockpit"
    color: "#000000"

    property int activeTab: 1
    property int themeColorIndex: 0
    property var themeColors: ["#E5A93C", "#00F0FF", "#E63946", "#F1FAEE"]
    readonly property color currentAccent: themeColors[themeColorIndex]

    property int currentWallpaperIndex: 1
    property real bgDimOpacity: 0.40
    property int clusterLayoutMode: 0 // 0: QUL Dual Ring, 1: Minimal HUD, 2: Performance 3D

    property real kerbWeight: 1090.0
    property real currentGrossWeight: 1170.0
    property real tireFL: 2.3
    property real tireFR: 2.3
    property real tireRL: 2.1
    property real tireRR: 1.8

    property bool tripActive: false
    property real liveTripDist: 0.0
    property real liveTripFuel: 0.0
    property var savedTripLogs: []

    property string statusMode: "DIAGNOSTICS"
    property bool statusRightSide: false
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

    MediaPlayer {
        id: bgVideoPlayer
        source: Qt.resolvedUrl("../../assets/backgrounds/live_bg_" + currentWallpaperIndex + ".mp4")
        loops: MediaPlayer.Infinite
        videoOutput: videoRenderer
        audioOutput: null
        Component.onCompleted: play()
    }

    VideoOutput {
        id: videoRenderer
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: bgDimOpacity
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
            height: 48
            z: 30

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 30
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle {
                    width: 10
                    height: 10
                    rotation: 45
                    color: currentAccent
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: {
                        switch(activeTab) {
                            case 0: return "LUMINUS // CLUSTER LAYOUT"
                            case 1: return "LUMINUS // DIGITAL TWIN ADAS"
                            case 2: return "LUMINUS // POWERTRAIN TELEMETRY"
                            case 3: return "LUMINUS // MEDIA SESSION"
                            case 4: return "LUMINUS // TRIP COMPUTER"
                            case 5: return "LUMINUS // SYSTEM PREFERENCES"
                            default: return "LUMINUS OS"
                        }
                    }
                    color: "#FFFFFF"
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 2
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 30
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                Text { text: "15/09/2026"; color: "#64748B"; font.pixelSize: 10; font.bold: true }
                Rectangle { width: 1; height: 12; color: "#334155"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "08:20"; color: currentAccent; font.pixelSize: 13; font.bold: true; font.family: "Consolas" }
            }
        }

        Item {
            id: mainView
            anchors.top: topHeader.bottom
            anchors.bottom: dsNavRack.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10

            Item {
                visible: activeTab === 0
                anchors.fill: parent

                Item {
                    visible: clusterLayoutMode === 0
                    anchors.fill: parent

                    Canvas {
                        id: qulDualRingCanvas
                        anchors.fill: parent
                        property real sVal: appWindow.displaySpeed
                        property real rVal: appWindow.displayRpm
                        onSValChanged: requestPaint()
                        onRValChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)

                            var cy = height * 0.52
                            var r = height * 0.38

                            var lx = width * 0.25
                            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.08)
                            ctx.lineWidth = 4
                            ctx.beginPath()
                            ctx.arc(lx, cy, r, Math.PI * 0.75, Math.PI * 1.85, false)
                            ctx.stroke()

                            var spdEnd = Math.PI * 0.75 + (Math.PI * 1.1 * Math.min(1.0, sVal / 220.0))
                            ctx.strokeStyle = currentAccent
                            ctx.lineWidth = 7
                            ctx.beginPath()
                            ctx.arc(lx, cy, r, Math.PI * 0.75, spdEnd, false)
                            ctx.stroke()

                            var rx = width * 0.75
                            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.08)
                            ctx.lineWidth = 4
                            ctx.beginPath()
                            ctx.arc(rx, cy, r, Math.PI * 1.15, Math.PI * 2.25, false)
                            ctx.stroke()

                            var rpmEnd = Math.PI * 1.15 + (Math.PI * 1.1 * Math.min(1.0, rVal / 7000.0))
                            ctx.strokeStyle = rVal > 5500 ? "#E63946" : currentAccent
                            ctx.lineWidth = 7
                            ctx.beginPath()
                            ctx.arc(rx, cy, r, Math.PI * 1.15, rpmEnd, false)
                            ctx.stroke()
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -parent.width * 0.25
                        anchors.verticalCenterOffset: 10
                        spacing: 2
                        Text { text: "SPEED"; color: "#64748B"; font.pixelSize: 10; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: appWindow.displaySpeed.toFixed(0); color: "#FFFFFF"; font.pixelSize: 84; font.bold: true; font.family: "Consolas"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "KM/H"; color: currentAccent; font.pixelSize: 12; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    }

                    Column {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 10
                        spacing: 6
                        Text { text: "GEAR"; color: currentAccent; font.pixelSize: 11; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "D" + Math.min(5, Math.max(1, Math.floor(vehicleSim.speed / 25) + 1)); color: "#FFFFFF"; font.pixelSize: 48; font.bold: true; font.family: "Consolas"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: vehicleSim.coolantTemp.toFixed(0) + " C"; color: "#94A3B8"; font.pixelSize: 11; font.bold: true; font.family: "Consolas"; anchors.horizontalCenter: parent.horizontalCenter }
                    }

                    Column {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: parent.width * 0.25
                        anchors.verticalCenterOffset: 10
                        spacing: 2
                        Text { text: "TACHOMETER"; color: "#64748B"; font.pixelSize: 10; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: appWindow.displayRpm.toFixed(0); color: appWindow.displayRpm > 5500 ? "#E63946" : currentAccent; font.pixelSize: 84; font.bold: true; font.family: "Consolas"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "RPM"; color: "#64748B"; font.pixelSize: 12; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }

                Item {
                    visible: clusterLayoutMode === 1
                    anchors.fill: parent

                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        Text { text: "VELOCITY HUD"; color: currentAccent; font.pixelSize: 12; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: appWindow.displaySpeed.toFixed(0); color: "#FFFFFF"; font.pixelSize: 130; font.bold: true; font.family: "Consolas"; anchors.horizontalCenter: parent.horizontalCenter }
                        Row {
                            spacing: 24
                            anchors.horizontalCenter: parent.horizontalCenter
                            Text { text: "GEAR: D" + Math.min(5, Math.max(1, Math.floor(vehicleSim.speed / 25) + 1)); color: "#FFFFFF"; font.pixelSize: 18; font.bold: true; font.family: "Consolas" }
                            Text { text: appWindow.displayRpm.toFixed(0) + " RPM"; color: currentAccent; font.pixelSize: 18; font.bold: true; font.family: "Consolas" }
                        }
                    }
                }

                Item {
                    visible: clusterLayoutMode === 2
                    anchors.fill: parent

                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        Text { text: "RACE TELEMETRY"; color: "#E63946"; font.pixelSize: 12; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: appWindow.displayRpm.toFixed(0); color: appWindow.displayRpm > 5500 ? "#E63946" : currentAccent; font.pixelSize: 100; font.bold: true; font.family: "Consolas"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "S" + Math.min(5, Math.max(1, Math.floor(vehicleSim.speed / 25) + 1)); color: "#FFFFFF"; font.pixelSize: 44; font.bold: true; font.family: "Consolas"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: appWindow.displaySpeed.toFixed(0) + " KM/H"; color: "#94A3B8"; font.pixelSize: 24; font.bold: true; font.family: "Consolas"; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }
            }

            Item {
                visible: activeTab === 1
                anchors.fill: parent

                Canvas {
                    id: mbuxAdasRoadCanvas
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    width: parent.width * 0.72
                    height: 250
                    property real progressTicker: 0.0

                    Timer {
                        interval: 16
                        running: vehicleSim.speed > 0
                        repeat: true
                        onTriggered: {
                            var delta = (vehicleSim.speed / 1200.0)
                            mbuxAdasRoadCanvas.progressTicker = (mbuxAdasRoadCanvas.progressTicker + delta) % 1.0
                            mbuxAdasRoadCanvas.requestPaint()
                        }
                    }

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)

                        var vpX = width * 0.48
                        var vpY = 15

                        for (var i = 0; i < 8; ++i) {
                            var t = (progressTicker + (i / 8.0)) % 1.0
                            var scaleFactor = 0.08 + (t * t * 1.95)
                            var yPos = vpY + (height - vpY) * scaleFactor

                            ctx.strokeStyle = Qt.rgba(currentAccent.r, currentAccent.g, currentAccent.b, scaleFactor * 0.45)
                            ctx.lineWidth = 1 + scaleFactor * 2.5

                            var span = width * 0.48 * scaleFactor
                            ctx.beginPath()
                            ctx.moveTo(vpX - span, yPos)
                            ctx.lineTo(vpX + span, yPos)
                            ctx.stroke()
                        }

                        ctx.strokeStyle = "#00F0FF"
                        ctx.lineWidth = 3
                        ctx.beginPath()
                        ctx.moveTo(vpX - (width * 0.48), height)
                        ctx.lineTo(vpX - (width * 0.05), vpY)
                        ctx.stroke()

                        ctx.beginPath()
                        ctx.moveTo(vpX + (width * 0.48), height)
                        ctx.lineTo(vpX + (width * 0.05), vpY)
                        ctx.stroke()
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 30
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.06
                    width: parent.width * 0.58
                    height: 36
                    radius: 18
                    color: "#000000"
                    opacity: 0.85
                }

                Item {
                    id: carBox
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width * 0.05
                    width: parent.width * 0.60
                    height: parent.height * 0.80

                    Image {
                        id: mainCarImage
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        source: {
                            if (appWindow.statusMode === "WEIGHT") return "qrc:/assets/vehicles/car_upside.png"
                            if (appWindow.statusMode === "DIAGNOSTICS") return "qrc:/assets/vehicles/car_side.png"
                            return appWindow.statusRightSide ? "qrc:/assets/vehicles/car_right.png" : "qrc:/assets/vehicles/car_left.png"
                        }
                        opacity: 1.0
                        scale: 1.0
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    }
                }

                Item {
                    anchors.fill: carBox
                    visible: appWindow.statusMode === "TPMS"

                    Rectangle {
                        x: appWindow.statusRightSide ? parent.width * 0.72 : parent.width * 0.14
                        y: parent.height * 0.56
                        width: 116
                        height: 36
                        radius: 18
                        color: Qt.rgba(8/255, 16/255, 28/255, 0.75)
                        border.color: (appWindow.statusRightSide ? tireFR : tireFL) < 2.0 ? "#E63946" : currentAccent
                        border.width: 1.5

                        Column {
                            anchors.centerIn: parent
                            Text { text: appWindow.statusRightSide ? "FRONT RIGHT" : "FRONT LEFT"; color: "#94A3B8"; font.pixelSize: 7; font.bold: true }
                            Text { text: (appWindow.statusRightSide ? tireFR.toFixed(1) : tireFL.toFixed(1)) + " BAR"; color: "#FFFFFF"; font.pixelSize: 10; font.bold: true; font.family: "Consolas" }
                        }
                    }

                    Rectangle {
                        x: appWindow.statusRightSide ? parent.width * 0.14 : parent.width * 0.72
                        y: parent.height * 0.56
                        width: 116
                        height: 36
                        radius: 18
                        color: Qt.rgba(8/255, 16/255, 28/255, 0.75)
                        border.color: (appWindow.statusRightSide ? tireRR : tireRL) < 2.0 ? "#E63946" : currentAccent
                        border.width: 1.5

                        Column {
                            anchors.centerIn: parent
                            Text { text: appWindow.statusRightSide ? "REAR RIGHT" : "REAR LEFT"; color: "#94A3B8"; font.pixelSize: 7; font.bold: true }
                            Text { text: (appWindow.statusRightSide ? tireRR.toFixed(1) : tireRL.toFixed(1)) + " BAR"; color: "#FFFFFF"; font.pixelSize: 10; font.bold: true; font.family: "Consolas" }
                        }
                    }
                }

                Column {
                    width: 250
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    component NeonPillBtn : Item {
                        id: pillItem
                        property string btnText: ""
                        property bool isActive: false
                        property color glowColor: currentAccent
                        signal clicked()

                        width: parent.width
                        height: 46

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: pillItem.isActive ? Qt.rgba(glowColor.r, glowColor.g, glowColor.b, 0.25) : Qt.rgba(4/255, 8/255, 15/255, 0.6)
                            border.color: pillItem.isActive ? glowColor : Qt.rgba(1, 1, 1, 0.12)
                            border.width: 1.5

                            Rectangle {
                                width: 22
                                height: 22
                                radius: 11
                                anchors.verticalCenter: parent.verticalCenter
                                x: pillItem.isActive ? (parent.width - width - 12) : 12
                                color: glowColor
                                opacity: pillItem.isActive ? 1.0 : 0.25
                                Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: pillItem.btnText
                                color: "#FFFFFF"
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: pillItem.clicked()
                        }
                    }

                    Timer {
                        id: carTransTimer
                        interval: 100
                        onTriggered: {
                            mainCarImage.opacity = 1.0
                            mainCarImage.scale = 1.0
                        }
                    }

                    NeonPillBtn {
                        btnText: "TIRE TELEMETRY (TPMS)"
                        isActive: appWindow.statusMode === "TPMS"
                        glowColor: tireRR < 2.0 ? "#E63946" : currentAccent
                        onClicked: {
                            mainCarImage.opacity = 0.0
                            mainCarImage.scale = 0.94
                            appWindow.statusMode = "TPMS"
                            carTransTimer.restart()
                        }
                    }

                    NeonPillBtn {
                        visible: appWindow.statusMode === "TPMS"
                        btnText: appWindow.statusRightSide ? "PROFILE: RIGHT" : "PROFILE: LEFT"
                        isActive: true
                        glowColor: currentAccent
                        onClicked: {
                            mainCarImage.opacity = 0.0
                            appWindow.statusRightSide = !appWindow.statusRightSide
                            carTransTimer.restart()
                        }
                    }

                    NeonPillBtn {
                        btnText: "CHASSIS MASS & LOAD"
                        isActive: appWindow.statusMode === "WEIGHT"
                        glowColor: currentAccent
                        onClicked: {
                            mainCarImage.opacity = 0.0
                            mainCarImage.scale = 0.94
                            appWindow.statusMode = "WEIGHT"
                            carTransTimer.restart()
                        }
                    }

                    NeonPillBtn {
                        btnText: "ECU WIREFRAME DIAGNOSTICS"
                        isActive: appWindow.statusMode === "DIAGNOSTICS"
                        glowColor: "#E63946"
                        onClicked: {
                            mainCarImage.opacity = 0.0
                            mainCarImage.scale = 0.94
                            appWindow.statusMode = "DIAGNOSTICS"
                            carTransTimer.restart()
                        }
                    }
                }
            }

            Item {
                visible: activeTab === 2
                anchors.fill: parent

                Row {
                    anchors.centerIn: parent
                    spacing: 40

                    Column {
                        spacing: 12
                        anchors.verticalCenter: parent.verticalCenter
                        Text { text: "0-100 KM/H ACCELERATION"; color: currentAccent; font.pixelSize: 11; font.bold: true }
                        Text { text: vehicleSim.dragTime.toFixed(2) + " s"; color: "#FFFFFF"; font.pixelSize: 76; font.bold: true; font.family: "Consolas" }
                        Text { text: "SESSION BEST: " + (vehicleSim.bestDragTime > 0 ? vehicleSim.bestDragTime.toFixed(2) + " s" : "--.-- s"); color: "#00E676"; font.pixelSize: 13; font.bold: true }

                        Rectangle {
                            width: 140
                            height: 38
                            radius: 19
                            color: Qt.rgba(0, 0, 0, 0.6)
                            border.color: currentAccent
                            border.width: 1.5
                            Text { anchors.centerIn: parent; text: "RESET TIMER"; color: "#FFFFFF"; font.pixelSize: 9; font.bold: true }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: vehicleSim.resetDragTimer() }
                        }
                    }

                    Rectangle { width: 1; height: 180; color: Qt.rgba(1, 1, 1, 0.12); anchors.verticalCenter: parent.verticalCenter }

                    Column {
                        spacing: 24
                        anchors.verticalCenter: parent.verticalCenter
                        Column {
                            Text { text: "INSTANT TORQUE"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                            Text { text: vehicleSim.speed.toFixed(0) + " KM/H"; color: "#FFFFFF"; font.pixelSize: 36; font.bold: true; font.family: "Consolas" }
                        }
                        Column {
                            Text { text: "DRIVETRAIN RPM"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                            Text { text: vehicleSim.rpm.toFixed(0) + " RPM"; color: currentAccent; font.pixelSize: 36; font.bold: true; font.family: "Consolas" }
                        }
                    }
                }
            }

            Item {
                visible: activeTab === 3
                anchors.fill: parent

                Item {
                    anchors.centerIn: parent
                    width: 480
                    height: 220

                    Rectangle {
                        anchors.fill: parent
                        radius: 20
                        color: Qt.rgba(8/255, 14/255, 26/255, 0.65)
                        border.color: currentAccent
                        border.width: 1.5
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        Text { text: "BLUETOOTH AUDIO SINK"; color: currentAccent; font.pixelSize: 11; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Thomas Lammer - Setsuna"; color: "#FFFFFF"; font.pixelSize: 22; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }

                        Row {
                            spacing: 16
                            anchors.horizontalCenter: parent.horizontalCenter
                            Rectangle { width: 42; height: 42; radius: 21; color: Qt.rgba(1,1,1,0.1); Text { anchors.centerIn: parent; text: "|<"; color: "#FFF"; font.bold: true } }
                            Rectangle { width: 48; height: 48; radius: 24; color: currentAccent; Text { anchors.centerIn: parent; text: "||"; color: "#000"; font.bold: true } }
                            Rectangle { width: 42; height: 42; radius: 21; color: Qt.rgba(1,1,1,0.1); Text { anchors.centerIn: parent; text: ">|"; color: "#FFF"; font.bold: true } }
                        }
                    }
                }
            }

            Item {
                visible: activeTab === 4
                anchors.fill: parent

                Row {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 30

                    Column {
                        width: parent.width * 0.45
                        spacing: 18

                        Text { text: "TELEMETRY ENGINE"; color: currentAccent; font.pixelSize: 11; font.bold: true }

                        Row {
                            spacing: 16
                            Column {
                                Text { text: "DISTANCE"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                                Text { text: liveTripDist.toFixed(2) + " KM"; color: "#FFFFFF"; font.pixelSize: 26; font.bold: true; font.family: "Consolas" }
                            }
                            Column {
                                Text { text: "EST. FUEL RATE"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                                Text { text: liveTripDist > 0.05 ? ((liveTripFuel / liveTripDist) * 100).toFixed(1) + " L/100KM" : "--.- L/100KM"; color: "#00E676"; font.pixelSize: 26; font.bold: true; font.family: "Consolas" }
                            }
                        }

                        Row {
                            spacing: 12
                            Rectangle {
                                width: 110
                                height: 38
                                radius: 19
                                color: tripActive ? Qt.rgba(230/255, 57/255, 70/255, 0.4) : Qt.rgba(0, 230/255, 118/255, 0.4)
                                border.color: tripActive ? "#E63946" : "#00E676"
                                border.width: 1.5
                                Text { anchors.centerIn: parent; text: tripActive ? "STOP TRIP" : "START TRIP"; color: "#FFFFFF"; font.pixelSize: 9; font.bold: true }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: tripActive = !tripActive
                                }
                            }

                            Rectangle {
                                width: 110
                                height: 38
                                radius: 19
                                color: Qt.rgba(currentAccent.r, currentAccent.g, currentAccent.b, 0.3)
                                border.color: currentAccent
                                border.width: 1.5

                                Text { anchors.centerIn: parent; text: "LOG TRIP"; color: "#FFFFFF"; font.pixelSize: 9; font.bold: true }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var copy = savedTripLogs.slice()
                                        var avgCons = liveTripDist > 0.05 ? ((liveTripFuel / liveTripDist) * 100).toFixed(1) : "0.0"
                                        copy.push(liveTripDist.toFixed(2) + " KM @ " + avgCons + " L/100KM")
                                        savedTripLogs = copy
                                    }
                                }
                            }

                            Rectangle {
                                width: 80
                                height: 38
                                radius: 19
                                color: Qt.rgba(0, 0, 0, 0.5)
                                border.color: "#475569"
                                border.width: 1.5
                                Text { anchors.centerIn: parent; text: "RESET"; color: "#94A3B8"; font.pixelSize: 9; font.bold: true }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        tripActive = false
                                        liveTripDist = 0.0
                                        liveTripFuel = 0.0
                                    }
                                }
                            }
                        }
                    }

                    Rectangle { width: 1; height: parent.height; color: Qt.rgba(1, 1, 1, 0.1) }

                    ListView {
                        width: parent.width * 0.48
                        height: parent.height
                        clip: true
                        model: savedTripLogs
                        spacing: 8
                        delegate: Rectangle {
                            width: parent.width
                            height: 34
                            radius: 17
                            color: Qt.rgba(8/255, 14/255, 26/255, 0.6)
                            border.color: Qt.rgba(1, 1, 1, 0.12)
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "Log #" + (index + 1) + ": " + modelData
                                color: "#E2E8F0"
                                font.pixelSize: 9
                                font.bold: true
                                font.family: "Consolas"
                            }
                        }
                    }
                }
            }

            Item {
                visible: activeTab === 5
                anchors.fill: parent

                Column {
                    anchors.centerIn: parent
                    spacing: 18

                    Text { text: "PREFERENCES & COCKPIT ARCHITECTURE"; color: currentAccent; font.pixelSize: 11; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }

                    Column {
                        spacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "CLUSTER DISPLAY LAYOUT MODE"; color: "#64748B"; font.pixelSize: 8; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Row {
                            spacing: 12
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                width: 140
                                height: 34
                                radius: 17
                                color: clusterLayoutMode === 0 ? Qt.rgba(currentAccent.r, currentAccent.g, currentAccent.b, 0.35) : Qt.rgba(0, 0, 0, 0.5)
                                border.color: clusterLayoutMode === 0 ? currentAccent : Qt.rgba(1, 1, 1, 0.15)
                                border.width: 1.5
                                Text { anchors.centerIn: parent; text: "QUL DUAL RING"; color: "#FFFFFF"; font.pixelSize: 8; font.bold: true }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: clusterLayoutMode = 0 }
                            }

                            Rectangle {
                                width: 140
                                height: 34
                                radius: 17
                                color: clusterLayoutMode === 1 ? Qt.rgba(currentAccent.r, currentAccent.g, currentAccent.b, 0.35) : Qt.rgba(0, 0, 0, 0.5)
                                border.color: clusterLayoutMode === 1 ? currentAccent : Qt.rgba(1, 1, 1, 0.15)
                                border.width: 1.5
                                Text { anchors.centerIn: parent; text: "MINIMAL HUD"; color: "#FFFFFF"; font.pixelSize: 8; font.bold: true }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: clusterLayoutMode = 1 }
                            }

                            Rectangle {
                                width: 140
                                height: 34
                                radius: 17
                                color: clusterLayoutMode === 2 ? Qt.rgba(currentAccent.r, currentAccent.g, currentAccent.b, 0.35) : Qt.rgba(0, 0, 0, 0.5)
                                border.color: clusterLayoutMode === 2 ? currentAccent : Qt.rgba(1, 1, 1, 0.15)
                                border.width: 1.5
                                Text { anchors.centerIn: parent; text: "PERFORMANCE 3D"; color: "#FFFFFF"; font.pixelSize: 8; font.bold: true }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: clusterLayoutMode = 2 }
                            }
                        }
                    }

                    Column {
                        spacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "AMBIENT SIGNATURE"; color: "#64748B"; font.pixelSize: 8; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Row {
                            spacing: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                            Repeater {
                                model: themeColors
                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: modelData
                                    border.color: themeColorIndex === index ? "#FFFFFF" : "transparent"
                                    border.width: 2
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: themeColorIndex = index
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        spacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "LIVE BACKGROUND PRESETS (1-8)"; color: "#64748B"; font.pixelSize: 8; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Row {
                            spacing: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            Repeater {
                                model: 8
                                Rectangle {
                                    width: 58
                                    height: 34
                                    radius: 17
                                    color: currentWallpaperIndex === (index + 1) ? Qt.rgba(currentAccent.r, currentAccent.g, currentAccent.b, 0.35) : Qt.rgba(0, 0, 0, 0.5)
                                    border.color: currentWallpaperIndex === (index + 1) ? currentAccent : Qt.rgba(1, 1, 1, 0.15)
                                    border.width: 1.5

                                    Text {
                                        anchors.centerIn: parent
                                        text: "BG " + (index + 1)
                                        color: currentWallpaperIndex === (index + 1) ? currentAccent : "#94A3B8"
                                        font.pixelSize: 9
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            currentWallpaperIndex = index + 1
                                            bgVideoPlayer.source = Qt.resolvedUrl("../../assets/backgrounds/live_bg_" + (index + 1) + ".mp4")
                                            bgVideoPlayer.play()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        spacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "GLASS OPACITY"; color: "#64748B"; font.pixelSize: 8; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Row {
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            Rectangle {
                                width: 110
                                height: 32
                                radius: 16
                                color: bgDimOpacity === 0.25 ? Qt.rgba(currentAccent.r, currentAccent.g, currentAccent.b, 0.3) : Qt.rgba(0, 0, 0, 0.5)
                                border.color: bgDimOpacity === 0.25 ? currentAccent : Qt.rgba(1, 1, 1, 0.15)
                                Text { anchors.centerIn: parent; text: "LIGHT (25%)"; color: "#FFFFFF"; font.pixelSize: 8; font.bold: true }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bgDimOpacity = 0.25 }
                            }
                            Rectangle {
                                width: 110
                                height: 32
                                radius: 16
                                color: bgDimOpacity === 0.40 ? Qt.rgba(currentAccent.r, currentAccent.g, currentAccent.b, 0.3) : Qt.rgba(0, 0, 0, 0.5)
                                border.color: bgDimOpacity === 0.40 ? currentAccent : Qt.rgba(1, 1, 1, 0.15)
                                Text { anchors.centerIn: parent; text: "BALANCED (40%)"; color: "#FFFFFF"; font.pixelSize: 8; font.bold: true }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bgDimOpacity = 0.40 }
                            }
                            Rectangle {
                                width: 110
                                height: 32
                                radius: 16
                                color: bgDimOpacity === 0.70 ? Qt.rgba(currentAccent.r, currentAccent.g, currentAccent.b, 0.3) : Qt.rgba(0, 0, 0, 0.5)
                                border.color: bgDimOpacity === 0.70 ? currentAccent : Qt.rgba(1, 1, 1, 0.15)
                                Text { anchors.centerIn: parent; text: "TINTED (70%)"; color: "#FFFFFF"; font.pixelSize: 8; font.bold: true }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bgDimOpacity = 0.70 }
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: dsNavRack
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48
            z: 30

            Row {
                anchors.centerIn: parent
                spacing: 8

                component BottomTabBtn : Rectangle {
                    property string bTitle: ""
                    property int bTarget: 0

                    width: 120
                    height: 34
                    radius: 17
                    color: activeTab === bTarget ? Qt.rgba(currentAccent.r, currentAccent.g, currentAccent.b, 0.3) : Qt.rgba(0, 0, 0, 0.5)
                    border.color: activeTab === bTarget ? currentAccent : Qt.rgba(1, 1, 1, 0.12)
                    border.width: 1.5

                    Text {
                        anchors.centerIn: parent
                        text: bTitle
                        color: activeTab === bTarget ? currentAccent : "#94A3B8"
                        font.pixelSize: 9
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: activeTab = bTarget
                    }
                }

                BottomTabBtn { bTitle: "COCKPIT"; bTarget: 0 }
                BottomTabBtn { bTitle: "STATUS"; bTarget: 1 }
                BottomTabBtn { bTitle: "DYNAMICS"; bTarget: 2 }
                BottomTabBtn { bTitle: "MEDIA"; bTarget: 3 }
                BottomTabBtn { bTitle: "TRIP"; bTarget: 4 }
                BottomTabBtn { bTitle: "SETTINGS"; bTarget: 5 }
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
