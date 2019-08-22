# frozen_string_literal: true

require 'rails_helper'

describe PolicyPolicy do
  subject { PolicyPolicy.new(user, policy) }

  let(:policy) { FactoryBot.create(:policy) }

  context 'for a visitor' do
    let(:user) { nil }

    it { is_expected.to_not permit(:show)    }
    it { is_expected.to_not permit(:create)  }
    it { is_expected.to_not permit(:new)     }
    it { is_expected.to_not permit(:update)  }
    it { is_expected.to_not permit(:edit)    }
    it { is_expected.to_not permit(:destroy) }
  end

  context 'for a user' do
    context 'user is root' do
      let(:user) { FactoryBot.create(:root) }

      it { is_expected.to permit(:show)    }
      it { is_expected.to permit(:create)  }
      it { is_expected.to permit(:new)     }
      it { is_expected.to permit(:update)  }
      it { is_expected.to permit(:edit)    }
      it { is_expected.to permit(:destroy) }
    end

    context 'user has the AdministratorAccess' do
      let(:administrator_access) do
        FactoryBot.create :policy, name: 'AdministratorAccess'
      end
      let(:user) { FactoryBot.create(:user, policies: [administrator_access]) }

      it { is_expected.to permit(:show)    }
      it { is_expected.to permit(:create)  }
      it { is_expected.to permit(:new)     }
      it { is_expected.to permit(:update)  }
      it { is_expected.to permit(:edit)    }
      it { is_expected.to permit(:destroy) }
    end
  end
end
