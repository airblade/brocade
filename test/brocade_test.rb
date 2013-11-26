require_relative 'helper'
require 'brocade'

class Foo
  include Brocade
  attr_accessor :code

  def self.after_create(callback); end
  def self.before_update(callback); end
  def self.after_destroy(callback); end
end

class BrocadeTest < TestCase

  test 'sanity' do
    assert_respond_to Foo, :has_barcode
  end

  test 'explicit code 128 subset' do
    Foo.send :has_barcode
    foo = Foo.new
    foo.code = 42
    assert_kind_of Barby::Code128A, foo.barcode(subset: 'A')
    assert_kind_of Barby::Code128B, foo.barcode(subset: 'B')
    assert_kind_of Barby::Code128C, foo.barcode(subset: 'C')
  end

  test 'implicit code 128 subset' do
    Foo.send :has_barcode
    foo = Foo.new

    foo.code = 42
    assert_kind_of Barby::Code128C, foo.barcode

    foo.code = '42aA'
    assert_kind_of Barby::Code128B, foo.barcode

    foo.code = "42A\t"
    assert_kind_of Barby::Code128A, foo.barcode
  end

  test 'code c handles odd number of digits' do
    Foo.send :has_barcode
    foo = Foo.new
    foo.code = 4
    assert_kind_of Barby::Code128C, foo.barcode(subset: 'C')
  end

end
