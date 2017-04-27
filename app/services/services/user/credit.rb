module Services
  module User
    class Credit
      attr_reader :issues

      include ActiveModel::Validations

      def initialize(user:, cents:, source:)
        @user, @cents, @source = user, cents, source
      end

      def call
        create_credit_transaction
        notify_user_of_payment
      end

      def success?
        @issues.blank?
      end

      private

      def create_credit_transaction
        @credit_transaction = CreditTransaction.create(
          user: user,
          source: source,
          cents: cents
        )

        @issues = credit_transaction.errors unless credit_transaction.persisted?
      end

      def notify_user_of_payment
        return unless credit_transaction.persisted?

        AppMailer.notify_payment(credit_transaction).deliver_later
      end

      attr_reader :user, :cents, :source, :credit_transaction
    end
  end
end
