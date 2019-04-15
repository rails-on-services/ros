# frozen_string_literal: true

# module ServiceTwilio
  class WhatsappsController < Comm::ApplicationController
    # skip_before_action :authenticate_user!
    # before_action :set_whatsapp, only: [:show, :update, :destroy]

    # GET /whatsapps
    def index
      @whatsapps = Whatsapp.all

      render json: @whatsapps
    end

    # GET /whatsapps/1
    def show
      render json: @whatsapp
    end

    # POST /whatsapps
    # NOTE: This is an endpoint that response to a Twilio notification
    # when a whatsapp message is sent to a registered number
    def create
      @whatsapp = Whatsapp.new(whatsapp_params)

      who = 'Blob'
      who = 'Narayani' if @whatsapp.from.ends_with? '26'

      if @whatsapp.save
        # Put a message on a bus (rabbitMQ)
        # Channels are named in a standardized way including service and tenant
        # TODO:
        # UserSpace, e.g. perx, truewards, LoyatlyCampaign listens on bus and sends message back
        # Twilio service listens on bus and sends message
        # Something like this
        twiml = Twilio::TwiML::MessagingResponse.new do |r|
          r.message(body: "Ahoy #{who}! Thanks so much for your message that said: '#{@whatsapp.Body}'")
        end
        render xml: twiml
      else
        # render json: @whatsapp, status: :created, location: @whatsapp
        render json: @whatsapp.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /whatsapps/1
    def update
      if @whatsapp.update(whatsapp_params)
        render json: @whatsapp
      else
        render json: @whatsapp.errors, status: :unprocessable_entity
      end
    end

    # DELETE /whatsapps/1
    def destroy
      @whatsapp.destroy
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_whatsapp
        @whatsapp = Whatsapp.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      # NOTE: Twilio sends params as SmsStatus
      def whatsapp_params
        request.request_parameters.deep_transform_keys!(&:underscore).except(:controller, :action)
      end
  end
#end
