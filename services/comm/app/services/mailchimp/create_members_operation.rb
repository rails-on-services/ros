# frozen_string_literal: true

module Mailchimp
  class CreateMembersOperation
    MEMBER_STATUS = :subscribed
    CREATE_METHOD = 'PUT'

    def initialize(list_id:, members:)
      @list_id = list_id
      @members = members
    end

    def request
      operations_array = []
      members = filter_members(@members)
      members.each do |member|
        operations_array << {
          method: CREATE_METHOD,
          path: "/lists/#{@list_id}/members/#{member_hash(member)}",
          body: MultiJson.dump(member_operation(member))
        }
      end
      operations_array
    end

    private

    def filter_members(members)
      members.reject { |member| member[:email].blank? }
    end

    def member_hash(member)
      Digest::MD5.hexdigest(member[:email]&.downcase)
    end

    def member_operation(member)
      {
        email_address: member[:email],
        status: member[:status] || MEMBER_STATUS,
        status_if_new: member[:status] || MEMBER_STATUS,
        merge_fields: {
          FNAME: member[:first_name] || '',
          LNAME: member[:last_name] || ''
        }
      }
    end

  end
end