//
//  ContentView.swift
//  DayTracker
//
//  Created by Alican Ozer on 5/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dateRangeManager = DateRangeManager()
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var isInclusive = true
    @State private var description = ""
    @State private var editingRange: DateRange? = nil
    @State private var editStartDate = Date()
    @State private var editEndDate = Date()
    @State private var editIsInclusive = true
    @State private var editDescription = ""
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Scrollable, fixed-height list at the top
            ZStack {
                if dateRangeManager.dateRanges.isEmpty {
                    VStack {
                        Spacer()
                        Text("No date ranges yet")
                            .foregroundColor(.secondary)
                            .font(.headline)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(dateRangeManager.dateRanges) { range in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(dateFormatter.string(from: range.startDate)) - \(dateFormatter.string(from: range.endDate))")
                                        Text(range.description)
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                        Text("Number of Days: \(range.numberOfDays)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(range.isInclusive ? "Inclusive" : "Exclusive")
                                        .font(.caption)
                                        .padding(4)
                                        .background(range.isInclusive ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                        .cornerRadius(4)
                                }
                                .opacity(range.ignore ? 0.4 : 1.0)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color(.systemBackground))
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        editingRange = range
                                        editStartDate = range.startDate
                                        editEndDate = range.endDate
                                        editIsInclusive = range.isInclusive
                                        editDescription = range.description
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                    Button(role: .destructive) {
                                        if let index = dateRangeManager.dateRanges.firstIndex(where: { $0.id == range.id }) {
                                            deleteDateRange(at: IndexSet(integer: index))
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    Button {
                                        dateRangeManager.toggleIgnore(id: range.id)
                                    } label: {
                                        Label(range.ignore ? "Unignore" : "Ignore", systemImage: range.ignore ? "eye" : "eye.slash")
                                    }
                                    .tint(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 240)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .padding(.top, 8)
            .padding(.horizontal)
            
            Spacer()
            
            // 2. Add new date range form fixed at the bottom
            VStack(spacing: 8) {
                // Total days section moved here, right above the form
                HStack(spacing: 12) {
                    Label { Text("\(dateRangeManager.totalIncludedDays)").bold() } icon: { Text("Included") }
                        .labelStyle(VerticalLabelStyle())
                    Divider().frame(height: 32)
                    Label { Text("\(dateRangeManager.totalExcludedDays)").bold() } icon: { Text("Excluded") }
                        .labelStyle(VerticalLabelStyle())
                    Divider().frame(height: 32)
                    Label { Text("\(dateRangeManager.totalDays)").bold() } icon: { Text("Final") }
                        .labelStyle(VerticalLabelStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(.systemGroupedBackground))
                .cornerRadius(8)
                .padding(.horizontal)
                
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                Toggle("Include Dates", isOn: $isInclusive)
                TextField("Description", text: $description)
                if endDate <= startDate {
                    Text("End date must be after start date.")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                Button(action: addDateRange) {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(endDate <= startDate)
            }
            .padding()
            .background(Color(.systemBackground).opacity(0.95))
            .cornerRadius(8)
            .shadow(radius: 4)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(item: $editingRange) { range in
            NavigationView {
                Form {
                    DatePicker("Start Date", selection: $editStartDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $editEndDate, displayedComponents: .date)
                    Toggle("Include Dates", isOn: $editIsInclusive)
                    TextField("Description", text: $editDescription)
                    Toggle("Ignore this range", isOn: Binding(
                        get: { range.ignore },
                        set: { newValue in dateRangeManager.toggleIgnore(id: range.id) }
                    ))
                    if editEndDate <= editStartDate {
                        Text("End date must be after start date.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .navigationTitle("Edit Date Range")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { editingRange = nil }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if let id = range.id as UUID? {
                                dateRangeManager.updateDateRange(
                                    id: id,
                                    startDate: editStartDate,
                                    endDate: editEndDate,
                                    isInclusive: editIsInclusive,
                                    description: editDescription
                                )
                            }
                            editingRange = nil
                        }
                        .disabled(editEndDate <= editStartDate)
                    }
                }
            }
        }
        .navigationTitle("Date Tracker")
    }
    
    private func addDateRange() {
        dateRangeManager.addDateRange(startDate: startDate, endDate: endDate, isInclusive: isInclusive, description: description)
        description = ""
    }
    
    private func deleteDateRange(at offsets: IndexSet) {
        offsets.forEach { index in
            dateRangeManager.removeDateRange(at: index)
        }
    }
}

// Custom label style for vertical arrangement
struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 2) {
            configuration.icon
                .font(.caption2)
                .foregroundColor(.secondary)
            configuration.title
                .font(.title3)
                .foregroundColor(.primary)
        }
        .frame(minWidth: 60)
    }
}

#Preview {
    ContentView()
}
