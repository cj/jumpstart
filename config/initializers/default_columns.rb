# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    class TableDefinition
      def default_columns(**args)
        created_by_args = args.clone

        created_by_args[:null] = false unless created_by_args.key? :null
        args[:null] = true unless args.key? :null

        references :created_by, foreign_key: { to_table: :users }, **created_by_args
        references :updated_by, foreign_key: { to_table: :users }, **args
        references :deleted_by, foreign_key: { to_table: :users }, **args

        merged_args = args.merge index: true
        merged_created_by_args = created_by_args.merge index: true

        column  :created_at, :timestamp, merged_created_by_args
        column  :updated_at, :timestamp, merged_args
        column  :deleted_at, :timestamp, merged_args
      end
    end
  end
end
