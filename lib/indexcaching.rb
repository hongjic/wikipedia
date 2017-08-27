require 'redis'
require 'singleton'

class IndexManager

  include Singleton
  attr_accessor :redis

  def initialize
    @redis = Redis.new
  end

  def get key
    @redis.get key
  end

  def set key, value
    @redis.set key, value
  end

end