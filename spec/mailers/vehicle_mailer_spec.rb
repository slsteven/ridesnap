require "rails_helper"

RSpec.describe VehicleMailer, :type => :mailer do
  describe "schedule_confirm" do
    let(:mail) { VehicleMailer.schedule_confirm }

    it "renders the headers" do
      expect(mail.subject).to eq("Schedule confirm")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
