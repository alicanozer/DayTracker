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
    
    // Color and font constants
    static let appBackground = Color(red: 235/255, green: 240/255, blue: 250/255)
    static let cardColor = Color.white
    static let textPrimary = Color(red: 30/255, green: 40/255, blue: 60/255)
    static let textSecondary = Color(red: 120/255, green: 130/255, blue: 150/255)
    static let accentBlue = Color(red: 80/255, green: 130/255, blue: 255/255)
    static let accentGreen = Color(red: 60/255, green: 180/255, blue: 120/255)
    static let accentRed = Color(red: 220/255, green: 80/255, blue: 80/255)
    static let monoFontName = "Menlo"
    static let monoFont = Font.custom(monoFontName, size: 15)
    
    var body: some View {
        VStack(spacing: 0) {
            mainListSection
            summaryAndAddButtonSection
        }
        .background(Self.appBackground.ignoresSafeArea())
        .sheet(isPresented: $showAddSheet) {
            addDateSheet
        }
        .sheet(item: $editingRange) { range in
            VStack(spacing: 16) {
                Text("Edit Date Range")
                    .font(.custom(Self.monoFontName, size: 22).weight(.bold))
                    .kerning(-0.8)
                    .foregroundColor(Self.textPrimary)
                    .padding(.top, 8)
                VStack(spacing: 8) {
                    DatePicker("Start Date", selection: $editStartDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(8)
                        .background(Self.cardColor)
                        .cornerRadius(8)
                        .foregroundColor(Self.textPrimary)
                        .font(.custom(Self.monoFontName, size: 15))
                        .kerning(-0.8)
                    DatePicker("End Date", selection: $editEndDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(8)
                        .background(Self.cardColor)
                        .cornerRadius(8)
                        .foregroundColor(Self.textPrimary)
                        .font(.custom(Self.monoFontName, size: 15))
                        .kerning(-0.8)
                    Toggle("Include Dates", isOn: $editIsInclusive)
                        .toggleStyle(SwitchToggleStyle(tint: Self.accentGreen))
                        .padding(.horizontal, 8)
                        .foregroundColor(Self.textPrimary)
                        .font(.custom(Self.monoFontName, size: 15))
                        .kerning(-0.8)
                    TextField("Description", text: $editDescription)
                        .padding(8)
                        .background(Self.cardColor)
                        .cornerRadius(8)
                        .foregroundColor(Self.textPrimary)
                        .font(.custom(Self.monoFontName, size: 15))
                        .kerning(-0.8)
                    if editEndDate <= editStartDate {
                        Text("End date must be after start date.")
                            .foregroundColor(Self.accentRed)
                            .font(.custom(Self.monoFontName, size: 15))
                            .kerning(-0.8)
                    }
                    Button(action: {
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
                    }) {
                        Text("Save")
                            .font(.custom(Self.monoFontName, size: 15).weight(.semibold))
                            .kerning(-0.8)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Self.accentBlue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: Self.accentBlue.opacity(0.10), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(editEndDate <= editStartDate)
                }
                .padding(.horizontal, 2)
                Spacer()
            }
            .padding()
            .background(Self.appBackground.ignoresSafeArea())
        }
        .navigationTitle("Date Tracker")
    }
    
    private var mainListSection: some View {
        ZStack {
            if dateRangeManager.dateRanges.isEmpty {
                VStack {
                    Spacer()
                    Text("No dates yet")
                        .foregroundColor(Self.textSecondary)
                        .font(.custom(Self.monoFontName, size: 17).weight(.bold))
                    Spacer()
                }
            } else {
                List {
                    ForEach(dateRangeManager.dateRanges) { range in
                        dateRangeRow(range)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(maxHeight: .infinity)
                .background(Self.appBackground)
                .padding(.horizontal, 2)
            }
        }
        .background(Self.appBackground)
        .cornerRadius(2)
        .padding(.top, 8)
    }
    
    private func dateRangeRow(_ range: DateRange) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Self.cardColor)
                .shadow(color: Self.accentBlue.opacity(0.07), radius: 4, x: 0, y: 2)
            HStack(spacing: 2) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(dateFormatter.string(from: range.startDate)) - \(dateFormatter.string(from: range.endDate))")
                        .font(.custom(Self.monoFontName, size: 15).weight(.semibold))
                        .kerning(-0.8)
                        .foregroundColor(Self.textPrimary)
                    Text(range.description)
                        .font(.custom(Self.monoFontName, size: 15))
                        .kerning(-0.8)
                        .foregroundColor(Self.accentBlue)
                }
                Spacer(minLength: 2)
                Text("\(range.numberOfDays) days")
                    .font(.custom(Self.monoFontName, size: 15).weight(.semibold))
                    .kerning(-0.8)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(range.isInclusive ? Self.accentGreen.opacity(0.18) : Self.accentRed.opacity(0.18))
                    .foregroundColor(range.isInclusive ? Self.accentGreen : Self.accentRed)
                    .cornerRadius(12)
                    .frame(minWidth: 120)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .opacity(range.ignore ? 0.4 : 1.0)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
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
            .tint(Self.accentBlue)
            
            Button(role: .destructive) {
                if let index = dateRangeManager.dateRanges.firstIndex(where: { $0.id == range.id }) {
                    deleteDateRange(at: IndexSet(integer: index))
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(Self.accentRed)
            
            Button {
                dateRangeManager.toggleIgnore(id: range.id)
            } label: {
                Label(range.ignore ? "Include" : "Ignore", systemImage: range.ignore ? "eye" : "eye.slash")
            }
            .tint(.gray)
        }
    }
    
    private var summaryAndAddButtonSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Label { Text("\(dateRangeManager.totalIncludedDays)").bold().foregroundColor(Self.textPrimary).font(.custom(Self.monoFontName, size: 15)).kerning(-0.8) } icon: { Text("Included").foregroundColor(Self.textSecondary).font(.custom(Self.monoFontName, size: 15)).kerning(-0.8) }
                    .labelStyle(VerticalLabelStyle())
                Divider().frame(height: 24)
                Label { Text("\(dateRangeManager.totalExcludedDays)").bold().foregroundColor(Self.textPrimary).font(.custom(Self.monoFontName, size: 15)).kerning(-0.8) } icon: { Text("Excluded").foregroundColor(Self.textSecondary).font(.custom(Self.monoFontName, size: 15)).kerning(-0.8) }
                    .labelStyle(VerticalLabelStyle())
                Divider().frame(height: 24)
                Label { Text("\(dateRangeManager.totalDays)").bold().foregroundColor(Self.textPrimary).font(.custom(Self.monoFontName, size: 15)).kerning(-0.8) } icon: { Text("Final").foregroundColor(Self.textSecondary).font(.custom(Self.monoFontName, size: 15)).kerning(-0.8) }
                    .labelStyle(VerticalLabelStyle())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Self.cardColor.opacity(0.95))
            .cornerRadius(10)
            .padding(.horizontal, 2)
            
            Button(action: { showAddSheet = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add New Range")
                        .fontWeight(.medium)
                }
                .font(.custom(Self.monoFontName, size: 15).weight(.semibold))
                .kerning(-0.8)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(Self.accentBlue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Self.accentBlue.opacity(0.10), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 2)
        }
        .padding(.top, 6)
        .padding(.bottom, 6)
        .background(Self.cardColor.opacity(0.98))
        .cornerRadius(18)
        .shadow(radius: 4)
        .padding(.horizontal, 4)
    }
    
    private var addDateSheet: some View {
        VStack(spacing: 16) {
            Text("Add New Dates")
                .font(.custom(Self.monoFontName, size: 22).weight(.bold))
                .kerning(-0.8)
                .foregroundColor(Self.textPrimary)
                .padding(.top, 8)
            VStack(spacing: 8) {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(8)
                    .background(Self.cardColor)
                    .cornerRadius(8)
                    .foregroundColor(Self.textPrimary)
                    .font(.custom(Self.monoFontName, size: 15))
                    .kerning(-0.8)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(8)
                    .background(Self.cardColor)
                    .cornerRadius(8)
                    .foregroundColor(Self.textPrimary)
                    .font(.custom(Self.monoFontName, size: 15))
                    .kerning(-0.8)
                Toggle("Include Dates", isOn: $isInclusive)
                    .toggleStyle(SwitchToggleStyle(tint: Self.accentGreen))
                    .padding(.horizontal, 8)
                    .foregroundColor(Self.textPrimary)
                    .font(.custom(Self.monoFontName, size: 15))
                    .kerning(-0.8)
                TextField("Description", text: $description)
                    .padding(8)
                    .background(Self.cardColor)
                    .cornerRadius(8)
                    .foregroundColor(Self.textPrimary)
                    .font(.custom(Self.monoFontName, size: 15))
                    .kerning(-0.8)
                if endDate <= startDate {
                    Text("End date must be after start date.")
                        .foregroundColor(Self.accentRed)
                        .font(.custom(Self.monoFontName, size: 15))
                        .kerning(-0.8)
                }
                Button(action: {
                    addDateRange()
                    showAddSheet = false
                }) {
                    Text("Add")
                        .font(.custom(Self.monoFontName, size: 15).weight(.semibold))
                        .kerning(-0.8)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Self.accentGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Self.accentGreen.opacity(0.10), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(.plain)
                .disabled(endDate <= startDate)
            }
            .padding(.horizontal, 2)
            Spacer()
        }
        .padding()
        .background(Self.appBackground.ignoresSafeArea())
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
