describe ContactFormMailer do
  let(:appointment) { 1.month.from_now }
  let(:contact_form_data) { {
    name: 'Tina Tester',
    school: 'Penn High School',
    event: 'Coding is FUNtastic!',
    email: 'tina.tester@penn-high-school.com',
    message: 'Hi Biene Maya, please be our coach! Cheers, Tina',
    datetime: appointment,
  } }
  let(:user) { create(:user) }
  let(:mailer_class) { ContactFormMailer }
  let(:mail) { mailer_class.contact_form_email(user, contact_form_data) }

  it "renders the headers" do
    expect(mail.content_type).to start_with('multipart/alternative') #html / text support
  end

  it "sets the correct subject" do
    expect(mail.subject).to eq("Rent a Role Model Anfrage")
  end

  it "injects contact_form_data into email body" do
    keys, values = contact_form_data.map { |k,v| [k.to_s, v.to_s] }.transpose
    values.each do |content|
      expect(mail.body.encoded).to include(content)
    end
  end

  it "is from 'tina.tester@school.com'" do
    expect(mail.from).to include('tina.tester@penn-high-school.com')
  end

  it "send to 'biene@maya.de'" do
    expect(mail.to).to include(user.email)
  end

  it "replys to 'tina.tester@school.com'" do
    expect(mail.reply_to).to include('tina.tester@penn-high-school.com')
  end
end