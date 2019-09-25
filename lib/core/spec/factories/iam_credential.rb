# frozen_string_literal: true

FactoryBot.define do
  factory :iam_credential, class: OpenStruct do
    # https://thoughtbot.com/blog/tips-for-using-factory-girl-without-an-orm
    skip_create

    type { 'Basic' }
    access_key_id { 'AFJYOBPQKSJFQPKKHRHF' }
    secret_access_key { 'Zdl1fD957XvRlyRylFSr2McwZCxJHU36B4j5Ze2kqg8UPkcerz5YgQ' }
    str { "#{type} #{access_key_id}:#{secret_access_key}" }
  end
end
