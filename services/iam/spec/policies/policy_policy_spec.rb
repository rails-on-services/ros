# frozen_string_literal: true

require 'rails_helper'

describe PolicyPolicy do
  subject { PolicyPolicy.new(user, policy) }

  let(:policy) { FactoryBot.create(:policy) }

  context 'for a visitor' do
    let(:user) { nil }

    it { is_expected.to_not permit(:index)   }
    it { is_expected.to_not permit(:show)    }
    it { is_expected.to_not permit(:create)  }
    it { is_expected.to_not permit(:update)  }
    it { is_expected.to_not permit(:destroy) }
  end

  context 'for a user' do
    context 'root' do
      let(:user) { FactoryBot.create(:root) }

      it { is_expected.to permit(:index)   }
      it { is_expected.to permit(:show)    }
      it { is_expected.to permit(:create)  }
      it { is_expected.to permit(:update)  }
      it { is_expected.to permit(:destroy) }
    end

    context 'with the AdministratorAccess' do
      let(:user) { FactoryBot.create(:user, :administrator_access) }

      it { is_expected.to permit(:index)   }
      it { is_expected.to permit(:show)    }
      it { is_expected.to permit(:create)  }
      it { is_expected.to permit(:update)  }
      it { is_expected.to permit(:destroy) }
    end

    context 'with the IamFullAccess' do
      let(:policy) do
        FactoryBot.create :policy, name: 'IamFullAccess'
      end
      let(:user) { FactoryBot.create(:user, policies: [policy]) }

      it { is_expected.to permit(:index)   }
      it { is_expected.to permit(:show)    }
      it { is_expected.to permit(:create)  }
      it { is_expected.to permit(:update)  }
      it { is_expected.to permit(:destroy) }
    end

    context 'with the IamReadOnlyAccess' do
      let(:policy) do
        FactoryBot.create :policy, name: 'IamReadOnlyAccess'
      end
      let(:user) { FactoryBot.create(:user, policies: [policy]) }

      it { is_expected.to permit(:index)   }
      it { is_expected.to permit(:show)    }
      it { is_expected.to_not permit(:create)  }
      it { is_expected.to_not permit(:update)  }
      it { is_expected.to_not permit(:destroy) }
    end
  end
end
