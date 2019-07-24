class ConfirmationMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    DeviseMailer.confirmation_instructions(User.new(email: 'a@a.a'), "faketoken", {})
  end
end