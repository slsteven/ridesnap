module UploadHelper

  def box_uploader_form(options = {}, &block)
    uploader = BoxUploader.new(options)
    authorize_url = uploader.session.authorize_url(Settings.box.redirect_uri)
    form_tag(uploader.url, uploader.form_options) do
      uploader.fields.map do |name, value|
        hidden_field_tag(name, value)
      end.join.html_safe + capture(&block)
    end
  end

  class BoxUploader
    def initialize(options)
      @options = options.reverse_merge(
        id: 'fileupload',
        as: 'file'
      )
      @session = RubyBox::Session.new({
        client_id: Settings.box.client_id,
        client_secret: Settings.box.client_secret
      })
    end

    def form_options
      {
        id: @options[:id],
        method: 'post',
        authenticity_token: false,
        multipart: true,
        data: {
          post: @options[:post],
          as: @options[:as]
        }
      }
    end
  end

  def url
    " "
  end

end