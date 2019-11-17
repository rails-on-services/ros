# frozen_string_literal: true

# TODO: If we don't want to use the TRB activity's multiple outcomes
# capabilities, we can rely on the TRB operation that already provides a result
# class that handles all the logic for this. Nevertheless I think it might be
# useful to have our operations using activity rather than Operation
module Ros
  class OperationResult
    attr_reader :errors

    alias resource model

    def initialize(signal, context)
      @end_signal = signal
      @ctx = context[0]
      @flow_props = context[1]
      @errors = @ctx[:errors]
    end

    def model
      @ctx[:model]
    end

    def failure?
      %i[fail_fast failure].include? @end_signal.to_h[:semantic]
    end

    def success?
      %i[pass_fast success].include? @end_signal.to_h[:semantic]
    end

    def has_errors?
      !@errors.empty?
    end
  end
end



#<JSONAPI::ResourceOperationResult:0x00007fd07a3a8de0
 @code=:created,
 @links={},
 @meta={},
 @options={},
 @resource=
  #<RequestOutcomeResource:0x00007fd070b22dc8
   @changing=true,
   @context=
    {:user=>
      #<PolicyUser:0x00007fd079699438
       @cognito_user_id=nil,
       @iam_user=
        #<Ros::IAM::User:@attributes={"type"=>"users", "id"=>1, "urn"=>"urn:whistler:iam::222222222:user/Admin_2", "created_at"=>"2019-09-13T00:25:26.208Z", "updated_at"=>"2019-09-13T00:25:27.330Z", "username"=>"Admin_2", "api"=>true, "console"=>true, "time_zone"=>"Asia/Singapore", "properties"=>{}, "display_properties"=>{}, "jwt_payload"=>{"iss"=>"http://iam.localhost:3000", "sub"=>"urn:whistler:iam::222222222:user/Admin_2", "scope"=>"*"}, "attached_policies"=>{"AdministratorAccess"=>1}, "attached_actions"=>{}}>,
       @params=
        <ActionController::Parameters {"data"=><ActionController::Parameters {"type"=>"request_outcomes", "attributes"=><ActionController::Parameters {"source_type"=>"Perx::Survey::Answer", "source_id"=>10, "entity_id"=>1} permitted: false>} permitted: false>, "controller"=>"request_outcomes", "action"=>"create"} permitted: false>>},
   @model=#<RequestOutcome:0x00007fd070b23020 id: 1, source_type: "Perx::Survey::Answer", source_id: 10, entity_id: 1, created_at: Sun, 17 Nov 2019 10:29:52 UTC +00:00, updated_at: Sun, 17 Nov 2019 10:29:52 UTC +00:00>,
   @reload_needed=false,
   @save_needed=false>>
