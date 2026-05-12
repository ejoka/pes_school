# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Create admin user
# admin = User.create!(
#   email: "emmanuel@pes.ac.tz",
#   password: "password123",
#   password_confirmation: "password123",
#   first_name: "Emmanuel",
#   last_name: "Kamala",
#   title: "Mr.",
#   phone_number: "+255678794479",
#   role: 1
# )

# Create categories
# categories = [
#   { name: "Primary School" },
#   { name: "Middle School" },
#   { name: "High School" }
# ]

# categories.each do |category|
#   Category.create!(category)
# end

# # Create classes
# primary = Category.find_by(name: "Primary School")
# middle = Category.find_by(name: "Middle School")
# high = Category.find_by(name: "High School")

# classes = [
#   { name: "Grade 1", pass_mark: 50, category: primary },
#   { name: "Grade 2", pass_mark: 50, category: primary },
#   { name: "Grade 3", pass_mark: 50, category: primary },
#   { name: "Grade 7", pass_mark: 60, category: middle },
#   { name: "Grade 8", pass_mark: 60, category: middle },
#   { name: "Grade 9", pass_mark: 60, category: middle },
#   { name: "Grade 10", pass_mark: 70, category: high }
# ]

# classes.each do |school_class|
#   SchoolClass.create!(school_class)
# end

# # Create subjects
# math = Subject.create!(name: "Mathematics", subject_code: "MATH101", pass_mark: 50, school_class: SchoolClass.first)
# english = Subject.create!(name: "English", subject_code: "ENG101", pass_mark: 50, school_class: SchoolClass.first)
# science = Subject.create!(name: "Science", subject_code: "SCI101", pass_mark: 50, school_class: SchoolClass.first)

# puts "Seed data created successfully!"
# puts "Admin login: admin@school.com / password123"

# Seed Exam Types
exam_types = [
  { name: 'Mid-term Exam', average_pass_mark: 50, description: 'Examination conducted in the middle of the academic term' },
  { name: 'Final Exam', average_pass_mark: 50, description: 'End of term/year comprehensive examination' },
  { name: 'Quiz', average_pass_mark: 40, description: 'Short assessment test' },
  { name: 'Assignment', average_pass_mark: 60, description: 'Take-home or in-class assignment' },
  { name: 'Project', average_pass_mark: 70, description: 'Long-term research or practical project' },
  { name: 'Practical Exam', average_pass_mark: 65, description: 'Hands-on practical assessment' }
]

exam_types.each do |type|
  ExamType.find_or_create_by(name: type[:name]) do |et|
    et.average_pass_mark = type[:average_pass_mark]
    et.description = type[:description]
  end
end

puts "Exam types seeded successfully!"