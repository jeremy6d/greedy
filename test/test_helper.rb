require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'matchy'
require 'mocha'
require 'ruby-debug'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'greedy'

class Test::Unit::TestCase
end
