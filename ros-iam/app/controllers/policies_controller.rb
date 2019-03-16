# frozen_string_literal: true

class PoliciesController < Iam::ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_it!
end

