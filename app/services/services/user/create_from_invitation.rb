module Services
  module User
    class CreateFromInvitation

      def initialize(invitation)
        @invitation = invitation
      end

      def call
        create_user
        update_invitation
        send_email
      end

      def success?
        @issues.blank?
      end

      attr_reader :user, :issues

      private

      def create_user
        @user = ::User.create(email: invitation.invitee_email)
        @issues = user.errors unless user.persisted?
      end

      def update_invitation
        return unless success?

        unless invitation.update(invitee: user)
          @issues = invitation.errors
        end
      end

      def send_email
        return unless success?

        AppMailer.welcome_email(user).deliver_later
      end


      attr_reader :invitation
    end
  end
end
