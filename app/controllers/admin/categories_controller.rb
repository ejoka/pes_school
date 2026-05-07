class Admin::CategoriesController < ApplicationController
  before_action :ensure_admin_or_permitted!
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = if current_user.admin?
                    Category.all.includes(:school_classes).order(created_at: :desc)
                  else
                    Category.accessible_by(current_user).includes(:school_classes)
                  end
  end

  def show
    unless @category
      redirect_to admin_categories_path, alert: 'Category not found.'
      return
    end
    
    unless current_user.can_access?(@category, :view)
      redirect_to admin_categories_path, alert: 'You do not have permission to view this category.'
    end
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_categories_path, notice: 'Category was successfully created.'
    else
      render :new
    end
  end

  def edit
    unless @category && current_user.can_access?(@category, :edit)
      redirect_to admin_categories_path, alert: 'You do not have permission to edit this category.'
    end
  end

  def update
    if @category && current_user.can_access?(@category, :edit)
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: 'Category was successfully updated.'
      else
        render :edit
      end
    else
      redirect_to admin_categories_path, alert: 'You do not have permission to update this category.'
    end
  end

  def destroy
    if @category && current_user.can_access?(@category, :delete)
      @category.destroy
      redirect_to admin_categories_path, notice: 'Category was successfully deleted.'
    else
      redirect_to admin_categories_path, alert: 'You do not have permission to delete this category.'
    end
  end

  private

  def set_category
    @category = Category.find_by(id: params[:id])
  rescue ActiveRecord::RecordNotFound
    @category = nil
  end

  def category_params
    params.require(:category).permit(:name)
  end

  def ensure_admin_or_permitted!
    unless current_user.admin? || current_user.user_resources.exists?(resource_type: 'Category')
      redirect_to root_path, alert: 'Access denied.'
    end
  end
end