describe User do
  describe '.active' do
    let!(:active_user) { create(:user) }
    let!(:user_without_token) { create(:user, profile_loaded: false) }
    let!(:user_with_invalid_token) { create(:user, access_token: nil) }

    it 'returns active users' do
      expected = [active_user]
      actual = User.active.to_a

      expect(actual).to eql(expected)
    end
  end

  describe '.update_or_create' do
    let(:token) do
      {
        access_token: 'accesstoken',
        access_token_secret: 'accesstokensecret'
      }
    end

    it 'uses passed token to load the XING profile' do
      expect(User).to receive(:load_xing_profile).with(token)
      User.update_or_create(token)
    end

    it 'returns nil if profile is not loaded' do
      allow(User).to receive(:load_xing_profile).and_return({})
      expect(User.update_or_create(token)).to be_nil
    end

    context 'when user is created' do
      let(:user_profile) { { active_email: 'does@not.exist' } }
      before do
        allow(User).to receive(:load_xing_profile).and_return(user_profile)
      end

      it 'returns a new user' do
        user = User.update_or_create(token)
        expect(user).to be_persisted
      end

      it 'sets the access token data' do
        user = User.update_or_create(token)
        expect(user.access_token).to eq(token[:access_token])
        expect(user.access_token_secret).to eq(token[:access_token_secret])
      end

      it 'sets the profile data' do
        expect_any_instance_of(User).to receive(:update_profile).with(user_profile)
        User.update_or_create(token)
      end
    end

    context 'when user is updated' do
      let(:existing_user) { create(:user) }
      let(:user_profile) { { active_email: existing_user.email } }
      before do
        allow(User).to receive(:load_xing_profile).and_return(user_profile)
      end

      it 'returns the existing user' do
        user = User.update_or_create(token)
        expect(user).to eq(existing_user)
      end

      it 'updates the access token' do
        new_token = {
          access_token: 'UPDATED access token',
          access_token_secret: 'UPDATED access token secret'
        }
        user = User.update_or_create(new_token)

        expect(user.token).to eq(new_token)
      end

      it 'updates the profile data' do
        expect_any_instance_of(User).to receive(:update_profile).with(user_profile)
        User.update_or_create(token)
      end
    end
  end

  describe '#update_profile' do
    subject { build(:user) }

    it 'saves the user' do
      subject.update_profile({})
      expect(subject).to be_persisted
    end

    it 'sets profile_loaded to true' do
      subject.update_profile(display_name: 'John Doe')
      expect(subject.profile_loaded).to eql(true)
    end

    it 'sets xing_id' do
      subject.update_profile(id: '1_abcdef')
      expect(subject.xing_id).to eq('1_abcdef')
    end

    it 'sets name' do
      subject.update_profile(display_name: 'John Doe')
      expect(subject.name).to eq('John Doe')
    end

    it 'sets email' do
      subject.update_profile(active_email: 'john.doe@acme.org')
      expect(subject.email).to eq('john.doe@acme.org')
    end

    it 'sets city to private address' do
      subject.update_profile(private_address: { city: 'New York'})
      expect(subject.city).to eq('New York')
    end

    it 'sets city to business address' do
      subject.update_profile(business_address: { city: 'San Francisco'})
      expect(subject.city).to eq('San Francisco')
    end

    it 'sets city to private address first' do
      subject.update_profile(
        private_address: { city: 'New York'},
        business_address: { city: 'San Francisco'}
      )
      expect(subject.city).to eq('New York')
    end

    it 'sets job' do
      subject.update_profile(
        professional_experience: {
          primary_company: {
            title: 'ACME corp'
          }
        }
      )
      expect(subject.job).to eq('ACME corp')
    end

    it 'sets image_url' do
      subject.update_profile(photo_urls: { large: 'image-url'})
      expect(subject.image_url).to eq('image-url')
    end

    it 'sets xing_profile' do
      subject.update_profile(permalink: 'link-to-xing-profile')
      expect(subject.xing_profile).to eq('link-to-xing-profile')
    end
  end

  describe '.load_xing_profile' do
    let(:token) do
      {
        access_token: 'accesstoken',
        access_token_secret: 'accesstokensecret'
      }
    end
    let(:user_profile) { double }
    let(:xing_response) { { users: [user_profile] } }

    it 'returns xing user profile' do
      allow(XingApi::User).to receive(:me).and_return(xing_response)

      actual = User.load_xing_profile(token)

      expect(actual).to eq(user_profile)
    end

    it 'returns empty profile if loading fails' do
      allow(XingApi::User).to receive(:me).and_raise(XingApi::Error.new(nil))

      actual = User.load_xing_profile(token)

      expect(actual).to eq({})
    end
  end

  describe '#profile_owner' do
    let(:user) { create(:user) }
    it 'is true for user id' do
      expect(user.profile_owner?(user)).to eql(true)
    end

    it 'is false for another id' do
      another_user = double(id: user.id + 1)
      expect(user.profile_owner?(another_user)).to eql(false)
    end
  end

  describe '#token' do
    let(:user) { create(:user) }

    it 'returns access token and secret' do
      expected = {
        access_token: user.access_token,
        access_token_secret: user.access_token_secret,
      }

      expect(user.token).to eq(expected)
    end

    it 'sets access token and secret' do
      new_token = {
        access_token: 'new_token',
        access_token_secret: 'new_token_secret',
      }

      user.token = new_token

      expect(user.token).to eq(new_token)
    end
  end
end
