class RolePolicyJoin < Iam::ApplicationRecord
  belongs_to :role
  belongs_to :policy
end
