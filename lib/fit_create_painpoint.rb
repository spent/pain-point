require 'fit/column_fixture'
require File.dirname(__FILE__) + '/../spec/spec_helper'

class FitCreatePainpoint < Fit::ColumnFixture

  attr_writer :the_pain

  def execute
    @pain_point = PainPoint.create(
      :name => @the_pain
    )
  end

  def results
    @pain_point.valid? ? true : @pain_point.errors.full_messages.join(", ")
  end

end
