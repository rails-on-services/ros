class User < Cognito::ApplicationRecord
  has_many :user_pools
  has_many :pools, through: :user_pools

  def self.converter_hash
    { title: :salutation, last_name: :last_name, phone_number: :mobile, primary_identifier: :ui, pool_name: :team }
  end

  def self.reset
    UserPool.delete_all
    Pool.delete_all
    User.delete_all
  end

  def self.load_csv(file_name, converter = converter_hash)
    CSV.foreach(file_name, { headers: true, header_converters: :symbol }) do |row|
      pool = Pool.find_or_create_by(name: row[converter[:pool_name]] || 'unknown')
      pool.users.find_or_create_by(primary_identifier: row[converter[:primary_identifier]]).tap do |user|
        user.title = row[converter[:title]]
        user.phone_number = row[converter[:phone_number]]
        user.last_name = row[converter[:last_name]]
        user.save
      end
    end
  end
end
