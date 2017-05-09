require "notifications/client/version"
require "notifications/client/speaker"
require "notifications/client/notification"
require "notifications/client/response_notification"
require "notifications/client/notifications_collection"
require "notifications/client/response_template"
require "notifications/client/template_collection"
require "notifications/client/template_preview"
require "forwardable"

module Notifications
  class Client
    attr_reader :speaker

    PRODUCTION_BASE_URL = "https://api.notifications.service.gov.uk".freeze

    extend Forwardable
    def_delegators :speaker, :service_id, :secret_token, :base_url, :base_url=

    ##
    # @see Notifications::Client::Speaker#initialize
    def initialize(*args)
      @speaker = Speaker.new(*args)
    end

    ##
    # @see Notifications::Client::Speaker#post
    # @return [ResponseNotification]
    def send_email(args)
      ResponseNotification.new(
        speaker.post("email", args)
      )
    end

    ##
    # @see Notifications::Client::Speaker#post
    # @return [ResponseNotification]
    def send_sms(args)
      ResponseNotification.new(
        speaker.post("sms", args)
      )
    end

    ##
    # @param id [String]
    # @see Notifications::Client::Speaker#get
    # @return [Notification]
    def get_notification(id)
      Notification.new(
        speaker.get(id)
      )
    end

    ##
    # @param options [Hash]
    # @option options [String] :template_type
    #   sms or email
    # @option options [String] :status
    #   sending, delivered, permanently failed,
    #   temporarily failed, or technical failure
    # @option options [String] :reference
    #   your reference for the notification
    # @option options [String] :olderThanId
    #   notification id to return notificaitons that are older than this id.
    # @see Notifications::Client::Speaker#get
    # @return [NotificationsCollection]
    def get_notifications(options = {})
      NotificationsCollection.new(
        speaker.get(nil, options)
      )
    end

    ##
    # @param id [String]
    # @return [Template]
    def get_template_by_id(id, options = {})
      path = "/v2/template/" << id
      Template.new(
        speaker.get_with_url(path, options)
      )
    end

    ##
    # @param id [String]
    # @param version [int]
    # @return [Template]
    def get_template_version(id, version, options = {})
      path = "/v2/template/" << id << "/version/" << version.to_s
      Template.new(
        speaker.get_with_url(path, options)
      )
    end

    ##
    # @option options [String] :type
    #   email, sms, letter
    # @return [TemplateCollection]
    def get_all_templates(options = {})
      path = "/v2/templates"
      TemplateCollection.new(
        speaker.get_with_url(path, options)
      )
    end

    ##
    # @param options [String]
    # @option personalisation [Hash]
    # @return [TemplatePreview]
    def generate_template_preview(id, options = {})
      path = "/v2/template/" << id << "/preview"
      TemplatePreview.new(
        speaker.post_with_url(path, options)
      )
    end

  end
end
