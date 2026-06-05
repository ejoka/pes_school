module Admin
  class GoalsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_goal_permission!
    before_action :set_goal, only: [:show, :edit, :update, :destroy, :add_progress]

    def index
      @goals = if current_user.admin?
                 Goal.all.order(created_at: :desc)
               else
                 Goal.accessible_by(current_user).order(created_at: :desc)
               end
      
      # Statistics
      @total_goals = @goals.count
      @completed_goals = @goals.where(status: 'completed').count
      @in_progress_goals = @goals.where(status: 'in_progress').count
      @overdue_goals = @goals.select(&:is_overdue?).count
    end

    def show
      @tasks = @goal.tasks.includes(:user).order(due_date: :asc)
      @progress_records = @goal.goal_progresses.includes(:user).order(recorded_at: :desc)
    end

    def new
      @goal = Goal.new
      @professional_types = User.distinct.pluck(:professional_type).compact
    end

    def create
      @goal = Goal.new(goal_params)
      @goal.user_id = current_user.id
      @goal.progress = 0
      @goal.status = 'not_started'
      
      if @goal.save
        # Create notification for all users of the professional type
        User.where(professional_type: @goal.professional_type).each do |user|
          Notification.create(
            user: user,
            title: "New Goal Created",
            message: "A new goal '#{@goal.title}' has been created for #{@goal.professional_type.pluralize}",
            actionable: @goal,
            read: false
          )
        end
        redirect_to admin_goals_path, notice: 'Goal was successfully created.'
      else
        @professional_types = User.distinct.pluck(:professional_type).compact
        render :new
      end
    end

    def edit
      @professional_types = User.distinct.pluck(:professional_type).compact
    end

    def update
      if @goal.update(goal_params)
        redirect_to admin_goals_path, notice: 'Goal was successfully updated.'
      else
        @professional_types = User.distinct.pluck(:professional_type).compact
        render :edit
      end
    end

    def destroy
      @goal.destroy
      redirect_to admin_goals_path, notice: 'Goal was successfully deleted.'
    end

    def add_progress
      @goal.goal_progresses.create(
        user_id: current_user.id,
        comment: params[:comment],
        progress_percentage: params[:progress_percentage],
        recorded_at: Time.current
      )
      @goal.update(progress: params[:progress_percentage])
      redirect_to admin_goal_path(@goal), notice: 'Progress was updated.'
    end

    private

    def ensure_goal_permission!
      unless current_user.admin? || current_user.can_manage_goals?(:view)
        redirect_to dashboard_path, alert: 'You do not have permission to access goals.'
      end
    end

    def set_goal
      @goal = Goal.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_goals_path, alert: 'Goal not found.'
    end

    def goal_params
      params.require(:goal).permit(:title, :description, :professional_type, :start_date, :end_date, :priority)
    end
  end
end