describe Task do
  describe '.sync_with_xing' do
    let(:user) { create(:user) }

    it 'uses user token to load xing profile' do
      expect(described_class).to receive(:load_xing_profile!).with(user.token).and_return({})
      described_class.sync_with_xing(user)
    end

    it 'updates the user with the loaded xing profile' do
      profile = double
      allow(described_class).to receive(:load_xing_profile!).and_return(profile)

      expect(user).to receive(:update_profile).with(profile)

      described_class.sync_with_xing(user)
    end

    context 'token revoked' do
      let(:token_error) { XingApi::InvalidOauthTokenError.new(401) }
      it 'sets profile loaded flag to false' do
        allow(described_class).to receive(:load_xing_profile!).and_raise(token_error)

        described_class.sync_with_xing(user)

        expect(user).to_not be_profile_loaded
      end
    end

    context 'xing returns an error' do
      let(:token_error) { XingApi::Error.new(500) }
      it 'does not raise an exception' do
        allow(described_class).to receive(:load_xing_profile!).and_raise(token_error)

        expect { described_class.sync_with_xing(user) }.to_not raise_error
      end
    end
  end
end
