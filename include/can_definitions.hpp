#pragma once

#include <cstdint>

namespace Luminus::CAN {

constexpr uint32_t PSA_SPEED_RPM_FRAME_ID = 0x0F6;
constexpr uint32_t PSA_COOLANT_VOLT_FRAME_ID = 0x128;
constexpr uint32_t PSA_DOOR_STATUS_FRAME_ID = 0x221;

#pragma pack(push, 1)
struct RawEngineFrame {
    uint8_t raw_rpm_high;
    uint8_t raw_rpm_low;
    uint8_t raw_speed_high;
    uint8_t raw_speed_low;
    uint8_t throttle_pos;
    uint8_t flags;
    uint16_t reserved;
};

struct RawStatusFrame {
    uint8_t coolant_temp_offset;
    uint8_t raw_voltage;
    uint8_t fuel_level;
    uint8_t ambient_temp;
    uint32_t unused;
};
#pragma pack(pop)

}