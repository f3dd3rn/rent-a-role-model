describe ContactFormsController, type: :controller do
  let(:user) { create(:user) }
  let(:appointment) { 1.month.from_now }
  let(:params) { {
    name: 'Tina Tester',
    school: 'Penn High School',
    event: 'Coding is FUNtastic!',
    email: 'tina.tester@penn-high-school.com',
    message: 'Hi Biene Maya, please be our coach! Cheers, Tina',
    datetime: appointment,
    user_id: user.id,
  } }

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe "#create" do
    context "when input is valid" do
      it "sends an email" do
        expect{
          post :create, user_id: user.id, name: 'Tina Tester', school: 'Penn High School', event: 'Coding is FUNtastic!', email: 'tina.tester@penn-high-school.com', message: 'Hi Biene Maya, please be our coach! Cheers, Tina', datetime: appointment
        }.to change{ActionMailer::Base.deliveries.count}.from(0).to(1)
      end
    end

    context "when input is invalid" do
      it "renders new" do
        post :create, user_id: user.id, email: 'tina.tester(at)test.com'
        expect(response).to render_template(:new)
      end

      it "has error message" do
        post :create, user_id: user.id, email: 'tina.tester(at)test.com'
        expect(flash[:error]).to be_present
        expect(flash[:error]).to eq('Fehler beim Versenden. Bitte prüfen Sie Ihre Angaben.')
      end
    end
  end

  describe "#new" do
    it "renders new" do
      get :new, user_id: user.id
      expect(response).to render_template(:new)
    end
  end
end
