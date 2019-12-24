# frozen_string_literal: true

module ServiceLocator
  module_function

  def locate(gid)
    gid = GlobalID.parse(gid)
    return unless gid

    GlobalID::Locator.send(:locator_for, gid).locate gid
  end
end
