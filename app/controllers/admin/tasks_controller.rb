module Admin
  class TasksController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_goal_permission!
    before_action :set_goal
    before_action :set_task, only: [:edit, :update, :destroy, :complete]

    def new
      @task = @goal.tasks.new
      @users = User.where(professional_type: @goal.professional_type).or(User.where(role: :admin)).order(:first_name)
    end

    def create
      @task = @goal.tasks.new(task_params)
      @task.status = 'pending'
      
      if @task.save
        redirect_to admin_goal_path(@goal), notice: 'Task was successfully created.'
      else
        @users = User.where(professional_type: @goal.professional_type).or(User.where(role: :admin)).order(:first_name)
        render :new
      end
    end

    def edit
      @users = User.where(professional_type: @goal.professional_type).or(User.where(role: :admin)).order(:first_name)
    end

    def update
      if @task.update(task_params)
        redirect_to admin_goal_path(@goal), notice: 'Task was successfully updated.'
      else
        @users = User.where(professional_type: @goal.professional_type).or(User.where(role: :admin)).order(:first_name)
        render :edit
      end
    end

    def destroy
      @task.destroy
      redirect_to admin_goal_path(@goal), notice: 'Task was successfully deleted.'
    end

    def complete
      @task.update(status: 'completed', completed_at: Time.current)
      redirect_to admin_goal_path(@goal), notice: 'Task was marked as completed.'
    end

    private

    def ensure_goal_permission!
      unless current_user.admin? || current_user.can_manage_goals?(:edit)
        redirect_to dashboard_path, alert: 'You do not have permission to manage tasks.'
      end
    end

    def set_goal
      @goal = Goal.find(params[:goal_id])
    end

    def set_task
      @task = @goal.tasks.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title, :description, :user_id, :due_date, :priority)
    end
  end
end