# frozen_string_literal: true

class UserRepository
  # @returns User
  def self.find_for_jwt_authentication(sub)
    binding.pry
    Repo.find_user_by_id(sub)
  end
end
