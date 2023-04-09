# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authorize_user, except: %i[new create waiting approve]
  before_action :unique_user, only: [:new]
  before_action :block_member, except: %i[new create waiting approve update edit]
  before_action :authorize_profile, only: [:edit]
  helper_method :sort_column, :sort_direction
  before_action :set_user, only: %i[show edit update destroy]

  def index
    # Search bar
    @per_page = params[:per_page] || User.per_page || 10
    if params[:search]
      # Able to search for first, last or both (where), Paginate splits table (paginate)
      @users = User.order("#{sort_column} #{sort_direction}").where("CONCAT_WS(' ', first_name, last_name) ILIKE ?", "%#{params[:search].strip.downcase}%").paginate(
        per_page: @per_page, page: params[:page]
      )

      # Display directory based on current status of users
      case params[:category]
      when 'Active'
        @users = @users.where(isActive: true)
      when 'Deactive'
        @users = @users.where(isActive: false, isRequesting: false)
      when 'Approval'
        @users = @users.where(isRequesting: true)
      end

    else
      @users = User.order("#{sort_column} #{sort_direction}").paginate(per_page: @per_page,
                                                                       page: params[:page]).where(isActive: true)
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(new_user_params)
    @user.email = current_admin.email
    @user.password = current_admin.uid
    @user.role = '0'

    # Don't allow duplicate user creation (Unique user per email)
    if User.find_by(email: @user.email)
        redirect_to "/"
    else
      respond_to do |format|
        if @user.save
          @error = false
          format.html { redirect_to(users_path, notice: 'User was successfully created.') }
          format.json { render(:show, status: :created, location: @user) }
        else
          Rails.logger.debug(@user.errors.inspect)
          @error = true
          format.html { render(:new, status: :unprocessable_entity) }
          format.json { render(json: @user.errors, status: :unprocessable_entity) }
        end
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    # This will allow categorization of events by event_type
    @categorize_events = Event.all.group_by(&:event_type)

    # To calculate participation score
    @total_attended = 0
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to(users_path, notice: 'User was successfully updated.') }
        format.json { render(:show, status: :ok, location: @user) }
      else
        format.html { render(:edit, status: :unprocessable_entity) }
        format.json { render(json: @user.errors, status: :unprocessable_entity) }
      end
    end
  end

  def waiting
    # Protects route from non-users
    user = User.find_by(email: current_admin.email)
    if user.nil? 
      redirect_to(controller: 'users', action: 'new')
    else
      if user.isActive
        redirect_to '/'
      end
    end
  end

  def update_multiple
    if params[:user_ids].present?
      User.where(id: params[:user_ids]).update_all(isActive: true,
                                                   isRequesting: false)
    end
    redirect_to users_path
  end

  private

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : 'first_name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :uin, :email, :phone, :password, :classify, :isActive,
                                 :role, event_ids: [])
  end

  # Select only non-default values from new user creation
  def new_user_params
    params.require(:user).permit(:first_name, :last_name, :uin, :phone, :classify)
  end

  # Verify User has created thier profile. Redirect to create profile if not
  def authorize_user
    user = User.find_by(email: current_admin.email)
    if user.nil?
      redirect_to(controller: 'users', action: 'new')
    elsif user.isActive == false
      redirect_to(controller: 'users', action: 'waiting')
      user.isRequesting = true
      user.save
    end
  end

  # Only allow unique users to visit the create profile page
  def unique_user
    redirect_to(controller: 'users', action: 'index') if User.find_by(email: current_admin.email) != nil
  end

  # URL protection: don't allow members to view officer pages/actions
  def block_member
    return unless User.find_by(email: current_admin.email).role.zero?

    redirect_to '/'
  end

  # URL protection: don't allow members to view officer pages/actions
  def authorize_profile
    if User.find_by(email: current_admin.email).role == 0
      id = params[:id]
      if User.find_by(email: current_admin.email).id != id.to_i
        redirect_to "/"
      else
        return
      end
    end
  end
end
