class Admin::SubjectsController < ApplicationController
  before_action :ensure_admin_or_permitted!
  before_action :set_subject, only: [:show, :edit, :update, :destroy]

  def index
    @subjects = if current_user.admin?
                  Subject.all.includes(:school_class).order(created_at: :desc)
                else
                  Subject.accessible_by(current_user).includes(:school_class)
                end
  end

  def show
    unless @subject
      redirect_to admin_subjects_path, alert: 'Subject not found.'
      return
    end
    
    unless current_user.can_access?(@subject, :view)
      redirect_to admin_subjects_path, alert: 'You do not have permission to view this subject.'
    end
  end

  def new
    @subject = Subject.new
    @school_classes = SchoolClass.all
  end

  def create
    @subject = Subject.new(subject_params)
    if @subject.save
      redirect_to admin_subjects_path, notice: 'Subject was successfully created.'
    else
      @school_classes = SchoolClass.all
      render :new
    end
  end

  def edit
    unless @subject && current_user.can_access?(@subject, :edit)
      redirect_to admin_subjects_path, alert: 'You do not have permission to edit this subject.'
    end
    @school_classes = SchoolClass.all
  end

  def update
    if @subject && current_user.can_access?(@subject, :edit)
      if @subject.update(subject_params)
        redirect_to admin_subjects_path, notice: 'Subject was successfully updated.'
      else
        @school_classes = SchoolClass.all
        render :edit
      end
    else
      redirect_to admin_subjects_path, alert: 'You do not have permission to update this subject.'
    end
  end

  def destroy
    if @subject && current_user.can_access?(@subject, :delete)
      @subject.destroy
      redirect_to admin_subjects_path, notice: 'Subject was successfully deleted.'
    else
      redirect_to admin_subjects_path, alert: 'You do not have permission to delete this subject.'
    end
  end

  private

  def set_subject
    @subject = Subject.find_by(id: params[:id])
  rescue ActiveRecord::RecordNotFound
    @subject = nil
  end

  def subject_params
    params.require(:subject).permit(:name, :subject_code, :pass_mark, :school_class_id)
  end

  def ensure_admin_or_permitted!
    unless current_user.admin? || current_user.user_resources.exists?(resource_type: 'Subject')
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end