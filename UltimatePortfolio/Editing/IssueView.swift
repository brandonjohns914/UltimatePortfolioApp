//
//  IssueView.swift
//  UltimatePortfolio
//
//  Created by Brandon Johns on 1/18/24.
//

import SwiftUI

struct IssueView: View {
    @ObservedObject var issue: Issue
    @EnvironmentObject var dataController: DataController
    
    @State private var showingNotificationsError = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the Issue title here"))
                        .font(.title)
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    Text("**Status:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)
                }
                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                TagsMenuView(issue: issue)
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Basic Infomation")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    TextField("Description",
                              text: $issue.issueContent,
                              prompt: Text("Enter the Issue description here"),
                              axis: .vertical
                    )
                }
            }
            
            Section("Reminders") {
                Toggle("Show Reminders", isOn: $issue.reminderEnabled.animation())

                if issue.reminderEnabled {
                   DatePicker(
                       "Reminder Time",
                       selection: $issue.issueReminderTime,
                       displayedComponents: .hourAndMinute
                   )
                }
            }
            
            
        } // if issue is deleted dont allow editing
        .disabled(issue.isDeleted)
        // every small change wont instantly save it will wait 3 seconds before calling save
        .onReceive(issue.objectWillChange){ _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save) // user submits does not have to wait for the queue
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
        .alert("Oops!", isPresented: $showingNotificationsError) {
            Button("Check Settings", action: showAppSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("There was a problem setting your notification. Please check you have notifications enabled.")
        }
        .onChange(of: issue.reminderEnabled) { _ , _ in
            updateReminder()
        }
        .onChange(of: issue.reminderTime) { _ , _ in
            updateReminder()
        }

    }
    
    func showAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) else {
            return
        }

        openURL(settingsURL)
    }

    
    func updateReminder() {
        dataController.removeReminders(for: issue)

        Task { @MainActor in
            if issue.reminderEnabled {
                let success = await dataController.addReminder(for: issue)

                if success == false {
                    issue.reminderEnabled = false
                    showingNotificationsError = true
                }
            }
        }
    }
    
}

#Preview {
    IssueView(issue: .example)
        .environmentObject(DataController(inMemory: true))
}
