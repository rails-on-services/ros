# frozen_string_literal: true

class ConfirmationsController < Devise::ConfirmationsController
  skip_before_action :authenticate_it!
  respond_to :json

  # GET /users/confirmation?confirmation_token=abcdef
  def show
    self.resource = User.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      render_success!
    else
      render_error!
    end
  end

  private

  def render_error!
    render json: { errors: resource.errors.messages }
  end

  def render_success!
    render json: { status: :ok }
  end
end
