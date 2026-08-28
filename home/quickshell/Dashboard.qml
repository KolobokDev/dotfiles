import Quickshell
import Quickshell.Io
import QtQuick
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: root

    anchors {
        top: true
        right: true
    }

    implicitWidth: 330
    implicitHeight: 430

    color: "transparent"


    // ═════════════════════════════════════
    // VALUES
    // ═════════════════════════════════════

    property string username: "username"
    property string uptimeText: "up 0 minutes"

    property int batteryLevel: 0
    property int cpuUsage: 0
    property int ramUsage: 0
    property int diskUsage: 0

    property int volumeLevel: 0
    property int brightnessLevel: 0

    function getBatteryColor() {
    if (root.batteryLevel <= 20)
        return "#ff5c70"

    if (root.batteryLevel <= 50)
        return "#f1d45c"

    return "#28e27a"
}

    // ═════════════════════════════════════
    // USERNAME
    // ═════════════════════════════════════

    Process {
        id: usernameProcess

        command: [
            "bash",
            "-c",
            "whoami"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {

                var value = this.text.trim()

                if (value.length > 0)
                    root.username = value
            }
        }
    }


    // ═════════════════════════════════════
    // UPTIME
    // ═════════════════════════════════════

    Process {
        id: uptimeProcess

        command: [
            "bash",
            "-c",
            "awk '{print int($1)}' /proc/uptime"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {

                var seconds = parseInt(this.text.trim())

                if (isNaN(seconds)) {
                    root.uptimeText = "up 0 minutes"
                    return
                }

                var days = Math.floor(seconds / 86400)

                seconds = seconds % 86400

                var hours = Math.floor(seconds / 3600)

                seconds = seconds % 3600

                var minutes = Math.floor(seconds / 60)

                var result = "up"

                if (days > 0) {
                    result += " " + days

                    result += days === 1
                            ? " day"
                            : " days"
                }

                if (hours > 0) {
                    result += " " + hours

                    result += hours === 1
                            ? " hour"
                            : " hours"
                }

                if (
                    minutes > 0 ||
                    (
                        days === 0 &&
                        hours === 0
                    )
                ) {
                    result += " " + minutes

                    result += minutes === 1
                            ? " minute"
                            : " minutes"
                }

                root.uptimeText = result
            }
        }
    }


    // ═════════════════════════════════════
    // BATTERY
    // ═════════════════════════════════════
Process {
    id: batteryProcess

    command: [
        "bash",
        "-c",
        "for d in /sys/class/power_supply/*; do " +
        "if [ -f \"$d/capacity\" ]; then " +
        "cat \"$d/capacity\"; " +
        "exit; " +
        "fi; " +
        "done"
    ]

    running: true

    stdout: StdioCollector {
        onStreamFinished: {

            var level =
                parseInt(
                    this.text.trim()
                )

            if (!isNaN(level)) {

                root.batteryLevel =
                    Math.max(
                        0,
                        Math.min(
                            100,
                            level
                        )
                    )
            }
        }
    }
}
    // ═════════════════════════════════════
    // CPU
    // ═════════════════════════════════════

    Process {
        id: cpuProcess

        command: [
            "bash",
            "-c",
            "top -bn1 | awk '/Cpu\\(s\\)/ {print int(100-$8); exit}'"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {

                var value =
                    parseInt(
                        this.text.trim()
                    )

                if (!isNaN(value)) {
                    root.cpuUsage =
                        Math.max(
                            0,
                            Math.min(
                                100,
                                value
                            )
                        )
                }
            }
        }
    }


    // ═════════════════════════════════════
    // RAM
    // ═════════════════════════════════════

    Process {
        id: ramProcess

        command: [
            "bash",
            "-c",
            "free | awk '/Mem:/ {printf \"%d\", ($3/$2)*100}'"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {

                var value =
                    parseInt(
                        this.text.trim()
                    )

                if (!isNaN(value)) {
                    root.ramUsage =
                        Math.max(
                            0,
                            Math.min(
                                100,
                                value
                            )
                        )
                }
            }
        }
    }


    // ═════════════════════════════════════
    // DISK
    // ═════════════════════════════════════

    Process {
    id: diskProcess

    command: [
        "bash",
        "-c",
        "df -P / | tail -1 | awk '{gsub(/%/,\"\",$5); print $5}'"
    ]

    running: true

    stdout: StdioCollector {
        onStreamFinished: {

            var value =
                parseInt(
                    this.text.trim()
                )

            if (!isNaN(value)) {

                root.diskUsage =
                    Math.max(
                        0,
                        Math.min(
                            100,
                            value
                        )
                    )
            }
        }
    }
}
    // ═════════════════════════════════════
    // VOLUME READ
    // ═════════════════════════════════════

    Process {
        id: volumeProcess

        command: [
            "bash",
            "-c",
            "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%d\", $2*100}'"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {

                var value =
                    parseInt(
                        this.text.trim()
                    )

                if (!isNaN(value)) {
                    root.volumeLevel =
                        Math.max(
                            0,
                            Math.min(
                                100,
                                value
                            )
                        )
                }
            }
        }
    }


    // ═════════════════════════════════════
    // VOLUME SET
    // ═════════════════════════════════════

    Process {
        id: volumeSetProcess

        command: [
            "bash",
            "-c",
            "true"
        ]

        running: false
    }


    // ═════════════════════════════════════
    // BRIGHTNESS READ
    // ═════════════════════════════════════

    Process {
        id: brightnessProcess

        command: [
            "bash",
            "-c",
            "brightnessctl -m 2>/dev/null | awk -F, '{gsub(/%/,\"\",$4); print $4}'"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {

                var value =
                    parseInt(
                        this.text.trim()
                    )

                if (!isNaN(value)) {
                    root.brightnessLevel =
                        Math.max(
                            0,
                            Math.min(
                                100,
                                value
                            )
                        )
                }
            }
        }
    }


    // ═════════════════════════════════════
    // BRIGHTNESS SET
    // ═════════════════════════════════════

    Process {
        id: brightnessSetProcess

        command: [
            "bash",
            "-c",
            "true"
        ]

        running: false
    }


    // ═════════════════════════════════════
    // UPDATE TIMER
    // ═════════════════════════════════════

    Timer {
        interval: 2000

        running: true

        repeat: true

        onTriggered: {

            uptimeProcess.running = true

            batteryProcess.running = true

            cpuProcess.running = true

            ramProcess.running = true

            diskProcess.running = true

            volumeProcess.running = true

            brightnessProcess.running = true
        }
    }


    // ═════════════════════════════════════
    // BACKGROUND
    // ═════════════════════════════════════

    Rectangle {
        anchors.fill: parent

        radius: 16

        color: "#11111b"

        border.width: 1

        border.color: "#24243a"
    }


    // ═════════════════════════════════════
    // HEADER
    // ═════════════════════════════════════

    Item {
        id: header

        anchors {
            top: parent.top

            left: parent.left

            right: parent.right

            topMargin: 14

            leftMargin: 14

            rightMargin: 14
        }

        height: 70


        // ═════════════════════════════════
        // AVATAR
        // ═════════════════════════════════

        Item {
            id: avatarContainer

            width: 68

            height: 68

            anchors.verticalCenter:
                parent.verticalCenter


            Image {
                id: avatarImage

                anchors.fill: parent

                source:
                    "/home/username/.face.jpg"

                fillMode:
                    Image.PreserveAspectCrop

                smooth: true

                visible: false
            }


            Rectangle {
                id: avatarMask

                anchors.fill: parent

                radius:
                    width / 2

                color: "white"

                visible: false
            }


            OpacityMask {
                anchors.fill: parent

                source: avatarImage

                maskSource: avatarMask
            }
        }


        // ═════════════════════════════════
        // USER INFO
        // ═════════════════════════════════

        Column {
            anchors {
                left:
                    avatarContainer.right

                leftMargin: 14

                verticalCenter:
                    parent.verticalCenter
            }

            spacing: 4


            Text {
                text:
                    root.username

                color:
                    "#cdd6f4"

                font.pixelSize:
                    20

                font.bold:
                    true
            }


            Text {
                text:
                    root.uptimeText

                color:
                    "#8f91a4"

                font.pixelSize:
                    13
            }
        }
    }


    // ═════════════════════════════════════
    // MAIN DASHBOARD
    // ═════════════════════════════════════

    Column {
        anchors {
            top:
                header.bottom

            left:
                parent.left

            right:
                parent.right

            leftMargin:
                10

            rightMargin:
                10

            topMargin:
                10
        }

        spacing: 10


        // ═════════════════════════════════
        // BATTERY
        // ═════════════════════════════════
// ═════════════════════════════════
// BATTERY
// ═════════════════════════════════

Rectangle {
    width:
        parent.width

    height:
        88

    radius:
        16

    color:
        "#171725"


    Row {
        anchors.centerIn:
            parent

        spacing:
            16


        // ═════════════════════════
        // BATTERY ICON
        // ═════════════════════════

        Item {
            width:
                54

            height:
                48

            anchors.verticalCenter:
                parent.verticalCenter


            // Battery body

            Rectangle {
                width:
                    40

                height:
                    27

                anchors {
                    left:
                        parent.left

                    verticalCenter:
                        parent.verticalCenter
                }

                radius:
                    4

                color:
                    "transparent"

                border.width:
                    3

                border.color:
                    root.getBatteryColor()
            }


            // Battery terminal

            Rectangle {
                width:
                    5

                height:
                    11

                anchors {
                    left:
                        parent.left

                    leftMargin:
                        40

                    verticalCenter:
                        parent.verticalCenter
                }

                radius:
                    2

                color:
                    root.getBatteryColor()
            }


            // Battery fill

            Rectangle {
                width:
                    30 *
                    root.batteryLevel /
                    100

                height:
                    17

                anchors {
                    left:
                        parent.left

                    leftMargin:
                        6

                    verticalCenter:
                        parent.verticalCenter
                }

                radius:
                    2

                color:
                    root.getBatteryColor()
            }
        }


        // ═════════════════════════
        // BATTERY TEXT
        // ═════════════════════════

        Text {
            anchors.verticalCenter:
                parent.verticalCenter

            text:
                "Battery " +
                root.batteryLevel +
                "%"

            color:
                "#f2f2f5"

            font.pixelSize:
                20

            font.bold:
                true
        }
    }
}

        // ═════════════════════════════════
        // CPU / RAM / DISK
        // ═════════════════════════════════

        Row {
            width:
                parent.width

            height:
                118

            spacing:
                8


            // ═════════════════════════════
            // CPU
            // ═════════════════════════════

            Rectangle {
                width:
                    (parent.width - 16) / 3

                height:
                    parent.height

                radius:
                    14

                color:
                    "#171725"


                Canvas {
                    id:
                        cpuRing

                    width:
                        70

                    height:
                        70

                    anchors {
                        top:
                            parent.top

                        topMargin:
                            8

                        horizontalCenter:
                            parent.horizontalCenter
                    }

                    onPaint: {

                        var ctx =
                            getContext("2d")

                        ctx.clearRect(
                            0,
                            0,
                            width,
                            height
                        )

                        var center =
                            width / 2

                        var radius =
                            27


                        // Background

                        ctx.beginPath()

                        ctx.arc(
                            center,
                            center,
                            radius,
                            0,
                            Math.PI * 2
                        )

                        ctx.lineWidth =
                            6

                        ctx.strokeStyle =
                            "#29283b"

                        ctx.stroke()


                        // Progress

                        ctx.beginPath()

                        ctx.arc(
                            center,
                            center,
                            radius,
                            -Math.PI / 2,
                            -Math.PI / 2 +
                            Math.PI * 2 *
                            root.cpuUsage /
                            100
                        )

                        ctx.lineWidth =
                            6

                        ctx.lineCap =
                            "round"

                        ctx.strokeStyle =
                            "#ff5c70"

                        ctx.stroke()
                    }

                    Connections {
                        target:
                            root

                        function onCpuUsageChanged() {
                            cpuRing.requestPaint()
                        }
                    }


                    Text {
                        anchors.centerIn:
                            parent

                        text:
                            "⚙"

                        color:
                            "#ff5c70"

                        font.pixelSize:
                            18
                    }
                }


                Text {
                    anchors {
                        bottom:
                            parent.bottom

                        bottomMargin:
                            11

                        horizontalCenter:
                            parent.horizontalCenter
                    }

                    text:
                        "CPU " +
                        root.cpuUsage +
                        "%"

                    color:
                        "#ff5c70"

                    font.pixelSize:
                        12

                    font.bold:
                        true
                }
            }


            // ═════════════════════════════
            // RAM
            // ═════════════════════════════

            Rectangle {
                width:
                    (parent.width - 16) / 3

                height:
                    parent.height

                radius:
                    14

                color:
                    "#171725"


                Canvas {
                    id:
                        ramRing

                    width:
                        70

                    height:
                        70

                    anchors {
                        top:
                            parent.top

                        topMargin:
                            8

                        horizontalCenter:
                            parent.horizontalCenter
                    }

                    onPaint: {

                        var ctx =
                            getContext("2d")

                        ctx.clearRect(
                            0,
                            0,
                            width,
                            height
                        )

                        var center =
                            width / 2

                        var radius =
                            27


                        ctx.beginPath()

                        ctx.arc(
                            center,
                            center,
                            radius,
                            0,
                            Math.PI * 2
                        )

                        ctx.lineWidth =
                            6

                        ctx.strokeStyle =
                            "#29283b"

                        ctx.stroke()


                        ctx.beginPath()

                        ctx.arc(
                            center,
                            center,
                            radius,
                            -Math.PI / 2,
                            -Math.PI / 2 +
                            Math.PI * 2 *
                            root.ramUsage /
                            100
                        )

                        ctx.lineWidth =
                            6

                        ctx.lineCap =
                            "round"

                        ctx.strokeStyle =
                            "#4da6ff"

                        ctx.stroke()
                    }

                    Connections {
                        target:
                            root

                        function onRamUsageChanged() {
                            ramRing.requestPaint()
                        }
                    }


                    Text {
                        anchors.centerIn:
                            parent

                        text:
                            "▮"

                        color:
                            "#4da6ff"

                        font.pixelSize:
                            19
                    }
                }


                Text {
                    anchors {
                        bottom:
                            parent.bottom

                        bottomMargin:
                            11

                        horizontalCenter:
                            parent.horizontalCenter
                    }

                    text:
                        "RAM " +
                        root.ramUsage +
                        "%"

                    color:
                        "#4da6ff"

                    font.pixelSize:
                        12

                    font.bold:
                        true
                }
            }


            // ═════════════════════════════
            // DISK
            // ═════════════════════════════

            Rectangle {
                width:
                    (parent.width - 16) / 3

                height:
                    parent.height

                radius:
                    14

                color:
                    "#171725"


                Canvas {
                    id:
                        diskRing

                    width:
                        70

                    height:
                        70

                    anchors {
                        top:
                            parent.top

                        topMargin:
                            8

                        horizontalCenter:
                            parent.horizontalCenter
                    }

                    onPaint: {

                        var ctx =
                            getContext("2d")

                        ctx.clearRect(
                            0,
                            0,
                            width,
                            height
                        )

                        var center =
                            width / 2

                        var radius =
                            27


                        ctx.beginPath()

                        ctx.arc(
                            center,
                            center,
                            radius,
                            0,
                            Math.PI * 2
                        )

                        ctx.lineWidth =
                            6

                        ctx.strokeStyle =
                            "#29283b"

                        ctx.stroke()


                        ctx.beginPath()

                        ctx.arc(
                            center,
                            center,
                            radius,
                            -Math.PI / 2,
                            -Math.PI / 2 +
                            Math.PI * 2 *
                            root.diskUsage /
                            100
                        )

                        ctx.lineWidth =
                            6

                        ctx.lineCap =
                            "round"

                        ctx.strokeStyle =
                            "#2ee681"

                        ctx.stroke()
                    }

                    Connections {
                        target:
                            root

                        function onDiskUsageChanged() {
                            diskRing.requestPaint()
                        }
                    }


                    Text {
                        anchors.centerIn:
                            parent

                        text:
                            "▱"

                        color:
                            "#2ee681"

                        font.pixelSize:
                            20
                    }
                }


                Text {
                    anchors {
                        bottom:
                            parent.bottom

                        bottomMargin:
                            11

                        horizontalCenter:
                            parent.horizontalCenter
                    }

                    text:
                        "DISK " +
                        root.diskUsage +
                        "%"

                    color:
                        "#2ee681"

                    font.pixelSize:
                        12

                    font.bold:
                        true
                }
            }
        }


        // ═════════════════════════════════
        // VOLUME / BRIGHTNESS
        // ═════════════════════════════════
        Rectangle {
            width:
                parent.width

            height:
                78

            radius:
                14

            color:
                "#171725"


            Column {
                anchors {
                    left:
                        parent.left

                    right:
                        parent.right

                    verticalCenter:
                        parent.verticalCenter

                    leftMargin:
                        14

                    rightMargin:
                        14
                }

                spacing:
                    10


                // ═════════════════════════
                // VOLUME
                // ═════════════════════════

                Row {
                    width:
                        parent.width

                    height:
                        18

                    spacing:
                        6


                    Text {
                        width:
                            18

                        text:
                            "♪"

                        color:
                            "#a66cff"

                        font.pixelSize:
                            15

                        horizontalAlignment:
                            Text.AlignHCenter
                    }


                    Text {
                        width:
                            32

                        text:
                            root.volumeLevel + "%"

                        color:
                            "#a66cff"

                        font.pixelSize:
                            11

                        font.bold:
                            true

                        verticalAlignment:
                            Text.AlignVCenter
                    }


                    Rectangle {
                        id:
                            volumeBar

                        width:
                            parent.width - 56

                        height:
                            8

                        anchors.verticalCenter:
                            parent.verticalCenter

                        radius:
                            4

                        color:
                            "#29283b"


                        Rectangle {
                            width:
                                volumeBar.width *
                                root.volumeLevel /
                                100

                            height:
                                parent.height

                            radius:
                                4

                            color:
                                "#a66cff"
                        }


                        MouseArea {
                            anchors.fill:
                                parent

                            cursorShape:
                                Qt.PointingHandCursor

                            onPressed: function(mouse) {
                                setVolume(mouse.x)
                            }

                            onPositionChanged: function(mouse) {
                                if (pressed)
                                    setVolume(mouse.x)
                            }


                            function setVolume(x) {

                                var value =
                                    Math.round(
                                        x /
                                        width *
                                        100
                                    )

                                value =
                                    Math.max(
                                        0,
                                        Math.min(
                                            100,
                                            value
                                        )
                                    )

                                volumeSetProcess.command = [
                                    "bash",
                                    "-c",
                                    "wpctl set-volume @DEFAULT_AUDIO_SINK@ " +
                                    (value / 100).toFixed(2)
                                ]

                                volumeSetProcess.running =
                                    true

                                root.volumeLevel =
                                    value
                            }
                        }
                    }
                }


                // ═════════════════════════
                // BRIGHTNESS
                // ═════════════════════════

                Row {
                    width:
                        parent.width

                    height:
                        18

                    spacing:
                        6


                    Text {
                        width:
                            18

                        text:
                            "☼"

                        color:
                            "#f1d45c"

                        font.pixelSize:
                            17

                        horizontalAlignment:
                            Text.AlignHCenter
                    }


                    Text {
                        width:
                            32

                        text:
                            root.brightnessLevel + "%"

                        color:
                            "#f1d45c"

                        font.pixelSize:
                            11

                        font.bold:
                            true

                        verticalAlignment:
                            Text.AlignVCenter
                    }


                    Rectangle {
                        id:
                            brightnessBar

                        width:
                            parent.width - 56

                        height:
                            8

                        anchors.verticalCenter:
                            parent.verticalCenter

                        radius:
                            4

                        color:
                            "#29283b"


                        Rectangle {
                            width:
                                brightnessBar.width *
                                root.brightnessLevel /
                                100

                            height:
                                parent.height

                            radius:
                                4

                            color:
                                "#f1d45c"
                        }


                        MouseArea {
                            anchors.fill:
                                parent

                            cursorShape:
                                Qt.PointingHandCursor

                            onPressed: function(mouse) {
                                setBrightness(mouse.x)
                            }

                            onPositionChanged: function(mouse) {
                                if (pressed)
                                    setBrightness(mouse.x)
                            }


                            function setBrightness(x) {

                                var value =
                                    Math.round(
                                        x /
                                        width *
                                        100
                                    )

                                value =
                                    Math.max(
                                        1,
                                        Math.min(
                                            100,
                                            value
                                        )
                                    )

                                brightnessSetProcess.command = [
                                    "bash",
                                    "-c",
                                    "brightnessctl set " +
                                    value +
                                    "%"
                                ]

                                brightnessSetProcess.running =
                                    true

                                root.brightnessLevel =
                                    value
                            }
                        }
                    }
                }
            }

        }
    }
}