import SwiftUI

struct ContentView: View {
    
    @State private var subjects: [Subject] = []
    @State private var showingAddSubject = false
    
    var body: some View {
        NavigationStack {
            List {
                if subjects.isEmpty {
                    ContentUnavailableView(
                        "No Subjects",
                        systemImage: "book.closed",
                        description: Text("Add your first subject to get started.")
                    )
                } else {
                    ForEach(subjects) { subject in
                        NavigationLink {
                            EditSubjectView(
                                subject: subject,
                                onSave: {
                                    loadSubjects()
                                }
                            )
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(subject.name)
                                    .font(.headline)
                                
                                Text("\(subject.code) • \(subject.credits) credits")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Text(subject.teacher)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteSubject)
                }
            }
            .navigationTitle("Subjects")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSubject = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSubject) {
                AddSubjectView {
                    loadSubjects()
                }
            }
            .onAppear {
                loadSubjects()
            }
        }
    }
    
    private func loadSubjects() {
        do {
            subjects = try DatabaseManager.shared.fetchSubjects()
        } catch {
            print("Failed to load subjects: \(error)")
        }
    }
    
    private func deleteSubject(at offsets: IndexSet) {
        for index in offsets {
            let subject = subjects[index]
            
            do {
                try DatabaseManager.shared.deleteSubject(id: subject.id)
            } catch {
                print("Failed to delete subject: \(error)")
            }
        }
        
        loadSubjects()
    }
}

struct AddSubjectView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var code = ""
    @State private var teacher = ""
    @State private var credits = 4
    
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Subject Details") {
                    TextField("Subject Name", text: $name)
                    TextField("Subject Code", text: $code)
                    TextField("Teacher", text: $teacher)
                    
                    Stepper(
                        "Credits: \(credits)",
                        value: $credits,
                        in: 1...10
                    )
                }
            }
            .navigationTitle("Add Subject")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSubject()
                    }
                    .disabled(
                        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
        }
    }
    
    private func saveSubject() {
        do {
            _ = try DatabaseManager.shared.createSubject(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                code: code.trimmingCharacters(in: .whitespacesAndNewlines),
                teacher: teacher.trimmingCharacters(in: .whitespacesAndNewlines),
                credits: credits
            )
            
            onSave()
            dismiss()
            
        } catch {
            print("Failed to save subject: \(error)")
        }
    }
    
}
struct EditSubjectView: View {
    @Environment(\.dismiss) private var dismiss
    
    let subject: Subject
    let onSave: () -> Void
    
    @State private var name: String
    @State private var code: String
    @State private var teacher: String
    @State private var credits: Int
    
    init(subject: Subject, onSave: @escaping () -> Void) {
        self.subject = subject
        self.onSave = onSave
        
        _name = State(initialValue: subject.name)
        _code = State(initialValue: subject.code)
        _teacher = State(initialValue: subject.teacher)
        _credits = State(initialValue: subject.credits)
    }
    
    var body: some View {
        Form {
            Section("Subject Details") {
                TextField("Subject Name", text: $name)
                TextField("Subject Code", text: $code)
                TextField("Teacher", text: $teacher)
                
                Stepper(
                    "Credits: \(credits)",
                    value: $credits,
                    in: 1...10
                )
            }
        }
        .navigationTitle("Edit Subject")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(
                    name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
        }
    }
    
    private func saveChanges() {
        do {
            try DatabaseManager.shared.updateSubject(
                id: subject.id,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                code: code.trimmingCharacters(in: .whitespacesAndNewlines),
                teacher: teacher.trimmingCharacters(in: .whitespacesAndNewlines),
                credits: credits
            )
            
            onSave()
            dismiss()
        } catch {
            print("Failed to update subject: \(error)")
        }
    }
}
