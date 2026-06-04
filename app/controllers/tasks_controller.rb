class TasksController < ApplicationController
  before_action :authenticate_user!
  
  def my_tasks
    @tasks = current_user.my_tasks.order(due_date: :asc)
  end
end