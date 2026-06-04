class NotificationsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @notifications = current_user.notifications.order(created_at: :desc)
    @unread_count = current_user.notifications.unread.count
  end
  
  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!
    
    respond_to do |format|
      format.html { redirect_to notifications_path, notice: 'Notification marked as read.' }
      format.json { render json: { success: true, unread_count: current_user.notifications.unread.count } }
    end
  end
  
  def mark_all_as_read
    Notification.mark_all_as_read(current_user)
    
    respond_to do |format|
      format.html { redirect_to notifications_path, notice: 'All notifications marked as read.' }
      format.json { render json: { success: true, unread_count: 0 } }
    end
  end
  
  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy
    
    respond_to do |format|
      format.html { redirect_to notifications_path, notice: 'Notification deleted.' }
      format.json { render json: { success: true } }
    end
  end
end