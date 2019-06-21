require 'logger'
require 'singleton'

class Log

  #シングルトン
  include Singleton

  #コンストラクタ
  def initialize
    @@log = Logger.new('./log/script.log', 'daily')
  end

  #クラスメソッド
  class << self

    #呼び出し元のファイル名を、動的に取得したかったからメソッド内でそれぞれcallerしてる。
    def debug(msg)
      caller()[0] =~ /(.*?):(\d+)/
      @@log.progname = "#{$1}"
      @@log.debug(msg)
    end

    def info(msg)
      caller()[0] =~ /(.*?):(\d+)/
      @@log.progname = "#{$1}"
      @@log.info(msg)
    end

    def warn(msg)
      caller()[0] =~ /(.*?):(\d+)/
      @@log.progname = "#{$1}"
      @@log.warn(msg)
    end

    def error(msg)
      caller()[0] =~ /(.*?):(\d+)/
      @@log.progname = "#{$1}"
      @@log.error(msg)
    end

    def fatal(msg)
      caller()[0] =~ /(.*?):(\d+)/
      @@log.progname = "#{$1}"
      @@log.fatal(msg)
    end

  end

end