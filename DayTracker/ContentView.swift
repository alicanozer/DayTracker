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
    @State private var showAddSheet = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        let appBackground = Color(red: 235/255, green: 240/255, blue: 250/255) // soft blue-gray
        let cardColor = Color.white
        let textPrimary = Color(red: 30/255, green: 40/255, blue: 60/255) // dark blue
        let textSecondary = Color(red: 120/255, green: 130/255, blue: 150/255) // soft gray-blue
        let accentBlue = Color(red: 80/255, green: 130/255, blue: 255/255)
        let accentGreen = Color(red: 60/255, green: 180/255, blue: 120/255)
        let accentRed = Color(red: 220/255, green: 80/255, blue: 80/255)
        let serifFont = Font.custom("Georgia", size: 17)
        VStack(spacing: 0) {
            // 1. List view at the top
            ZStack {
                if dateRangeManager.dateRanges.isEmpty {
                    VStack {
                        Spacer()
                        Text("No date ranges yet")
                            .foregroundColor(textSecondary)
                            .font(serifFont.weight(.bold))
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(dateRangeManager.dateRanges) { range in
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(cardColor)
                                    .shadow(color: accentBlue.opacity(0.07), radius: 4, x: 0, y: 2)
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(dateFormatter.string(from: range.startDate)) - \(dateFormatter.string(from: range.endDate))")
                                            .font(serifFont.weight(.semibold))
                                            .foregroundColor(textPrimary)
                                        Text(range.description)
                                            .font(serifFont.italic().weight(.regular).size(15))
                                            .foregroundColor(accentBlue)
                                    }
                                    Spacer(minLength: 8)
                                    Text("\(range.numberOfDays) days")
                                        .font(serifFont.size(15))
                                        .foregroundColor(textSecondary)
                                    Text(range.isInclusive ? "Inclusive" : "Exclusive")
                                        .font(serifFont.size(14).weight(.semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(range.isInclusive ? accentGreen.opacity(0.15) : accentRed.opacity(0.15))
                                        .foregroundColor(range.isInclusive ? accentGreen : accentRed)
                                        .cornerRadius(8)
                                }
                                .padding(14)
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
                                .tint(accentBlue)
                                
                                Button(role: .destructive) {
                                    if let index = dateRangeManager.dateRanges.firstIndex(where: { $0.id == range.id }) {
                                        deleteDateRange(at: IndexSet(integer: index))
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(accentRed)
                                
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
                    .background(appBackground)
                }
            }
            .background(appBackground)
            .cornerRadius(18)
            .padding(.top, 8)
            .padding(.horizontal, 4)
            
            // 2. Total days and add button
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Label { Text("\(dateRangeManager.totalIncludedDays)").bold().foregroundColor(textPrimary).font(serifFont) } icon: { Text("Included").foregroundColor(textSecondary).font(serifFont.size(14)) }
                        .labelStyle(VerticalLabelStyle())
                    Divider().frame(height: 24)
                    Label { Text("\(dateRangeManager.totalExcludedDays)").bold().foregroundColor(textPrimary).font(serifFont) } icon: { Text("Excluded").foregroundColor(textSecondary).font(serifFont.size(14)) }
                        .labelStyle(VerticalLabelStyle())
                    Divider().frame(height: 24)
                    Label { Text("\(dateRangeManager.totalDays)").bold().foregroundColor(textPrimary).font(serifFont) } icon: { Text("Final").foregroundColor(textSecondary).font(serifFont.size(14)) }
                        .labelStyle(VerticalLabelStyle())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(cardColor.opacity(0.95))
                .cornerRadius(10)
                .padding(.horizontal, 2)
                
                Button(action: { showAddSheet = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add New Range")
                            .fontWeight(.medium)
                    }
                    .font(serifFont.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(accentBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: accentBlue.opacity(0.10), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 2)
            }
            .padding(.top, 6)
            .padding(.bottom, 6)
            .background(cardColor.opacity(0.98))
            .cornerRadius(18)
            .shadow(radius: 4)
            .padding(.horizontal, 4)
        }
        .background(appBackground.ignoresSafeArea())
        .sheet(isPresented: $showAddSheet) {
            VStack(spacing: 16) {
                Text("Add New Date Range")
                    .font(serifFont.weight(.bold).size(22))
                    .foregroundColor(textPrimary)
                    .padding(.top, 8)
                VStack(spacing: 8) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(8)
                        .background(cardColor)
                        .cornerRadius(8)
                        .foregroundColor(textPrimary)
                        .font(serifFont)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(8)
                        .background(cardColor)
                        .cornerRadius(8)
                        .foregroundColor(textPrimary)
                        .font(serifFont)
                    Toggle("Include Dates", isOn: $isInclusive)
                        .toggleStyle(SwitchToggleStyle(tint: accentGreen))
                        .padding(.horizontal, 8)
                        .foregroundColor(textPrimary)
                        .font(serifFont)
                    TextField("Description", text: $description)
                        .padding(8)
                        .background(cardColor)
                        .cornerRadius(8)
                        .foregroundColor(textPrimary)
                        .font(serifFont)
                    if endDate <= startDate {
                        Text("End date must be after start date.")
                            .foregroundColor(accentRed)
                            .font(serifFont.size(14))
                    }
                    Button(action: {
                        addDateRange()
                        showAddSheet = false
                    }) {
                        Text("Add")
                            .font(serifFont.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(accentGreen)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: accentGreen.opacity(0.10), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(endDate <= startDate)
                }
                .padding(.horizontal, 2)
                Spacer()
            }
            .padding()
            .background(appBackground.ignoresSafeArea())
        }
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
