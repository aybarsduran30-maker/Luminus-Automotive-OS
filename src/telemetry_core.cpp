#include "telemetry_core.hpp"
#include <algorithm>
#include <sstream>
#include <iomanip>

TelemetryEngine::TelemetryEngine(QObject *parent)
    : QObject(parent) {
    connect(&m_tickTimer, &QTimer::timeout, this, &TelemetryEngine::onTick);
    m_tickTimer.start(33);
}

void TelemetryEngine::setThrottleActive(bool active) noexcept {
    if (m_throttleActive != active) {
        m_throttleActive = active;
        emit throttleActiveChanged();
    }
}

void TelemetryEngine::setBrakeActive(bool active) noexcept {
    if (m_brakeActive != active) {
        m_brakeActive = active;
        emit brakeActiveChanged();
    }
}

void TelemetryEngine::resetDragTimer() {
    m_isDragRunning = false;
    m_dragFinished = false;
    m_dragTime = 0.0;
    m_dragArmed = (m_speed < 0.5);
    emit dragTimerUpdated();
}

void TelemetryEngine::armDragTimer() {
    m_isDragRunning = false;
    m_dragFinished = false;
    m_dragTime = 0.0;
    m_dragArmed = true;
    emit dragTimerUpdated();
}

void TelemetryEngine::updateDragLogic() {
    if (m_speed < 0.2 && !m_isDragRunning && !m_dragFinished) {
        m_dragArmed = true;
    }

    if (m_dragArmed && !m_isDragRunning && !m_dragFinished) {
        if (m_speed > 0.8 && m_throttleActive) {
            m_dragArmed = false;
            m_isDragRunning = true;
            m_elapsedTimer.start();
            emit dragTimerUpdated();
        }
    } else if (m_isDragRunning && !m_dragFinished) {
        m_dragTime = m_elapsedTimer.elapsed() / 1000.0;

        if (m_speed >= 100.0) {
            m_isDragRunning = false;
            m_dragFinished = true;
            if (m_bestDragTime == 0.0 || m_dragTime < m_bestDragTime) {
                m_bestDragTime = m_dragTime;
            }
        }
        emit dragTimerUpdated();
    }
}

void TelemetryEngine::connectHardware(const QString &portName) {
    Q_UNUSED(portName);
    m_hardwareConnected = true;
    m_source = TelemetrySource::HARDWARE_OBD2;
    emit hardwareStatusChanged();
}

void TelemetryEngine::disconnectHardware() {
    m_hardwareConnected = false;
    m_source = TelemetrySource::SIMULATION;
    emit hardwareStatusChanged();
}

void TelemetryEngine::onTick() {
    if (m_source == TelemetrySource::SIMULATION) {
        if (m_throttleActive) {
            m_speed = std::min(m_speed + 1.2, 195.0);
            m_rpm = std::min(m_rpm + 65.0, 5600.0);
            m_throttlePos = std::min(m_throttlePos + 4.0, 100.0);
            m_coolantTemp = std::min(m_coolantTemp + 0.03, 96.0);
            m_batteryVoltage = 14.2;
        } else if (m_brakeActive) {
            m_speed = std::max(m_speed - 2.5, 0.0);
            m_rpm = std::max(m_rpm - 90.0, 850.0);
            m_throttlePos = std::max(m_throttlePos - 6.0, 0.0);
        } else {
            m_speed = std::max(m_speed - 0.3, 0.0);
            m_rpm = std::max(m_rpm - 30.0, 850.0);
            m_throttlePos = std::max(m_throttlePos - 3.0, 0.0);
            m_batteryVoltage = 13.8;
        }

        static int mockCounter = 0;
        if (++mockCounter % 15 == 0) {
            std::stringstream ss;
            ss << "RX CAN [0x7E8] 04 41 0C " << std::hex << std::uppercase 
               << static_cast<int>(m_rpm * 4) / 256 << " " 
               << static_cast<int>(m_rpm * 4) % 256;
            m_lastRawPacket = QString::fromStdString(ss.str());
            emit rawPacketReceived();
        }

        updateDragLogic();
        emit telemetryUpdated();
    }
}

void TelemetryEngine::parseObdResponse(const std::string &response) {
    if (response.find("41 0C") != std::string::npos) {
        auto pos = response.find("41 0C");
        std::stringstream ss(response.substr(pos + 6));
        int a = 0, b = 0;
        ss >> std::hex >> a >> b;
        m_rpm = ((a * 256.0) + b) / 4.0;
    } else if (response.find("41 0D") != std::string::npos) {
        auto pos = response.find("41 0D");
        std::stringstream ss(response.substr(pos + 6));
        int a = 0;
        ss >> std::hex >> a;
        m_speed = static_cast<double>(a);
    } else if (response.find("41 05") != std::string::npos) {
        auto pos = response.find("41 05");
        std::stringstream ss(response.substr(pos + 6));
        int a = 0;
        ss >> std::hex >> a;
        m_coolantTemp = static_cast<double>(a - 40);
    }
    emit telemetryUpdated();
}