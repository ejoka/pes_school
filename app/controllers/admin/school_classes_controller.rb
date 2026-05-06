class Admin::SchoolClassesController < ApplicationController
  before_action :ensure_admin!
  before_action :set_school_class, only: [:edit, :update, :destroy]

  def index
    @school_classes = SchoolClass.all.includes(:category).order(created_at: :desc)
  end

  def new
    @school_class = SchoolClass.new
    @categories = Category.all
  end

  def create
    @school_class = SchoolClass.new(school_class_params)
    if @school_class.save
      redirect_to admin_school_classes_path, notice: 'Class was successfully created.'
    else
      @categories = Category.all
      render :new
    end
  end

  def edit
    @categories = Category.all
  end

  def update
    if @school_class.update(school_class_params)
      redirect_to admin_school_classes_path, notice: 'Class was successfully updated.'
    else
      @categories = Category.all
      render :edit
    end
  end

  def destroy
    @school_class.destroy
    redirect_to admin_school_classes_path, notice: 'Class was successfully deleted.'
  end

  private

  def set_school_class
    @school_class = SchoolClass.find(params[:id])
  end

  def school_class_params
    params.require(:school_class).permit(:name, :pass_mark, :category_id)
  end

  def ensure_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end
end