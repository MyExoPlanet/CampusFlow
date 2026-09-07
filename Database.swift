import Foundation
import SQLite

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private var db: Connection?
    
    // MARK: - Subjects
    
    private let subjects = Table("subjects")
    
    private let subjectID = Expression<Int64>("id")
    private let subjectName = Expression<String>("name")
    private let subjectCode = Expression<String>("code")
    private let teacher = Expression<String>("teacher")
    private let credits = Expression<Int>("credits")
    
    // MARK: - Assignments
    
    private let assignments = Table("assignments")
    
    private let assignmentID = Expression<Int64>("id")
    private let assignmentSubjectID = Expression<Int64>("subject_id")
    private let assignmentTitle = Expression<String>("title")
    private let assignmentDescription = Expression<String>("description")
    private let dueDate = Expression<String>("due_date")
    private let priority = Expression<String>("priority")
    private let assignmentStatus = Expression<String>("status")
    
    // MARK: - Exams
    
    private let exams = Table("exams")
    
    private let examID = Expression<Int64>("id")
    private let examSubjectID = Expression<Int64>("subject_id")
    private let examTitle = Expression<String>("title")
    private let examDate = Expression<String>("exam_date")
    private let examType = Expression<String>("exam_type")
    
    // MARK: - Tasks
    
    private let tasks = Table("tasks")
    
    private let taskID = Expression<Int64>("id")
    private let taskTitle = Expression<String>("title")
    private let taskDescription = Expression<String>("description")
    private let taskDueDate = Expression<String>("due_date")
    private let taskPriority = Expression<String>("priority")
    private let taskStatus = Expression<String>("status")
    
    // MARK: - Database Connection
    
    private init() {
        do {
            let documentsDirectory = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )[0]
            
            let databaseURL = documentsDirectory.appendingPathComponent(
                "campusflow.sqlite3"
            )
            
            db = try Connection(databaseURL.path)
            
            try createTables()
            
            print("Database connected successfully!")
            
        } catch {
            print("Database connection failed: \(error)")
        }
    }
    
    // MARK: - Create Tables
    
    private func createTables() throws {
        
        guard let db = db else {
            return
        }
        
        try db.run(subjects.create(ifNotExists: true) { table in
            table.column(subjectID, primaryKey: .autoincrement)
            table.column(subjectName)
            table.column(subjectCode)
            table.column(teacher)
            table.column(credits)
        })
        
        try db.run(assignments.create(ifNotExists: true) { table in
            table.column(assignmentID, primaryKey: .autoincrement)
            table.column(assignmentSubjectID)
            table.column(assignmentTitle)
            table.column(assignmentDescription)
            table.column(dueDate)
            table.column(priority)
            table.column(assignmentStatus)
            
            table.foreignKey(
                assignmentSubjectID,
                references: subjects,
                subjectID
            )
        })
        
        try db.run(exams.create(ifNotExists: true) { table in
            table.column(examID, primaryKey: .autoincrement)
            table.column(examSubjectID)
            table.column(examTitle)
            table.column(examDate)
            table.column(examType)
            
            table.foreignKey(
                examSubjectID,
                references: subjects,
                subjectID
            )
        })
        
        try db.run(tasks.create(ifNotExists: true) { table in
            table.column(taskID, primaryKey: .autoincrement)
            table.column(taskTitle)
            table.column(taskDescription)
            table.column(taskDueDate)
            table.column(taskPriority)
            table.column(taskStatus)
        })
    }
}
