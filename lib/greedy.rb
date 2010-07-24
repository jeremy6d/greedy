# Copyright (c) 2010 Jeremy Weiland
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'gdata'
require 'nokogiri'
require 'json'
require 'ruby-debug'

require 'lib/greedy/connection'
require 'lib/greedy/stream'
require 'lib/greedy/entry'
require 'lib/greedy/feed'

module Greedy
  class ConnectionError < RuntimeError
  end
  
  class AuthorizationError < ConnectionError
    def self.gdata_errors
      %w{AuthorizationError BadRequestError CaptchaError}.collect do |e| 
        "GData::Client::#{e}"
      end
    end
  end
  
  class ServiceError < ConnectionError
    %w{ServerError UnknownError VersionConflictError}.collect do |e| 
      "GData::Client::#{e}"
    end
  end
end