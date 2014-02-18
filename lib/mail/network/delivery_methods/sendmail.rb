require 'mail/check_delivery_params'

module Mail
  # A delivery method implementation which sends via sendmail.
  #
  # To use this, first find out where the sendmail binary is on your computer,
  # if you are on a mac or unix box, it is usually in /usr/sbin/sendmail, this will
  # be your sendmail location.
  #
  #   Mail.defaults do
  #     delivery_method :sendmail
  #   end
  #
  # Or if your sendmail binary is not at '/usr/sbin/sendmail'
  #
  #   Mail.defaults do
  #     delivery_method :sendmail, :location => '/absolute/path/to/your/sendmail'
  #   end
  #
  # Then just deliver the email as normal:
  #
  #   Mail.deliver do
  #     to 'mikel@test.lindsaar.net'
  #     from 'ada@test.lindsaar.net'
  #     subject 'testing sendmail'
  #     body 'testing sendmail'
  #   end
  #
  # Or by calling deliver on a Mail message
  #
  #   mail = Mail.new do
  #     to 'mikel@test.lindsaar.net'
  #     from 'ada@test.lindsaar.net'
  #     subject 'testing sendmail'
  #     body 'testing sendmail'
  #   end
  #
  #   mail.deliver!
  class Sendmail
    require 'shellwords'

    include Mail::CheckDeliveryParams

    def initialize(values)
      self.settings = { :location       => '/usr/sbin/sendmail',
                        :arguments      => '-i' }.merge(values)
    end

    attr_accessor :settings

    def deliver!(mail)
      smtp_from, smtp_to, message = check_delivery_params(mail)

      from = "-f #{smtp_from.shellescape}"
      to = smtp_to.map(&:shellescape).join(' ')

      arguments = "#{settings[:arguments]} #{from} --"
      self.class.call(settings[:location], arguments, to, message)
    end

    def self.call(path, arguments, destinations, encoded_message)
      IO.popen "#{path} #{arguments} #{destinations}" do |io|
        io.puts encoded_message.to_lf
        io.flush
      end
    end
  end
end
