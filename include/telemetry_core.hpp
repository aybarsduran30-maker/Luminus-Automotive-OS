#pragma once

#include <QObject>
#include <QTimer>
#include <QElapsedTimer>
#include <memory>
#include <string>

enum class TelemetrySource {
    SIMULATION,
    HARDWARE_OBD2
};

class TelemetryEngine : public QObject {
    Q_OBJECT
    Q_PROPERTY(double speed READ speed NOTIFY telemetryUpdated)
    Q_PROPERTY(double rpm READ rpm NOTIFY telemetryUpdated)
    Q_PROPERTY(double coolantTemp READ coolantTemp NOTIFY telemetryUpdated)
    Q_PROPERTY(double batteryVoltage READ batteryVoltage NOTIFY telemetryUpdated)
    Q_PROPERTY(double throttlePos READ throttlePos NOTIFY telemetryUpdated)
    Q_PROPERTY(bool hardwareConnected READ hardwareConnected NOTIFY hardwareStatusChanged)
    Q_PROPERTY(bool throttleActive READ throttleActive WRITE setThrottleActive NOTIFY throttleActiveChanged)
    Q_PROPERTY(bool brakeActive READ brakeActive WRITE setBrakeActive NOTIFY brakeActiveChanged)

    Q_PROPERTY(double dragTime READ dragTime NOTIFY dragTimerUpdated)
    Q_PROPERTY(bool isDragRunning READ isDragRunning NOTIFY dragTimerUpdated)
    Q_PROPERTY(bool dragArmed READ dragArmed NOTIFY dragTimerUpdated)
    Q_PROPERTY(double bestDragTime READ bestDragTime NOTIFY dragTimerUpdated)

    Q_PROPERTY(double tireFL READ tireFL NOTIFY tpmsUpdated)
    Q_PROPERTY(double tireFR READ tireFR NOTIFY tpmsUpdated)
    Q_PROPERTY(double tireRL READ tireRL NOTIFY tpmsUpdated)
    Q_PROPERTY(double tireRR READ tireRR NOTIFY tpmsUpdated)

    Q_PROPERTY(QString lastRawPacket READ lastRawPacket NOTIFY rawPacketReceived)

public:
    explicit TelemetryEngine(QObject *parent = nullptr);
    ~TelemetryEngine() override = default;

    double speed() const noexcept { return m_speed; }
    double rpm() const noexcept { return m_rpm; }
    double coolantTemp() const noexcept { return m_coolantTemp; }
    double batteryVoltage() const noexcept { return m_batteryVoltage; }
    double throttlePos() const noexcept { return m_throttlePos; }
    bool hardwareConnected() const noexcept { return m_hardwareConnected; }

    bool throttleActive() const noexcept { return m_throttleActive; }
    void setThrottleActive(bool active) noexcept;

    bool brakeActive() const noexcept { return m_brakeActive; }
    void setBrakeActive(bool active) noexcept;

    double dragTime() const noexcept { return m_dragTime; }
    bool isDragRunning() const noexcept { return m_isDragRunning; }
    bool dragArmed() const noexcept { return m_dragArmed; }
    double bestDragTime() const noexcept { return m_bestDragTime; }

    double tireFL() const noexcept { return m_tireFL; }
    double tireFR() const noexcept { return m_tireFR; }
    double tireRL() const noexcept { return m_tireRL; }
    double tireRR() const noexcept { return m_tireRR; }

    QString lastRawPacket() const noexcept { return m_lastRawPacket; }

    Q_INVOKABLE void connectHardware(const QString &portName);
    Q_INVOKABLE void disconnectHardware();
    Q_INVOKABLE void resetDragTimer();
    Q_INVOKABLE void armDragTimer();

signals:
    void telemetryUpdated();
    void hardwareStatusChanged();
    void throttleActiveChanged();
    void brakeActiveChanged();
    void dragTimerUpdated();
    void tpmsUpdated();
    void rawPacketReceived();

private slots:
    void onTick();

private:
    void parseObdResponse(const std::string &response);
    void updateDragLogic();

    TelemetrySource m_source{TelemetrySource::SIMULATION};
    QTimer m_tickTimer;

    double m_speed{0.0};
    double m_rpm{850.0};
    double m_coolantTemp{85.0};
    double m_batteryVoltage{13.9};
    double m_throttlePos{0.0};

    QElapsedTimer m_elapsedTimer;
    double m_dragTime{0.0};
    double m_bestDragTime{0.0};
    bool m_isDragRunning{false};
    bool m_dragFinished{false};
    bool m_dragArmed{true};

    double m_tireFL{2.3};
    double m_tireFR{2.3};
    double m_tireRL{2.1};
    double m_tireRR{2.1};

    QString m_lastRawPacket{"CAN: IDLE - WAITING FOR STREAM"};

    bool m_throttleActive{false};
    bool m_brakeActive{false};
    bool m_hardwareConnected{false};
};