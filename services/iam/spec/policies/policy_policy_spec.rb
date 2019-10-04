# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PolicyPolicy do
  subject { described_class.new(user, policy) }

  let(:policy) { create(:policy) }

  context 'for a visitor' do
    let(:user) { PolicyUser.new(nil, nil) }

    it { is_expected.to_not permit(:index)   }
    it { is_expected.to_not permit(:show)    }
    it { is_expected.to_not permit(:create)  }
    it { is_expected.to_not permit(:update)  }
    it { is_expected.to_not permit(:destroy) }
  end

  context 'for a user' do
    context 'root' do
      let(:user) { PolicyUser.new(create(:root), nil) }

      it { is_expected.to permit(:index)   }
      it { is_expected.to permit(:show)    }
      it { is_expected.to permit(:create)  }
      it { is_expected.to permit(:update)  }
      it { is_expected.to permit(:destroy) }
    end

    context 'with the AdministratorAccess' do
      let(:user) { PolicyUser.new(create(:user, :administrator_access), nil) }

      it { is_expected.to permit(:index)   }
      it { is_expected.to permit(:show)    }
      it { is_expected.to permit(:create)  }
      it { is_expected.to permit(:update)  }
      it { is_expected.to permit(:destroy) }
    end

    context 'with the IamFullAccess' do
      let(:policy) { create :policy, name: 'IamFullAccess' }
      let(:user) { PolicyUser.new(create(:user, policies: [policy]), nil) }

      it { is_expected.to permit(:index)   }
      it { is_expected.to permit(:show)    }
      it { is_expected.to permit(:create)  }
      it { is_expected.to permit(:update)  }
      it { is_expected.to permit(:destroy) }
    end

    context 'with the IamReadOnlyAccess' do
      let(:policy) { create :policy, name: 'IamReadOnlyAccess' }
      let(:user) { PolicyUser.new(create(:user, policies: [policy]), nil) }

      it { is_expected.to permit(:index)   }
      it { is_expected.to permit(:show)    }
      it { is_expected.to_not permit(:create)  }
      it { is_expected.to_not permit(:update)  }
      it { is_expected.to_not permit(:destroy) }
    end
  end
end
