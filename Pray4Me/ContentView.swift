import SwiftUI

struct PrayerRow: Codable, Identifiable {
    let id = UUID()
    var text: String
    var prayedFor: Bool
}

struct ContentView: View {
    @State private var rows: [PrayerRow] = []
    @State private var newRowPrayerRequest: String = ""
    @State private var newRowPrayerPerson: String = ""

    init() {
        if let data = UserDefaults.standard.data(forKey: "rows"),
           let decoded = try? JSONDecoder().decode([PrayerRow].self, from: data) {
            self._rows = State(initialValue: decoded)
        }
    }

    var body: some View {
        VStack {
            TextField("Enter Prayer Request", text: $newRowPrayerRequest)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Enter Person", text: $newRowPrayerPerson)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                let rowText = newRowPrayerRequest +  " - " +  newRowPrayerPerson
                rows.append(PrayerRow(text: rowText, prayedFor: false))
                newRowPrayerRequest = ""
                newRowPrayerPerson = ""
                if let encoded = try? JSONEncoder().encode(rows) {
                    UserDefaults.standard.set(encoded, forKey: "rows")
                }
            }) {
                Text("Add Row")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        
        List {
            ForEach(rows) { row in
                HStack {
                    Toggle(isOn: Binding(
                        get: { row.prayedFor },
                        set: { newValue in
                            if let index = rows.firstIndex(where: { $0.id == row.id }) {
                                rows[index].prayedFor = newValue
                                if let encoded = try? JSONEncoder().encode(rows) {
                                    UserDefaults.standard.set(encoded, forKey: "rows")
                                }
                            }
                        }
                    )) {
                        Text(row.text)
                            .font(.title)
                            .padding()
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            .font(.body)
                    }
                    Spacer()
                    Button(action: {
                        if let index = rows.firstIndex(where: { $0.id == row.id }) {
                            rows.remove(at: index)
                            if let encoded = try? JSONEncoder().encode(rows) {
                                UserDefaults.standard.set(encoded, forKey: "rows")
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

