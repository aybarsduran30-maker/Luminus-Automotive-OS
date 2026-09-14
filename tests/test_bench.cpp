#include <iostream>
#include <thread>
#include "telemetry_core.hpp"

int main() {
    TelemetryCore core;
    core.set_base_weight(1090.0f);
    core.add_passenger_weight(85.0f);

    std::cout << "Base Weight: " << core.get_display_weight() << " kg\n";
    core.toggle_units_weight();
    std::cout << "Base Weight: " << core.get_display_weight() << " lbs\n";
    core.toggle_units_weight();

    core.arm_drag_timer();
    std::cout << "Drag timer armed. Launching vehicle...\n";

    float sim_speed = 0.0f;
    uint16_t sim_rpm = 900;

    for (int step = 0; step <= 120; ++step) {
        sim_speed += 1.0f;
        sim_rpm = static_cast<uint16_t>(900 + (sim_speed * 40));
        
        core.update_can_signals(sim_speed, sim_rpm, 88.0f, 14.1f, 100.0f);
        
        std::this_thread::sleep_for(std::chrono::milliseconds(20));

        if (core.get_timer_metrics().state == TimerState::COMPLETED) {
            break;
        }
    }

    const auto& t = core.get_timer_metrics();
    std::cout << "0-60 Time: " << t.split_0_60_s << " s\n";
    std::cout << "0-100 Time: " << t.final_0_100_s << " s\n";

    return 0;
}