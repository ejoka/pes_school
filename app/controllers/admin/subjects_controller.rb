class Admin::SubjectsController < ApplicationController
  before_action :ensure_admin!
  before_action :set_subject, only: [:edit, :update, :destroy]

  def index
    @subjects = Subject.all.includes(:school_class).order(created_at: :desc)
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
    @school_classes = SchoolClass.all
  end

  def update
    if @subject.update(subject_params)
      redirect_to admin_subjects_path, notice: 'Subject was successfully updated.'
    else
      @school_classes = SchoolClass.all
      render :edit
    end
  end

  def destroy
    @subject.destroy
    redirect_to admin_subjects_path, notice: 'Subject was successfully deleted.'
  end

  private

  def set_subject
    @subject = Subject.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name, :subject_code, :pass_mark, :school_class_id)
  end

  def ensure_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end
end