class Outcome
  attr_reader :value, :success, :message

  def initialize(success, value = nil, message = nil)
    @success = success
    @value = value
    @message = message
  end

  def self.success(value = nil, message = "Success")
    new(true, value, message)
  end

  def self.failure(message = "Failure")
    new(false, nil, message)
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
