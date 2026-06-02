class StaffAttendanceSummary < ApplicationRecord
  belongs_to :staff_assignment
  
  validates :month, presence: true, inclusion: { in: 1..12 }
  validates :year, presence: true
  validates :staff_assignment_id, uniqueness: { scope: [:month, :year], message: "already has summary for this period" }
  
  def self.generate_for_month(staff_assignment, date)
    month = date.month
    year = date.year
    records = staff_assignment.staff_attendance_records.for_month(date)
    
    summary = find_or_initialize_by(
      staff_assignment: staff_assignment,
      month: month,
      year: year
    )
    
    summary.update(
      total_present: records.present.count,
      total_absent: records.absent.count,
      total_late: records.late.count,
      total_leave: records.leave.count,
      attendance_percentage: records.count > 0 ? (records.present.count.to_f / records.count * 100).round(2) : 0
    )
    
    summary
  end
end