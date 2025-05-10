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
        let backgroundColor = Color(red: 24/255, green: 26/255, blue: 32/255) // #181A20
        let cardColor = Color(red: 35/255, green: 39/255, blue: 47/255) // #23272F
        let textPrimary = Color(red: 224/255, green: 224/255, blue: 224/255) // #E0E0E0
        let textSecondary = Color(red: 170/255, green: 170/255, blue: 180/255) // #AAAAAA
        VStack(spacing: 0) {
            // 1. List view at the top
            ZStack {
                if dateRangeManager.dateRanges.isEmpty {
                    VStack {
                        Spacer()
                        Text("No date ranges yet")
                            .foregroundColor(textSecondary)
                            .font(.headline)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(dateRangeManager.dateRanges) { range in
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(cardColor)
                                    .shadow(color: Color.black.opacity(0.10), radius: 3, x: 0, y: 1)
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(dateFormatter.string(from: range.startDate)) - \(dateFormatter.string(from: range.endDate))")
                                            .font(.subheadline)
                                            .foregroundColor(textPrimary)
                                        Text(range.description)
                                            .font(.caption)
                                            .foregroundColor(Color.blue.opacity(0.7))
                                    }
                                    Spacer(minLength: 8)
                                    Text("\(range.numberOfDays) days")
                                        .font(.caption)
                                        .foregroundColor(textSecondary)
                                    Text(range.isInclusive ? "Inclusive" : "Exclusive")
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(range.isInclusive ? Color.green.opacity(0.18) : Color.red.opacity(0.18))
                                        .foregroundColor(range.isInclusive ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                                        .cornerRadius(6)
                                }
                                .padding(10)
                                .opacity(range.ignore ? 0.4 : 1.0)
                            }
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
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
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: .infinity)
                    .background(backgroundColor)
                }
            }
            .background(backgroundColor)
            .cornerRadius(18)
            .padding(.top, 8)
            .padding(.horizontal, 4)
            
            // 2. Add new date range form fixed at the bottom
            VStack(spacing: 10) {
                // Total days section moved here, right above the form
                HStack(spacing: 8) {
                    Label { Text("\(dateRangeManager.totalIncludedDays)").bold().foregroundColor(textPrimary) } icon: { Text("Included").foregroundColor(textSecondary) }
                        .labelStyle(VerticalLabelStyle())
                    Divider().frame(height: 24)
                    Label { Text("\(dateRangeManager.totalExcludedDays)").bold().foregroundColor(textPrimary) } icon: { Text("Excluded").foregroundColor(textSecondary) }
                        .labelStyle(VerticalLabelStyle())
                    Divider().frame(height: 24)
                    Label { Text("\(dateRangeManager.totalDays)").bold().foregroundColor(textPrimary) } icon: { Text("Final").foregroundColor(textSecondary) }
                        .labelStyle(VerticalLabelStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(cardColor.opacity(0.85))
                .cornerRadius(10)
                .padding(.horizontal, 2)
                
                VStack(spacing: 8) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(6)
                        .background(cardColor.opacity(0.9))
                        .cornerRadius(8)
                        .foregroundColor(textPrimary)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(6)
                        .background(cardColor.opacity(0.9))
                        .cornerRadius(8)
                        .foregroundColor(textPrimary)
                    Toggle("Include Dates", isOn: $isInclusive)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                        .padding(.horizontal, 6)
                        .foregroundColor(textPrimary)
                    TextField("Description", text: $description)
                        .padding(6)
                        .background(cardColor.opacity(0.9))
                        .cornerRadius(8)
                        .foregroundColor(textPrimary)
                    if endDate <= startDate {
                        Text("End date must be after start date.")
                            .foregroundColor(.red.opacity(0.8))
                            .font(.caption2)
                    }
                    Button(action: addDateRange) {
                        Text("Add")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.green.opacity(0.85))
                            .foregroundColor(backgroundColor)
                            .cornerRadius(10)
                            .shadow(color: Color.green.opacity(0.10), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(endDate <= startDate)
                }
                .padding(.horizontal, 2)
            }
            .padding(.top, 6)
            .padding(.bottom, 6)
            .background(cardColor.opacity(0.95))
            .cornerRadius(18)
            .shadow(radius: 4)
            .padding(.horizontal, 4)
        }
        .background(backgroundColor.ignoresSafeArea())
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
                            .font(.caption2)
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
