import LumiUI
import SwiftUI

struct HydrationSettingsView: View {
    @ObservedObject private var manager = HydrationReminderManager.shared
    @State private var customMinutes: Int = 120

    var body: some View {
        AppSettingsContentScaffold(maxContentWidth: nil) {
            AppSettingSection(title: String(localized: "Reminder Intervals", table: "HydrationReminder", bundle: .module)) {
                VStack(spacing: 0) {
                    // 用选项自身的稳定 id 标识行，而不是数组下标——
                    // 列表会被增删并重新排序，下标变化会让 SwiftUI 把旧行
                    // 的状态套用到别的行上。
                    ForEach(manager.availableIntervals) { option in
                        AppSettingRow(
                            title: option.displayName,
                            description: HydrationReminderManager.commonIntervals.contains(option)
                                ? nil
                                : String(localized: "Custom interval", table: "HydrationReminder", bundle: .module),
                            icon: "drop"
                        ) {
                            if !HydrationReminderManager.commonIntervals.contains(option) {
                                AppButton(systemImage: "minus", style: .destructive) {
                                    manager.removeInterval(option)
                                }
                                .help(Text("Delete", tableName: "HydrationReminder", bundle: .module))
                                .accessibilityIdentifier("wakey.hydration.interval.remove.\(Int(option.timeInterval))")
                            }
                        }
                        if option != manager.availableIntervals.last {
                            rowDivider
                        }
                    }

                    rowDivider

                    AppSettingRow(
                        title: String(localized: "Add Custom (minutes):", table: "HydrationReminder", bundle: .module),
                        description: String(localized: "Add a custom hydration reminder interval.", table: "HydrationReminder", bundle: .module),
                        icon: "plus.circle"
                    ) {
                        HStack(spacing: 8) {
                            TextField("", value: $customMinutes, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 64)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                                .accessibilityIdentifier("wakey.hydration.custom-interval.minutes")
                                .onSubmit { addCustomInterval() }
                            AppButton(systemImage: "plus", style: .secondary, action: addCustomInterval)
                                .disabled(customMinutes <= 0)
                                .accessibilityIdentifier("wakey.hydration.custom-interval.add")
                        }
                    }

                    rowDivider

                    AppSettingRow(
                        title: String(localized: "Reset to Default Intervals", table: "HydrationReminder", bundle: .module),
                        description: String(localized: "Restore the built-in reminder intervals.", table: "HydrationReminder", bundle: .module),
                        icon: "arrow.counterclockwise"
                    ) {
                        AppButton(
                            String(localized: "Reset", table: "HydrationReminder", bundle: .module),
                            systemImage: "arrow.counterclockwise",
                            style: .secondary,
                            size: .small,
                            action: manager.resetIntervals
                        )
                        .accessibilityIdentifier("wakey.hydration.interval.reset")
                    }
                }
            }
        }
        .onAppear {
            customMinutes = 120
        }
    }

    private func addCustomInterval() {
        guard customMinutes > 0 else { return }
        manager.addCustomInterval(minutes: customMinutes)
        customMinutes = 120 // Reset to default suggestion
    }

    private func formatInterval(_ interval: TimeInterval) -> String {
        let mins = Int(interval / 60)
        if mins % 60 == 0 {
            return "\(mins / 60) hr"
        }
        return "\(mins) min"
    }

    /// iOS 的卡片行自带发丝分隔线；macOS 的分组卡片需要显式分隔线。
    @ViewBuilder
    private var rowDivider: some View {
        #if os(macOS)
        Divider()
            .padding(.vertical, 8)
        #endif
    }
}

#Preview {
    HydrationSettingsView()
        .frame(width: 400, height: 500)
}
