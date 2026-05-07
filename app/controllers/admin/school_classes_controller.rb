class Admin::SchoolClassesController < ApplicationController
  before_action :ensure_admin_or_permitted!
  before_action :set_school_class, only: [:show, :edit, :update, :destroy]

  def index
    @school_classes = if current_user.admin?
                        SchoolClass.all.includes(:category).order(created_at: :desc)
                      else
                        SchoolClass.accessible_by(current_user).includes(:category)
                      end
  end

  def show
    unless @school_class
      redirect_to admin_school_classes_path, alert: 'Class not found.'
      return
    end
    
    unless current_user.can_access?(@school_class, :view)
      redirect_to admin_school_classes_path, alert: 'You do not have permission to view this class.'
    end
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
    unless @school_class && current_user.can_access?(@school_class, :edit)
      redirect_to admin_school_classes_path, alert: 'You do not have permission to edit this class.'
    end
    @categories = Category.all
  end

  def update
    if @school_class && current_user.can_access?(@school_class, :edit)
      if @school_class.update(school_class_params)
        redirect_to admin_school_classes_path, notice: 'Class was successfully updated.'
      else
        @categories = Category.all
        render :edit
      end
    else
      redirect_to admin_school_classes_path, alert: 'You do not have permission to update this class.'
    end
  end

  def destroy
    if @school_class && current_user.can_access?(@school_class, :delete)
      @school_class.destroy
      redirect_to admin_school_classes_path, notice: 'Class was successfully deleted.'
    else
      redirect_to admin_school_classes_path, alert: 'You do not have permission to delete this class.'
    end
  end

  private

  def set_school_class
    @school_class = SchoolClass.find_by(id: params[:id])
  rescue ActiveRecord::RecordNotFound
    @school_class = nil
  end

  def school_class_params
    params.require(:school_class).permit(:name, :pass_mark, :category_id)
  end

  def ensure_admin_or_permitted!
    unless current_user.admin? || current_user.user_resources.exists?(resource_type: 'SchoolClass')
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end