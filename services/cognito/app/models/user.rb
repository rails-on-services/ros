class User < Cognito::ApplicationRecord
  has_many :user_pools
  has_many :pools, through: :user_pools

  def self.converter_hash
    # { title: :salutation, last_name: :last_name, phone_number: :mobile, primary_identifier: :ui, pool_name: :team }
    # { title: :salutation, last_name: :last_name, phone_number: :phone_number, primary_identifier: :ui, pool_name: :campaign }
    { title: :salutation, last_name: :last_name, phone_number: :mobile, primary_identifier: :ui, pool_name: :campaign_id }
  end

  def self.reset
    UserPool.delete_all
    Pool.delete_all
    User.delete_all
  end

  def self.load_csv(file_name, create = false, converter = converter_hash)
    CSV.foreach(file_name, { headers: true, header_converters: :symbol }) do |row|
      if create
        pool = Pool.find_or_create_by(name: row[converter[:pool_name]] || 'unknown')
        user = User.find_or_create_by(primary_identifier: row[converter[:primary_identifier]]).tap do |user|
          user.title = row[converter[:title]]
          user.phone_number = row[converter[:phone_number]]
          user.last_name = row[converter[:last_name]]
          user.save
        end
        pool.users << user
      else
        puts "title: #{row[converter[:title]]} phone_number: #{row[converter[:phone_number]]} last_name: #{row[converter[:last_name]]} id: #{row[converter[:primary_identifier]]} pool: #{row[converter[:pool_name]]}"
      end
    end
  end
end
